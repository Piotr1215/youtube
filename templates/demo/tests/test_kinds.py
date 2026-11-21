"""Exercise lifecycle kinds with fake command line tools."""

import http.server
import json
import os
from pathlib import Path
import signal
import tempfile
import threading
import time
import unittest
from unittest import mock

from kinds import DockerHost, KINDS, Platform, Process, Stack, VclusterInstance


FAKE = '''#!/usr/bin/env python3
import json, os, pathlib, sys, time
name = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
with open(os.environ["FAKE_LOG"], "a") as log:
    log.write(json.dumps([name] + args) + "\\n")
fixture = json.loads(os.environ.get("FAKE_DATA", "{}"))
if fixture.get("sleep") == name:
    time.sleep(2)
if name == "docker":
    if args[0] == "ps":
        names = fixture.get("containers", {})
        status = next((x.split("=", 1)[1] for x in args if x.startswith("status=")), None)
        print("\\n".join(n for n, s in names.items() if not status or s == status))
    elif args[0] == "port":
        # Like real docker: a stopped container publishes nothing.
        if fixture.get("containers", {}).get(args[1]) == "running":
            print(fixture.get("docker_port", "127.0.0.1:6443"))
    elif args[0] == "inspect" and any("PortBindings" in arg for arg in args):
        # The configured bindings, which docker keeps while the container is stopped.
        print(json.dumps(fixture.get("port_bindings", {"8443/tcp": [{"HostIp": "", "HostPort": "6443"}]})))
    elif args[0] == "inspect":
        print("true" if fixture.get("platform", True) else "false")
    elif args[:2] == ["network", "ls"]:
        print("\\n".join(fixture.get("networks", [])))
elif name == "vcluster":
    if args[:4] == ["platform", "connect", "management", "--print"]:
        print("apiVersion: v1")
    elif args[:2] == ["platform", "get"]:
        count = pathlib.Path(os.environ["FAKE_ROOT"]) / "checks"
        n = int(count.read_text()) if count.exists() else 0
        count.write_text(str(n + 1))
        sys.exit(fixture.get("check_codes", [0])[min(n, len(fixture.get("check_codes", [0])) - 1)])
elif name == "kubectl":
    (pathlib.Path(os.environ["FAKE_ROOT"]) / "kubeconfig-used").write_text(os.environ.get("KUBECONFIG", ""))
    if "config" in args and "view" in args:
        print(fixture.get("kube_server", "https://127.0.0.1:6443"))
        sys.exit(0)
    if fixture.get("api_down"):
        print("API unavailable", file=sys.stderr)
        sys.exit(1)
    if "nodes" in args:
        print(json.dumps(fixture.get("nodes", {"items": [{"status": {"conditions": [{"type": "Ready", "status": "True"}]}}]})))
    elif "get" in args and "--raw" not in args:
        print(json.dumps(fixture.get("object", {"metadata": {}, "status": {"phase": "Ready"}})))
'''


class KindTests(unittest.TestCase):
    """Keep external calls inside an isolated fake executable directory."""

    # Create a deck and fake executables for each test.
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.deck = self.root / "deck"
        self.state = self.root / "state"
        self.deck.mkdir()
        self.state.mkdir()
        (self.deck / "demo.toml").write_text('deck = "test"\nclusters = ["alpha"]\n')
        binary = self.root / "bin"
        binary.mkdir()
        for name in ("docker", "kubectl", "vcluster"):
            path = binary / name
            path.write_text(FAKE)
            path.chmod(0o755)
        self.log = self.root / "calls"
        self.env = {**os.environ, "PATH": str(binary) + os.pathsep + os.environ["PATH"],
                    "FAKE_LOG": str(self.log), "FAKE_ROOT": str(self.root),
                    "KUBECONFIG": "deck-config", "DEMO_STATE": str(self.state)}

    # Supply JSON fixture data to the fake tools.
    def data(self, **data):
        self.env["FAKE_DATA"] = json.dumps(data)

    # Read the exact calls made to fake executables.
    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    # Construct a kind with the same port as the lifecycle core.
    def kind(self, cls, **config):
        return cls({"name": "example", **config}, self.deck, self.state, self.env)

    # Check the built-in registry and kind-specific manifest validation.
    def test_registry_and_validation(self):
        self.assertEqual(set(KINDS), {"process", "docker-host", "platform", "vcluster-instance", "stack"})
        for cls, item, key in [(Process, {}, "run"), (DockerHost, {"cluster": "other"}, "cluster"),
                               (VclusterInstance, {"instance": "x"}, "project"),
                               (Stack, {"project": "x"}, "instance"),
                               (Stack, {"project": "x", "instance": "y", "want": []}, "want")]:
            with self.subTest(cls=cls), self.assertRaisesRegex(ValueError, key):
                cls.validate({"name": "example", **item}, {"clusters": ["alpha"]})

    # Start cluster containers in dependency order and reject outside targets.
    def test_docker_start_order_and_scope_refusal(self):
        self.data(containers={"vcluster.lb.alpha.b": "exited", "vcluster.node.alpha.a": "exited",
                              "vcluster.cp.alpha": "exited", "vcluster.cp.other": "exited"})
        host = self.kind(DockerHost, cluster="alpha")
        self.assertTrue(host.start())
        self.assertIn(["docker", "start", "vcluster.cp.alpha", "vcluster.node.alpha.a", "vcluster.lb.alpha.b"], self.calls())
        before = self.calls()
        self.assertFalse(host._docker(["stop"], ["vcluster.cp.other"]))
        self.assertEqual(host.tail, ["scope: refusing vcluster.cp.other"])
        self.assertEqual(self.calls(), before)

    # A stopped cluster still proves its kube port, so a wake can start it.
    def test_docker_stopped_cluster_passes_locality_and_starts(self):
        self.data(containers={"vcluster.cp.alpha": "exited", "vcluster.node.alpha.a": "exited"})
        host = self.kind(DockerHost, cluster="alpha")
        self.assertEqual(host.probe(), (False, "containers stopped"))
        self.assertTrue(host.start())
        self.assertIn(["docker", "start", "vcluster.cp.alpha", "vcluster.node.alpha.a"], self.calls())

    # Treat an unreachable API as unknown even when all containers run.
    def test_docker_api_unavailable_is_unknown(self):
        self.data(containers={"vcluster.cp.alpha": "running", "vcluster.node.alpha.a": "running"}, api_down=True)
        host = self.kind(DockerHost, cluster="alpha")
        self.assertIsNone(host.probe()[0])
        self.assertIn(["kubectl", "--context", "vcluster-docker_alpha", "--request-timeout=5s", "get", "--raw", "/readyz"], self.calls())

    # Check running containers and every node's readiness.
    def test_docker_probe_rejects_stopped_or_unready(self):
        host = self.kind(DockerHost, cluster="alpha")
        self.data(containers={"vcluster.cp.alpha": "running", "vcluster.node.alpha.a": "exited"})
        self.assertIs(host.probe()[0], False)
        self.data(containers={"vcluster.cp.alpha": "running"}, nodes={"items": [{"status": {"conditions": []}}]})
        self.assertIs(host.probe()[0], False)
        self.data(containers={"vcluster.cp.alpha": "running"})
        self.assertIs(host.probe()[0], True)

    # Refuse an unrelated loopback server before any cluster action.
    def test_docker_host_rejects_unpublished_loopback_port(self):
        self.data(containers={"vcluster.cp.alpha": "running"},
                  kube_server="https://127.0.0.1:9999", docker_port="127.0.0.1:6443",
                  port_bindings={"8443/tcp": [{"HostIp": "", "HostPort": "6443"}]})
        host = self.kind(DockerHost, cluster="alpha")
        status, detail = host.probe()
        self.assertIsNone(status)
        self.assertIn("kube server is not alpha's container", detail)
        for verb in ("start", "stop", "remove"):
            self.assertFalse(getattr(host, verb)())
        calls = self.calls()
        self.assertFalse(any(call[0] == "kubectl" and "config" not in call for call in calls))
        self.assertFalse(any(call[:2] in (["docker", "start"], ["docker", "stop"], ["docker", "rm"], ["vcluster", "delete"]) for call in calls))

    # Delete only the cluster's leftover containers and network.
    def test_docker_remove_leaves_other_clusters(self):
        self.data(containers={"vcluster.cp.alpha": "exited", "vcluster.cp.other": "running"},
                  networks=["vcluster.alpha", "vcluster.other"])
        host = self.kind(DockerHost, cluster="alpha")
        self.assertTrue(host.remove())
        self.assertIn(["vcluster", "delete", "alpha", "--driver", "docker"], self.calls())
        self.assertIn(["docker", "rm", "-f", "vcluster.cp.alpha"], self.calls())
        self.assertIn(["docker", "network", "rm", "vcluster.alpha"], self.calls())
        self.assertFalse(any("vcluster.other" in call or "vcluster.cp.other" in call for call in self.calls()))

    # Keep the shared Platform running for another deck's cluster.
    def test_platform_stop_keeps_other_decks_and_has_no_remove(self):
        self.data(containers={"vcluster.cp.alpha": "running", "vcluster.cp.beta": "running"})
        platform = self.kind(Platform, remove="exit 0")
        self.assertFalse(platform.has_verb("remove"))
        self.assertTrue(platform.stop())
        self.assertEqual(platform.note, "kept: another deck's cluster runs on it")
        self.assertNotIn(["docker", "stop", "vcluster-platform"], self.calls())

    # Stop the Platform after the deck's own clusters are the only ones running.
    def test_platform_stops_when_scope_is_idle(self):
        self.data(containers={"vcluster.cp.alpha": "running"})
        self.assertTrue(self.kind(Platform).stop())
        self.assertIn(["docker", "stop", "vcluster-platform"], self.calls())

    # Require consecutive Platform checks and stop at the first failure.
    def test_platform_requires_steady_successes(self):
        self.data(check_codes=[0, 1, 0])
        platform = self.kind(Platform, steady=3)
        with mock.patch("kinds.time", wraps=time) as clock:
            clock.sleep = mock.Mock()
            self.assertIs(platform.probe()[0], False)
            self.assertEqual(clock.sleep.call_count, 1)
        (self.root / "checks").unlink()
        self.data(check_codes=[0, 0, 0])
        with mock.patch("kinds.time", wraps=time) as clock:
            clock.sleep = mock.Mock()
            self.assertIs(platform.probe()[0], True)
            self.assertEqual(clock.sleep.call_count, 2)

    # Identify a process by both pid and Linux start time and stop its group.
    def test_process_identity_restart_and_stop_group(self):
        child = self.root / "child"
        process = self.kind(Process, run=f"sleep 30 & echo $! > {child}; wait", health="test -f healthy")
        self.addCleanup(process._stop_process)
        (self.deck / "healthy").touch()
        self.assertTrue(process.start())
        pid_file = self.state / "proc/example.pid"
        pid, start = pid_file.read_text().split()
        self.assertEqual(process._identity(int(pid)), start)
        self.assertIs(process.probe()[0], True)
        pid_file.write_text(f"{pid} 0\n")
        self.assertIs(process.probe()[0], False)
        pid_file.write_text(f"{pid} {start}\n")
        (self.deck / "healthy").unlink()
        self.assertTrue(process.start())
        self.assertNotEqual(pid_file.read_text().split()[0], pid)
        self.assertTrue(process.stop())
        self.assertFalse(pid_file.exists())
        self.assertIs(process.probe()[0], False)
        pid_file.write_text("99999999 0\n")
        self.assertIs(process.probe()[0], False)

    # Exercise an actual HTTP health endpoint on loopback.
    def test_process_http_health(self):
        class Handler(http.server.BaseHTTPRequestHandler):
            # Serve a successful health response.
            def do_GET(self):
                self.send_response(204)
                self.end_headers()

            # Keep test output free of HTTP access logs.
            def log_message(self, format, *args):
                pass

        server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        self.addCleanup(server.server_close)
        self.addCleanup(server.shutdown)
        process = self.kind(Process, run="sleep 30", health=f"http://127.0.0.1:{server.server_port}/health")
        self.addCleanup(process._stop_process)
        self.assertTrue(process.start())
        self.assertIs(process.probe()[0], True)

    # Kill a child that outlives the process group leader after SIGTERM.
    def test_process_stop_kills_child_after_leader_exits(self):
        child_file = self.root / "stubborn.pid"
        run = f"bash -c 'trap \"\" TERM; echo $$ > {child_file}; while :; do sleep 1; done' & wait"
        process = self.kind(Process, run=run)
        self.addCleanup(process._stop_process)
        self.assertTrue(process.start())
        deadline = time.monotonic() + 2
        while not child_file.exists() and time.monotonic() < deadline:
            time.sleep(0.01)
        self.assertTrue(child_file.exists())
        child = int(child_file.read_text())
        self.assertTrue(process.stop())
        deadline = time.monotonic() + 2
        while process._identity(child) and time.monotonic() < deadline:
            time.sleep(0.01)
        self.assertIsNone(process._identity(child))

    # Do not leave an untracked process when its identity cannot be saved.
    def test_process_start_cleans_up_if_pid_write_fails(self):
        process = self.kind(Process, run="sleep 30")
        with mock.patch.object(Path, "write_text", side_effect=OSError("disk full")):
            with mock.patch("kinds.os.killpg", wraps=os.killpg) as kill_group:
                self.assertFalse(process.start())
        self.assertEqual(process.tail, ["disk full"])
        self.assertEqual(kill_group.call_args.args[1], signal.SIGKILL)

    # Check instance phase, deletion, online condition, and private credentials.
    def test_instance_conditions_and_kubeconfig(self):
        instance = self.kind(VclusterInstance, project="demo", instance="test")
        (self.state / "mgmt.kubeconfig").write_text("stale")
        self.assertFalse(instance.has_verb("start"))
        self.assertFalse(instance.has_verb("stop"))
        self.data(object={"metadata": {}, "status": {"phase": "Ready", "conditions": [{"type": "VirtualClusterOnline", "status": "False"}]}})
        self.assertIs(instance.probe()[0], False)
        self.data(object={"metadata": {}, "status": {"phase": "Ready"}})
        self.assertIs(instance.probe()[0], True)
        self.data(object={"metadata": {"deletionTimestamp": "now"}, "status": {"phase": "Ready"}})
        self.assertIs(instance.probe()[0], False)
        self.data(object={"metadata": {}, "status": {"phase": "Ready", "conditions": [{"type": "VirtualClusterOnline", "status": "Unknown"}]}})
        self.assertIsNone(instance.probe()[0])
        self.assertEqual((self.state / "mgmt.kubeconfig").stat().st_mode & 0o777, 0o600)
        self.assertEqual((self.state / "mgmt.kubeconfig").read_text(), "apiVersion: v1\n")
        self.assertEqual((self.root / "kubeconfig-used").read_text(), "deck-config")
        self.assertEqual(sum(call[:4] == ["vcluster", "platform", "connect", "management"] for call in self.calls()), 1)

    # Treat management API errors as unknown.
    def test_instance_api_error_unknown(self):
        self.data(api_down=True)
        self.assertIsNone(self.kind(VclusterInstance, project="demo", instance="x").probe()[0])

    # Check desired Stack phases and the longer deletion timeout.
    def test_stack_phase_and_remove_timeout(self):
        stack = self.kind(Stack, project="demo", instance="example")
        self.data(object={"metadata": {}, "status": {"phase": "Pending"}})
        self.assertIs(stack.probe()[0], False)
        self.data(object={"metadata": {}, "status": {"phase": "Healthy"}})
        self.assertIs(stack.probe()[0], True)
        self.assertTrue(stack.remove())
        self.assertIn(["kubectl", "--kubeconfig", str(self.state / "mgmt.kubeconfig"), "delete", "stackinstance", "-n", "p-demo", "example", "--ignore-not-found", "--wait=true", "--timeout=420s"], self.calls())

    # Treat native command timeouts as unknown rather than down.
    def test_native_probe_timeout_is_unknown(self):
        self.data(sleep="docker")
        host = self.kind(DockerHost, cluster="alpha", probe_timeout=0.05)
        self.assertIsNone(host.probe()[0])

    # Use the command adapter for overrides and retain its failure tail.
    def test_command_overrides_and_timeout(self):
        process = self.kind(Process, run="sleep 30", probe="sleep 1", probe_timeout=0.05,
                            build="printf 'line 1\\nline 2\\n' >&2; exit 1")
        self.assertIsNone(process.probe()[0])
        self.assertFalse(process.build())
        self.assertEqual(process.tail, ["line 1", "line 2"])
        process.config["probe"] = "exit 1"
        self.assertIs(process.probe()[0], False)
        process.config["probe"] = "exit 2"
        self.assertIsNone(process.probe()[0])

    # Accept the boolean command port as well as an integer exit-status adapter.
    def test_boolean_command_port(self):
        process = self.kind(Process, run="sleep 30", build="ignored")
        with mock.patch("kinds.Command") as command:
            command.return_value.run.return_value = True
            self.assertTrue(process.build())
            command.return_value.run.return_value = False
            command.return_value.tail = ["failed"]
            self.assertFalse(process.build())
            self.assertEqual(process.tail, ["failed"])


if __name__ == "__main__":
    unittest.main()
