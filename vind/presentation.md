# vind

> What If Your Docker Was Also Your Kubernetes?

```bash +exec_replace
echo "vind" | figlet -f small -w 90
```

<!-- end_slide -->

## The Problem

> Every local K8s tool has the same rough edges

```bash +exec_replace
cat << 'EOF' | ccze -A
LoadBalancer services stay <pending> forever
   → Need MetalLB, Cilium, or tunneling

Every image change requires loading:
   → kind load docker-image myapp:v2
   → Wait... wait... now deploy

Port-forward becomes the default workflow
   → kubectl port-forward svc/app 8080:80
EOF
```

<!-- end_slide -->

## What is vind?

> vCluster in Docker - Full K8s, no host cluster needed

```bash +exec_replace
just digraph architecture
```

<!-- end_slide -->

## How LoadBalancer Works

> Real IPs, not port-forward gymnastics

```bash +exec_replace
just digraph loadbalancer
```

<!-- end_slide -->

## Set the Driver

> Switch vcluster CLI to use Docker instead of K8s host cluster

```bash +exec
vcluster use driver docker
```

<!-- end_slide -->

## Cluster Config

> vcluster.yaml - minimal config with one worker

```yaml
experimental:
  docker:
    nodes:
    - name: "worker-1"
```

<!-- end_slide -->

## Create the Cluster

> Spins up control plane + workers as Docker containers

```bash +exec
vcluster create my-cluster --values vcluster.yaml
```

<!-- end_slide -->

## Registry Proxy

> Local images served from host Docker cache

```bash +exec_replace
cat << 'EOF' | ccze -A
┌──────────────┐     ┌──────────────┐
│  Your Host   │     │  vind Node   │
│              │     │              │
│ docker pull  │────▶│ registry     │
│ nginx:alpine │     │ proxy        │
│              │     │              │
│ Image cache  │◀────│ pulls from   │
│              │     │ host daemon  │
└──────────────┘     └──────────────┘
EOF
```

<!-- end_slide -->

## Pull Image on Host

> Image lands in Docker's containerd storage

```bash +exec
docker pull nginx:alpine
```

<!-- end_slide -->

## Deploy from Cache

> No "kind load" - pulls from host daemon

```bash +exec
kubectl create deployment web --image=nginx:alpine
```

<!-- end_slide -->

## Wait for Rollout

> Pod starts instantly - image already cached locally

```bash +exec
kubectl rollout status deployment/web --timeout=60s
```

<!-- end_slide -->

## Expose as LoadBalancer

> No MetalLB needed - vind handles LoadBalancer natively

```bash +exec
kubectl expose deployment web --port=80 --type=LoadBalancer
```

<!-- end_slide -->

## Check the Service

> Real external IP - not pending

```bash +exec
kubectl get svc web
```

<!-- end_slide -->

## Curl the IP

> IP is routable from host - no port-forward needed

```bash +exec
EXTERNAL_IP=$(kubectl get svc web -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -s $EXTERNAL_IP | grep -oP '(?<=<h1>).*(?=</h1>)'
```

<!-- end_slide -->

## Under the Hood

> It's just Docker containers

```bash +exec
docker ps --filter "name=vcluster" --format "table {{.Names}}\t{{.Status}}"
```

<!-- end_slide -->

## Start Platform

> Runs locally in Docker, gets public URL via tunneling

```bash +exec
vcluster platform start --docker
```

<!-- end_slide -->

## Platform Free Tier

> All this included - no credit card needed

```bash +exec_replace
cat << 'EOF' | ccze -A
┌─────────────────────────────────────────────────────┐
│  FREE TIER INCLUDES:                                │
│                                                     │
│  Infrastructure        Collaboration               │
│  ─────────────────     ─────────────────           │
│  • 64 vCPU cores       • Unlimited users           │
│  • 32 GPUs             • Invite teammates          │
│  • Unlimited clusters  • Share kubeconfigs         │
│  • Embedded etcd       • RBAC & permissions        │
│                                                     │
│  Features              Self-Service                │
│  ─────────────────     ─────────────────           │
│  • CRD Sync            • Templates                 │
│  • Sync Patches        • One-click clusters        │
│  • Private Nodes       • Sleep/Resume              │
│  • Auto Nodes          • Platform UI               │
└─────────────────────────────────────────────────────┘
EOF
```

<!-- end_slide -->

## VPN: Join Cloud Nodes

```bash +exec_replace
cat << 'EOF' | ccze -A
Uses Tailscale under the hood for secure mesh networking
Platform provides public endpoint for nodes to connect
Works through NAT, firewalls, and complex networks
EOF
```

```yaml
experimental:
  docker:
    nodes:
    - name: "local-worker"
privateNodes:
  vpn:
    enabled: true
    nodeToNode:
      enabled: true
```

<!-- end_slide -->

## VPN Architecture

> Local Docker + Cloud VM = One Cluster

```bash +exec_replace
cat << 'EOF' | ccze -A
┌─────────────────┐         ┌─────────────────┐
│   Your Laptop   │         │    Cloud VM     │
│                 │   VPN   │                 │
│  ┌───────────┐  │◀───────▶│  ┌───────────┐  │
│  │   vind    │  │ tunnel  │  │   node    │  │
│  │  cluster  │  │         │  │  (kubelet)│  │
│  └───────────┘  │         │  └───────────┘  │
└─────────────────┘         └─────────────────┘

Your pods can run on either!
EOF
```

<!-- end_slide -->

## Create Cloud VM

```bash +exec_replace
cat << 'EOF' | ccze -A
Any VM works: KVM, Hetzner, DigitalOcean, AWS, GCP...
Node just needs: Linux, network access, curl
Join script installs kubelet, containerd, tailscale
EOF
```

```bash +exec
sudo virsh list --all && sudo virsh domifaddr cloud-node 2>/dev/null | grep ipv4
```

<!-- end_slide -->

## Join External Node

```bash +exec_replace
cat << 'EOF' | ccze -A
Token contains: platform URL + cluster ID + auth
Curl downloads join script, runs as root
Sets up systemd services: vcluster-vpn, kubelet, containerd
EOF
```

```bash +exec
vcluster token create --expires=1h
```

<!-- end_slide -->

## Verify on the VM

> SSH to the node, see containers running with crictl

```bash +exec
VM_IP=$(sudo virsh domifaddr cloud-node | awk '/ipv4/ {print $4}' | cut -d/ -f1)
ssh decoder@$VM_IP "sudo crictl ps --output=table"
```

<!-- end_slide -->

## Problems Solved

| Pain Point | kind | vind |
|------------|------|------|
| LoadBalancer stuck `<pending>` | Install MetalLB | Works out of box |
| Image not found after build | `kind load` every time | Host cache shared |
| Need 3 nodes for HA testing | Edit config, recreate | Add 2 yaml lines |
| "Let me just pause this cluster" | Delete and recreate | `vcluster pause` |
| Share cluster with teammate | Manual kubeconfig | Platform invite |

<!-- end_slide -->

## Cleanup

> Removes Docker containers, networks, volumes - clean slate

```bash +acquire_terminal
vcluster delete my-cluster
```

<!-- end_slide -->

## Resources

| Resource |
|----------|
| GitHub: github.com/loft-sh/vind |
| Docs: vcluster.com/docs/vcluster/configure/vcluster-yaml/experimental/docker |
| Platform Free: vcluster.com/blog/launching-vcluster-free |

<!-- end_slide -->

# That's All Folks!

```bash +exec_replace
just intro_toilet "vind"
```
