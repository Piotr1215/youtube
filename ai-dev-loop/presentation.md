# Curl a GPU Into Your Cluster

> A platform pattern for GPU-powered AI development

<!-- new_lines: 3 -->

```bash +exec_replace
echo "AI Dev Loop" | figlet -f small -w 90
```

<!-- jump_to_middle -->

```bash +exec_replace
while IFS= read -r line; do
    printf '\033[38;5;208m%s\033[0m\n' "$line"
done < vcluster-logo-ascii.txt
```

<!-- end_slide -->

## Demo Reset

> Back to a clean start, with the T4 VM kept warm.

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
```

```bash +acquire_terminal
./reset.sh
```

<!-- end_slide -->

## Platform Setup

> The CLI logs in to the Platform so new clusters get a license.

```bash +exec_replace
paint cyan '  Shows   ' plain 'the Platform starting and the CLI logging in'
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

> The usual inner and outer loops gain a remote GPU step.

```bash +exec_replace
paint 'bold cyan' '             edit                              pull request'
paint gray '          ╭────────╮                            ╭────────╮'
paint gray '        ╭─╯        ╰─╮                        ╭─╯        ╰─╮'
paint gray '        │            │  ' 'bold cyan' 'build' gray '                 │            │  ' 'bold cyan' 'CI'
paint 'bold cyan' '  test  ' gray '▲            ▼' 'bold cyan' '               monitor  ' gray '▲            ▼'
paint gray '        │            │  ' 'bold cyan' 'run' gray '                   │            │  ' 'bold cyan' 'deploy'
paint gray '        ╰─╮        ╭─╯                        ╰─╮        ╭─╯'
paint gray '          ╰────────╯                            ╰────────╯'
paint 'bold yellow' '          remote GPU                            remote GPU'
paint
paint 'bold white' '          Inner Loop                            Outer Loop'
paint
paint yellow '         inference' gray '  •  ' yellow 'evals' gray '  •  ' yellow 'fine-tuning' gray '  •  ' yellow 'embeddings'
```

<!-- end_slide -->

## Basic Concepts

> What gives a developer a real cluster on a laptop?

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

## Simple and Local

> Which parts of the dev loop should stay fast and local?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## A Cluster on the Laptop

> vcluster.yaml gives every developer the same Kubernetes environment.

```bash +exec_replace
paint cyan '  Shows   ' plain 'the dev cluster created from vcluster.yaml'
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

## The Cluster as Containers

> The cluster we just created is a few Docker containers on the laptop.

```bash +exec_replace
paint cyan '  Shows   ' plain 'the Docker containers behind ai-dev'
paint cyan '  Why     ' plain 'no VM to manage: control plane and workers are plain containers'
```

```bash +exec
docker ps --filter name=ai-dev --format "table {{.Names}}\t{{.Status}}"
```

<!-- end_slide -->

## Build, Run, Test

> The inner loop stays fast until the workload needs scarce hardware.

```bash +exec_replace
paint cyan '  Shows   ' plain 'build, run and test, then the same loop after an edit'
paint cyan '  Why     ' plain 'no kind load step: vind pulls the new image from the laptop'"'"'s Docker'
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

## A Cloud GPU Node

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
paint cyan '  Shows   ' plain 'the GPU VM with its driver, Ollama, and the model ready'
paint cyan '  Why     ' plain 'the platform must plan for a 7.4 GB model pull and cache'
```

```bash +exec
./create-gpu-vm.sh
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

## The VPN in vcluster.yaml

> The cluster config gives every joined node the VPN.

```file
path: vcluster.yaml
language: yaml
start_line: 12
end_line: 17
```

```bash +exec_replace
paint cyan '  privateNodes  ' plain 'real hosts join this cluster'
paint cyan '  vpn           ' plain 'the tunnel each joined node uses to reach the cluster'
paint cyan '  nodeToNode    ' plain 'joined nodes also reach each other'
```

<!-- end_slide -->

## Curl In the GPU

> The VM already has a GPU and model; a curl command joins it to ai-dev.

```bash +exec_replace
paint cyan '  Shows   ' plain 'a one-hour join URL, then its curl running as root on the T4'
paint cyan '  Why     ' plain 'remote capacity appears behind the same Kubernetes API'
```

```bash
curl -fsSLk '<join-url>' | sh -s -- --node-name remote-node --force-join
```

```bash +exec_replace
paint gray '  <join-url> contains the token from vcluster token create --expires=1h'
paint cyan '  on the T4: ' plain 'install kubelet' gray ' ──▶ ' plain 'connect VPN' gray ' ──▶ ' plain 'register node'
```

```bash +acquire_terminal
./join.sh gpu
```

<!-- end_slide -->

## Laptop and Cloud Nodes

> Developer access stays simple while the platform spans laptop and cloud.

```bash +exec_replace
paint cyan '  Shows   ' plain 'the nodes and where each one runs'
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

## A Model Service on the GPU

> A GPU node becomes a model endpoint with a health gate.

```bash +exec_replace
paint plain '  vcluster.yaml'
paint gray '  └── ' 'bold cyan' 'Stack classif     ' plain 'created with the cluster'
paint gray '      ├── ' 'bold cyan' 'model         ' plain 'a pod pinned to remote-node, Pending until it joins'
paint gray '      │                 ' plain 'then exposes Ollama behind a LoadBalancer'
paint gray '      │                 ' plain 'and loads Winnow into GPU memory'
paint gray '      └── ' 'bold cyan' 'check         ' plain 'once model is healthy: one test question'
paint
paint cyan '  platform owns   ' plain 'model placement, startup, and health check'
paint cyan '  developer gets  ' plain 'a model endpoint when the dependency is ready'
paint
paint yellow '  The model service waits for the GPU it needs.'
```

<!-- end_slide -->

## Model Service Startup

> The Stack reports when the model service is ready on the T4.

```bash +exec_replace
paint cyan '  Shows   ' plain 'the Stack created with the cluster, finishing live'
paint cyan '  Why     ' plain 'the Stack retries its tasks and reports model health'
```

```bash +exec
./stack-status.sh --watch
```

<!-- end_slide -->

## The Model in GPU Memory

> Winnow sits in the T4's memory, ready to answer.

```bash +exec_replace
paint cyan '  Shows   ' plain 'what the T4 holds in GPU memory'
paint cyan '  Why     ' plain 'a healthy Stack should mean the model really is on the GPU'
```

```bash +exec
./gpu.sh
```

<!-- end_slide -->

## Platform Architecture

> The platform connects the nodes; applications use the model endpoint.

```bash +exec_replace
just digraph architecture | awk '
{
  gsub(/vCluster Platform|join tokens [+] VPN|health checks/, "\033[1;35m&\033[0m")
  gsub(/Dev cluster|API server [+] workers|your app/, "\033[1;36m&\033[0m")
  gsub(/GPU node|kubelet|model server/, "\033[1;32m&\033[0m")
  gsub(/Developers and users|kubectl, apps, tests|kube context|model endpoint|over the VPN/, "\033[1;33m&\033[0m")
  print
}'
paint
paint yellow '  The same kube context reaches local workers and remote GPU nodes.'
```

<!-- end_slide -->

## Share the Loop

> A small public page makes the same model call from any phone.

```bash +exec_replace
paint cyan '  Shows   ' plain 'the page starting, its public URL, and a real model answer'
paint cyan '  Why     ' plain 'a public request now crosses ingress, the laptop, and the T4'
```

```bash +exec
./audience.sh start
```

<!-- end_slide -->

## Try It From Your Phone

> Scan the code, ask a yes or no question, and the cloud GPU answers on your phone.

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
```

<!-- end_slide -->

## Closing the Loop

> How does this move from the laptop to a shared cluster?

```bash +exec_replace
./journey.sh 6
```

<!-- end_slide -->

## From Laptop to Git

> The app and its manifests move to Git and go through review.

```bash +exec_replace
paint plain '  app/' gray ' ──▶ ' plain 'pull request' gray ' ──▶ ' plain 'CI builds the image' gray ' ──▶ ' plain 'Argo CD' gray ' ──▶ ' plain 'shared cluster'
paint
paint cyan '  moves to Git   ' plain 'app/, the manifests from the laptop'
paint cyan '  changes        ' plain 'web:dev becomes an immutable tag from CI'
paint cyan '  stays local    ' plain 'Docker workers and this T4'
paint cyan '  each cluster   ' plain 'supplies its own GPU and model endpoint'
paint
paint yellow '  Git holds the app; each cluster supplies its own GPU.'
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
```

<!-- end_slide -->

## Self-Service Requirements

> The demo proves the pattern. Teams still need these to run it on their own.

```bash +exec_replace
paint cyan '  access       ' plain 'authenticate callers; enforce tenant boundaries'
paint cyan '  capacity     ' plain 'quota, placement policy, node pools for on-demand GPUs'
paint cyan '  reliability  ' plain 'replace the GPU VMs GCE stops for maintenance'
paint cyan '  cost         ' plain 'budget idle GPU time and model downloads'
paint cyan '  telemetry    ' plain 'measure tunnel health, inference latency, and failures'
paint cyan '  promotion    ' plain 'publish the image, then sync the Argo CD Application'
paint
paint yellow '  With these in place, teams get a GPU without filing a ticket.'
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
