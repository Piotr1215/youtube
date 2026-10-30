# Curl a GPU Into Your Cluster

> A platform pattern for GPU-powered AI development

<!-- new_lines: 3 -->

```bash +exec_replace
echo "Curl a GPU" | figlet -f small -w 90
```

<!-- jump_to_middle -->

```bash +exec_replace
while IFS= read -r line; do
    printf '\033[38;5;208m%s\033[0m\n' "$line"
done < vcluster-logo-ascii.txt
```

<!-- end_slide -->

## Demo Reset

> Presenter only: back to a clean start, T4 VM kept. Skip on stage.

```bash +exec_replace
paint red '  ✗  ' cyan 'audience page    ' plain 'server stopped, its state deleted'
paint red '  ✗  ' cyan 'T4 join          ' plain 'undone, vcluster-vpn stopped, its config deleted'
paint red '  ✗  ' cyan 'all vclusters    ' plain 'ai-dev and anything else in vcluster list'
paint red '  ✗  ' cyan 'Docker           ' plain 'vcluster.* containers and networks'
paint red '  ✗  ' cyan 'kubeconfig       ' plain '~/.kube/vind-demo.config'
paint red '  ✗  ' cyan 'cloud-node       ' plain 'KVM VM and disk, rebuilt fresh from the Ubuntu image'
paint
paint green '  ✓  ' cyan 'Platform         ' plain 'stays up; a new one needs activation in the UI'
paint green '  ✓  ' cyan 'T4 VM            ' plain 'keeps running and billing, with driver and model'
paint
paint yellow '  ▶  ' cyan 'also             ' plain 'loads br_netfilter, sets the docker driver'
paint yellow '  ▶  ' cyan '--clean-platform ' plain 'destroys the Platform too'
paint yellow '  ▶  ' cyan '--clean-gcp      ' plain 'deletes the T4 VM; recreating it re-downloads the model'
paint
paint yellow '  Next: Platform Setup, then Step 1.'
```

```bash +acquire_terminal
./reset.sh
```

<!-- end_slide -->

## Platform Setup

> Presenter only, before the talk: the CLI logs in so clusters get a license.

```bash +exec_replace
paint cyan '  Doing   ' plain 'start the Platform, print its login, log the CLI in'
paint cyan '  Why     ' plain 'vcluster create needs this login to get a license'
```

```file
path: platform.sh
language: bash
start_line: 33
end_line: 37
```

```bash +exec
./platform.sh
```

<!-- end_slide -->

<!-- include: ../_partials/about-me.md -->

<!-- end_slide -->

## AI Dev Loop

> What changes when developers need a model inside their workflow?

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

## The AI Dev Loop

> Build, test, and repeat still apply; the loop now needs model access.

```bash +exec_replace
paint 'bold cyan' '  edit prompt or code' gray ' ──▶ ' 'bold yellow' 'call the model' gray ' ──▶ ' 'bold cyan' 'score the answers'
paint gray '      ▲                                             │'
paint gray '      └──────────◀ swap the model, retry ───────────┘'
paint
paint cyan '  your code    ' plain 'calls a model: an MCP server, an agent, an app feature'
paint cyan '  your tests   ' plain 'score a prompt or a model over many examples'
paint cyan '  your tools   ' plain 'an assistant or agent inside the dev environment'
paint
paint yellow '  A GPU-backed model is now a dependency of the development loop.'
```

<!-- end_slide -->

## From Request to Platform Service

> A developer needs an endpoint. The platform team must make it dependable.

```bash +exec_replace
paint 'bold cyan' '  developer request' gray ' ──▶ ' plain 'a model endpoint in the dev loop'
paint gray '          │'
paint gray '          ▼'
paint 'bold yellow' '  platform service'
paint cyan '    capacity      ' plain 'find suitable GPU compute'
paint cyan '    reachability  ' plain 'connect code and model across networks'
paint cyan '    lifecycle     ' plain 'join, wait, pause, resume, recover'
paint cyan '    repeatability ' plain 'declare the cluster and its dependencies'
paint
paint yellow '  How do we deliver that without a new infrastructure ticket each time?'
```

<!-- end_slide -->

## Basic Concepts

> Which components turn remote hardware into a reusable capability?

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

## vind

> vCluster in Docker: each node is a container on the laptop.

```bash +exec_replace
paint plain '  laptop'
paint gray '  │'
paint gray '  ├── ' 'bold cyan' 'control plane     ' plain 'API server and scheduler, one container'
paint gray '  ├── ' 'bold cyan' 'worker nodes      ' plain 'kubelet and containerd, one container each'
paint gray '  ├── ' 'bold cyan' 'LoadBalancers     ' plain 'IPs on the Docker network, reachable locally'
paint gray '  └── ' 'bold cyan' 'images            ' plain 'pulled through the laptop'"'"'s Docker, no push'
paint
paint yellow '  A fast, production-shaped API before scarce GPU capacity enters the loop.'
```

<!-- end_slide -->

## Private Nodes

> A Linux host joins the laptop cluster over WireGuard.

```bash +exec_replace
just boxart vpn-architecture | sed 's/^/              /'
paint
paint cyan '              host      ' plain 'KVM VM, cloud VM, or bare metal'
paint cyan '              join      ' plain 'a curl command installs kubelet and connects the tunnel'
paint cyan '              token     ' plain 'an expiring join token for this cluster'
paint cyan '              Platform  ' plain 'a public URL the node dials; it coordinates WireGuard'
paint cyan '              VPN       ' plain 'Tailscale library + WireGuard; no Tailscale account'
paint
paint yellow '          Every node joins the same way, with no network setup per VM.'
```

<!-- end_slide -->

## Simple and Local

> Which parts of the service should stay fast and local?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## Step 1: A Cluster on the Laptop

> Give a developer a repeatable Kubernetes environment from vcluster.yaml.

```bash +exec_replace
paint cyan '  Doing   ' plain 'create the dev cluster from vcluster.yaml'
paint cyan '  Why     ' plain 'vcluster.yaml declares the workers, VPN, and model dependency'
```

```bash
vcluster create ai-dev --values vcluster.yaml
kubectl wait --for=condition=Ready node --all
```

```bash +exec
./create-cluster.sh
```

<!-- end_slide -->

## Step 2: Build, Run, Test

> Keep the inner loop fast before the workload needs scarce hardware.

```bash +exec_replace
paint cyan '  Doing   ' plain 'build an image, run it in the cluster, test it from the laptop'
paint cyan '  Why     ' plain 'developers use real manifests without waiting for a registry push'
```

```bash +exec
./local-loop.sh
```

<!-- end_slide -->

## Complex and Remote

> How do we supply GPU capacity outside the laptop?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## Step 3: A Cloud GPU Node

> A remote T4 joins the same cluster and becomes a placement target.

```bash +exec_replace
paint plain '  ai-dev'
paint gray '  │'
paint gray '  ├── ' 'bold cyan' 'control plane     ' plain 'the same API server and scheduler'
paint gray '  ├── ' 'bold cyan' 'worker-1          ' plain 'a Docker container on the laptop'
paint gray '  └── ' 'bold green' 'remote-node       ' plain 'a GCE VM with an NVIDIA T4'
paint gray '        ├── ' cyan 'at first boot   ' plain 'driver, Ollama, and the model download'
paint gray '        └── ' cyan 'at join         ' plain 'kubelet and the tunnel to the laptop'
paint
paint cyan '  Doing   ' plain 'check the GPU VM: driver, Ollama, and the model are ready'
paint cyan '  Why     ' plain 'the platform must plan for a 7.4 GB model pull and cache'
```

```bash +exec
./create-gpu-vm.sh
```

<!-- end_slide -->

## Step 4: Curl In the GPU

> The VM already has a GPU and model; a curl command joins it to ai-dev.

```bash +exec_replace
paint cyan '  Doing   ' plain 'generate a one-hour join URL; paste its curl as root on the T4'
paint cyan '  Why     ' plain 'remote capacity appears behind the same Kubernetes API'
```

```bash
curl -fsSLk '<join-url>' | sh -s -- --node-name remote-node
```

```bash +exec_replace
paint gray '  <join-url> contains the token from vcluster token create --expires=1h'
paint cyan '  on the T4: ' plain 'install kubelet' gray ' ──▶ ' plain 'connect VPN' gray ' ──▶ ' plain 'register node'
```

```bash +acquire_terminal
./join.sh gpu
```

<!-- end_slide -->

## Step 5: Same Kube Context

> Developer access stays simple while the platform spans laptop and cloud.

```bash +exec_replace
paint cyan '  Doing   ' plain 'list the nodes and where each one runs'
paint cyan '  Why     ' plain 'the platform owns placement and network; the user keeps the same context'
```

```bash +exec
./nodes.sh
```

<!-- end_slide -->

## Adding Services

> How does a GPU become a dependable model service?

```bash +exec_replace
./journey.sh 5
```

<!-- end_slide -->

## Stacks

> Turn a GPU node into a model endpoint with a health gate.

```bash +exec_replace
paint plain '  vcluster.yaml'
paint gray '  └── ' 'bold cyan' 'Stack classif     ' plain 'created with the cluster in step 1'
paint gray '      ├── ' 'bold cyan' 'model         ' plain 'a pod pinned to remote-node, Pending until it joins'
paint gray '      │                 ' plain 'then exposes Ollama behind a LoadBalancer'
paint gray '      │                 ' plain 'and loads Winnow into GPU memory'
paint gray '      └── ' 'bold cyan' 'check         ' plain 'once model is healthy: one test question'
paint
paint cyan '  platform owns   ' plain 'model placement, startup, and health check'
paint cyan '  developer gets  ' plain 'a model endpoint when the dependency is ready'
paint
paint yellow '  The service definition waits for the hardware it needs.'
```

<!-- end_slide -->

## Step 6: The Stack Finishes

> The Stack reports when the model service is ready on the T4.

```bash +exec_replace
paint cyan '  Doing   ' plain 'watch the Stack the cluster created in step 1'
paint cyan '  Why     ' plain 'the Stack retries its tasks and reports model health'
```

```bash +exec
./stack-status.sh --watch
```

<!-- end_slide -->

## The Whole Path

> The platform connects the nodes; applications use the model endpoint.

```bash +exec_replace
just digraph architecture | awk '
{
  gsub(/vCluster Platform|join tokens [+] VPN|Stack health/, "\033[1;35m&\033[0m")
  gsub(/LAPTOP \/ ai-dev|API [+] worker-1/, "\033[1;36m&\033[0m")
  gsub(/GCE \/ remote-node|proxy -> Ollama|Winnow on T4/, "\033[1;32m&\033[0m")
  gsub(/Audience phone|via Cloudflare|HTTPS|page [+] classif|model Service|Tailscale\/WireGuard/, "\033[1;33m&\033[0m")
  print
}'
paint
paint yellow '  The same kube context reaches Docker and the T4.'
```

<!-- end_slide -->

## Step 7: Share the Loop

> Expose the same model call to the room through a small page.

```bash +exec_replace
paint cyan '  Doing   ' plain 'start the page; check the public URL and a real model answer'
paint cyan '  Why     ' plain 'a public request now crosses ingress, the laptop, and the T4'
```

```bash +exec
./audience.sh start
```

<!-- end_slide -->

## Try It From Your Phone

> Ask Winnow on the T4 any yes or no question.

```bash +exec
./audience.sh qr
```

<!-- end_slide -->

## vind Capabilities

> Docker is the only requirement; the Platform adds external nodes.

```bash +exec_replace
paint green '  ✓  ' cyan 'pull through cache  ' plain 'images come from the laptop'"'"'s Docker, no kind load'
paint green '  ✓  ' cyan 'LoadBalancers       ' plain 'work out of the box, reachable locally'
paint green '  ✓  ' cyan 'multiple nodes      ' plain 'each worker declared in vcluster.yaml'
paint green '  ✓  ' cyan 'external nodes      ' plain 'remote hosts join over vCluster VPN'
paint
paint yellow '  ▶  ' cyan 'pause and resume    ' plain 'stop a cluster, free its resources, start it again'
paint yellow '  ▶  ' cyan 'snapshot, restore   ' plain 'save a cluster to a file, restore it under a new name'
paint yellow '  ▶  ' cyan 'CI                  ' plain 'setup-vind GitHub Action creates clusters in workflows'
paint
paint gray '  ✓ used in this talk   ▶ in the docs'
```

<!-- end_slide -->

## Closing the Loop

> How does this become a reviewed service instead of a ticket?

```bash +exec_replace
./journey.sh 6
```

<!-- end_slide -->

## From Laptop to Git

> Review the service definition; supply GPU capacity in each target cluster.

```bash +exec_replace
paint plain '  app/' gray ' ──▶ ' plain 'pull request' gray ' ──▶ ' plain 'CI builds the image' gray ' ──▶ ' plain 'Argo CD' gray ' ──▶ ' plain 'shared cluster'
paint
paint cyan '  moves to Git   ' plain 'app/, the manifests from step 2'
paint cyan '  changes        ' plain 'web:dev becomes an immutable tag from CI'
paint cyan '  stays local    ' plain 'Docker workers, this T4 and its node pin'
paint cyan '  each cluster   ' plain 'supplies its own GPU and model Service'
paint
paint yellow '  Git carries the service contract; each cluster supplies its own capacity.'
```

<!-- end_slide -->

## Auto Nodes

> From a manual join to capacity requested by the workload.

```bash +exec_replace
paint plain '  pod has nowhere to run' gray ' ──▶ ' plain 'Platform creates a machine' gray ' ──▶ ' plain 'it joins'
paint plain '  node sits empty       ' gray ' ──▶ ' plain 'Platform removes the machine'
paint
paint cyan '  node provider   ' plain 'where machines come from, set up once in the Platform'
paint cyan '  node pools      ' plain 'which machine types a cluster may get, in vcluster.yaml'
paint
paint yellow '  Node pools are a path to self-service GPU capacity.'
paint gray '  Today we join by hand; this provider and pool are not configured here.'
```

<!-- end_slide -->

## Before This Is Self-Service

> The demo proves the path. A platform offering needs an operating contract.

```bash +exec_replace
paint green '  ✓  ' cyan 'proven           ' plain 'same context, remote T4, Stack health, public page'
paint
paint red '  ✗  ' cyan 'laptop sleeps    ' plain 'pause first; on resume the tunnel returns'
paint red '  ✗  ' cyan 'model downloads  ' plain 'gigabytes per new VM: pull at boot, never on stage'
paint red '  ✗  ' cyan 'GPU host event   ' plain 'GCE stops GPU VMs for maintenance, no live migration'
paint
paint cyan '     access           ' plain 'authenticate callers; enforce tenant boundaries'
paint cyan '     capacity         ' plain 'quota, placement policy, node pools for on-demand GPUs'
paint cyan '     operations       ' plain 'measure tunnel health, inference latency, and failures'
paint cyan '     cost             ' plain 'budget idle time and model pulls; replace failed GPU VMs'
paint cyan '     promotion        ' plain 'publish the image, then sync the Argo CD Application'
paint
paint yellow '  Make these defaults before treating a new model as self-service.'
```

<!-- end_slide -->

## Takeaways

```bash +exec_replace
paint green '  ✓  ' cyan 'requirement   ' plain 'AI work brings model and GPU access into the dev loop'
paint green '  ✓  ' cyan 'platform      ' plain 'join external capacity; expose a healthy model service'
paint 'bold yellow' '  ▶  ' cyan 'next          ' plain 'automate capacity and promotion, with access and telemetry'
```

<!-- end_slide -->

<!-- new_lines: 3 -->

```bash +exec_replace
while IFS= read -r line; do
    printf '\033[38;5;208m%s\033[0m\n' "$line"
done < vcluster-logo-ascii.txt
```

<!-- new_lines: 5 -->

<!-- jump_to_middle -->

```bash +exec_replace
echo "Questions?" | figlet -f small -w 90
```

```markdown
vind:     github.com/loft-sh/vind
Stacks:   vcluster.com/docs/platform/understand/what-are-stacks
classif:  github.com/Piotr1215/classif
Slack:    slack.vcluster.com
```
