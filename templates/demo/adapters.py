"""Component port and shell command adapter for demo lifecycle verbs."""

import fcntl
import os
import signal
import subprocess
import tempfile
import time
from typing import Protocol


class Component(Protocol):
    """The operations the lifecycle core needs from each adapter."""

    # Report whether the component exists or is healthy, or None if unknown.
    def probe(self) -> tuple[bool | None, str]: ...

    # Report whether this component supports a lifecycle verb.
    def has_verb(self, verb: str) -> bool: ...

    # Start the existing component.
    def start(self) -> bool: ...

    # Stop the component without deleting it.
    def stop(self) -> bool: ...

    # Build the component from nothing.
    def build(self) -> bool: ...

    # Remove the component.
    def remove(self) -> bool: ...


class Command:
    """Run manifest verbs as bounded shell commands."""

    timeouts = {"probe": 10, "start": 120, "stop": 60, "build": 900,
                "remove": 600}

    # Keep command context and expose verb availability to the core.
    def __init__(self, config, deck, state, env):
        self.config = config
        self.deck = deck
        self.state = state
        self.env = env
        self.tail = []
        self.deadline = None

    # Tell the core whether the manifest supplies a verb.
    def has_verb(self, verb):
        return bool(self.config.get(verb))

    # Run a verb, isolate its output, and append it to the shared log.
    def run(self, verb):
        command = self.config.get(verb)
        if not command:
            return 0
        timeout = self.config.get(f"{verb}_timeout", self.timeouts[verb])
        if self.deadline is not None:
            timeout = min(timeout, max(0, self.deadline - time.monotonic()))
        with tempfile.NamedTemporaryFile(dir=self.state, prefix="command-", mode="w+b") as output:
            try:
                proc = subprocess.Popen(
                    ["bash", "-c", command], cwd=self.deck, env=self.env,
                    stdin=subprocess.DEVNULL, stdout=output, stderr=output,
                    start_new_session=True, close_fds=True,
                )
                try:
                    code = proc.wait(timeout=timeout)
                except subprocess.TimeoutExpired:
                    try:
                        os.killpg(proc.pid, signal.SIGKILL)
                    except ProcessLookupError:
                        pass
                    proc.wait()
                    code = None
                    output.write(b"command timed out\n")
            except OSError as exc:
                output.write(f"{exc}\n".encode())
                code = None
            output.flush()
            output.seek(0)
            data = output.read()
            header = f"\n[{time.strftime('%Y-%m-%d %H:%M:%S%z')}] == {self.config['name']} {verb}\n"
            with (self.state / "log").open("ab") as log:
                fcntl.flock(log, fcntl.LOCK_EX)
                log.write(header.encode() + data)
                log.flush()
                fcntl.flock(log, fcntl.LOCK_UN)
        if code != 0:
            self.tail = data.decode(errors="replace").splitlines()[-3:]
        elif verb != "probe":
            self.tail = []
        return code

    # Distinguish an unhealthy component from an indeterminate probe.
    def probe(self):
        code = self.run("probe")
        if code == 0:
            return True, "ready"
        if code == 1:
            return False, "not ready"
        return None, self.tail[-1] if self.tail else f"probe exited {code}"

    # Start the component if a start command was supplied.
    def start(self):
        return self.run("start") == 0

    # Stop the component if a stop command was supplied.
    def stop(self):
        return self.run("stop") == 0

    # Build the component if a build command was supplied.
    def build(self):
        return self.run("build") == 0

    # Remove the component if a remove command was supplied.
    def remove(self):
        return self.run("remove") == 0


# Register new adapter kinds here without changing the lifecycle state machine.
REGISTRY = {"command": Command}
