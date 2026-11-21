# Demo lifecycle

The demo engine prepares, checks, wakes and stops a deck's components from a `demo.toml` manifest. It keeps the work in dependency order and can stop the active demo before laptop sleep, then wake it after resume so stale Platform tunnels recover without a rebuild.

## Manifest

Put `demo.toml` in the deck directory. This example describes a shared Platform, a Docker driver cluster and a page that should be absent until the live demo starts it:

```toml
deck = "ai-dev-loop"
kubeconfig = "~/.kube/vind-demo.config"
clusters = ["ai-dev"]
env = { CLOUDSDK_CORE_CHECK_GCE_METADATA = "false" }

[[component]]
name = "platform"
kind = "platform"
build = "./platform.sh"

[[component]]
name = "ai-dev"
kind = "docker-host"
cluster = "ai-dev"
build = "./create-cluster.sh"
remove = "./lifecycle/remove-cluster.sh"
timeout = 300

[[component]]
name = "demo page"
kind = "command"
prepared = "absent"
probe = "./demo.sh status"
remove = "./demo.sh stop"
```

`deck` is the state and notification label. `kubeconfig`, `clusters` and `env` are optional; `clusters` scopes Docker host operations and `env` supplies environment variables to commands. Components start and build in file order, and stop and remove in reverse order. Each needs a unique `name` of at most 16 characters and a `kind`. Common optional fields are `prepared` (`present` by default or `absent`), `timeout` (probe wait after start or build, default 180 seconds), `hint`, and `probe`, `start`, `stop`, `build` and `remove` shell commands. A supplied command overrides the kind's matching operation. `probe_timeout`, `start_timeout`, `stop_timeout`, `build_timeout` and `remove_timeout` override individual command limits; `timeout = 0` checks once without waiting. Commands run in the deck directory with `DEMO_STATE`, the manifest's environment and optional `KUBECONFIG` set. A probe exit of 0 means present, 1 means absent, and other results are unknown. An `absent` component is ready only when its probe says it is absent.

The kinds below are implemented in `kinds.py`. The current CLI registry exposes `command` only; the other kinds need to be registered before a manifest can use them.

| Kind | Kind-specific fields and behavior |
| --- | --- |
| `command` | `probe` is required. Supply any other verbs needed by the demo. |
| `process` | `run` is required. Optional `health` is an HTTP URL or shell command; `steady` is the number of consecutive health checks, default 1. The engine tracks and stops its process group. |
| `docker-host` | `cluster` is required and must appear in `clusters`. `context` defaults to `vcluster-docker_<cluster>`. The engine manages that cluster's scoped Docker resources. Supply `build` to create it; `remove` can override the default deletion. |
| `platform` | Optional `check` defaults to `vcluster platform get current-user`; `steady` defaults to 3. The engine keeps the shared Platform running if another deck's cluster needs it. Supply `build` to create it. |
| `vcluster-instance` | `project` and `instance` are required. Checks the instance through the Platform management API. Supply `build` to create it; the default remove deletes it. |
| `stack` | `project` and `instance` are required. Optional `want` is a list of accepted phases, default `["Healthy"]`. Supply `build` to create it; the default remove deletes it. |

## Commands

Run `templates/demo/demo <command> --deck <deck-directory>` or run the engine from the deck directory without `--deck`. Add `--notify` for desktop notifications.

| Command | Effect |
| --- | --- |
| `ready` | Probe components and report whether the demo is set. |
| `wake` | Start stopped components, with a stop and start pass if needed. It does not rebuild or remove components. |
| `reset [--fresh]` | Prepare the demo by waking it when stopped, or rebuilding it. |
| `down` | Stop components and clear this deck as active. |
| `sleep` | Stop the active deck, keeping it active for resume. |
| `resume` | Wake the active deck without rebuilding. If it cannot wake, run `just reset`. It stays quiet if probes already pass or the lock is held. |
| `used` | Clear the `set` marker after a live demo step changes the prepared state. |

The `set` marker records a successful reset that prepared the demo and has not since been marked used. Sleep and down keep it; wake and resume preserve it. With `set` and at least one present component down or unknown, reset tries wake first and rebuilds if wake fails. If all present components pass, if `set` is missing, or if `--fresh` is passed, reset rebuilds. A rebuild removes the marker and writes it again only when all probes pass. Wake leaves an `absent` component alone, so a live step is not undone on resume.

From a deck directory, `just reset`, `just reset fresh`, `just down` and `just ready` call the engine when `demo.toml` exists. For older decks without a manifest, reset and down use the deck's `reset.sh` and `down.sh` instead.

## Suspend hooks

Run `templates/demo/hooks/install.sh` as your normal user to install the system sleep hook, NetworkManager dispatcher and user service. The installer uses sudo for the two system hooks. Use `--dry-run` to inspect the filled files and commands, or `--uninstall` to remove them. Before suspend the hook stops the active demo as your user. After resume the user service wakes it with notifications. A NetworkManager connectivity change to FULL starts the service again, which lets a wake retry after venue Wi-Fi connects.

## Tests

From the repository root:

```sh
python3 -m unittest discover -s templates/demo/tests -t templates/demo
python3 -m unittest discover -s templates/demo/hooks/tests -v
shellcheck templates/demo/hooks/run-active templates/demo/hooks/install.sh
shellcheck -s sh templates/demo/hooks/system-sleep templates/demo/hooks/nm-dispatcher
```
