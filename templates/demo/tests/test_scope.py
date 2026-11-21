"""Exercise target isolation through the real lifecycle executable."""

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest


FAKE = '''#!/usr/bin/python3
import json, os, pathlib, sys
name = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
keys = ["KUBECONFIG", "DOCKER_HOST", "DOCKER_CONTEXT", "CLOUDSDK_CORE_PROJECT", "CLOUDSDK_COMPUTE_ZONE", "CLUSTER", "PROJECT"]
with open(os.environ["CALL_LOG"], "a") as output:
    output.write(json.dumps({"argv": [name] + args, "env": {key: os.environ.get(key) for key in keys}}) + "\\n")
if name == "docker":
    if args[0] == "ps":
        print("vcluster.cp.demo")
    elif args[0] == "port":
        print("127.0.0.1:6443")
    elif args[0] == "inspect" and any("PortBindings" in arg for arg in args):
        print(json.dumps({"8443/tcp": [{"HostIp": "", "HostPort": "6443"}]}))
    elif args[0] == "inspect":
        print("true")
elif name == "vcluster" and args[:4] == ["platform", "connect", "management", "--print"]:
    print("apiVersion: v1")
elif name == "kubectl" and "config" in args and "view" in args:
    print("https://127.0.0.1:6443")
elif name == "kubectl" and "get" in args:
    if "nodes" in args:
        print(json.dumps({"items": [{"status": {"conditions": [{"type": "Ready", "status": "True"}]}}]}))
    elif "--raw" not in args:
        phase = "Healthy" if "stackinstance" in args else "Ready"
        print(json.dumps({"metadata": {}, "status": {"phase": phase}}))
'''


class ScopeTests(unittest.TestCase):
    """Use fake tools but run the actual CLI and every registered kind."""

    # Create a deck and a hostile caller environment.
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.deck = self.root / "deck"
        self.deck.mkdir()
        self.home = self.root / "home"
        (self.home / ".vcluster").mkdir(parents=True)
        binary = self.root / "bin"
        binary.mkdir()
        for name in ("docker", "kubectl", "vcluster", "gcloud"):
            path = binary / name
            path.write_text(FAKE)
            path.chmod(0o755)
        self.log = self.root / "calls.jsonl"
        self.kubeconfig = self.root / "deck-kubeconfig"
        self.kubeconfig.write_text("clusters:\n- cluster:\n    server: https://127.0.0.1:6443\n")
        hostile = self.root / "caller-kubeconfig"
        hostile.write_text("server: https://prod.example.com\n")
        self.env = {**os.environ, "HOME": str(self.home), "PATH": str(binary) + os.pathsep + os.environ["PATH"],
                    "XDG_STATE_HOME": str(self.root / "state"), "KUBECONFIG": str(hostile),
                    "DOCKER_HOST": "ssh://work", "CLUSTER": "prod", "PROJECT": "prod",
                    "CLOUDSDK_CORE_PROJECT": "prod"}
        self.platform = "https://demo.example.com:8443"
        self.login("https://work.example.com")
        (self.deck / "demo.toml").write_text(f'''deck = "isolated"
kubeconfig = "{self.kubeconfig}"
platform = "{self.platform}"
gcp_project = "demo-project"
gcp_zone = "demo-zone"
clusters = ["demo"]
env = {{ CALL_LOG = "{self.log}" }}

[[component]]
name = "command"
kind = "command"
probe = "docker version && kubectl version && vcluster version && gcloud version"
start = "gcloud version"
stop = "gcloud version"
remove = "gcloud version"
build = "gcloud version"

[[component]]
name = "process"
kind = "process"
run = "true"
probe = "gcloud version"
start = "gcloud version"
stop = "gcloud version"
remove = "gcloud version"

[[component]]
name = "host"
kind = "docker-host"
cluster = "demo"
remove = "vcluster version"

[[component]]
name = "platform"
kind = "platform"
steady = 1

[[component]]
name = "instance"
kind = "vcluster-instance"
project = "demo"
instance = "sample"

[[component]]
name = "stack"
kind = "stack"
project = "demo"
instance = "sample"
''')

    # Set the CLI login in the isolated home.
    def login(self, host):
        (self.home / ".vcluster/config.json").write_text(json.dumps({"platform": {"host": host}}))

    # Invoke the installed executable with the hostile caller environment.
    def run_demo(self, *args):
        demo = Path(__file__).resolve().parents[1] / "demo"
        return subprocess.run([str(demo), *args, "--deck", str(self.deck)], env=self.env,
                              text=True, capture_output=True, timeout=30)

    # Wrong login refuses both operations before any fake tool runs.
    def test_wrong_login_refuses_all_operations(self):
        for command in (("reset",), ("down",)):
            with self.subTest(command=command):
                result = self.run_demo(*command)
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertIn("scope", result.stdout)
                self.assertIn("not ready: scope", result.stdout)
                self.assertFalse(self.log.exists())

    # Correct login keeps every native and shell invocation inside the pins.
    def test_hostile_caller_environment_is_pinned(self):
        self.login(self.platform)
        for command in (("reset",), ("down",)):
            with self.subTest(command=command):
                result = self.run_demo(*command)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertIn("scope", result.stdout)
        calls = [json.loads(line) for line in self.log.read_text().splitlines()]
        self.assertEqual({call["argv"][0] for call in calls}, {"docker", "kubectl", "vcluster", "gcloud"})
        for call in calls:
            env = call["env"]
            self.assertEqual(env["KUBECONFIG"], str(self.kubeconfig))
            self.assertEqual(env["DOCKER_CONTEXT"], "default")
            self.assertIsNone(env["DOCKER_HOST"])
            self.assertEqual(env["CLOUDSDK_CORE_PROJECT"], "demo-project")
            self.assertEqual(env["CLOUDSDK_COMPUTE_ZONE"], "demo-zone")
            self.assertIsNone(env["CLUSTER"])
            self.assertIsNone(env["PROJECT"])
            self.assertNotIn("prod", json.dumps(call))
            self.assertNotIn("work", json.dumps(call))

    # A nonlocal kube server outside the declared Platform is refused.
    def test_nonlocal_kube_server_is_refused(self):
        self.login(self.platform)
        for entry in ("server: https://outside.example.com\n", 'clusters: [{cluster: {server: "https://outside.example.com"}}]\n'):
            with self.subTest(entry=entry):
                self.kubeconfig.write_text(entry)
                result = self.run_demo("reset")
                self.assertEqual(result.returncode, 1)
                self.assertIn("outside.example.com", result.stdout)
                self.assertFalse(self.log.exists())

    # All entry points refuse a mismatched login before probing.
    def test_scope_refusal_covers_all_commands(self):
        root = Path(self.env["XDG_STATE_HOME"]) / "demo"
        root.mkdir(parents=True)
        (root / "active").write_text(str(self.deck))
        for command in ("ready", "wake", "sleep", "resume"):
            with self.subTest(command=command):
                result = self.run_demo(command)
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertIn("not ready: scope", result.stdout)
                self.assertFalse(self.log.exists())

    # Loopback addresses and the declared Platform host are accepted.
    def test_allowed_kube_server_hosts(self):
        self.login(self.platform)
        for host in ("127.8.9.10", "[::1]", "localhost", "demo.example.com"):
            with self.subTest(host=host):
                self.kubeconfig.write_text(f"server: https://{host}:6443\n")
                result = self.run_demo("ready")
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    # A missing login, malformed server, or missing Platform declaration is refused.
    def test_invalid_scope_inputs(self):
        (self.home / ".vcluster/config.json").unlink()
        self.assertEqual(self.run_demo("ready").returncode, 1)
        self.login(self.platform)
        self.kubeconfig.write_text("server: \n")
        self.assertEqual(self.run_demo("ready").returncode, 1)
        manifest = self.deck / "demo.toml"
        manifest.write_text(manifest.read_text().replace(f'platform = "{self.platform}"\n', ""))
        result = self.run_demo("ready")
        self.assertEqual(result.returncode, 1)
        self.assertIn("missing platform", result.stderr)
        self.assertFalse(self.log.exists())

    # The report retains every declared server host.
    def test_scope_row_lists_all_hosts(self):
        self.login(self.platform)
        self.kubeconfig.write_text("".join(f"server: https://127.0.0.{number}:6443\n" for number in range(1, 8)))
        result = self.run_demo("ready")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        for number in range(1, 8):
            self.assertIn(f"127.0.0.{number}", result.stdout.splitlines()[0])

    # Invalid values for each new manifest field fail validation.
    def test_manifest_scope_keys_are_validated(self):
        manifest = self.deck / "demo.toml"
        original = manifest.read_text()
        for old, new in ((f'platform = "{self.platform}"', 'platform = "http://localhost"'),
                         ('gcp_project = "demo-project"', 'gcp_project = ""'),
                         ('gcp_zone = "demo-zone"', 'gcp_zone = 4')):
            with self.subTest(field=old):
                manifest.write_text(original.replace(old, new))
                result = self.run_demo("ready")
                self.assertEqual(result.returncode, 1)
                self.assertIn("invalid", result.stderr)
                self.assertFalse(self.log.exists())


if __name__ == "__main__":
    unittest.main()
