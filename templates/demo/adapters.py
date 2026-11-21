"""Component port and shell command adapter for demo lifecycle verbs."""

import os
import signal
import subprocess
import time
from typing import Protocol


class Component(Protocol):
    """The operations the lifecycle core needs from each adapter."""

    # Check whether the component is healthy.
    def probe(self) -> tuple[bool, str]: ...

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

    # Run a verb with output directly attached to the shared log file.
    def run(self, verb):
        command = self.config.get(verb)
        if not command:
            return True
        timeout = self.timeouts[verb]
        if self.deadline is not None:
            timeout = min(timeout, max(0, self.deadline - time.monotonic()))
        log_path = self.state / "log"
        with log_path.open("ab", buffering=0) as log:
            header = f"\n[{time.strftime('%Y-%m-%d %H:%M:%S%z')}] == {self.config['name']} {verb}\n"
            log.write(header.encode())
            offset = log.tell()
            try:
                proc = subprocess.Popen(
                    ["bash", "-c", command], cwd=self.deck, env=self.env,
                    stdin=subprocess.DEVNULL, stdout=log, stderr=log,
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
                    code = 1
                    log.write(b"command timed out\n")
            except OSError as exc:
                log.write(f"{exc}\n".encode())
                code = 1
        if code:
            with log_path.open("rb") as log:
                log.seek(offset)
                lines = log.read().decode(errors="replace").splitlines()[-3:]
                if lines:
                    self.tail = lines
        elif verb != "probe":
            self.tail = []
        return code == 0

    # Check whether the command reports the component as healthy.
    def probe(self):
        ok = self.run("probe")
        return ok, "ready" if ok else "not ready"

    # Start the component if a start command was supplied.
    def start(self):
        return self.run("start")

    # Stop the component if a stop command was supplied.
    def stop(self):
        return self.run("stop")

    # Build the component if a build command was supplied.
    def build(self):
        return self.run("build")

    # Remove the component if a remove command was supplied.
    def remove(self):
        return self.run("remove")


# Register new adapter kinds here without changing the lifecycle state machine.
REGISTRY = {"command": Command}
