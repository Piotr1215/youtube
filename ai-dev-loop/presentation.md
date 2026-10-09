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
paint cyan '              host    ' plain 'KVM VM, cloud VM, or bare metal'
paint cyan '              join    ' plain 'one curl installs kubelet and connects the tunnel'
paint cyan '              scope   ' plain 'one cluster and one kube context'
paint cyan '              VPN     ' plain 'Tailscale library + WireGuard; no Tailscale account'
paint
paint yellow '          Remote hardware becomes a worker, not a second cluster.'
```

<!-- end_slide -->

## vCluster Platform

> The control point for joining and operating external nodes.

```bash +exec_replace
paint cyan '  reachability   ' plain 'a public Platform URL that the node can dial'
paint cyan '  admission      ' plain 'an expiring join token for this cluster'
paint cyan '  network        ' plain 'WireGuard coordination between node and control plane'
paint cyan '  services       ' plain 'Stacks track dependent applications and their health'
paint cyan '  operations     ' plain 'cluster, node, and Stack state in the UI'
paint
paint yellow '  One repeatable join path replaces per-VM network plumbing.'
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

## Simple and Local

> Which parts of the service should stay fast and local?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## Step 1: A Cluster on the Laptop

> Give a developer a repeatable Kubernetes environment from one file.

```bash +exec_replace
paint cyan '  Doing   ' plain 'create the dev cluster from vcluster.yaml'
paint cyan '  Why     ' plain 'one file declares the workers, VPN, and model dependency'
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

## Complex and Local

> How do we add a real host without handing out another cluster?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## A Local VM Node

> One join contract works for hosts outside Docker.

```bash +exec_replace
paint plain '  ai-dev, one kube context'
paint gray '  │'
paint gray '  ├── ' 'bold cyan' 'control plane     ' plain 'the same API server, in Docker'
paint gray '  ├── ' 'bold cyan' 'worker-1          ' plain 'a Docker container on the laptop'
paint gray '  └── ' 'bold green' 'cloud-node        ' plain 'a KVM VM: its own kernel and systemd'
paint gray '                        ' plain 'joined over a WireGuard tunnel'
paint
paint yellow '  The platform adds capacity; the developer keeps one API and context.'
```

<!-- end_slide -->

## Step 3: Join a Local VM

> First prove the join path on a VM we control locally.

```bash +exec_replace
paint cyan '  Doing   ' plain 'copy a join command, open a shell on the VM, paste it'
paint cyan '  Why     ' plain 'the onboarding contract is independent of the host location'
```

```bash +acquire_terminal
./join.sh vm
```

<!-- end_slide -->

## Complex and Remote

> How do we supply GPU capacity outside the laptop?

```bash +exec_replace
./journey.sh 5
```

<!-- end_slide -->

## A Cloud GPU Node

> A remote T4 joins the same cluster and becomes a placement target.

```bash +exec_replace
paint plain '  ai-dev, one kube context'
paint gray '  │'
paint gray '  ├── ' 'bold cyan' 'control plane     ' plain 'the same API server and scheduler'
paint gray '  ├── ' 'bold cyan' 'worker-1          ' plain 'a Docker container on the laptop'
paint gray '  ├── ' 'bold cyan' 'cloud-node        ' plain 'the KVM VM from step 3'
paint gray '  └── ' 'bold green' 'vind-node         ' plain 'a GCE VM with an NVIDIA T4'
paint gray '        ├── ' cyan 'at first boot   ' plain 'driver, Ollama, and the model download'
paint gray '        └── ' cyan 'at join         ' plain 'kubelet and the tunnel to the laptop'
paint
paint yellow '  The demo pins a proxy pod here; Ollama itself runs on the GPU host.'
```

<!-- end_slide -->

## Step 4: A GPU VM in the Cloud

> Provision and warm the scarce resource before developers need it.

```bash +exec_replace
paint cyan '  Doing   ' plain 'check the GPU VM: driver, Ollama, and the model are ready'
paint cyan '  Why     ' plain 'the platform must plan for a 7.4 GB model pull and cache'
```

```bash +exec
./create-gpu-vm.sh
```

<!-- end_slide -->

## Step 5: Join the GPU

> The cloud host uses the same join contract as the local VM.

```bash +exec_replace
paint cyan '  Doing   ' plain 'copy a fresh join command, open a root shell on the T4, paste it'
paint cyan '  Why     ' plain 'remote capacity appears behind the same Kubernetes API'
```

```bash +acquire_terminal
./join.sh gpu
```

<!-- end_slide -->

## Step 6: One Kube Context

> Developer access stays simple while the platform spans three locations.

```bash +exec_replace
paint cyan '  Doing   ' plain 'list the nodes and where each one runs'
paint cyan '  Why     ' plain 'the platform owns placement and network; the user keeps one context'
```

```bash +exec
./nodes.sh
```

<!-- end_slide -->

## Adding Services

> How does a GPU become a dependable model service?

```bash +exec_replace
./journey.sh 6
```

<!-- end_slide -->

## Stacks

> Turn a GPU node into a model endpoint with a health gate.

```bash +exec_replace
paint plain '  vcluster.yaml'
paint gray '  └── ' 'bold cyan' 'Stack classif     ' plain 'created with the cluster in step 1'
paint gray '      ├── ' 'bold cyan' 'model         ' plain 'a pod pinned to vind-node, Pending until it joins'
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

## Step 7: The Stack Finishes

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
  gsub(/LAPTOP \/ ai-dev|API [+] worker-1|Local KVM|cloud-node/, "\033[1;36m&\033[0m")
  gsub(/GCE \/ vind-node|proxy -> Ollama|Winnow on T4/, "\033[1;32m&\033[0m")
  gsub(/Audience phone|via Cloudflare|HTTPS|page [+] classif|model Service|Tailscale\/WireGuard/, "\033[1;33m&\033[0m")
  print
}'
paint
paint yellow '  One kube context spans Docker, KVM, and the T4.'
```

<!-- end_slide -->

## Step 8: Score, Edit, Retry

> Iterate locally against a platform-supplied model endpoint.

```bash +exec_replace
paint cyan '  Doing   ' plain 'score six labeled examples, edit the question, score again'
paint cyan '  Why     ' plain 'the developer changes code; the platform keeps the GPU available'
```

```bash +exec
./eval.sh "Is this an infrastructure problem?" "Is this a Kubernetes problem?"
```

<!-- end_slide -->

## Step 9: Share the Loop

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

> Is this a Kubernetes problem? Ask Winnow on the T4.

```bash +exec
./audience.sh qr
```

<!-- end_slide -->

## Step 10: Pause and Resume

> A developer environment needs a predictable stop and start.

```bash +exec_replace
paint cyan '  Doing   ' plain 'pause the cluster like a closed laptop, then resume it'
paint cyan '  Why     ' plain 'the platform restores the route without rebuilding the model VM'
```

```bash +exec
./sleep-wake.sh
```

<!-- end_slide -->

## Failure Modes

> The platform owns recovery, time, and cost across both sites.

```bash +exec_replace
paint red '  ✗  ' cyan 'laptop sleeps      ' plain 'pause first; on resume the tunnel returns'
paint red '  ✗  ' cyan 'model downloads    ' plain 'gigabytes per new VM: pull at boot, never on stage'
paint red '  ✗  ' cyan 'GPU host event     ' plain 'GCE stops GPU VMs for maintenance, no live migration'
paint
paint yellow '  Treat the GPU VM as replaceable; keep the topology in Git.'
```

<!-- end_slide -->

## Closing the Loop

> How does this become a reviewed service instead of a ticket?

```bash +exec_replace
./journey.sh 7
```

<!-- end_slide -->

## The AI App Is a Package

> Package the interface against a model Service contract.

```bash +exec_replace
paint plain '  ai-dev-loop/'
paint gray '  ├── ' 'bold cyan' 'classifier/'
paint gray '  │   ├── ' plain 'deployment.yaml' cyan '      audience API on worker-1'
paint gray '  │   ├── ' plain 'service.yaml' cyan '         LoadBalancer for the page'
paint gray '  │   └── ' plain 'kustomization.yaml' cyan '   kubectl apply -k classifier/'
paint gray '  └── ' 'bold cyan' 'argocd/classifier.yaml' plain '    points at classifier/'
paint
paint plain '  classifier pod' gray ' ──▶ ' plain 'Ollama Service' gray ' ──▶ ' plain 'WireGuard' gray ' ──▶ ' plain 'T4'
paint
paint yellow '  Verified: the page ran on worker-1; the T4 answered in about 1.2 s.'
```

<!-- end_slide -->

## From Laptop to Git

> Review the service definition; supply GPU capacity in each target cluster.

```bash +exec_replace
paint 'bold cyan' '  LAPTOP CLUSTER: VERIFIED'
paint gray '  │  ' plain 'classifier/' gray ' ──▶ ' plain 'worker-1' gray ' ──▶ ' plain 'model on the T4'
paint gray '  │'
paint gray '  ▼  ' cyan 'pull request'
paint 'bold yellow' '  NEXT: GIT + CI'
paint gray '  │  ' plain 'classifier/ + argocd/classifier.yaml'
paint gray '  │  ' plain 'CI publishes classifier:<sha> and updates its tag'
paint gray '  │'
paint gray '  ▼  ' cyan 'Argo CD sync'
paint 'bold green' '  SHARED CLUSTER'
paint gray '     ' plain 'same classifier API + its own model Service'
paint
paint cyan '  stays local   ' plain 'Docker workers, KVM VM, this T4 and its node pin'
paint cyan '  still to do   ' plain 'publish an image and replace the Argo CD placeholder'
paint
paint yellow '  Git carries the service contract; each cluster supplies its own capacity.'
```

<!-- end_slide -->

## Before This Is Self-Service

> The demo proves the path. A platform offering needs an operating contract.

```bash +exec_replace
paint green '  ✓  ' cyan 'proven       ' plain 'one context, remote T4, Stack health, packaged API'
paint
paint cyan '  access       ' plain 'authenticate callers; enforce tenant boundaries separately'
paint cyan '  capacity     ' plain 'quota and placement policy; this demo pins one proxy pod'
paint cyan '  operations   ' plain 'measure tunnel health, inference latency, and failures'
paint cyan '  cost         ' plain 'budget idle time and model pulls; replace failed GPU VMs'
paint cyan '  promotion    ' plain 'publish the image, then sync the Argo CD Application'
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

## Resources

```markdown
vind:     github.com/loft-sh/vind
Stacks:   vcluster.com/docs/platform/understand/what-are-stacks
classif:  github.com/Piotr1215/classif
Slack:    slack.vcluster.com
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
