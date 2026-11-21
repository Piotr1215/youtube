# Demo lifecycle

The demo engine prepares, checks, wakes and stops a deck's components from a `demo.toml` manifest. Components follow dependency order. Prepare the deck once before the talk, then use reset to restore it after sleep or a live moment.

## Manifest

Put `demo.toml` in the deck directory:

```toml
deck = "ai-dev-loop"
kubeconfig = "~/.kube/vind-demo.config"
platform = "https://localhost:8443"
gcp_project = "demo-project"
gcp_zone = "europe-west1-b"
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
live = true
probe = "./demo.sh status"
remove = "./demo.sh stop"
```

`deck` is the state and notification label. `kubeconfig`, `platform`, `gcp_project`, `gcp_zone`, `clusters` and `env` are optional. `platform` must be an HTTPS URL and is required for a `vcluster-instance` or `stack`. `clusters` scopes Docker host operations. `env` adds variables to commands.

Components start and build in file order, and stop and remove in reverse order. Each needs a unique `name` of at most 16 characters and a `kind`. Common fields are `live` (false by default), `inputs`, `tools`, `timeout` (probe wait after start or build, default 180 seconds), `hint`, and `probe`, `start`, `stop`, `build` and `remove` shell commands. A supplied command overrides the kind's matching operation. Per verb timeout fields such as `probe_timeout` override command limits. `timeout = 0` checks once without waiting.

A probe exit of 0 means present, 1 means absent, and other results are unknown. A live step is ready only when its probe says it has not happened. Declare every state-changing live step as a `live = true` component with a probe and remove command. Every other demo command must be idempotent. The old `prepared` field is rejected.

Before any component runs, the engine checks every server in the declared kubeconfig. Each server must be loopback or use the declared Platform host. If `platform` is set, `~/.vcluster/config.json` must have the exact URL in `platform.host`. A mismatch stops the command before any probe or action. Every report begins with the scope, including kube server hosts, Platform host and GCP project.

Commands run in the deck directory. The engine passes PATH, HOME, USER, LOGNAME, SHELL, LANG, LC_*, TERM, TZ, TMPDIR, XDG_*, DBUS_SESSION_BUS_ADDRESS, DISPLAY, WAYLAND_DISPLAY and SSH_AUTH_SOCK from the caller, then adds the manifest's `env`. It pins `KUBECONFIG` to the declared file or a nonexistent file in the deck state directory, `DOCKER_CONTEXT` to `default`, and `DEMO_STATE` to that directory. It removes `DOCKER_HOST` and pins `CLOUDSDK_CORE_PROJECT` and `CLOUDSDK_COMPUTE_ZONE` when declared. Typed kinds use these pins too.

| Kind | Kind-specific fields and behavior |
| --- | --- |
| `command` | `probe` is required. Supply any other verbs needed by the demo. |
| `process` | `run` is required. Optional `health` is an HTTP URL or shell command; `steady` is the number of consecutive health checks, default 1. The engine tracks and stops its process group. |
| `docker-host` | `cluster` is required and must appear in `clusters`. `context` defaults to `vcluster-docker_<cluster>`. Supply `build` to create it; `remove` can override the default deletion. Its kubeconfig server port must be published by `vcluster.cp.<cluster>`. If it is not, the engine refuses to probe or change that host through kubectl. |
| `platform` | Optional `check` defaults to `vcluster platform get current-user`; `steady` defaults to 3. The engine keeps the shared Platform running if another deck's cluster needs it. Supply `build` to create it. |
| `vcluster-instance` | `project` and `instance` are required. Checks the instance through the Platform management API. Supply `build` to create it; the default remove deletes it. |
| `stack` | `project` and `instance` are required. Optional `want` lists accepted phases, default `["Healthy"]`. Supply `build` to create it; the default remove deletes it. |

## Commands

From a deck directory, use `just reset` to get the demo ready. It starts stopped parts, builds missing parts, rebuilds a part that cannot come back, and undoes completed live steps. After suspend it can wake the demo without rebuilding. After `just down`, it builds what is missing. To rebuild the whole demo, run `just down` followed by `just reset`.

Use `just down` to remove the demo infrastructure. It removes parts with a remove verb in reverse order and stops parts without one. Keep downloaded resources such as the image cache, T4 VM and model by leaving them out of remove commands. The shared Platform is stopped rather than removed. Down reports each part and continues after a failure.

`just ready` probes without changing the demo. A completed live step is reported as `live steps done`; run `just reset` for a fresh run. Sleep stops all known decks and keeps their infrastructure. Resume and the Wi-Fi trigger wake only the active deck and never build, remove or undo a live step.

A part can declare `inputs = ["relative/path"]` and `tools = ["tool-name"]`. After a successful build, the engine records the content hash of each input and the output of each tool's `--version`. On reset, a changed input or tool version causes that part to be removed and built again. The first reset without a stored value records the current values without rebuilding.

The engine also accepts `templates/demo/demo <command> --deck <deck-directory>`. Run it from the deck directory to omit `--deck`, and add `--notify` for desktop notifications. Available commands are `ready`, `wake`, `reset`, `down`, `sleep` and `resume`. For older decks without a manifest, `just reset` and `just down` run the deck's `reset.sh` and `down.sh`.

## Suspend hooks

Run `templates/demo/hooks/install.sh` as your normal user to install the system sleep hook, NetworkManager dispatcher and user service. The installer uses sudo for the two system hooks. Use `--dry-run` to inspect the filled files and commands, or `--uninstall` to remove them. Before suspend the hook stops every known demo as your user. After resume the user service wakes it with notifications. A NetworkManager connectivity change to FULL starts the service again.

## Tests

From the repository root:

```sh
python3 -m unittest discover -s templates/demo/tests -t templates/demo -v
python3 -m unittest discover -s templates/demo/hooks/tests -v
cd tests && bats scope_test.bats
```
