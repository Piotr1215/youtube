#!/usr/bin/env python3
"""Route a shared localhost audience endpoint to the most recently chosen deck."""

import argparse
import asyncio
import contextlib
import os
from pathlib import Path
import re
import shutil
import socket
import subprocess
import sys
import tempfile
import time

NAME = re.compile(r"[a-z0-9][a-z0-9-]{0,62}\Z")
BODY = b"no demo page is live on this laptop\n"
UNAVAILABLE = (b"HTTP/1.1 503 Service Unavailable\r\n"
               b"Content-Type: text/plain; charset=utf-8\r\n"
               + f"Content-Length: {len(BODY)}\r\n".encode()
               + b"Connection: close\r\n\r\n" + BODY)


# Resolve settings on every call so callers can change their environment.
def state_dir():
    default = (Path(os.environ["XDG_RUNTIME_DIR"]) / "demo-audience"
               if os.environ.get("XDG_RUNTIME_DIR") else
               Path("/tmp") / f"demo-audience-{os.getuid()}")
    return Path(os.environ.get("DEMO_AUDIENCE_DIR", str(default))).expanduser().resolve()


# Return the configured loopback listener port.
def router_port():
    return int(os.environ.get("AUDIENCE_PORT", "8089"))


# Return the base directory used for installed files.
def install_home():
    return Path(os.environ.get("DEMO_AUDIENCE_HOME", str(Path.home()))).expanduser().resolve()


# Create the private state directory and its route directory.
def ensure_state():
    root = state_dir()
    root.mkdir(mode=0o700, parents=True, exist_ok=True)
    (root / "routes").mkdir(mode=0o700, exist_ok=True)
    return root


# Atomically replace a file using a temporary file in its directory.
def atomic_write(path, data):
    fd, name = tempfile.mkstemp(prefix=".audience-", dir=path.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            stream.write(data)
        os.replace(name, path)
    finally:
        with contextlib.suppress(FileNotFoundError):
            os.unlink(name)


# Read a small state file, treating missing and unreadable files as absent.
def read_text(path):
    try:
        return path.read_text(encoding="utf-8").strip()
    except (OSError, UnicodeError):
        return ""


# Validate deck names before using them as filenames.
def valid_name(name):
    return bool(NAME.fullmatch(name))


# Parse a route while rejecting invalid or unsafe upstream ports.
def parse_port(value):
    if not re.fullmatch(r"[0-9]+", value):
        return None
    try:
        port = int(value)
    except ValueError:
        return None
    return port if 1024 <= port <= 65535 and port != router_port() else None


# Return the active name when its route file exists.
def active_deck():
    root = state_dir()
    name = read_text(root / "active")
    return name if valid_name(name) and (root / "routes" / name).is_file() else None


# Resolve the current name and usable port afresh from the state files.
def current_route():
    name = active_deck()
    if name is None:
        return None, None
    port = parse_port(read_text(state_dir() / "routes" / name))
    return (name, port) if port is not None else (None, None)


# Enumerate validly named route files in a stable order.
def routes():
    directory = state_dir() / "routes"
    try:
        return sorted((p for p in directory.iterdir() if valid_name(p.name) and p.is_file()),
                      key=lambda p: p.name)
    except FileNotFoundError:
        return []


# Execute the configured user systemctl command without a shell.
def systemctl(*args):
    try:
        return subprocess.run([os.environ.get("DEMO_AUDIENCE_SYSTEMCTL", "systemctl"),
                               "--user", *args], capture_output=True, text=True)
    except OSError as exc:
        raise RuntimeError(f"cannot run systemctl: {exc}") from exc


# Report failures from systemctl when a service must be started or restarted.
def require_systemctl(*args):
    result = systemctl(*args)
    if result.returncode:
        raise RuntimeError(f"systemctl {' '.join(args)} failed: {result.stderr.strip()}")
    return result


# Escape systemd argument values only when their bytes need quoting.
def unit_arg(value):
    value = str(value)
    if re.fullmatch(r"[A-Za-z0-9_./:@+,-]+", value):
        return value
    return '"' + value.replace('\\', '\\\\').replace('"', '\\"').replace('%', '%%') + '"'


# Write an installed file only if its content has changed.
def write_if_changed(path, data, mode=None):
    path.parent.mkdir(parents=True, exist_ok=True)
    try:
        same = path.read_bytes() == data
    except FileNotFoundError:
        same = False
    if not same:
        path.write_bytes(data)
    if mode is not None and (not same or (path.stat().st_mode & 0o777) != mode):
        path.chmod(mode)
    return not same


# Install the current router and its user unit, then start or restart it.
def install_router():
    home = install_home()
    script = home / ".local/share/demo-audience/audience.py"
    unit = home / ".config/systemd/user/demo-audience.service"
    content = ("[Unit]\n"
               "Description=Demo audience router: the shared hostname serves the deck that took it last\n\n"
               "[Service]\n"
               f"Environment=AUDIENCE_PORT={router_port()}\n"
               f"Environment=DEMO_AUDIENCE_DIR={unit_arg(state_dir())}\n"
               f"ExecStart={unit_arg(sys.executable)} -I {unit_arg(script)} serve\n"
               "Restart=on-failure\nRestartSec=1\n")
    changed_script = write_if_changed(script, Path(__file__).resolve().read_bytes(), 0o755)
    changed_unit = write_if_changed(unit, content.encode())
    if changed_script or changed_unit:
        require_systemctl("daemon-reload")
        require_systemctl("restart", "demo-audience.service")
    else:
        require_systemctl("start", "demo-audience.service")


# Check whether the router accepts TCP connections on its loopback port.
def router_listening():
    try:
        with socket.create_connection(("127.0.0.1", router_port()), timeout=0.2):
            return True
    except OSError:
        return False


# Print the pid listening on the router port, or None when nothing listens.
def port_holder():
    try:
        out = subprocess.run(["ss", "-Hltnp", f"sport = :{router_port()}"],
                             capture_output=True, text=True, timeout=5).stdout
    except (OSError, subprocess.SubprocessError):
        return None
    found = re.search(r"pid=([0-9]+)", out)
    return int(found.group(1)) if found else None


# Install the router and wait until its service holds the port: another process on
# the port, such as an old page forward, would take the hostname's traffic instead.
def ensure_router():
    install_router()
    deadline = time.monotonic() + 10
    holder = None
    while time.monotonic() < deadline:
        main = systemctl("show", "-p", "MainPID", "--value", "demo-audience.service").stdout.strip()
        holder = port_holder()
        if router_listening() and holder is not None and str(holder) == main:
            return
        time.sleep(0.1)
    if holder is not None:
        with contextlib.suppress(OSError):
            command = Path(f"/proc/{holder}/cmdline").read_bytes().replace(b"\0", b" ").decode().strip()
            raise RuntimeError(f"port {router_port()} is held by pid {holder} ({command}), not the router")
    raise RuntimeError("router did not start listening within 10 seconds")


# Select a deck and register its upstream port.
def use_deck(name, port):
    if not valid_name(name):
        raise ValueError("invalid deck name")
    port = parse_port(str(port))
    if port is None:
        raise ValueError("port must be 1024..65535 and differ from the router port")
    root = ensure_state()
    for route in routes():
        if route.name != name and parse_port(read_text(route)) == port:
            raise RuntimeError(f"port {port} is already {route.name}'s page")
    atomic_write(root / "routes" / name, str(port))
    atomic_write(root / "active", name)
    ensure_router()


# Remove a deck and restore the most recently written remaining route.
def release_deck(name):
    if not valid_name(name):
        raise ValueError("invalid deck name")
    root = ensure_state()
    with contextlib.suppress(FileNotFoundError):
        (root / "routes" / name).unlink()
    remaining = routes()
    active = read_text(root / "active")
    if active == name or not valid_name(active) or not (root / "routes" / active).is_file():
        if remaining:
            newest = max(remaining, key=lambda p: (p.stat().st_mtime_ns, p.name))
            atomic_write(root / "active", newest.name)
        else:
            with contextlib.suppress(FileNotFoundError):
                (root / "active").unlink()
    if not remaining:
        with contextlib.suppress(RuntimeError):
            systemctl("stop", "demo-audience-tunnel.service")


# Install the named tunnel unit and wait until systemd reports it active.
def start_tunnel(token):
    token = Path(token).expanduser().resolve()
    try:
        if not token.is_file() or token.stat().st_size == 0:
            raise RuntimeError("tunnel token file is missing or empty")
    except OSError as exc:
        raise RuntimeError(f"cannot access tunnel token file: {exc}") from exc
    cloudflared = shutil.which("cloudflared")
    if not cloudflared:
        raise RuntimeError("cloudflared was not found on PATH")
    cloudflared = str(Path(cloudflared).resolve())
    unit = install_home() / ".config/systemd/user/demo-audience-tunnel.service"
    content = ("[Unit]\n"
               "Description=Demo audience tunnel: the named tunnel's connector for the shared hostname\n\n"
               "[Service]\n"
               f"Environment=TUNNEL_TOKEN_FILE={unit_arg(token)}\n"
               f"ExecStart={unit_arg(cloudflared)} tunnel --no-autoupdate run\n"
               "Restart=on-failure\nRestartSec=2\n")
    if write_if_changed(unit, content.encode()):
        require_systemctl("daemon-reload")
        require_systemctl("restart", "demo-audience-tunnel.service")
    else:
        require_systemctl("start", "demo-audience-tunnel.service")
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        if systemctl("is-active", "demo-audience-tunnel.service").returncode == 0:
            return
        time.sleep(0.1)
    raise RuntimeError("tunnel did not become active within 10 seconds")


# Print the router, selected deck, routes, and tunnel status.
def show_status():
    print(f"Router: {'listening' if router_listening() else 'not listening'}")
    name = active_deck()
    print(f"Active deck: {name or 'none'}")
    for route in routes():
        print(f"Route: {route.name} {read_text(route)}")
    result = systemctl("is-active", "demo-audience-tunnel.service")
    print(f"Tunnel: {result.stdout.strip() or result.stderr.strip() or 'unknown'}")


# Forward bytes in one direction until a peer disconnects.
async def pipe(reader, writer):
    while data := await reader.read(65536):
        writer.write(data)
        await writer.drain()


# Proxy one connection and register it for forced closure on a route switch.
async def proxy_connection(reader, writer, pairs):
    upstream = None
    pair = None
    tasks = []
    try:
        _, port = current_route()
        if port is not None:
            try:
                upstream_reader, upstream = await asyncio.wait_for(
                    asyncio.open_connection("127.0.0.1", port), timeout=3)
            except (OSError, asyncio.TimeoutError):
                pass
        if upstream is None:
            writer.write(UNAVAILABLE)
            await writer.drain()
            return
        pair = (writer, upstream, port)
        pairs.add(pair)
        tasks = [asyncio.create_task(pipe(reader, upstream)),
                 asyncio.create_task(pipe(upstream_reader, writer))]
        await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
    except (OSError, ConnectionError):
        pass
    finally:
        for task in tasks:
            task.cancel()
        if tasks:
            await asyncio.gather(*tasks, return_exceptions=True)
        if pair is not None:
            pairs.discard(pair)
        writer.close()
        if upstream is not None:
            upstream.close()
        with contextlib.suppress(OSError, ConnectionError):
            await writer.wait_closed()
        if upstream is not None:
            with contextlib.suppress(OSError, ConnectionError):
                await upstream.wait_closed()


# Close stale connections and log each observed change of active route.
async def watch_routes(pairs):
    previous = current_route()
    while True:
        await asyncio.sleep(0.5)
        current = current_route()
        if current != previous:
            print(f"audience switch: {previous[0] or 'none'} -> {current[0] or 'none'}", file=sys.stderr, flush=True)
            previous = current
        for client, upstream, port in tuple(pairs):
            if port != current[1]:
                client.close()
                upstream.close()


# Run the loopback-only asynchronous TCP router.
async def serve():
    ensure_state()
    pairs = set()
    server = await asyncio.start_server(lambda r, w: proxy_connection(r, w, pairs),
                                        "127.0.0.1", router_port())
    watcher = asyncio.create_task(watch_routes(pairs))
    try:
        async with server:
            await server.serve_forever()
    finally:
        watcher.cancel()
        await asyncio.gather(watcher, return_exceptions=True)
        for client, upstream, _ in pairs:
            client.close()
            upstream.close()


# Parse and run the requested command, reporting validation and service errors.
def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("serve")
    use = commands.add_parser("use")
    use.add_argument("deck")
    use.add_argument("port")
    release = commands.add_parser("release")
    release.add_argument("deck")
    commands.add_parser("active")
    tunnel = commands.add_parser("tunnel")
    tunnel.add_argument("token_file")
    commands.add_parser("status")
    args = parser.parse_args(argv)
    try:
        if args.command == "serve":
            asyncio.run(serve())
        elif args.command == "use":
            use_deck(args.deck, args.port)
        elif args.command == "release":
            release_deck(args.deck)
        elif args.command == "active":
            name = active_deck()
            if name is None:
                return 1
            print(name)
        elif args.command == "tunnel":
            start_tunnel(args.token_file)
        else:
            show_status()
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 2
    except (RuntimeError, OSError) as exc:
        print(str(exc), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
