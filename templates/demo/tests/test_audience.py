"""Test the audience router with temporary state and loopback services."""

import contextlib
import io
import json
import os
from pathlib import Path
import socket
import socketserver
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from unittest.mock import patch

import audience


# Allocate an ephemeral loopback port while excluding the public router default.
def free_port():
    while True:
        with socket.socket() as sock:
            sock.bind(("127.0.0.1", 0))
            port = sock.getsockname()[1]
        if port != 8089:
            return port


class PageHandler(socketserver.BaseRequestHandler):
    """Answer HTTP requests and retain the connection for keep-alive tests."""

    # Serve requests until the client closes the socket.
    def handle(self):
        buffer = b""
        try:
            while True:
                chunk = self.request.recv(4096)
                if not chunk:
                    return
                buffer += chunk
                while b"\r\n\r\n" in buffer:
                    _, buffer = buffer.split(b"\r\n\r\n", 1)
                    self.request.sendall(b"HTTP/1.1 200 OK\r\nContent-Length: 1\r\n"
                                         b"Connection: keep-alive\r\n\r\n" + self.server.body)
        except (ConnectionError, OSError):
            return


class PageServer(socketserver.ThreadingTCPServer):
    """Run a small loopback HTTP server in daemon threads."""

    allow_reuse_address = True
    daemon_threads = True

    # Bind a free non-default port and choose the single-byte response body.
    def __init__(self, body):
        super().__init__(("127.0.0.1", 0), PageHandler)
        if self.server_address[1] == 8089:
            self.server_close()
            self.__init__(body)
            return
        self.body = body


class AudienceTests(unittest.TestCase):
    """Cover CLI behavior, user-unit installation, and live forwarding."""

    # Isolate all state and install a systemctl fake that records JSON argv.
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.log = self.root / "systemctl.jsonl"
        fake = self.root / "systemctl"
        fake.write_text('#!/usr/bin/env python3\nimport json, os, sys\n'
                        'with open(os.environ["SYSTEMCTL_LOG"], "a") as log:\n'
                        '    log.write(json.dumps(sys.argv[1:]) + "\\n")\n'
                        'if "is-active" in sys.argv: print("active")\n'
                        'if "MainPID" in sys.argv: print(os.environ.get("FAKE_MAINPID", ""))\n')
        fake.chmod(0o755)
        self.env = patch.dict(os.environ, {
            "DEMO_AUDIENCE_DIR": str(self.root / "state"),
            "DEMO_AUDIENCE_HOME": str(self.home),
            "DEMO_AUDIENCE_SYSTEMCTL": str(fake),
            "SYSTEMCTL_LOG": str(self.log),
            "AUDIENCE_PORT": str(free_port()),
            "PYTHONDONTWRITEBYTECODE": "1",
        })
        self.env.start()
        self.addCleanup(self.env.stop)

    # Capture the return code and output of the in-process CLI.
    def run_cli(self, *args):
        out, err = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            code = audience.main(list(args))
        return code, out.getvalue(), err.getvalue()

    # Parse the calls recorded by the systemctl fake.
    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    # Select two decks and expose the most recent one through active.
    def test_use_and_active(self):
        with patch.object(audience, "ensure_router") as ensure:
            self.assertEqual(self.run_cli("use", "alpha", "11001"), (0, "", ""))
            self.assertEqual(self.run_cli("active"), (0, "alpha\n", ""))
            self.assertEqual(self.run_cli("use", "beta", "11002"), (0, "", ""))
            self.assertEqual(self.run_cli("active"), (0, "beta\n", ""))
            self.assertEqual(ensure.call_count, 2)
        state = self.root / "state"
        self.assertEqual((state / "routes/alpha").read_text(), "11001")
        self.assertEqual((state / "routes/beta").read_text(), "11002")
        self.assertEqual((state / "active").read_text(), "beta")
        self.assertEqual(state.stat().st_mode & 0o777, 0o700)

    # Reject unsafe names, invalid ports, the router port, and port collisions.
    def test_use_validation_and_collision(self):
        with patch.object(audience, "ensure_router"):
            for deck, port in [("../bad", "12000"), ("Upper", "12000"),
                               ("a" * 64, "12000"), ("ok", "1023"),
                               ("ok", "65536"), ("ok", "not-a-port"),
                               ("ok", os.environ["AUDIENCE_PORT"])]:
                with self.subTest(deck=deck, port=port):
                    code, out, err = self.run_cli("use", deck, port)
                    self.assertEqual(code, 2)
                    self.assertEqual(out, "")
                    self.assertTrue(err)
            self.assertEqual(self.run_cli("use", "first", "12000")[0], 0)
            code, out, err = self.run_cli("use", "second", "12000")
            self.assertEqual((code, out, err), (1, "", "port 12000 is already first's page\n"))
            self.assertEqual(self.run_cli("active"), (0, "first\n", ""))

    # Release selects the newest remaining route and stops the last tunnel.
    def test_release_fallback_and_last_route(self):
        with patch.object(audience, "ensure_router"):
            for deck, port in [("old", "13001"), ("new", "13002"), ("current", "13003")]:
                self.assertEqual(self.run_cli("use", deck, port)[0], 0)
        routes = self.root / "state/routes"
        os.utime(routes / "old", ns=(1_000_000_000, 1_000_000_000))
        os.utime(routes / "new", ns=(2_000_000_000, 2_000_000_000))
        self.assertEqual(self.run_cli("release", "current"), (0, "", ""))
        self.assertEqual(self.run_cli("active"), (0, "new\n", ""))
        self.assertEqual(self.run_cli("release", "unknown"), (0, "", ""))
        self.assertEqual(self.run_cli("release", "new")[0], 0)
        self.assertEqual(self.run_cli("active"), (0, "old\n", ""))
        self.assertEqual(self.run_cli("release", "old"), (0, "", ""))
        self.assertFalse((self.root / "state/active").exists())
        self.assertEqual(self.run_cli("active"), (1, "", ""))
        self.assertIn(["--user", "stop", "demo-audience-tunnel.service"], self.calls())

    # Repair a dangling active name when an unrelated deck is released.
    def test_release_repairs_dangling_active(self):
        with patch.object(audience, "ensure_router"):
            self.run_cli("use", "remaining", "14000")
        (self.root / "state/active").write_text("missing")
        self.assertEqual(self.run_cli("release", "unknown")[0], 0)
        self.assertEqual(self.run_cli("active"), (0, "remaining\n", ""))
        (self.root / "state/routes/remaining").write_text("invalid")
        self.assertEqual(self.run_cli("active"), (0, "remaining\n", ""))
        (self.root / "state/routes/remaining").unlink()
        self.assertEqual(self.run_cli("active"), (1, "", ""))

    # Install once, then use start when neither installed file has changed.
    def test_install_is_idempotent(self):
        audience.install_router()
        script = self.home / ".local/share/demo-audience/audience.py"
        unit = self.home / ".config/systemd/user/demo-audience.service"
        self.assertEqual(script.read_bytes(), Path(audience.__file__).resolve().read_bytes())
        self.assertEqual(script.stat().st_mode & 0o777, 0o755)
        self.assertEqual(unit.read_text(),
                         "[Unit]\nDescription=Demo audience router: the shared hostname serves the deck that took it last\n\n"
                         "[Service]\n"
                         f"Environment=AUDIENCE_PORT={os.environ['AUDIENCE_PORT']}\n"
                         f"Environment=DEMO_AUDIENCE_DIR={self.root / 'state'}\n"
                         f"ExecStart={sys.executable} -I {script} serve\n"
                         "Restart=on-failure\nRestartSec=1\n")
        original = (script.stat().st_mtime_ns, unit.stat().st_mtime_ns)
        audience.install_router()
        self.assertEqual(original, (script.stat().st_mtime_ns, unit.stat().st_mtime_ns))
        self.assertEqual(self.calls(), [["--user", "daemon-reload"],
                                        ["--user", "restart", "demo-audience.service"],
                                        ["--user", "start", "demo-audience.service"]])

    # Exercise use through installation and a real listening socket, then report status.
    def test_use_starts_router_and_status_reports_state(self):
        port = int(os.environ["AUDIENCE_PORT"])
        with socket.socket() as listener:
            listener.bind(("127.0.0.1", port))
            listener.listen(4)
            with patch.dict(os.environ, {"FAKE_MAINPID": str(os.getpid())}):
                self.assertEqual(self.run_cli("use", "demo", "15001"), (0, "", ""))
            code, out, err = self.run_cli("status")
        self.assertEqual((code, err), (0, ""))
        self.assertEqual(out, "Router: listening\nActive deck: demo\n"
                              "Route: demo 15001\nTunnel: active\n")
        self.assertEqual(self.calls(), [["--user", "daemon-reload"],
                                        ["--user", "restart", "demo-audience.service"],
                                        ["--user", "show", "-p", "MainPID", "--value", "demo-audience.service"],
                                        ["--user", "is-active", "demo-audience-tunnel.service"]])

    # Refuse a port held by another process, such as an old page forward.
    def test_use_refuses_a_port_held_by_another_process(self):
        port = int(os.environ["AUDIENCE_PORT"])
        with socket.socket() as listener, \
             patch.object(audience.time, "monotonic", side_effect=[0, 0, 11]), \
             patch.object(audience.time, "sleep"), \
             patch.dict(os.environ, {"FAKE_MAINPID": "1"}):
            listener.bind(("127.0.0.1", port))
            listener.listen(4)
            code, out, err = self.run_cli("use", "demo", "15001")
        self.assertEqual((code, out), (1, ""))
        self.assertIn(f"port {port} is held by pid {os.getpid()}", err)
        self.assertIn("not the router", err)

    # Report an unavailable listener without waiting ten seconds in the test.
    def test_use_reports_router_timeout(self):
        with patch.object(audience, "install_router"), \
             patch.object(audience, "router_listening", return_value=False), \
             patch.object(audience.time, "monotonic", side_effect=[0, 0, 11]), \
             patch.object(audience.time, "sleep"):
            code, out, err = self.run_cli("use", "demo", "15001")
        self.assertEqual((code, out), (1, ""))
        self.assertIn("router did not start listening", err)

    # Validate token and cloudflared, then install and start the tunnel unit.
    def test_tunnel_install_and_validation(self):
        code, _, err = self.run_cli("tunnel", str(self.root / "missing"))
        self.assertEqual(code, 1)
        self.assertIn("missing or empty", err)
        token = self.root / "token"
        token.write_text("")
        self.assertEqual(self.run_cli("tunnel", str(token))[0], 1)
        token.write_text("secret")
        with patch.object(audience.shutil, "which", return_value=None):
            self.assertEqual(self.run_cli("tunnel", str(token))[0], 1)
        cloudflared = self.root / "cloudflared"
        cloudflared.write_text("#!/bin/sh\nexit 0\n")
        cloudflared.chmod(0o755)
        with patch.dict(os.environ, {"PATH": f"{self.root}:{os.environ['PATH']}"}):
            self.assertEqual(self.run_cli("tunnel", str(token)), (0, "", ""))
            self.assertEqual(self.run_cli("tunnel", str(token)), (0, "", ""))
        unit = self.home / ".config/systemd/user/demo-audience-tunnel.service"
        self.assertEqual(unit.read_text(),
                         "[Unit]\nDescription=Demo audience tunnel: the named tunnel's connector for the shared hostname\n\n"
                         "[Service]\n"
                         f"Environment=TUNNEL_TOKEN_FILE={token.resolve()}\n"
                         f"ExecStart={cloudflared.resolve()} tunnel --no-autoupdate run\n"
                         "Restart=on-failure\nRestartSec=2\n")
        self.assertEqual(self.calls(), [["--user", "daemon-reload"],
                                        ["--user", "restart", "demo-audience-tunnel.service"],
                                        ["--user", "is-active", "demo-audience-tunnel.service"],
                                        ["--user", "start", "demo-audience-tunnel.service"],
                                        ["--user", "is-active", "demo-audience-tunnel.service"]])

    # Report absent upstreams and close existing keep-alive sockets on switch.
    def test_serve_switches_and_returns_503(self):
        servers = [PageServer(b"A"), PageServer(b"B")]
        for server in servers:
            threading.Thread(target=server.serve_forever, daemon=True).start()
            self.addCleanup(server.server_close)
            self.addCleanup(server.shutdown)
        port = int(os.environ["AUDIENCE_PORT"])
        state = audience.ensure_state()
        audience.atomic_write(state / "routes/a", str(servers[0].server_address[1]))
        audience.atomic_write(state / "routes/b", str(servers[1].server_address[1]))
        audience.atomic_write(state / "active", "a")
        process = subprocess.Popen([sys.executable, str(Path(audience.__file__).resolve()), "serve"],
                                   stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, env=os.environ.copy())
        self.addCleanup(self.stop_process, process)
        deadline = time.monotonic() + 5
        while True:
            try:
                client = socket.create_connection(("127.0.0.1", port), timeout=0.2)
                break
            except OSError:
                if process.poll() is not None or time.monotonic() >= deadline:
                    self.fail("router failed to start")
                time.sleep(0.02)
        self.addCleanup(client.close)
        client.settimeout(2)
        request = b"GET / HTTP/1.1\r\nHost: localhost\r\n\r\n"
        client.sendall(request)
        self.assertEqual(self.read_http(client)[1], b"A")
        audience.atomic_write(state / "active", "b")
        self.assertEqual(client.recv(1), b"")
        with socket.create_connection(("127.0.0.1", port), timeout=2) as fresh:
            fresh.sendall(request)
            self.assertEqual(self.read_http(fresh)[1], b"B")
        expected_503 = (b"HTTP/1.1 503 Service Unavailable\r\n"
                        b"Content-Type: text/plain; charset=utf-8\r\n"
                        b"Content-Length: 36\r\nConnection: close\r\n\r\n"
                        b"no demo page is live on this laptop\n")
        (state / "active").unlink()
        with socket.create_connection(("127.0.0.1", port), timeout=2) as absent:
            self.assertEqual(self.read_all(absent), expected_503)
        audience.atomic_write(state / "active", "a")
        (state / "routes/a").write_text("invalid")
        with socket.create_connection(("127.0.0.1", port), timeout=2) as invalid:
            self.assertEqual(self.read_all(invalid), expected_503)
        (state / "routes/a").write_text(str(free_port()))
        with socket.create_connection(("127.0.0.1", port), timeout=2) as down:
            self.assertEqual(self.read_all(down), expected_503)

    # Read one length-delimited HTTP response without closing a keep-alive socket.
    def read_http(self, sock):
        data = b""
        while b"\r\n\r\n" not in data:
            chunk = sock.recv(4096)
            self.assertTrue(chunk)
            data += chunk
        headers, body = data.split(b"\r\n\r\n", 1)
        length = int(next(line.split(b":", 1)[1] for line in headers.split(b"\r\n")
                          if line.lower().startswith(b"content-length:")))
        while len(body) < length:
            chunk = sock.recv(4096)
            self.assertTrue(chunk)
            body += chunk
        return headers, body

    # Read a response until the router closes its connection.
    def read_all(self, sock):
        result = b""
        while True:
            chunk = sock.recv(4096)
            if not chunk:
                return result
            result += chunk

    # Terminate the test router and close its captured error stream.
    def stop_process(self, process):
        process.terminate()
        try:
            process.wait(timeout=3)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=3)
        process.stderr.close()


if __name__ == "__main__":
    unittest.main()
