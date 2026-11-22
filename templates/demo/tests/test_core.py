"""Exercise the lifecycle core and shell adapter without external services."""

import contextlib
import fcntl
import io
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
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
            items.append({"name": name, "kind": "fake", "live": name in absent, "timeout": 2, "start": "yes", "stop": "yes", "build": "yes", "remove": "yes"})
        return core.Lifecycle(self.deck, {"fake": Fake}, self.clock.clock,
                              self.clock.sleep, self.root,
                              {"deck": "test", "component": items})

    # Capture output while invoking the core.
    def invoke(self, life, command):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            result = life.execute(command)
        return result, output.getvalue()

    # Fresh reset removes in reverse and builds in dependency order.
    def test_01_missing_parts_build_in_order(self):
        life = self.lifecycle()
        result, _ = self.invoke(life, "reset")
        self.assertTrue(result[0])
        self.assertEqual(Fake.calls, [("a", "start"), ("b", "start")])

    # Reset leaves healthy present components intact.
    def test_02_reset_leaves_healthy_deck(self):
        life = self.lifecycle()
        Fake.states.update(a=True, b=True)
        self.assertTrue(self.invoke(life, "reset")[0][0])
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

    # Wake leaves an in-use absent component for reset to remove.
    def test_05_absent_component(self):
        life = self.lifecycle(("a", "live"), ("live",))
        Fake.states.update(a=True, live=True)
        result, output = self.invoke(life, "wake")
        self.assertFalse(result[0])
        self.assertIn("live steps done", output)
        self.assertNotIn(("live", "remove"), Fake.calls)
        self.assertIn("live steps done", self.invoke(life, "ready")[1])
        self.assertTrue(self.invoke(life, "reset")[0][0])
        self.assertIn(("live", "remove"), Fake.calls)
        self.assertTrue(self.invoke(life, "ready")[0][0])

    # A failed build reports remaining work skipped.
    def test_06_build_failure_skips_rest(self):
        life = self.lifecycle()
        Fake.failures.update({("a", "start"), ("a", "build")})
        result, output = self.invoke(life, "reset")
        self.assertFalse(result[0])
        self.assertIn("skipped", output)
        self.assertNotIn(("b", "build"), Fake.calls)

    # Down clears active while sleep keeps it.
    def test_07_down_sleep_and_no_active(self):
        life = self.lifecycle()
        (life.root / "active").write_text(str(self.deck))
        self.invoke(life, "sleep")
        self.assertTrue((life.root / "active").exists())
        self.invoke(life, "down")
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
        self.write_manifest('probe = "test -f flag"\nstart = "sleep 30 & echo $! > child; touch flag"\n')
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

    # Readiness depends on probes alone.
    def test_11_ready_reports_probes(self):
        life = self.lifecycle()
        Fake.states.update(a=True, b=True)
        result, output = self.invoke(life, "ready")
        self.assertTrue(result[0])
        self.assertIn("all set for the demo", output)

    # A daemon inheriting output must not keep the shell verb waiting.
    def test_12_background_daemon_does_not_block(self):
        self.write_manifest('probe = "test -f flag"\nstart = "sleep 30 & echo $! > child; touch flag"\n')
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
        deadline = time.monotonic() + 2
        while True:
            try:
                state = stat.read_text().split(") ", 1)[1][0]
            except FileNotFoundError:
                break
            if state == "Z":
                break
            self.assertLess(time.monotonic(), deadline, f"child still alive: {state}")
            time.sleep(0.01)
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

    # Engine pins override manifest values and caller variables are filtered.
    def test_environment_pins_and_missing_kubeconfig(self):
        manifest = {"deck": "pins", "env": {"KUBECONFIG": "bad", "DOCKER_HOST": "bad", "DOCKER_CONTEXT": "bad", "CLOUDSDK_CORE_PROJECT": "bad", "CLOUDSDK_COMPUTE_ZONE": "bad"},
                    "gcp_project": "demo", "gcp_zone": "zone", "component": [{"name": "a", "kind": "fake"}]}
        with patch.dict(os.environ, {"CLUSTER": "prod", "PROJECT": "prod", "LC_TEST": "yes"}, clear=True):
            life = core.Lifecycle(self.deck, {"fake": Fake}, root=self.root, manifest=manifest)
        self.assertEqual(life.env["KUBECONFIG"], str(life.state / "no-kubeconfig"))
        self.assertFalse(Path(life.env["KUBECONFIG"]).exists())
        self.assertEqual(life.env["DOCKER_CONTEXT"], "default")
        self.assertNotIn("DOCKER_HOST", life.env)
        self.assertNotIn("CLUSTER", life.env)
        self.assertNotIn("PROJECT", life.env)
        self.assertEqual(life.env["LC_TEST"], "yes")
        self.assertEqual(life.env["CLOUDSDK_CORE_PROJECT"], "demo")
        self.assertEqual(life.env["CLOUDSDK_COMPUTE_ZONE"], "zone")
        self.assertEqual(life.env["DEMO_STATE"], str(life.state))

    # Ready probes run together rather than waiting for each component in turn.
    def test_ready_probes_in_parallel(self):
        life = self.lifecycle()
        for _, adapter in life.items:
            adapter.probe = lambda: (time.sleep(0.2) or True, "healthy")
        started = time.monotonic()
        self.assertTrue(self.invoke(life, "ready")[0][0])
        self.assertLess(time.monotonic() - started, 0.35)

    # The removed command is not accepted by the CLI.
    def test_used_command_removed(self):
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            core.main(["used"])

    # Each verb timeout is valid and overrides the default.
    def test_amendment_02_verb_timeouts(self):
        for verb in ("probe", "start", "stop", "build", "remove"):
            with self.subTest(verb=verb):
                extra = f'{verb}_timeout = 0.05\n'
                command = 'sleep 1' if verb == "probe" else "true"
                self.write_manifest(f'probe = "{command}"\n' + (f'{verb} = "sleep 1"\n' if verb != "probe" else "") + extra)
                life = core.Lifecycle(self.deck, root=self.root)
                start = time.monotonic()
                result = life.items[0][1].run(verb)
                self.assertIsNone(result)
                self.assertLess(time.monotonic() - start, 0.8)
                self.write_manifest(f'probe = "true"\n{verb}_timeout = 0\n')
                with self.assertRaises(ValueError):
                    core.load_manifest(self.deck)

    # Zero wait still permits one complete probe after a verb.
    def test_amendment_03_zero_timeout_probes_once(self):
        self.write_manifest('timeout = 0\nprobe = "sleep 0.05; true"\n')
        life = core.Lifecycle(self.deck, root=self.root)
        self.assertTrue(life.wait(life.items[0]))
        fake = self.lifecycle(("a",))
        fake.items[0][0]["timeout"] = 0
        self.assertFalse(fake.wait(fake.items[0]))
        self.assertEqual(self.clock.now, 0)

    # Missing start and build verbs fail without advancing the clock.
    def test_amendment_04_missing_verb_fails_immediately(self):
        for command in ("wake", "reset"):
            with self.subTest(command=command):
                life = self.lifecycle(("a",))
                life.items[0][0].update(hint="repair it")
                for verb in ("start", "build"):
                    life.items[0][0].pop(verb)
                result, output = self.invoke(life, command)
                self.assertFalse(result[0])
                self.assertIn("repair it", output)
                self.assertEqual(self.clock.now, 0)

    # In-use absent components never cause a cold wake or removal.
    def test_amendment_05_absent_does_not_trigger_cold(self):
        life = self.lifecycle(("a", "live"), ("live",))
        Fake.states.update(a=True, live=True)
        for command in ("wake", "resume"):
            result, output = self.invoke(life, command)
            self.assertFalse(result[0])
            self.assertIn("live steps done", output)
            self.assertEqual(Fake.calls, [])
        Fake.states["a"] = False
        Fake.unresponsive.add("a")
        self.invoke(life, "wake")
        self.assertNotIn(("live", "stop"), Fake.calls)
        self.assertNotIn(("live", "remove"), Fake.calls)

    # Unknown command probes never pass for present or absent components.
    def test_amendment_06_probe_unknown(self):
        for live in (False, True):
            for command in ('exit 2', 'sleep 1'):
                with self.subTest(live=live, command=command):
                    self.write_manifest(f'live = {str(live).lower()}\nprobe = "{command}"\nprobe_timeout = 0.05\n')
                    life = core.Lifecycle(self.deck, root=self.root)
                    result, output = self.invoke(life, "ready")
                    self.assertFalse(result[0])
                    self.assertIn("cannot tell", output)
        self.write_manifest('live = true\nprobe = "exit 1"\n')
        life = core.Lifecycle(self.deck, root=self.root)
        self.assertTrue(self.invoke(life, "ready")[0][0])

    # Wake readiness does not rely on a marker.
    def test_wake_uses_probes(self):
        life = self.lifecycle(("a",))
        Fake.states["a"] = True
        self.assertTrue(self.invoke(life, "wake")[0][0])

    # Gentle and cold passes stop at their first failed component.
    def test_review_08_wake_fails_fast_and_skips(self):
        life = self.lifecycle(("a", "b", "c"))
        Fake.unresponsive.add("a")
        result, output = self.invoke(life, "wake")
        self.assertFalse(result[0])
        self.assertEqual(self.clock.now, 4)
        self.assertNotIn(("b", "start"), Fake.calls)
        self.assertNotIn(("c", "start"), Fake.calls)
        self.assertEqual(output.count("skipped"), 2)
        Fake.calls.clear()
        Fake.unresponsive.clear()
        Fake.failures.update({("a", "start"), ("b", "start")})
        Fake.states.update(a=False, b=False, c=False)
        # The first cold start succeeds; the next can fail before any probe.
        original = life.items[0][1].start
        attempts = []
        # Fail only the gentle start.
        def fail_once():
            attempts.append(1)
            if len(attempts) == 1:
                return False
            Fake.failures.discard(("a", "start"))
            return original()
        life.items[0][1].start = fail_once
        life.last_probes.clear()
        result, output = self.invoke(life, "wake")
        self.assertFalse(result[0])
        self.assertIn("b", result[1])
        self.assertIn("skipped", output)

    # Missing verbs have no progress row and are never invoked.
    def test_review_09_missing_verb_has_no_row(self):
        life = self.lifecycle(("a",))
        life.items[0][0].pop("stop")
        life.items[0][0].pop("remove")
        result, output = self.invoke(life, "down")
        self.assertNotIn("stopping", output)
        self.assertEqual(Fake.calls, [])

    # Parallel failed probes retain only their own command output.
    def test_review_10_parallel_command_logs_and_tails(self):
        (self.deck / "demo.toml").write_text('deck = "parallel"\n' + ''.join(
            f'[[component]]\nname = "{name}"\nkind = "command"\nprobe = "echo {name}; sleep 0.1; echo {name}; exit 2"\n'
            for name in ("first", "second")))
        life = core.Lifecycle(self.deck, root=self.root)
        self.invoke(life, "ready")
        for config, adapter in life.items:
            self.assertEqual(adapter.tail, [config["name"], config["name"]])
        log = (life.state / "log").read_text()
        for name in ("first", "second"):
            self.assertIn(f'== {name} probe\n{name}\n{name}\n', log)
        self.assertEqual(list(life.state.glob("command-*")), [])

    # Notification starts identify the operation and end with its summary.
    def test_review_12_notifications(self):
        self.write_manifest('probe = "false"\nstart = "true"\ntimeout = 0\n')
        for command, message in (("wake", "waking the demo"), ("resume", "waking the demo"),
                                 ("reset", "preparing the demo"), ("down", "stopping the demo"),
                                 ):
            with self.subTest(command=command), patch.dict(os.environ, {"XDG_STATE_HOME": str(self.path / "xdg")}):
                root = core.state_root()
                root.mkdir(parents=True, exist_ok=True)
                (root / "active").write_text(str(self.deck))
                with patch.object(core, "notify") as notify, contextlib.redirect_stdout(io.StringIO()):
                    core.main([command, "--deck", str(self.deck), "--notify"])
                self.assertEqual(notify.call_args_list[0].args[1], message)
                self.assertEqual(notify.call_count, 2)

    # Every operation honors has_verb even when methods exist.
    def test_review_13_core_respects_has_verb(self):
        life = self.lifecycle(("a",))
        life.items[0][0].pop("remove")
        life.items[0][0].pop("start")
        life.items[0][0].pop("stop")
        self.assertTrue(self.invoke(life, "reset")[0][0])
        self.assertEqual(Fake.calls, [("a", "build")])
        self.invoke(life, "down")
        self.assertEqual(Fake.calls, [("a", "build")])

    # A failed wake reports the component.
    def test_wake_failure_reports_component(self):
        life = self.lifecycle(("a",))
        Fake.failures.add(("a", "start"))
        result, output = self.invoke(life, "wake")
        self.assertFalse(result[0])
        self.assertIn("a", output)

    # Resume is silent and sends no notifications when already ready.
    def test_resume_quiet_when_ready(self):
        self.write_manifest('probe = "true"\n')
        with patch.dict(os.environ, {"XDG_STATE_HOME": str(self.path / "xdg")}):
            life = core.Lifecycle(self.deck)
            (life.root / "active").write_text(str(self.deck))
            out = io.StringIO()
            with patch.object(core, "notify") as notify, contextlib.redirect_stdout(out):
                self.assertEqual(core.main(["resume", "--notify"]), 0)
            self.assertEqual(out.getvalue(), "")
            notify.assert_not_called()

    # Reset restores present components and removes only known live moments.
    def test_reset_restores_and_removes_live_moment(self):
        life = self.lifecycle(("a", "live", "other"), ("live", "other"))
        Fake.states.update(a=False, live=True, other=False)
        self.assertTrue(self.invoke(life, "reset")[0][0])
        self.assertEqual(Fake.calls, [("a", "start"), ("live", "remove")])

    # List every failed part when a live step and a prepared part need attention.
    def test_ready_lists_live_and_unready_parts(self):
        life = self.lifecycle(("live", "a"), ("live",))
        Fake.states.update(live=True, a=False)
        result, output = self.invoke(life, "ready")
        self.assertFalse(result[0])
        self.assertIn("✗  not ready: live, a", output)

    # An unknown live moment stays untouched and fails the verdict.
    def test_reset_unknown_live_moment(self):
        life = self.lifecycle(("a", "live"), ("live",))
        Fake.states.update(a=True, live=None)
        result, output = self.invoke(life, "reset")
        self.assertFalse(result[0])
        self.assertIn("cannot tell", output)
        self.assertEqual(Fake.calls, [])

    # Build a missing part without stopping healthy parts.
    def test_reset_builds_missing_without_cold_restart(self):
        life = self.lifecycle(("a", "b"))
        Fake.states.update(a=True, b=False)
        Fake.failures.add(("b", "start"))
        self.assertTrue(self.invoke(life, "reset")[0][0])
        self.assertEqual(Fake.calls, [("b", "start"), ("b", "build")])

    # A stopped part can recover through the cold pass without a build.
    def test_reset_after_suspend_cold_restarts_without_building(self):
        life = self.lifecycle(("a",))
        life.items[0][0].pop("build")
        Fake.states["a"] = False
        original = life.items[0][1].start
        attempts = []

        # Fail the first start and recover during the cold pass.
        def start():
            attempts.append(1)
            if len(attempts) == 1:
                Fake.calls.append(("a", "start"))
                return False
            return original()

        life.items[0][1].start = start
        self.assertTrue(self.invoke(life, "reset")[0][0])
        self.assertEqual(Fake.calls, [("a", "start"), ("a", "stop"), ("a", "start")])

    # Rebuild only the part that cannot recover.
    def test_reset_rebuilds_only_unresponsive_part(self):
        life = self.lifecycle(("a", "b"))
        Fake.states.update(a=True, b=False)
        adapter = life.items[1][1]
        builds = []
        # Succeed after the cold pass requests a rebuild.
        def build():
            Fake.calls.append(("b", "build"))
            builds.append(1)
            if len(builds) >= 3:
                Fake.states["b"] = True
            return True
        adapter.build = build
        adapter.start = lambda: (Fake.calls.append(("b", "start")) or False)
        result, output = self.invoke(life, "reset")
        self.assertTrue(result[0], output)
        self.assertIn("rebuilding b", output)
        self.assertIn(("b", "remove"), Fake.calls)
        self.assertNotIn(("a", "remove"), Fake.calls)
        self.assertNotIn(("a", "build"), Fake.calls)

    # Keep resume to start and stop verbs.
    def test_resume_cold_restart_never_builds_or_undoes_live(self):
        life = self.lifecycle(("a", "live"), ("live",))
        Fake.states.update(a=False, live=True)
        adapter = life.items[0][1]
        original = adapter.start
        attempts = []
        # Fail the first start and recover during the cold pass.
        def start():
            attempts.append(1)
            if len(attempts) == 1:
                Fake.calls.append(("a", "start"))
                return False
            return original()
        adapter.start = start
        self.invoke(life, "resume")
        self.assertIn(("a", "stop"), Fake.calls)
        self.assertEqual(attempts, [1, 1])
        self.assertFalse(any(verb in ("build", "remove") for _, verb in Fake.calls))

    # Continue teardown after an unknown live step fails.
    def test_down_continues_after_failure_and_removes_unknown_live(self):
        life = self.lifecycle(("a", "live", "uncertain"), ("live", "uncertain"))
        Fake.states.update(a=True, live=True, uncertain=None)
        Fake.failures.add(("uncertain", "remove"))
        result, output = self.invoke(life, "down")
        self.assertFalse(result[0], output)
        self.assertEqual(Fake.calls, [("uncertain", "remove"), ("live", "remove"), ("a", "remove")])

    # A part with nothing to stop or remove is kept, not a failed teardown.
    def test_down_keeps_parts_without_stop_or_remove(self):
        life = core.Lifecycle(self.deck, {"fake": Fake}, self.clock.clock, self.clock.sleep, self.root,
                              {"deck": "test", "component": [
                                  {"name": "kept", "kind": "fake", "timeout": 2},
                                  {"name": "a", "kind": "fake", "timeout": 2, "remove": "yes"}]})
        Fake.states.update(kept=True, a=True)
        result, output = self.invoke(life, "down")
        self.assertTrue(result[0], output)
        self.assertIn("kept", output.splitlines()[-2])
        self.assertNotIn("unavailable", output)
        self.assertEqual(Fake.calls, [("a", "remove")])

    # Reject the old manifest field and reset modes.
    def test_old_prepared_and_fresh_are_rejected(self):
        self.write_manifest('prepared = "absent"\nprobe = "false"\n')
        with self.assertRaisesRegex(ValueError, "prepared.*live = true"):
            core.load_manifest(self.deck)
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            core.main(["reset", "--fresh"])
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            core.main(["reset", "fresh"])

    # Wait for the deck lock while rejecting a second waiter.
    def test_resume_waits_for_lock_and_second_waiter_exits(self):
        self.write_manifest('probe = "test -f flag"\nstart = "touch flag"\ntimeout = 0\n')
        env = {**os.environ, "XDG_STATE_HOME": str(self.path / "xdg")}
        with patch.dict(os.environ, env):
            life = core.Lifecycle(self.deck)
        (life.root / "active").write_text(str(self.deck))
        demo = Path(core.__file__).parent / "demo"
        with (life.state / "lock").open("a+") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            first = subprocess.Popen([str(demo), "resume"], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            self.addCleanup(lambda: first.poll() is None and first.kill())
            waiter_path = life.state / "resume-waiter"
            deadline = time.monotonic() + 3
            while not waiter_path.exists():
                self.assertLess(time.monotonic(), deadline)
                time.sleep(0.02)
            second = subprocess.run([str(demo), "resume"], env=env, capture_output=True, text=True, timeout=3)
            self.assertEqual(second.returncode, 0, second.stderr)
            self.assertEqual(second.stdout, "")
            self.assertIsNone(first.poll())
            fcntl.flock(lock, fcntl.LOCK_UN)
            output, error = first.communicate(timeout=5)
        self.assertEqual(first.returncode, 0, output + error)
        self.assertTrue((self.deck / "flag").exists())

    # Stop both decks with the active deck first.
    def test_sleep_stops_two_registered_decks_and_keeps_active(self):
        env = {"XDG_STATE_HOME": str(self.path / "xdg")}
        with patch.dict(os.environ, env):
            lives = []
            for name in ("first", "second"):
                deck = self.path / name
                deck.mkdir()
                (deck / "flag").touch()
                (deck / "demo.toml").write_text(f'deck = "{name}"\n[[component]]\nname = "a"\nkind = "command"\nprobe = "test -f flag"\nstop = "rm -f flag"\n')
                lives.append(core.Lifecycle(deck))
            active = lives[0].root / "active"
            active.write_text(str(lives[1].deck))
            order = self.path / "sleep-order"
            for life in lives:
                manifest = life.deck / "demo.toml"
                manifest.write_text(manifest.read_text().replace('stop = "rm -f flag"', f'stop = "echo {life.deck.name} >> {order}; rm -f flag"'))
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(core.main(["sleep"]), 0)
            self.assertEqual(active.read_text(), str(lives[1].deck))
            self.assertEqual(order.read_text().splitlines(), ["second", "first"])
            for life in lives:
                self.assertFalse((life.deck / "flag").exists())

    # Rebuild after an input or tool version changes.
    def test_changed_input_or_tool_rebuilds_only_affected_part(self):
        source = self.deck / "input"
        source.write_text("one")
        binary = self.deck / "tool"
        binary.write_text('#!/bin/sh\necho v1\n')
        binary.chmod(0o755)
        self.write_manifest(f'probe = "test -f flag"\nbuild = "echo build >> calls; touch flag"\nremove = "rm -f flag"\ninputs = ["input"]\ntools = ["{binary}"]\n')
        life = core.Lifecycle(self.deck, root=self.root)
        self.assertTrue(self.invoke(life, "reset")[0][0])
        fingerprint = json.loads((life.state / "built" / "shell").read_text())
        self.assertEqual(fingerprint["inputs"], {"input": hashlib.sha256(b"one").hexdigest()})
        self.assertIn("v1", fingerprint["tools"][str(binary)]["stdout"])
        self.assertTrue(self.invoke(life, "reset")[0][0])
        self.assertEqual((self.deck / "calls").read_text().splitlines(), ["build"])
        source.write_text("two")
        result, output = self.invoke(life, "reset")
        self.assertTrue(result[0], output)
        self.assertIn("rebuilding shell: input changed", output)
        binary.write_text('#!/bin/sh\necho v2\n')
        result, output = self.invoke(life, "reset")
        self.assertTrue(result[0], output)
        self.assertIn(f"rebuilding shell: {binary} changed", output)
        self.assertEqual((self.deck / "calls").read_text().splitlines(), ["build"] * 3)

    # A failed rebuild cannot report the stale part as ready.
    def test_changed_input_rebuild_failure_is_not_ready(self):
        (self.deck / "input").write_text("old")
        (self.deck / "flag").touch()
        self.write_manifest('probe = "test -f flag"\nstart = "true"\nbuild = "true"\nremove = "false"\ninputs = ["input"]\n')
        life = core.Lifecycle(self.deck, root=self.root)
        self.assertTrue(self.invoke(life, "reset")[0][0])
        (self.deck / "input").write_text("new")
        result, output = self.invoke(life, "reset")
        self.assertFalse(result[0])
        self.assertIn("rebuild failed", output)

    # A prepared part without a fingerprint records its first values.
    def test_first_fingerprint_only_records(self):
        (self.deck / "input").write_text("current")
        (self.deck / "flag").touch()
        self.write_manifest('probe = "test -f flag"\nbuild = "echo build >> calls"\nremove = "rm -f flag"\ninputs = ["input"]\n')
        life = core.Lifecycle(self.deck, root=self.root)
        self.assertTrue(self.invoke(life, "reset")[0][0])
        self.assertTrue((life.state / "built" / "shell").exists())
        self.assertFalse((self.deck / "calls").exists())
        self.assertTrue((self.deck / "flag").exists())

    # Reject input paths that escape the deck.
    def test_input_paths_must_remain_within_deck(self):
        outside = self.path / "outside"
        outside.write_text("secret")
        (self.deck / "link").symlink_to(outside)
        for name in (str(outside), "../outside", "link"):
            with self.subTest(name=name):
                self.write_manifest(f'probe = "true"\ninputs = [{json.dumps(name)}]\n')
                with self.assertRaisesRegex(ValueError, "input"):
                    core.load_manifest(self.deck)
        self.write_manifest('probe = "true"\ninputs = ["nested/input"]\n')
        self.assertEqual(core.load_manifest(self.deck)["component"][0]["inputs"], ["nested/input"])

    # Each deck runs its own Platform, so another deck's running cluster is not reported.
    def test_reset_ignores_another_decks_cluster(self):
        life = self.lifecycle(("a",))
        Fake.states["a"] = True
        result = subprocess.CompletedProcess([], 0, "vcluster.cp.other\n", "")
        with patch.object(core.subprocess, "run", return_value=result):
            success, output = self.invoke(life, "reset")
        self.assertTrue(success[0], output)
        self.assertNotIn("another deck", output)
        self.assertEqual(Fake.calls, [])

    # The executable accepts all built-in kinds in one manifest.
    def test_registry_wiring_through_ready_cli(self):
        (self.deck / "demo.toml").write_text(
            'deck = "registry"\nplatform = "https://localhost"\nclusters = ["demo"]\n'
            '[[component]]\nname = "cmd"\nkind = "command"\nprobe = "true"\n'
            '[[component]]\nname = "proc"\nkind = "process"\nrun = "true"\nprobe = "true"\n'
            '[[component]]\nname = "host"\nkind = "docker-host"\ncluster = "demo"\nprobe = "true"\n'
            '[[component]]\nname = "platform"\nkind = "platform"\nprobe = "true"\n'
            '[[component]]\nname = "instance"\nkind = "vcluster-instance"\nproject = "p"\ninstance = "i"\nprobe = "true"\n'
            '[[component]]\nname = "stack"\nkind = "stack"\nproject = "p"\ninstance = "i"\nprobe = "true"\n')
        state = self.path / "xdg" / "demo" / "registry"
        state.mkdir(parents=True)
        home = self.path / "home"
        (home / ".vcluster").mkdir(parents=True)
        (home / ".vcluster/config.json").write_text('{"platform": {"host": "https://localhost"}}')
        binary = self.path / "bin"
        binary.mkdir()
        docker = binary / "docker"
        docker.write_text('#!/bin/sh\ncase "$1" in ps) echo vcluster.cp.demo;; port) echo 127.0.0.1:6443;; '
                          'inspect) echo \'{"8443/tcp":[{"HostIp":"","HostPort":"6443"}]}\';; esac\n')
        docker.chmod(0o755)
        kubectl = binary / "kubectl"
        kubectl.write_text('#!/bin/sh\necho https://127.0.0.1:6443\n')
        kubectl.chmod(0o755)
        demo = Path(core.__file__).parent / "demo"
        result = subprocess.run([str(demo), "ready", "--deck", str(self.deck)],
                                env={**os.environ, "HOME": str(home), "PATH": str(binary) + os.pathsep + os.environ["PATH"], "XDG_STATE_HOME": str(self.path / "xdg")},
                                text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        self.assertIn("all set for the demo", result.stdout)

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
