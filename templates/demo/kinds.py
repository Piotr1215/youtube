"""Built-in demo lifecycle kinds."""

import json
import os
from pathlib import Path
import shlex
import signal
import subprocess
import tempfile
import threading
import time
import tomllib
import urllib.error
import urllib.request
from urllib.parse import urlsplit

from adapters import Command

_MGMT_LOCK = threading.Lock()
_MGMT_READY = set()
_CHILDREN = {}


# Run a bounded external command without a shell.
def _run(argv, env, timeout=15, cwd=None):
    try:
        result = subprocess.run(argv, stdin=subprocess.DEVNULL, capture_output=True,
                                text=True, errors="replace", env=env, cwd=cwd,
                                timeout=max(0.001, timeout), check=False)
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return None, "", "command timed out"
    except OSError as exc:
        return None, "", str(exc)


# Require a nonempty string in a kind's configuration.
def _required(item, key):
    if not isinstance(item.get(key), str) or not item[key].strip() or "\x00" in item[key]:
        raise ValueError(f"component {item.get('name', '')}: invalid {key}")


# Validate the number of consecutive health checks.
def _steady(item):
    value = item.get("steady", 1)
    if isinstance(value, bool) or not isinstance(value, int) or value < 1:
        raise ValueError(f"component {item.get('name', '')}: invalid steady")


# Read the deck's cluster scope from its manifest.
def _clusters(deck):
    try:
        with (deck / "demo.toml").open("rb") as source:
            return tomllib.load(source).get("clusters", [])
    except (OSError, tomllib.TOMLDecodeError):
        return None


class _Common:
    """Share command overrides and bounded subprocess handling."""

    # Store the component's execution context.
    def __init__(self, config, deck, state, env):
        self.config, self.deck, self.state, self.env = config, Path(deck), Path(state), env
        self.tail = []
        self.note = ""
        self.deadline = None

    # Calculate a command timeout while respecting the core's deadline.
    def _timeout(self, verb, default):
        timeout = self.config.get(f"{verb}_timeout", default)
        if self.deadline is not None:
            timeout = min(timeout, max(0, self.deadline - time.monotonic()))
        return timeout

    # Run a manifest command and retain its own failure output.
    def _command(self, verb):
        command = Command(self.config, self.deck, self.state, self.env)
        if hasattr(command, "deadline"):
            command.deadline = self.deadline
        result = command.run(verb)
        command._kind_result = result
        ok = result if isinstance(result, bool) else result == 0
        self.tail = list(command.tail[-3:]) if not ok else []
        return ok, command

    # Run a native command and retain a short failure explanation.
    def _call(self, argv, verb, default=15, env=None):
        code, out, err = _run(argv, self.env if env is None else env,
                              self._timeout(verb, default), self.deck)
        # Keep output only from a failed call, so a failed row never shows a good call's.
        self.tail = (err or out or "command failed").splitlines()[-3:] if code else []
        return code, out, err

    # Run a supplied probe using the command adapter's outcome when available.
    def _override_probe(self):
        ok, command = self._command("probe")
        if ok:
            return True, "ready"
        code = command._kind_result
        if isinstance(code, bool):
            code = getattr(command, "returncode", getattr(command, "last_returncode", None))
        return (False if code == 1 else None), "not ready" if code == 1 else "probe failed"

    # Tell the core which component verbs are implemented.
    def has_verb(self, verb):
        return verb in self.native_verbs or bool(self.config.get(verb))

    # Run the deck's optional build command.
    def build(self):
        if self.config.get("build"):
            return self._command("build")[0]
        self.tail = ["no build command"]
        return False


class Process(_Common):
    """Manage a background process owned by a deck."""

    fields = {"run", "health", "steady"}
    native_verbs = {"probe", "start", "stop", "build", "remove"}

    # Validate process settings before any process starts.
    @staticmethod
    def validate(item, manifest):
        _required(item, "run")
        if "health" in item:
            _required(item, "health")
        _steady(item)
        if item.get("name") in (".", "..") or "/" in item.get("name", ""):
            raise ValueError("invalid name")

    # Locate a process state file without using a shell.
    def _path(self, suffix):
        return self.state / "proc" / (self.config["name"] + suffix)

    # Read Linux process identity and reject zombies.
    def _identity(self, pid):
        try:
            stat = Path(f"/proc/{pid}/stat").read_text()
            parts = stat[stat.rfind(")") + 2:].split()
            return None if parts[0] == "Z" else parts[19]
        except (OSError, IndexError):
            return None

    # Return the recorded process only when its start time still matches.
    def _pid(self):
        try:
            pid, start = self._path(".pid").read_text().split()
            pid = int(pid)
            return pid if pid > 0 and self._identity(pid) == start else None
        except (OSError, ValueError):
            return None

    # Check whether a process group still contains a live process.
    def _group_alive(self, pgid):
        for path in Path("/proc").iterdir():
            if not path.name.isdigit():
                continue
            try:
                stat = (path / "stat").read_text()
                parts = stat[stat.rfind(")") + 2:].split()
                if parts[0] != "Z" and int(parts[2]) == pgid:
                    return True
            except (OSError, ValueError, IndexError):
                continue
        return False

    # Check one HTTP or shell health condition.
    def _health(self):
        health = self.config.get("health")
        if not health:
            return True
        if health.startswith(("http://", "https://")):
            try:
                with urllib.request.urlopen(health, timeout=self._timeout("probe", 3)) as response:
                    return 200 <= response.status < 300
            except urllib.error.HTTPError:
                return False
            except (OSError, ValueError):
                return None
        code, _, _ = self._call(["bash", "-c", health], "probe", 10)
        return True if code == 0 else False if code == 1 else None

    # Check process identity and consecutive health passes.
    def probe(self):
        if self.config.get("probe"):
            return self._override_probe()
        if not self._pid():
            return False, "process stopped"
        for i in range(self.config.get("steady", 1)):
            if i:
                time.sleep(1)
            health = self._health()
            if health is not True:
                return health, "health check failed"
            if not self._pid():
                return False, "process stopped"
        return True, "running"

    # Start the process in its own session after replacing an unhealthy one.
    def start(self):
        if self.config.get("start"):
            return self._command("start")[0]
        if self.probe()[0] is True:
            return True
        if self._pid() and not self._stop_process():
            return False
        path = self._path(".pid")
        proc = None
        try:
            path.parent.mkdir(parents=True, exist_ok=True)
            for pid, child in list(_CHILDREN.items()):
                if child.poll() is not None:
                    _CHILDREN.pop(pid, None)
            with self._path(".log").open("ab") as log:
                proc = subprocess.Popen(["bash", "-c", self.config["run"]], cwd=self.deck,
                                        env=self.env, stdin=subprocess.DEVNULL, stdout=log,
                                        stderr=log, start_new_session=True, close_fds=True)
            start = self._identity(proc.pid)
            if start is None:
                proc.poll()
                self.tail = ["process exited during start"]
                return False
            _CHILDREN[proc.pid] = proc
            path.write_text(f"{proc.pid} {start}\n")
            self.tail = []
            return True
        except OSError as exc:
            if proc is not None and proc.poll() is None:
                try:
                    os.killpg(proc.pid, signal.SIGKILL)
                    proc.wait(timeout=1)
                except (OSError, subprocess.TimeoutExpired):
                    pass
                _CHILDREN.pop(proc.pid, None)
            self.tail = [str(exc)]
            return False

    # Terminate the recorded process group and clear its identity file.
    def _stop_process(self):
        pid = self._pid()
        if pid:
            try:
                os.killpg(pid, signal.SIGTERM)
                end = time.monotonic() + 5
                while self._group_alive(pid) and time.monotonic() < end:
                    time.sleep(0.05)
                if self._group_alive(pid):
                    os.killpg(pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            except OSError as exc:
                self.tail = [str(exc)]
                return False
            proc = _CHILDREN.pop(pid, None)
            if proc is not None:
                try:
                    proc.wait(timeout=1)
                except subprocess.TimeoutExpired:
                    _CHILDREN[pid] = proc
        try:
            self._path(".pid").unlink(missing_ok=True)
        except OSError as exc:
            self.tail = [str(exc)]
            return False
        return True

    # Stop the process or run the deck's override.
    def stop(self):
        return self._command("stop")[0] if self.config.get("stop") else self._stop_process()

    # Build a process by starting it unless a command is supplied.
    def build(self):
        return self._command("build")[0] if self.config.get("build") else self.start()

    # Remove a process by stopping it unless a command is supplied.
    def remove(self):
        return self._command("remove")[0] if self.config.get("remove") else self.stop()


class DockerHost(_Common):
    """Manage the Docker driver containers for one scoped cluster."""

    fields = {"cluster", "context"}
    native_verbs = {"probe", "start", "stop", "remove"}

    # Validate the cluster scope and optional context.
    @staticmethod
    def validate(item, manifest):
        _required(item, "cluster")
        if item["cluster"] not in manifest.get("clusters", []):
            raise ValueError("cluster outside clusters")
        if "context" in item:
            _required(item, "context")

    # Check each direct Docker target before invoking Docker.
    def _check_names(self, names):
        c = self.config["cluster"]
        for name in names:
            if not (name in (f"vcluster.cp.{c}", f"vcluster.{c}") or
                    name.startswith((f"vcluster.node.{c}.", f"vcluster.lb.{c}."))):
                self.tail = [f"scope: refusing {name}"]
                return False
        return True

    # List only this cluster's containers, ordered by role.
    def _containers(self, status=None):
        args = ["docker", "ps", "-a"]
        if status:
            args += ["--filter", f"status={status}"]
        args += ["--format", "{{.Names}}"]
        code, out, _ = self._call(args, "probe")
        if code != 0:
            return None
        c = self.config["cluster"]
        names = out.splitlines()
        return [name for role in ("cp", "node", "lb") for name in sorted(names)
                if (name == f"vcluster.cp.{c}" if role == "cp" else
                    name.startswith(f"vcluster.{role}.{c}."))]

    # Call Docker only after validating every named target.
    def _docker(self, action, names):
        if not self._check_names(names):
            return False
        if not names:
            return True
        return self._call(["docker", *action, *names], action[0])[0] == 0

    # Verify the context port belongs to this cluster before acting on it.
    def _scope(self):
        self.scope_refused = False
        cluster = self.config["cluster"]
        ctx = self.config.get("context", f"vcluster-docker_{cluster}")
        code, out, _ = self._call(["kubectl", "config", "view", "--minify", "--context", ctx,
                                    "-o", "jsonpath={.clusters[0].cluster.server}"], "probe")
        try:
            port = urlsplit(out.strip()).port if code == 0 else None
        except ValueError:
            port = None
        # The configured bindings, not docker port: a stopped container publishes nothing,
        # and the wake must prove a stopped cluster's port before it starts it.
        code, ports, _ = self._call(["docker", "inspect", "-f", "{{json .HostConfig.PortBindings}}",
                                     f"vcluster.cp.{cluster}"], "probe")
        published = set()
        try:
            for bindings in (json.loads(ports) if code == 0 else {}).values():
                for binding in bindings or []:
                    published.add(int(binding["HostPort"]))
        except (ValueError, TypeError, AttributeError, KeyError):
            published = set()
        if port is None or code != 0 or port not in published:
            self.tail = [f"kube server is not {cluster}'s container"]
            self.scope_refused = True
            return False
        return True

    # Check containers, API readiness, and every node's Ready condition.
    def probe(self):
        self.scope_refused = False
        all_names = self._containers()
        if all_names is None:
            return None, "docker unavailable"
        if f"vcluster.cp.{self.config['cluster']}" not in all_names:
            return False, "containers missing"
        if not self._scope():
            return None, self.tail[-1]
        if self.config.get("probe"):
            return self._override_probe()
        running = self._containers("running")
        if running is None:
            return None, "docker unavailable"
        if f"vcluster.cp.{self.config['cluster']}" not in all_names or set(all_names) != set(running):
            return False, "containers stopped"
        ctx = self.config.get("context", f"vcluster-docker_{self.config['cluster']}")
        prefix = ["kubectl", "--context", ctx, "--request-timeout=5s"]
        if self._call(prefix + ["get", "--raw", "/readyz"], "probe")[0] != 0:
            return None, "API unavailable"
        code, out, _ = self._call(prefix + ["get", "nodes", "-o", "json"], "probe")
        if code != 0:
            return None, "nodes unavailable"
        try:
            nodes = json.loads(out)["items"]
            ready = bool(nodes) and all(any(c.get("type") == "Ready" and c.get("status") == "True"
                                            for c in n.get("status", {}).get("conditions", []))
                                        for n in nodes)
        except (ValueError, KeyError, TypeError):
            return None, "invalid node response"
        return ready, "ready" if ready else "nodes not ready"

    # Start exited containers in control plane, node, load balancer order.
    def start(self):
        names = self._containers()
        if names is None or f"vcluster.cp.{self.config['cluster']}" not in names or not self._scope():
            return False
        if self.config.get("start"):
            return self._command("start")[0]
        names = self._containers("exited")
        return names is not None and self._docker(["start"], names)

    # Stop the cluster's running containers.
    def stop(self):
        names = self._containers()
        if names is None:
            return False
        if not names:
            return True
        if not self._scope():
            return False
        if self.config.get("stop"):
            return self._command("stop")[0]
        names = self._containers("running")
        return names is not None and self._docker(["stop"], names)

    # Delete the cluster, then remove only its remaining Docker objects.
    def remove(self):
        names = self._containers()
        if names is None:
            return False
        if not names:
            # The deck's remove also clears what lives outside Docker, such as the cluster's
            # Platform record, and with no container there is no kube server to mistake.
            return self._command("remove")[0] if self.config.get("remove") else True
        if not self._scope():
            return False
        if self.config.get("remove"):
            return self._command("remove")[0]
        cluster = self.config["cluster"]
        if self._call(["vcluster", "delete", cluster, "--driver", "docker"], "remove", 600)[0] != 0:
            return False
        names = self._containers()
        if names is None or not self._docker(["rm", "-f"], names):
            return False
        code, out, _ = self._call(["docker", "network", "ls", "--format", "{{.Name}}"], "remove")
        if code != 0:
            return False
        network = f"vcluster.{cluster}"
        return self._docker(["network", "rm"], [network] if network in out.splitlines() else [])


class Platform(_Common):
    """Manage the shared local Platform without removing it."""

    fields = {"check", "steady"}
    native_verbs = {"probe", "start", "stop"}

    # Validate the steady check settings.
    @staticmethod
    def validate(item, manifest):
        _steady(item)
        if "check" in item:
            _required(item, "check")
            try:
                if not shlex.split(item["check"]):
                    raise ValueError
            except ValueError:
                raise ValueError("invalid check") from None

    # Always preserve the shared Platform when a remove command is supplied.
    def has_verb(self, verb):
        return False if verb == "remove" else super().has_verb(verb)

    # Read the Platform container state.
    def _running(self):
        code, out, _ = self._call(["docker", "inspect", "-f", "{{.State.Running}}", "vcluster-platform"], "probe")
        if code is None:
            return None
        if code != 0:
            return False if "No such" in self.tail_text() else None
        return True if out.strip() == "true" else False if out.strip() == "false" else None

    # Join the last failure lines for a state check.
    def tail_text(self):
        return " ".join(self.tail)

    # Require the container and repeated successful Platform checks.
    def probe(self):
        if self.config.get("probe"):
            return self._override_probe()
        running = self._running()
        if running is not True:
            return running, "platform stopped" if running is False else "docker unavailable"
        for i in range(self.config.get("steady", 3)):
            if i:
                time.sleep(2)
            code, _, _ = self._call(shlex.split(self.config.get("check", "vcluster platform get current-user")), "probe")
            if code != 0:
                return (None if code is None or code != 1 else False), "platform check failed"
        return True, "ready"

    # Start the Platform container when stopped.
    def start(self):
        if self.config.get("start"):
            return self._command("start")[0]
        running = self._running()
        if running is None:
            return False
        return running or self._call(["docker", "start", "vcluster-platform"], "start")[0] == 0

    # Stop the Platform only when no other deck's control plane runs.
    def stop(self):
        if self.config.get("stop"):
            return self._command("stop")[0]
        self.note = ""
        clusters = _clusters(self.deck)
        if clusters is None:
            self.tail = ["cannot read clusters"]
            return False
        code, out, _ = self._call(["docker", "ps", "--filter", "status=running", "--format", "{{.Names}}"], "stop")
        if code != 0:
            return False
        if any(name.startswith("vcluster.cp.") and name[len("vcluster.cp."):] not in clusters
               for name in out.splitlines()):
            self.note = "kept: another deck's cluster runs on it"
            return True
        running = self._running()
        return running is False or (running is True and self._call(["docker", "stop", "vcluster-platform"], "stop")[0] == 0)

    # Refuse to delete the shared Platform.
    def remove(self):
        self.tail = ["shared platform cannot be removed"]
        return False


class VclusterInstance(_Common):
    """Manage an instance through the Platform management API."""

    fields = {"project", "instance"}
    native_verbs = {"probe", "remove"}
    resource = "virtualclusterinstance"
    remove_timeout = 600

    # Validate the target project and instance.
    @staticmethod
    def validate(item, manifest):
        _required(item, "project")
        _required(item, "instance")

    # Get or create the deck's private management kubeconfig once.
    def _management_env(self):
        path = self.state / "mgmt.kubeconfig"
        with _MGMT_LOCK:
            if path not in _MGMT_READY or not path.exists():
                code, out, _ = self._call(["vcluster", "platform", "connect", "management", "--print"], "probe")
                if code != 0 or not out.strip():
                    return None
                temporary = None
                try:
                    with tempfile.NamedTemporaryFile(mode="w", dir=self.state, delete=False) as target:
                        temporary = Path(target.name)
                        os.fchmod(target.fileno(), 0o600)
                        target.write(out)
                    os.replace(temporary, path)
                    _MGMT_READY.add(path)
                except OSError as exc:
                    if temporary is not None:
                        temporary.unlink(missing_ok=True)
                    self.tail = [str(exc)]
                    return None
        return path

    # Fetch the target object as JSON from the management API.
    def _object(self):
        kubeconfig = self._management_env()
        if kubeconfig is None:
            return None
        code, out, _ = self._call(["kubectl", "--kubeconfig", str(kubeconfig), "get", self.resource, "-n", f"p-{self.config['project']}",
                                   self.config["instance"], "-o", "json"], "probe")
        if code != 0:
            return None
        try:
            data = json.loads(out)
            return data if isinstance(data, dict) else None
        except ValueError:
            return None

    # Check the instance phase and optional online condition.
    def probe(self):
        if self.config.get("probe"):
            return self._override_probe()
        obj = self._object()
        if obj is None:
            return None, "API unavailable"
        status = obj.get("status", {})
        online = [c.get("status") for c in status.get("conditions", []) if c.get("type") == "VirtualClusterOnline"]
        if obj.get("metadata", {}).get("deletionTimestamp") or status.get("phase") != "Ready" or "False" in online:
            return False, "not ready"
        if any(value != "True" for value in online):
            return None, "online status unknown"
        ready = True
        return ready, "ready" if ready else "not ready"

    # Run an explicitly supplied start override.
    def start(self):
        return self._command("start")[0]

    # Run an explicitly supplied stop override.
    def stop(self):
        return self._command("stop")[0]

    # Delete the instance and wait for the API to finish.
    def remove(self):
        if self.config.get("remove"):
            return self._command("remove")[0]
        kubeconfig = self._management_env()
        if kubeconfig is None:
            return False
        timeout = self.config.get("remove_timeout", self.remove_timeout)
        args = ["kubectl", "--kubeconfig", str(kubeconfig), "delete", self.resource, "-n", f"p-{self.config['project']}", self.config["instance"],
                "--ignore-not-found", "--wait=true", f"--timeout={timeout}s"]
        return self._call(args, "remove", self.remove_timeout)[0] == 0


class Stack(VclusterInstance):
    """Manage a Platform StackInstance."""

    fields = {"project", "instance", "want"}
    resource = "stackinstance"
    remove_timeout = 420

    # Validate the Stack target and desired phases.
    @staticmethod
    def validate(item, manifest):
        VclusterInstance.validate(item, manifest)
        want = item.get("want", ["Healthy"])
        if not isinstance(want, list) or not want or any(not isinstance(x, str) or not x for x in want):
            raise ValueError("invalid want")

    # Check that the Stack exists and is in a desired phase.
    def probe(self):
        if self.config.get("probe"):
            return self._override_probe()
        obj = self._object()
        if obj is None:
            return None, "API unavailable"
        ready = not obj.get("metadata", {}).get("deletionTimestamp") and obj.get("status", {}).get("phase") in self.config.get("want", ["Healthy"])
        return ready, "ready" if ready else "not ready"


KINDS = {"process": Process, "docker-host": DockerHost, "platform": Platform,
         "vcluster-instance": VclusterInstance, "stack": Stack}
