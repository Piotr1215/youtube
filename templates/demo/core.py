"""Load demo manifests and run their lifecycle with pluggable components."""

import argparse
import concurrent.futures
import fcntl
import hashlib
import math
import ipaddress
import json
import re
import os
from pathlib import Path
import subprocess
import sys
import time
import tomllib
from urllib.parse import urlsplit

from adapters import REGISTRY as COMMAND_REGISTRY
from kinds import KINDS

REGISTRY = {**COMMAND_REGISTRY, **KINDS}

VERBS = {"probe", "start", "stop", "build", "remove"}
COMMON = {"name", "kind", "live", "inputs", "tools", "timeout", "hint"} | VERBS | {f"{verb}_timeout" for verb in VERBS}


# Validate strings used as labels and command fields.
def _string(value, key, where, limit=None):
    if (not isinstance(value, str) or not value.strip() or "\n" in value
            or "\r" in value or "\x00" in value or (limit and len(value) > limit)):
        raise ValueError(f"{where}: invalid {key}")


# Load and validate the entire manifest before making any changes.
def load_manifest(deck, registry=None):
    registry = REGISTRY if registry is None else registry
    with (Path(deck) / "demo.toml").open("rb") as source:
        data = tomllib.load(source)
    unknown = set(data) - {"deck", "kubeconfig", "clusters", "env", "component", "platform", "gcp_project", "gcp_zone"}
    if unknown:
        raise ValueError(f"manifest: unknown key {sorted(unknown)[0]}")
    _string(data.get("deck"), "deck", "manifest")
    if data["deck"] in {".", ".."} or "/" in data["deck"] or "\\" in data["deck"]:
        raise ValueError("manifest: invalid deck")
    if "kubeconfig" in data:
        _string(data["kubeconfig"], "kubeconfig", "manifest")
    for key in ("platform", "gcp_project", "gcp_zone"):
        if key in data:
            _string(data[key], key, "manifest")
    if "platform" in data:
        try:
            url = urlsplit(data["platform"])
            if url.scheme != "https" or not url.hostname or url.username or url.password:
                raise ValueError
            _ = url.port
        except ValueError:
            raise ValueError("manifest: invalid platform") from None
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
        if name in (".", "..") or "/" in name or "\\" in name:
            raise ValueError("component: invalid name")
        where = f"component {name}"
        if name in names:
            raise ValueError(f"{where}: duplicate name")
        names.add(name)
        kind = item.get("kind")
        if not isinstance(kind, str) or kind not in registry:
            raise ValueError(f"{where}: unknown kind {kind}")
        if kind in ("vcluster-instance", "stack") and not data.get("platform"):
            raise ValueError(f"{where}: missing platform")
        adapter = registry[kind]
        allowed = COMMON | set(getattr(adapter, "fields", ()))
        unknown = set(item) - allowed
        if "prepared" in unknown:
            raise ValueError(f"{where}: prepared is no longer supported; use live = true")
        if unknown:
            raise ValueError(f"{where}: unknown key {sorted(unknown)[0]}")
        if "live" in item and not isinstance(item["live"], bool):
            raise ValueError(f"{where}: invalid live")
        for key in ("inputs", "tools"):
            if key in item and (not isinstance(item[key], list) or any(not isinstance(x, str) or not x or "\x00" in x for x in item[key])):
                raise ValueError(f"{where}: invalid {key}")
        for name in item.get("inputs", []):
            path = Path(name)
            if path.is_absolute() or ".." in path.parts:
                raise ValueError(f"{where}: invalid inputs")
            if not (Path(deck).resolve() / path).resolve().is_relative_to(Path(deck).resolve()):
                raise ValueError(f"{where}: input outside deck")
        timeout = item.get("timeout", 180)
        if isinstance(timeout, bool) or not isinstance(timeout, (int, float)) or not math.isfinite(timeout) or timeout < 0:
            raise ValueError(f"{where}: invalid timeout")
        for key in (f"{verb}_timeout" for verb in VERBS):
            if key in item:
                value = item[key]
                if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value) or value <= 0:
                    raise ValueError(f"{where}: invalid {key}")
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
    text = detail if label == "scope" or detail.startswith("rebuilding ") else detail[:61]
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
        (self.state / "deck").write_text(str(self.deck))
        self.clock = clock
        self.sleep = sleep
        self.last_probes = {}
        allowed = {"PATH", "HOME", "USER", "LOGNAME", "SHELL", "LANG", "TERM", "TZ", "TMPDIR", "DBUS_SESSION_BUS_ADDRESS", "DISPLAY", "WAYLAND_DISPLAY", "SSH_AUTH_SOCK"}
        env = {key: value for key, value in os.environ.items()
               if key in allowed or key.startswith(("LC_", "XDG_"))}
        env.update(self.manifest.get("env", {}))
        kubeconfig = Path(os.path.expanduser(self.manifest.get("kubeconfig", str(self.state / "no-kubeconfig"))))
        self.kubeconfig = kubeconfig if kubeconfig.is_absolute() else self.deck / kubeconfig
        if "kubeconfig" not in self.manifest and self.kubeconfig.exists():
            raise ValueError("manifest: no-kubeconfig path exists")
        env["KUBECONFIG"] = str(self.kubeconfig)
        env["DOCKER_CONTEXT"] = "default"
        env.pop("DOCKER_HOST", None)
        for key, target in (("gcp_project", "CLOUDSDK_CORE_PROJECT"), ("gcp_zone", "CLOUDSDK_COMPUTE_ZONE")):
            if key in self.manifest:
                env[target] = self.manifest[key]
        env["DEMO_STATE"] = str(self.state)
        self.env = env
        self.items = [(config, self.registry[config["kind"]](config, self.deck, self.state, env))
                      for config in self.manifest["component"]]

    # Check declared kube servers and the current Platform login.
    def scope(self):
        platform = self.manifest.get("platform")
        platform_host = urlsplit(platform).hostname if platform else None
        hosts = []
        errors = []
        if "kubeconfig" in self.manifest:
            try:
                if self.kubeconfig.exists():
                    for line in self.kubeconfig.read_text().splitlines():
                        content = line.split("#", 1)[0]
                        for key in re.finditer(r"(?<![\w-])['\"]?server['\"]?\s*:", content):
                            value = re.match(r"\s*['\"]?([^\s'\",}]+)", content[key.end():])
                            if not value:
                                errors.append("invalid kube server")
                                continue
                            try:
                                host = urlsplit(value.group(1)).hostname
                                if not host:
                                    raise ValueError
                                hosts.append(host)
                                try:
                                    loopback = ipaddress.ip_address(host).is_loopback
                                except ValueError:
                                    loopback = host.lower() == "localhost"
                                if not loopback and host != platform_host:
                                    errors.append(f"kube server {host}")
                            except ValueError:
                                errors.append(f"invalid kube server {value.group(1)}")
            except (OSError, UnicodeError) as exc:
                errors.append(f"kubeconfig {exc}")
        if platform:
            try:
                login = json.loads((Path(self.env.get("HOME", "")) / ".vcluster/config.json").read_text())
                current = login.get("platform", {}).get("host")
            except (OSError, ValueError, TypeError, AttributeError):
                current = None
            if current != platform:
                errors.append(f"platform login {current or 'missing'} != {platform}")
        detail = f"{', '.join(hosts) or 'none'}, platform {platform_host or 'none'}, gcp {self.manifest.get('gcp_project', 'none')}"
        return not errors, "; ".join(errors) if errors else detail

    # Check a component against its desired prepared state.
    def probe(self, item):
        config, adapter = item
        state, detail = adapter.probe()
        if state is None:
            result = False, f"cannot tell: {detail}"
        elif config.get("live", False):
            result = state is False, "absent" if state is False else "in use"
        else:
            result = state is True, detail
        self.last_probes[config["name"]] = result
        return result

    # Probe concurrently while retaining manifest order in the results.
    def probes(self):
        with concurrent.futures.ThreadPoolExecutor(max_workers=len(self.items)) as pool:
            return list(pool.map(self.probe, self.items))

    # Print results and report the current readiness summary.
    def report(self, results=None):
        results = self.probes() if results is None else results
        failed = []
        live = []
        for (config, adapter), (ok, detail) in zip(self.items, results):
            row("✓" if ok else "✗", config["name"], detail,
                config.get("hint") if not ok else None,
                getattr(adapter, "tail", []) if not ok else ())
            if not ok:
                if config.get("live") and detail == "in use":
                    live.append(config["name"])
                else:
                    failed.append(config["name"])
        if failed:
            names = [config["name"] for (config, _), (ok, _) in zip(self.items, results) if not ok]
            summary = "✗  not ready: " + ", ".join(names)
        elif live:
            summary = "✗  live steps done: " + ", ".join(live) + "; run just reset for a fresh run"
        else:
            summary = "✓  all set for the demo"
        print(summary)
        return not failed and not live, summary

    # Invoke a verb and print progress before it starts.
    def verb(self, item, verb):
        config, adapter = item
        if not adapter.has_verb(verb):
            return False
        row("↻", config["name"], {"start": "starting", "stop": "stopping",
                                 "build": "building", "remove": "removing"}[verb])
        return getattr(adapter, verb)() is not False

    # Wait for a component to reach its desired state within its timeout.
    def wait(self, item):
        deadline = self.clock() + item[0].get("timeout", 180)
        while True:
            adapter = item[1]
            previous = getattr(adapter, "deadline", None)
            if hasattr(adapter, "deadline") and item[0].get("timeout", 180) > 0:
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

    # Report the final probe verdict.
    def finish(self):
        return self.report()

    # Report a failed component and skip all following components.
    def failure(self, index, detail):
        config, adapter = self.items[index]
        row("✗", config["name"], detail, config.get("hint"), getattr(adapter, "tail", []))
        for later, _ in self.items[index + 1:]:
            row("✗", later["name"], "skipped")
        summary = f"✗  not ready: {config['name']}"
        print(summary)
        return False, summary

    # Hash declared files and tool versions independently for useful change reports.
    def fingerprint(self, item):
        config, _ = item
        values = {"inputs": {}, "tools": {}}
        for name in config.get("inputs", []):
            path = (self.deck / name).resolve()
            if not path.is_relative_to(self.deck):
                raise ValueError(f"{config['name']}: input {name} outside deck")
            try:
                values["inputs"][name] = hashlib.sha256(path.read_bytes()).hexdigest()
            except OSError as exc:
                raise ValueError(f"{config['name']}: input {name}: {exc}") from exc
        for tool in config.get("tools", []):
            try:
                result = subprocess.run([tool, "--version"], cwd=self.deck, env=self.env,
                                        stdin=subprocess.DEVNULL, capture_output=True, timeout=10, check=True)
            except (OSError, subprocess.SubprocessError) as exc:
                raise ValueError(f"{config['name']}: tool {tool}: {exc}") from exc
            values["tools"][tool] = {"stdout": result.stdout.decode("utf-8", errors="replace"),
                                      "stderr": result.stderr.decode("utf-8", errors="replace")}
        return values

    # Component names are validated as a single filename at manifest load.
    def fingerprint_path(self, item):
        name = item[0]["name"]
        if name in (".", "..") or "/" in name or "\\" in name:
            raise ValueError("component: invalid name")
        return self.state / "built" / name

    # Save the inputs only after the build reaches a healthy state.
    def build(self, item):
        if not self.verb(item, "build") or not self.wait(item):
            return False
        if item[0].get("inputs") or item[0].get("tools"):
            path = self.fingerprint_path(item)
            path.parent.mkdir(exist_ok=True, mode=0o700)
            path.write_text(json.dumps(self.fingerprint(item), sort_keys=True))
        return True

    # Establish a baseline for older decks, then identify the first changed input.
    def changed(self, item):
        if not (item[0].get("inputs") or item[0].get("tools")):
            return None
        current = self.fingerprint(item)
        path = self.fingerprint_path(item)
        if not path.exists():
            path.parent.mkdir(exist_ok=True, mode=0o700)
            path.write_text(json.dumps(current, sort_keys=True))
            return None
        try:
            previous = json.loads(path.read_text())
        except (OSError, ValueError):
            return "fingerprint"
        if not isinstance(previous, dict):
            return "fingerprint"
        for category in ("inputs", "tools"):
            old = previous.get(category, {})
            if not isinstance(old, dict):
                return "fingerprint"
            for name in sorted(set(current[category]) | set(old)):
                if current[category].get(name) != old.get(name):
                    return name
        return None

    # Wake in dependency order, with build and repair reserved for reset.
    def wake_present(self, allow_build=False):
        (self.root / "active").write_text(str(self.deck))
        for item in self.items:
            if item[0].get("live"):
                continue
            changed = self.changed(item) if allow_build else None
            if changed:
                row("↻", item[0]["name"], f"rebuilding {item[0]['name']}: {changed} changed")
                if not item[1].has_verb("remove") or not self.verb(item, "remove") or not self.build(item):
                    return self.failure(self.items.index(item), "rebuild failed")
                continue
            if self.probe(item)[0]:
                continue
            if getattr(item[1], "scope_refused", False):
                return self.failure(self.items.index(item), self.last_probes[item[0]["name"]][1])
            if item[1].has_verb("start") and self.verb(item, "start") and self.wait(item):
                continue
            if allow_build and item[1].has_verb("build") and self.build(item):
                continue
            break
        else:
            return True, ""
        for item in reversed(self.items):
            if not item[0].get("live") and item[1].has_verb("stop"):
                self.verb(item, "stop")
        for index, item in enumerate(self.items):
            if item[0].get("live"):
                continue
            if item[1].has_verb("start") and self.verb(item, "start") and self.wait(item):
                continue
            if getattr(item[1], "scope_refused", False):
                return self.failure(index, item[1].tail[-1])
            if self.probe(item)[0]:
                continue
            if allow_build and item[1].has_verb("build"):
                if self.build(item):
                    continue
                if item[1].has_verb("remove"):
                    row("↻", item[0]["name"], "rebuilding " + item[0]["name"])
                    if self.verb(item, "remove") and self.build(item):
                        continue
            return self.failure(index, self.last_probes.get(item[0]["name"], (False, "not ready"))[1])
        return True, ""

    # Restore prepared parts and undo completed live steps.
    def reset(self):
        try:
            result = subprocess.run(["docker", "ps", "--filter", "status=running", "--format", "{{.Names}}"], cwd=self.deck, env=self.env, stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=10, check=False)
            clusters = self.manifest.get("clusters", [])
            if result.returncode == 0 and any(name.startswith("vcluster.cp.") and name[len("vcluster.cp."):] not in clusters for name in result.stdout.splitlines()):
                row("↻", "platform", "another deck's cluster runs on it")
        except (OSError, subprocess.SubprocessError):
            pass
        ok, summary = self.wake_present(allow_build=True)
        if not ok:
            return ok, summary
        for index in reversed(range(len(self.items))):
            item = self.items[index]
            if item[0].get("live"):
                state, _ = item[1].probe()
                if state is True and not self.verb(item, "remove"):
                    return self.failure(index, "remove failed")
        return self.finish()

    # Stop on sleep and remove owned infrastructure on down.
    def down(self, keep_active=False, deadline=None):
        success = True
        for item in reversed(self.items):
            config, adapter = item
            if deadline is not None and time.monotonic() >= deadline:
                success = False
                break
            if hasattr(adapter, "deadline"):
                adapter.deadline = deadline
            if keep_active:
                verb = "stop" if not config.get("live") else None
            elif config.get("live"):
                verb = "remove" if adapter.probe()[0] is not False else None
            else:
                verb = "remove" if adapter.has_verb("remove") else "stop"
            if verb and adapter.has_verb(verb):
                ok = self.verb(item, verb)
                row("✓" if ok else "✗", config["name"], getattr(adapter, "note", "") or ("done" if ok else verb + " failed"), config.get("hint") if not ok else None, getattr(adapter, "tail", []) if not ok else ())
                success = ok and success
            elif verb:
                row("✗", config["name"], verb + " unavailable")
                success = False
        active = self.root / "active"
        if not keep_active and success and active.exists() and active.read_text() == str(self.deck):
            active.unlink(missing_ok=True)
        summary = "stopped" if success else "not ready: teardown failed"
        print(summary)
        return success, summary

    # Hold a non-inheritable, nonblocking deck lock while a command runs.
    def execute(self, command, on_start=None, sleep_deadline=None):
        scope_result = None
        if command != "resume":
            scope_result = self.scope()
            if not scope_result[0]:
                row("✗", "scope", scope_result[1])
                print("✗  not ready: scope")
                return False, "✗  not ready: scope"
            if command == "ready":
                row("✓", "scope", scope_result[1])
                return self.report()
        with (self.state / "lock").open("a+") as lock:
            os.set_inheritable(lock.fileno(), False)
            try:
                if command == "resume":
                    waiter = (self.state / "resume-waiter").open("a+")
                    try:
                        fcntl.flock(waiter, fcntl.LOCK_EX | fcntl.LOCK_NB)
                    except BlockingIOError:
                        waiter.close()
                        return True, ""
                    deadline = time.monotonic() + 1200
                    while True:
                        try:
                            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
                            break
                        except BlockingIOError:
                            if time.monotonic() >= deadline:
                                waiter.close()
                                return False, "resume timed out waiting for lock"
                            time.sleep(0.2)
                    waiter.close()
                else:
                    fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                if command in ("sleep", "resume"):
                    return True, ""
                row("✓", "scope", scope_result[1])
                lock.seek(0)
                message = f"a reset is already running (pid {lock.read().strip() or '?'})"
                print(message)
                return False, message
            lock.seek(0)
            lock.truncate()
            lock.write(str(os.getpid()))
            lock.flush()
            try:
                scope_ok, detail = scope_result if scope_result is not None else self.scope()
                if not scope_ok:
                    row("✗", "scope", detail)
                    print("✗  not ready: scope")
                    return False, "✗  not ready: scope"
                if command == "resume" and all(ok for ok, _ in self.probes()):
                    return True, ""
                row("✓", "scope", detail)
                if on_start:
                    on_start()
                if command == "reset":
                    result = self.reset()
                elif command in ("wake", "resume"):
                    result = self.wake_present()
                    if result[0]:
                        result = self.finish()
                    if command == "resume" and not result[0] and not result[1].startswith("✗  live steps done:"):
                        failed = [item[0]["name"] for item, value in zip(self.items, self.probes()) if not value[0]]
                        if failed:
                            result = False, f"not ready: {', '.join(failed)}: run just reset"
                            print(result[1])
                elif command in ("down", "sleep"):
                    result = self.down(command == "sleep", sleep_deadline or time.monotonic() + 60 if command == "sleep" else None)
                if command in ("reset", "wake", "down"):
                    presentation = self.deck / "presentation.md"
                    if presentation.exists():
                        presentation.touch()
                return result
            finally:
                fcntl.flock(lock, fcntl.LOCK_UN)


# Send an optional desktop notification without requiring notify-send.
def notify(deck, message, env=None):
    try:
        subprocess.run(["notify-send", deck, message], stdin=subprocess.DEVNULL,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5,
                       check=False, close_fds=True, env=env)
    except (OSError, subprocess.TimeoutExpired):
        pass


# Parse the CLI, select the active deck for suspend hooks, and run a command.
def main(argv=None):
    parser = argparse.ArgumentParser(description="Prepare and check a deck's demo")
    parser.add_argument("command", choices=["ready", "wake", "reset", "down", "sleep", "resume"])
    parser.add_argument("--deck")
    parser.add_argument("--notify", action="store_true")
    args = parser.parse_args(argv)
    try:
        deck = Path(args.deck or ".")
        if args.command == "sleep":
            if args.deck is not None:
                Lifecycle(deck)
            success = True
            deadline = time.monotonic() + 60
            root = state_root()
            try:
                active_deck = (root / "active").read_text()
            except OSError:
                active_deck = None
            markers = list(root.glob("*/deck"))
            # Give the active deck the first share of the suspend deadline.
            def active_first(marker):
                try:
                    return marker.read_text() != active_deck
                except OSError:
                    return True
            markers.sort(key=active_first)
            for marker in markers:
                if time.monotonic() >= deadline:
                    return 1
                try:
                    candidate = Lifecycle(Path(marker.read_text()))
                    ok, _ = candidate.execute("sleep", sleep_deadline=deadline)
                    success = ok and success
                except (OSError, ValueError, tomllib.TOMLDecodeError):
                    success = False
            return 0 if success else 1
        if args.command == "resume":
            active = state_root() / "active"
            if not active.exists():
                return 0
            deck = Path(active.read_text())
        lifecycle = Lifecycle(deck)
        message = {"wake": "waking the demo", "resume": "waking the demo",
                   "reset": "preparing the demo", "down": "stopping the demo",
                   "sleep": "stopping the demo"}.get(args.command, f"{args.command} starting")
        on_start = lambda: notify(lifecycle.manifest["deck"], message, lifecycle.env) if args.notify else None
        ok, summary = lifecycle.execute(args.command, on_start)
        if args.notify and summary:
            notify(lifecycle.manifest["deck"], summary, lifecycle.env)
        return 0 if ok else 1
    except (OSError, ValueError, tomllib.TOMLDecodeError) as exc:
        print(f"demo: {exc}", file=sys.stderr)
        return 1
