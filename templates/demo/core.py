"""Load demo manifests and run their lifecycle with pluggable components."""

import argparse
import concurrent.futures
import fcntl
import math
import os
from pathlib import Path
import subprocess
import sys
import time
import tomllib

from adapters import REGISTRY

VERBS = {"probe", "start", "stop", "build", "remove"}
COMMON = {"name", "kind", "prepared", "timeout", "hint"} | VERBS


# Validate strings used as labels and command fields.
def _string(value, key, where, limit=None):
    if (not isinstance(value, str) or not value.strip() or "\n" in value
            or "\r" in value or (limit and len(value) > limit)):
        raise ValueError(f"{where}: invalid {key}")


# Load and validate the entire manifest before making any changes.
def load_manifest(deck, registry=None):
    registry = REGISTRY if registry is None else registry
    with (Path(deck) / "demo.toml").open("rb") as source:
        data = tomllib.load(source)
    unknown = set(data) - {"deck", "kubeconfig", "clusters", "env", "component"}
    if unknown:
        raise ValueError(f"manifest: unknown key {sorted(unknown)[0]}")
    _string(data.get("deck"), "deck", "manifest")
    if data["deck"] in {".", ".."} or "/" in data["deck"] or "\\" in data["deck"]:
        raise ValueError("manifest: invalid deck")
    if "kubeconfig" in data:
        _string(data["kubeconfig"], "kubeconfig", "manifest")
    clusters = data.get("clusters", [])
    if not isinstance(clusters, list) or any(not isinstance(c, str) or not c for c in clusters):
        raise ValueError("manifest: invalid clusters")
    env = data.get("env", {})
    if (not isinstance(env, dict) or any(not isinstance(k, str) or not k or "=" in k
            or "\x00" in k or not isinstance(v, str) or "\x00" in v
            for k, v in env.items())):
        raise ValueError("manifest: invalid env")
    components = data.get("component")
    if not isinstance(components, list) or not components:
        raise ValueError("manifest: missing component")
    names = set()
    for item in components:
        if not isinstance(item, dict):
            raise ValueError("component: invalid entry")
        name = item.get("name")
        _string(name, "name", "component", 16)
        where = f"component {name}"
        if name in names:
            raise ValueError(f"{where}: duplicate name")
        names.add(name)
        kind = item.get("kind")
        if not isinstance(kind, str) or kind not in registry:
            raise ValueError(f"{where}: unknown kind {kind}")
        adapter = registry[kind]
        allowed = COMMON | set(getattr(adapter, "fields", ()))
        unknown = set(item) - allowed
        if unknown:
            raise ValueError(f"{where}: unknown key {sorted(unknown)[0]}")
        if item.get("prepared", "present") not in ("present", "absent"):
            raise ValueError(f"{where}: invalid prepared")
        timeout = item.get("timeout", 180)
        if isinstance(timeout, bool) or not isinstance(timeout, (int, float)) or not math.isfinite(timeout) or timeout <= 0:
            raise ValueError(f"{where}: invalid timeout")
        for key in VERBS:
            if key in item and (not isinstance(item[key], str) or not item[key].strip() or "\x00" in item[key]):
                raise ValueError(f"{where}: invalid {key}")
        if "hint" in item:
            _string(item["hint"], "hint", where)
        if kind == "command" and "probe" not in item:
            raise ValueError(f"{where}: missing probe")
        if kind == "docker-host" and item.get("cluster") not in clusters:
            raise ValueError(f"{where}: cluster outside clusters")
        validator = getattr(adapter, "validate", None)
        if validator:
            validator(item, data)
    return data


# Return the state root, respecting the XDG state directory.
def state_root(root=None):
    return Path(root) if root is not None else Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state") / "demo"


# Render a single bounded row with optional hint and command failure output.
def row(mark, label, detail, hint=None, tail=()):
    colors = {"✓": "32", "✗": "31", "↻": "33"}
    detail = " ".join(str(detail).split())
    text = detail[:61]
    print(f"  \033[{colors[mark]}m{mark}\033[0m  \033[36m{label:<16}\033[0m  {text}")
    if mark == "✗":
        for line in ([hint] if hint else []) + list(tail)[-3:]:
            print(f"    \033[90m{' '.join(str(line).split())[:80]}\033[0m")


class Lifecycle:
    """Run commands for a validated deck using injected time and adapters."""

    # Build adapters and prepare the private per-deck state directory.
    def __init__(self, deck, registry=None, clock=time.monotonic, sleep=time.sleep,
                 root=None, manifest=None):
        self.deck = Path(deck).resolve()
        self.registry = REGISTRY if registry is None else registry
        self.manifest = manifest if manifest is not None else load_manifest(self.deck, self.registry)
        self.root = state_root(root)
        self.state = self.root / self.manifest["deck"]
        self.state.mkdir(parents=True, mode=0o700, exist_ok=True)
        self.state.chmod(0o700)
        self.clock = clock
        self.sleep = sleep
        env = os.environ.copy()
        env.update(self.manifest.get("env", {}))
        if self.manifest.get("kubeconfig"):
            env["KUBECONFIG"] = os.path.expanduser(self.manifest["kubeconfig"])
        env["DEMO_STATE"] = str(self.state)
        self.items = [(config, self.registry[config["kind"]](config, self.deck, self.state, env))
                      for config in self.manifest["component"]]

    # Check a component against its desired prepared state.
    def probe(self, item):
        config, adapter = item
        ok, detail = adapter.probe()
        if config.get("prepared", "present") == "absent":
            return not ok, "absent" if not ok else "should be absent"
        return ok, detail

    # Probe concurrently while retaining manifest order in the results.
    def probes(self):
        with concurrent.futures.ThreadPoolExecutor(max_workers=len(self.items)) as pool:
            return list(pool.map(self.probe, self.items))

    # Print results and report the current readiness summary.
    def report(self, results=None):
        results = self.probes() if results is None else results
        failed = []
        for (config, adapter), (ok, detail) in zip(self.items, results):
            row("✓" if ok else "✗", config["name"], detail,
                config.get("hint") if not ok else None,
                getattr(adapter, "tail", []) if not ok else ())
            if not ok:
                failed.append(config["name"])
        if failed:
            summary = "✗  not ready: " + ", ".join(failed)
        elif not (self.state / "set").exists():
            summary = "✗  used since the last reset: run just reset"
        else:
            summary = "✓  all set for the demo"
        print(summary)
        return not failed and (self.state / "set").exists(), summary

    # Invoke a verb and print progress before it starts.
    def verb(self, item, verb):
        config, adapter = item
        row("↻", config["name"], {"start": "starting", "stop": "stopping",
                                 "build": "building", "remove": "removing"}[verb])
        return getattr(adapter, verb)() is not False

    # Wait for a component to reach its desired state within its timeout.
    def wait(self, item):
        deadline = self.clock() + item[0].get("timeout", 180)
        while True:
            adapter = item[1]
            previous = getattr(adapter, "deadline", None)
            if hasattr(adapter, "deadline"):
                remaining = max(0, deadline - self.clock())
                adapter.deadline = time.monotonic() + remaining
                if previous is not None:
                    adapter.deadline = min(previous, adapter.deadline)
            try:
                result = self.probe(item)
            finally:
                if hasattr(adapter, "deadline"):
                    adapter.deadline = previous
            if result[0] or self.clock() >= deadline:
                return result[0]
            self.sleep(min(1, max(0, deadline - self.clock())))

    # Record the deck as active and mark it set only when all probes pass.
    def finish(self):
        results = self.probes()
        if all(ok for ok, _ in results):
            (self.state / "set").touch()
        else:
            (self.state / "set").unlink(missing_ok=True)
        return self.report(results)

    # Wake gently, then stop and start in dependency order if needed.
    def wake(self, allow_remove=True):
        (self.state / "set").unlink(missing_ok=True)
        (self.root / "active").write_text(str(self.deck))
        failed = False
        for item in self.items:
            if self.probe(item)[0]:
                continue
            if item[0].get("prepared", "present") == "absent":
                ok = allow_remove and self.verb(item, "remove") and self.wait(item)
            else:
                ok = self.verb(item, "start") and self.wait(item)
            failed = failed or not ok
        if failed:
            for item in reversed(self.items):
                self.verb(item, "stop")
            for item in self.items:
                if item[0].get("prepared", "present") == "absent":
                    continue
                self.verb(item, "start")
                self.wait(item)
        return self.finish()

    # Rebuild in reverse removal order and forward dependency order.
    def reset(self, fresh=False):
        (self.root / "active").write_text(str(self.deck))
        marker = self.state / "set"
        if marker.exists() and not fresh:
            results = self.probes()
            if all(ok for ok, _ in results):
                print("already set, nothing to do")
                return True, "already set, nothing to do"
            ok, summary = self.wake()
            if ok:
                return ok, summary
        marker.unlink(missing_ok=True)
        for item in self.items:
            if item[0].get("prepared", "present") == "present":
                self.verb(item, "start")
        for item in reversed(self.items):
            config, adapter = item
            has_remove = getattr(adapter, "has_verb", lambda verb: True)("remove")
            absent = config.get("prepared", "present") == "absent"
            if has_remove and (not absent or not self.probe(item)[0]):
                if not self.verb(item, "remove"):
                    row("✗", config["name"], "remove failed", config.get("hint"),
                        getattr(adapter, "tail", []))
                    summary = f"✗  not ready: {config['name']}"
                    print(summary)
                    return False, summary
        for index, item in enumerate(self.items):
            if self.probe(item)[0]:
                continue
            config, adapter = item
            if config.get("prepared", "present") == "absent":
                success = False
            else:
                has_build = getattr(adapter, "has_verb", lambda verb: True)("build")
                success = self.verb(item, "build" if has_build else "start") and self.wait(item)
            if not success:
                row("✗", config["name"], "not ready", config.get("hint"), getattr(adapter, "tail", []))
                for later, _ in self.items[index + 1:]:
                    row("✗", later["name"], "skipped")
                summary = f"✗  not ready: {config['name']}"
                print(summary)
                return False, summary
        return self.finish()

    # Stop in reverse order, optionally retaining the active deck.
    def down(self, keep_active=False, deadline=None):
        success = True
        for item in reversed(self.items):
            if deadline is not None and time.monotonic() >= deadline:
                success = False
                break
            if hasattr(item[1], "deadline"):
                item[1].deadline = deadline
            success = self.verb(item, "stop") and success
        active = self.root / "active"
        if not keep_active and active.exists() and active.read_text() == str(self.deck):
            active.unlink(missing_ok=True)
        summary = "stopped" if success else "not ready: stop failed"
        print(summary)
        return success, summary

    # Hold a non-inheritable, nonblocking deck lock while a command runs.
    def execute(self, command, fresh=False):
        if command == "ready":
            return self.report()
        with (self.state / "lock").open("a+") as lock:
            os.set_inheritable(lock.fileno(), False)
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                if command == "sleep":
                    return True, ""
                lock.seek(0)
                message = f"a reset is already running (pid {lock.read().strip() or '?'})"
                print(message)
                return False, message
            lock.seek(0)
            lock.truncate()
            lock.write(str(os.getpid()))
            lock.flush()
            try:
                if command == "reset":
                    result = self.reset(fresh)
                elif command in ("wake", "resume"):
                    result = self.wake(allow_remove=command != "resume")
                    if command == "resume" and not result[0]:
                        failed = [item[0]["name"] for item, value in zip(self.items, self.probes()) if not value[0]]
                        result = False, f"not ready: {', '.join(failed)}: run just reset"
                        print(result[1])
                elif command in ("down", "sleep"):
                    result = self.down(command == "sleep", time.monotonic() + 60 if command == "sleep" else None)
                else:
                    (self.state / "set").unlink(missing_ok=True)
                    print("marked used")
                    result = True, "marked used"
                if command in ("reset", "wake", "down"):
                    presentation = self.deck / "presentation.md"
                    if presentation.exists():
                        presentation.touch()
                return result
            finally:
                fcntl.flock(lock, fcntl.LOCK_UN)


# Send an optional desktop notification without requiring notify-send.
def notify(deck, message):
    try:
        subprocess.run(["notify-send", deck, message], stdin=subprocess.DEVNULL,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5,
                       check=False, close_fds=True)
    except (OSError, subprocess.TimeoutExpired):
        pass


# Parse the CLI, select the active deck for suspend hooks, and run a command.
def main(argv=None):
    parser = argparse.ArgumentParser(description="Prepare and check a deck's demo")
    parser.add_argument("command", choices=["ready", "wake", "reset", "down", "sleep", "resume", "used"])
    parser.add_argument("--deck", default=".")
    parser.add_argument("--notify", action="store_true")
    parser.add_argument("--fresh", action="store_true")
    args = parser.parse_args(argv)
    if args.fresh and args.command != "reset":
        parser.error("--fresh is only valid with reset")
    try:
        deck = Path(args.deck)
        if args.command in ("sleep", "resume"):
            active = state_root() / "active"
            if not active.exists():
                return 0
            deck = Path(active.read_text())
        lifecycle = Lifecycle(deck)
        if args.notify:
            notify(lifecycle.manifest["deck"], f"{args.command} starting")
        ok, summary = lifecycle.execute(args.command, args.fresh)
        if args.notify and summary:
            notify(lifecycle.manifest["deck"], summary)
        return 0 if ok else 1
    except (OSError, ValueError, tomllib.TOMLDecodeError) as exc:
        print(f"demo: {exc}", file=sys.stderr)
        return 1
