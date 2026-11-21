"""Exercise the lifecycle core and shell adapter without external services."""

import contextlib
import fcntl
import io
import os
from pathlib import Path
import signal
import tempfile
import time
import unittest
from unittest.mock import patch

import core


class Fake:
    """An in-process adapter with configurable state and recorded verbs."""

    calls = []
    states = {}
    failures = set()
    unresponsive = set()

    # Keep the manifest entry used by the fake component.
    def __init__(self, config, deck, state, env):
        self.config = config
        self.name = config["name"]
        self.tail = []

    # Expose configured verb availability.
    def has_verb(self, verb):
        return verb in self.config

    # Return the fake component's current health.
    def probe(self):
        return self.states.get(self.name, False), "healthy"

    # Record a verb and update health when it succeeds.
    def action(self, verb):
        self.calls.append((self.name, verb))
        if (self.name, verb) in self.failures:
            return False
        if self.name not in self.unresponsive:
            if verb in ("start", "build"):
                self.states[self.name] = True
            if verb in ("stop", "remove"):
                self.states[self.name] = False
        return True

    # Start the fake component.
    def start(self):
        return self.action("start")

    # Stop the fake component.
    def stop(self):
        return self.action("stop")

    # Build the fake component.
    def build(self):
        return self.action("build")

    # Remove the fake component.
    def remove(self):
        return self.action("remove")


class Clock:
    """A clock advanced by the injected sleep function."""

    # Begin at zero for each test.
    def __init__(self):
        self.now = 0

    # Return the current simulated time.
    def clock(self):
        return self.now

    # Advance time without waiting in real time.
    def sleep(self, seconds):
        self.now += seconds


class CoreTests(unittest.TestCase):
    """Cover phase one lifecycle requirements and subprocess behavior."""

    # Make an isolated deck, state root, and fake registry.
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.path = Path(self.tmp.name)
        self.deck = self.path / "deck"
        self.deck.mkdir()
        self.root = self.path / "state"
        self.clock = Clock()
        Fake.calls = []
        Fake.states = {}
        Fake.failures = set()
        Fake.unresponsive = set()

    # Make a lifecycle with fake adapters and a simulated clock.
    def lifecycle(self, names=("a", "b"), absent=()):
        items = []
        for name in names:
            items.append({"name": name, "kind": "fake", "prepared": "absent" if name in absent else "present", "timeout": 2, "build": "yes", "remove": "yes"})
        return core.Lifecycle(self.deck, {"fake": Fake}, self.clock.clock,
                              self.clock.sleep, self.root,
                              {"deck": "test", "component": items})

    # Capture output while invoking the core.
    def invoke(self, life, command, fresh=False):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            result = life.execute(command, fresh)
        return result, output.getvalue()

    # A first reset removes in reverse and builds in dependency order.
    def test_01_reset_order_and_set(self):
        life = self.lifecycle()
        result, _ = self.invoke(life, "reset")
        self.assertTrue(result[0])
        self.assertEqual(Fake.calls, [("a", "start"), ("b", "start"), ("b", "remove"), ("a", "remove"), ("a", "build"), ("b", "build")])
        self.assertTrue((life.state / "set").exists())

    # A healthy marked deck does not run lifecycle verbs.
    def test_02_reset_already_set(self):
        life = self.lifecycle()
        (life.state / "set").touch()
        Fake.states.update(a=True, b=True)
        result, output = self.invoke(life, "reset")
        self.assertTrue(result[0])
        self.assertIn("already set", output)
        self.assertEqual(Fake.calls, [])

    # A failed gentle wake causes a full reverse stop and forward start.
    def test_03_wake_gentle_then_cold(self):
        life = self.lifecycle()
        Fake.states.update(a=True, b=False)
        Fake.unresponsive.add("b")
        result, _ = self.invoke(life, "wake")
        self.assertFalse(result[0])
        self.assertEqual(Fake.calls, [("b", "start"), ("b", "stop"), ("a", "stop"), ("a", "start"), ("b", "start")])
        self.assertEqual(self.clock.now, 4)

    # Neither wake nor resume builds or removes present components.
    def test_04_wake_and_resume_do_not_rebuild(self):
        life = self.lifecycle()
        self.invoke(life, "wake")
        Fake.states.update(a=False, b=False)
        self.invoke(life, "resume")
        self.assertTrue(Fake.calls)
        self.assertFalse(any(verb in ("build", "remove") for _, verb in Fake.calls))

    # Absent components are removed on wake and reset, and pass when absent.
    def test_05_absent_component(self):
        life = self.lifecycle(("a", "live"), ("live",))
        Fake.states.update(a=True, live=True)
        self.assertTrue(self.invoke(life, "wake")[0][0])
        self.assertIn(("live", "remove"), Fake.calls)
        self.assertTrue(self.invoke(life, "ready")[0][0])
        Fake.calls.clear()
        Fake.states["live"] = True
        self.assertTrue(self.invoke(life, "reset", True)[0][0])
        self.assertIn(("live", "remove"), Fake.calls)
        Fake.states["live"] = True
        Fake.calls.clear()
        self.invoke(life, "resume")
        self.assertNotIn(("live", "remove"), Fake.calls)

    # A failed build leaves the marker absent and reports remaining work skipped.
    def test_06_build_failure_skips_rest(self):
        life = self.lifecycle()
        Fake.failures.add(("a", "build"))
        result, output = self.invoke(life, "reset")
        self.assertFalse(result[0])
        self.assertIn("skipped", output)
        self.assertNotIn(("b", "build"), Fake.calls)
        self.assertFalse((life.state / "set").exists())

    # Down clears active while sleep keeps it and both preserve the marker.
    def test_07_down_sleep_and_no_active(self):
        life = self.lifecycle()
        (life.state / "set").touch()
        (life.root / "active").write_text(str(self.deck))
        self.invoke(life, "sleep")
        self.assertTrue((life.state / "set").exists())
        self.assertTrue((life.root / "active").exists())
        self.invoke(life, "down")
        self.assertTrue((life.state / "set").exists())
        self.assertFalse((life.root / "active").exists())
        with patch.dict(os.environ, {"XDG_STATE_HOME": str(self.path / "unused")}):
            self.assertEqual(core.main(["sleep"]), 0)
            self.assertEqual(core.main(["resume"]), 0)

    # The lock refuses overlap and the spawned child does not inherit its fd.
    def test_08_lock_and_child_fd(self):
        life = self.lifecycle()
        with (life.state / "lock").open("w+") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            lock.write("123")
            lock.flush()
            result, output = self.invoke(life, "reset")
            self.assertFalse(result[0])
            self.assertIn("pid 123", output)
            self.assertTrue(self.invoke(life, "sleep")[0][0])
        self.write_manifest('probe = "true"\nstart = "sleep 30 & echo $! > child"\n')
        command_life = core.Lifecycle(self.deck, root=self.root)
        self.invoke(command_life, "reset")
        pid = int((self.deck / "child").read_text())
        self.addCleanup(self.kill, pid)
        paths = []
        for fd in (Path("/proc") / str(pid) / "fd").iterdir():
            try:
                paths.append(os.readlink(fd))
            except FileNotFoundError:
                pass
        self.assertNotIn(str(command_life.state / "lock"), paths)
        self.assertTrue(self.invoke(command_life, "used")[0][0])

    # A failed health check stops at the configured timeout.
    def test_09_wait_timeout(self):
        life = self.lifecycle(("a",))
        Fake.unresponsive.add("a")
        self.assertFalse(life.wait(life.items[0]))
        self.assertEqual(self.clock.now, 2)

    # Strict manifest validation rejects malformed and out-of-scope entries.
    def test_10_manifest_validation(self):
        cases = [
            ('bad = "x"\n', "bad", {"command": core.REGISTRY["command"]}),
            ('kind = "bogus"\n', "kind", {"command": core.REGISTRY["command"]}),
            ('duplicate', "duplicate", {"command": core.REGISTRY["command"]}),
            ('kind = "docker-host"\ncluster = "other"\n', "cluster", {"docker-host": Fake}),
        ]
        for extra, expected, registry in cases:
            with self.subTest(expected=expected):
                if extra == "duplicate":
                    text = 'deck = "x"\n[[component]]\nname = "a"\nkind = "command"\nprobe = "true"\n[[component]]\nname = "a"\nkind = "command"\nprobe = "true"\n'
                elif "kind =" in extra:
                    text = 'deck = "x"\nclusters = ["allowed"]\n[[component]]\nname = "a"\n' + extra
                else:
                    text = 'deck = "x"\n[[component]]\nname = "a"\nkind = "command"\nprobe = "true"\n' + extra
                (self.deck / "demo.toml").write_text(text)
                with self.assertRaisesRegex(ValueError, expected):
                    core.load_manifest(self.deck, registry)

    # A healthy unmarked deck is reported as used.
    def test_11_ready_reports_used(self):
        life = self.lifecycle()
        Fake.states.update(a=True, b=True)
        result, output = self.invoke(life, "ready")
        self.assertFalse(result[0])
        self.assertIn("used since the last reset", output)

    # A daemon inheriting output must not keep the shell verb waiting.
    def test_12_background_daemon_does_not_block(self):
        self.write_manifest('probe = "true"\nstart = "sleep 30 & echo $! > child"\n')
        life = core.Lifecycle(self.deck, root=self.root)
        start = time.monotonic()
        self.invoke(life, "reset")
        self.assertLess(time.monotonic() - start, 3)
        pid = int((self.deck / "child").read_text())
        self.addCleanup(self.kill, pid)

    # A timed-out shell kills its entire process group and records the error.
    def test_shell_timeout_kills_group(self):
        self.write_manifest('probe = "true"\nstart = "sleep 30 & echo $! > child; wait"\n')
        life = core.Lifecycle(self.deck, root=self.root)
        adapter = life.items[0][1]
        adapter.timeouts = dict(adapter.timeouts, start=0.2)
        self.assertFalse(adapter.start())
        pid = int((self.deck / "child").read_text())
        self.addCleanup(self.kill, pid)
        stat = Path(f"/proc/{pid}/stat")
        if stat.exists():
            self.assertEqual(stat.read_text().split(") ", 1)[1][0], "Z")
        self.assertIn("command timed out", (life.state / "log").read_text())

    # A slow probe cannot extend a component wait past its timeout.
    def test_wait_bounds_slow_shell_probe(self):
        self.write_manifest('timeout = 0.2\nprobe = "sleep 30"\n')
        life = core.Lifecycle(self.deck, root=self.root)
        started = time.monotonic()
        self.assertFalse(life.wait(life.items[0]))
        self.assertLess(time.monotonic() - started, 2)

    # Environment and output reach a real shell in the deck folder.
    def test_command_environment_and_failure_tail(self):
        (self.deck / "demo.toml").write_text(
            'deck = "shell"\nenv = { SAMPLE = "hello" }\nkubeconfig = "~/demo-config"\n'
            '[[component]]\nname = "shell"\nkind = "command"\n'
            'probe = "test -f flag"\n'
            "build = 'printenv SAMPLE KUBECONFIG DEMO_STATE > env; touch flag'\n"
            'remove = "rm -f flag"\n')
        life = core.Lifecycle(self.deck, root=self.root)
        self.assertTrue(self.invoke(life, "reset")[0][0])
        self.assertEqual((self.deck / "env").read_text().splitlines(),
                         ["hello", os.path.expanduser("~/demo-config"), str(life.state)])
        adapter = life.items[0][1]
        adapter.config["start"] = "printf 'one\\ntwo\\nthree\\nfour\\n'; exit 1"
        self.assertFalse(adapter.start())
        self.assertEqual(adapter.tail, ["two", "three", "four"])

    # Ready probes run together rather than waiting for each component in turn.
    def test_ready_probes_in_parallel(self):
        life = self.lifecycle()
        for _, adapter in life.items:
            adapter.probe = lambda: (time.sleep(0.2) or True, "healthy")
        (life.state / "set").touch()
        started = time.monotonic()
        self.assertTrue(self.invoke(life, "ready")[0][0])
        self.assertLess(time.monotonic() - started, 0.35)

    # Write a minimal command manifest for subprocess tests.
    def write_manifest(self, fields):
        (self.deck / "demo.toml").write_text('deck = "shell"\n[[component]]\nname = "shell"\nkind = "command"\n' + fields)

    # Stop a test daemon if it is still running.
    def kill(self, pid):
        try:
            os.kill(pid, signal.SIGKILL)
        except ProcessLookupError:
            pass


if __name__ == "__main__":
    unittest.main()
