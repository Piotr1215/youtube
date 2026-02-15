# vCluster in Docker

<!-- new_lines: 5 -->

```bash +exec_replace
while IFS= read -r line; do
    printf '\033[38;5;208m%s\033[0m\n' "$line"
done < vind-logo-ascii.txt
```

<!-- end_slide -->

## Set the Driver

```bash +exec
vcluster use driver docker
```

<!-- end_slide -->

## Start Platform

```bash +exec
vcluster platform start
```

<!-- end_slide -->

## Cluster Config

```bash +exec_replace
bat --color=always --style=plain vcluster.yaml
```

<!-- end_slide -->

## Create the Cluster

```bash +exec
vcluster create my-cluster --values vcluster.yaml
```

<!-- end_slide -->

## Connect to Cluster

```bash +exec
vcluster connect my-cluster && \
  echo "Waiting for node to register..." && \
  until kubectl get nodes 2>/dev/null | grep -q worker; do sleep 2; done && \
  kubectl wait --for=condition=Ready node --all --timeout=120s && \
  kubectl get nodes
```

<!-- end_slide -->

## Under the Hood

> It's just Docker containers

```bash +exec
docker ps --format "table {{.Names}}\t{{.Status}}"
```

<!-- end_slide -->

## Deploy + LoadBalancer

> Deploy nginx and expose with a real IP - no MetalLB, no port-forward

```bash +exec
kubectl create deployment web --image=nginx:alpine && \
  kubectl rollout status deployment/web --timeout=60s && \
  kubectl expose deployment web --port=80 --type=LoadBalancer && \
  sleep 3 && \
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

## What Just Happened?

> vCluster in Docker - full K8s, no host cluster needed

```bash +exec_replace
just digraph architecture
```

<!-- end_slide -->

## Registry Proxy

> Images pulled from host Docker cache - no "kind load" needed

```bash +exec_replace
printf '\e[36m┌──────────────┐     ┌──────────────┐\e[0m\n'
printf '\e[36m│\e[0m  \e[1;33mHost       \e[0m \e[36m│\e[0m     \e[36m│\e[0m  \e[1;32mvind Node \e[0m \e[36m│\e[0m\n'
printf '\e[36m│\e[0m              \e[36m│\e[0m     \e[36m│\e[0m              \e[36m│\e[0m\n'
printf '\e[36m│\e[0m docker pull  \e[36m│\e[0m\e[33m────▶\e[0m\e[36m│\e[0m registry     \e[36m│\e[0m\n'
printf '\e[36m│\e[0m nginx:alpine \e[36m│\e[0m     \e[36m│\e[0m proxy        \e[36m│\e[0m\n'
printf '\e[36m│\e[0m              \e[36m│\e[0m     \e[36m│\e[0m              \e[36m│\e[0m\n'
printf '\e[36m│\e[0m Image cache  \e[36m│\e[0m\e[33m◀────\e[0m\e[36m│\e[0m pulls from   \e[36m│\e[0m\n'
printf '\e[36m│\e[0m              \e[36m│\e[0m     \e[36m│\e[0m host daemon  \e[36m│\e[0m\n'
printf '\e[36m└──────────────┘     └──────────────┘\e[0m\n'
```

<!-- end_slide -->

## Platform Free Tier

> Web UI, team access, no credit card needed

```bash +exec_replace
printf '\e[1;36m┌─────────────────────────────────────────────────────┐\e[0m\n'
printf '\e[1;36m│\e[0m  \e[1;33mFREE TIER INCLUDES:                               \e[0m \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m                                                     \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  \e[32mInfrastructure       \e[0m \e[35mCollaboration             \e[0m \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  \e[36m─────────────────\e[0m    \e[36m─────────────────\e[0m          \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  • 64 vCPU cores      • Unlimited users          \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  • 32 GPUs            • Invite teammates         \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  • Unlimited clusters • Share kubeconfigs        \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  • Embedded etcd      • RBAC & permissions       \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m                                                     \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  \e[32mFeatures             \e[0m \e[35mSelf-Service              \e[0m \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  \e[36m─────────────────\e[0m    \e[36m─────────────────\e[0m          \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  • CRD Sync           • Templates                \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  • Sync Patches       • One-click clusters       \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  • Private Nodes      • Sleep/Resume             \e[1;36m│\e[0m\n'
printf '\e[1;36m│\e[0m  • Auto Nodes         • Platform UI              \e[1;36m│\e[0m\n'
printf '\e[1;36m└─────────────────────────────────────────────────────┘\e[0m\n'
```

<!-- end_slide -->

## Private Nodes

> Add any Linux machine to the cluster - local or cloud

```bash +exec_replace
printf '\e[1;36m%s\e[0m\n\n' "How private nodes work:"
printf '\e[35m•\e[0m %s\n' "VPN tunnel connects external machines to the cluster"
printf '\e[35m•\e[0m %s\n' "One curl command to join - installs kubelet automatically"
printf '\e[35m•\e[0m %s\n' "Works with: KVM, cloud VMs, bare metal, Raspberry Pi"
```

<!-- end_slide -->

## VPN Config

> Two additions to vcluster.yaml - that's it

```bash +exec_replace
bat --color=always --style=plain vpn-cluster/vcluster.yaml
```

<!-- end_slide -->

## Create VPN Cluster

```bash +exec
vcluster create vpn-cluster --values vpn-cluster/vcluster.yaml
```

<!-- end_slide -->

## VPN Architecture

```bash +exec_replace
printf '\e[36m┌─────────────────┐\e[0m         \e[36m┌─────────────────┐\e[0m\n'
printf '\e[36m│\e[0m   \e[1;33mLocal Host  \e[0m \e[36m│\e[0m         \e[36m│\e[0m    \e[1;32mCloud VM    \e[0m \e[36m│\e[0m\n'
printf '\e[36m│\e[0m                 \e[36m│\e[0m   \e[35mVPN\e[0m   \e[36m│\e[0m                 \e[36m│\e[0m\n'
printf '\e[36m│\e[0m  \e[36m┌───────────┐\e[0m  \e[36m│\e[0m\e[35m◀───────▶\e[0m\e[36m│\e[0m  \e[36m┌───────────┐\e[0m  \e[36m│\e[0m\n'
printf '\e[36m│\e[0m  \e[36m│\e[0m   \e[1;33mvind   \e[0m \e[36m│\e[0m  \e[36m│\e[0m \e[35mtunnel\e[0m  \e[36m│\e[0m  \e[36m│\e[0m   \e[1;32mnode   \e[0m \e[36m│\e[0m  \e[36m│\e[0m\n'
printf '\e[36m│\e[0m  \e[36m│\e[0m  \e[1;33mcluster\e[0m \e[36m│\e[0m  \e[36m│\e[0m         \e[36m│\e[0m  \e[36m│\e[0m  \e[1;32m(kubelet)\e[0m\e[36m│\e[0m  \e[36m│\e[0m\n'
printf '\e[36m│\e[0m  \e[36m└───────────┘\e[0m  \e[36m│\e[0m         \e[36m│\e[0m  \e[36m└───────────┘\e[0m  \e[36m│\e[0m\n'
printf '\e[36m└─────────────────┘\e[0m         \e[36m└─────────────────┘\e[0m\n'
printf '\n'
printf '\e[37mPods scheduled on either side - VPN handles routing\e[0m\n'
```

<!-- end_slide -->

## Connect + Join Token

> Token outputs a curl command - paste it on any machine

```bash +exec
vcluster connect vpn-cluster && \
  echo "Waiting for node to register..." && \
  until kubectl get nodes --no-headers 2>/dev/null | grep -q Ready; do sleep 2; done && \
  kubectl get nodes && \
  vcluster token create --expires=1h
```

<!-- end_slide -->

## Local VM

> KVM virtual machine running on the same host

```bash +exec
sudo virsh list --all && sudo virsh domifaddr cloud-node 2>/dev/null | grep ipv4
```

<!-- end_slide -->

## Join Local VM

> SSH in, paste the curl command from the token

```bash +acquire_terminal
VM_IP=$(sudo virsh domifaddr cloud-node | awk '/ipv4/ {print $4}' | cut -d/ -f1) && ssh root@$VM_IP
```

<!-- end_slide -->

## Verify Local Node

```bash +exec
kubectl get nodes -o wide
```

<!-- end_slide -->

## Cloud VM

> Same curl command works with any cloud provider

```bash +exec
gcloud compute instances create vind-node \
  --project=eng-sandbox-02 \
  --zone=us-central1-a \
  --machine-type=n1-standard-4 \
  --image-family=common-cu128-ubuntu-2404-nvidia-570 \
  --image-project=deeplearning-platform-release \
  --accelerator=type=nvidia-tesla-t4,count=1 \
  --maintenance-policy=TERMINATE \
  --boot-disk-size=100GB \
  --scopes=cloud-platform \
  --metadata-from-file startup-script=gce-startup.sh && \
  echo "Waiting for SSH..." && \
  until gcloud compute ssh vind-node --project=eng-sandbox-02 --zone=us-central1-a --command="echo ready" 2>/dev/null; do sleep 5; done
```

<!-- end_slide -->

## Startup Script

> While the VM boots - here's what the startup script does

```bash +exec_replace
printf '\e[1;36m%s\e[0m\n\n' "gce-startup.sh"
printf '  \e[33m%s\e[0m\n' "1. Configure NVIDIA container runtime"
printf '  \e[37m%s\e[0m\n\n' "   nvidia-ctk → containerd integration"
printf '  \e[33m%s\e[0m\n' "2. Install ollama"
printf '  \e[37m%s\e[0m\n\n' "   LLM inference server on the host"
printf '  \e[33m%s\e[0m\n' "3. Bind to 0.0.0.0"
printf '  \e[37m%s\e[0m\n\n' "   Pods reach ollama via node IP (not localhost)"
printf '  \e[33m%s\e[0m\n' "4. Pull llama3.2:1b"
printf '  \e[37m%s\e[0m\n' "   Small model, fast inference on T4 GPU"
```

<!-- end_slide -->

## Cloud Join Token

```bash +exec
vcluster token create --expires=1h
```

<!-- end_slide -->

## Join Cloud VM

> SSH in, paste the curl command

```bash +acquire_terminal
gcloud compute ssh vind-node --project=eng-sandbox-02 --zone=us-central1-a
```

<!-- end_slide -->

## All Nodes

> Docker workers + KVM node + GCE node = one cluster

```bash +exec
kubectl get nodes -o wide
```

<!-- end_slide -->

## Label GPU Node

```bash +exec
GCE_NODE=$(kubectl get nodes -o name | grep vind-node) && \
  kubectl label $GCE_NODE role=gpu-node && \
  kubectl get nodes -l role=gpu-node
```

<!-- end_slide -->

## SRE Haiku Generator

> Flask app talking to ollama on the private node

```bash +exec
kubectl apply -f sre-demo-app/deployment.yaml && \
  kubectl rollout status deployment/sre-haiku --timeout=120s
```

<!-- end_slide -->

## Demo App Live

> LoadBalancer gives a real IP - no port-forward, no ngrok

```bash +exec
SRE_IP=$(kubectl get svc sre-haiku -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "http://$SRE_IP:5000"
echo ""
echo "http://$SRE_IP:5000" | qrencode -t UTF8 -s 1 -m 2
```

<!-- end_slide -->

## Sleep / Wake

> Pause clusters to save resources, resume instantly

```bash +exec
vcluster pause my-cluster
```

```bash +exec
docker ps --format "table {{.Names}}\t{{.Status}}"
```

<!-- end_slide -->

## Resume Cluster

> Picks up exactly where it left off

```bash +exec
vcluster resume my-cluster && \
  sleep 5 && \
  kubectl get pods -A
```

<!-- end_slide -->

## kind vs vind

```bash +exec_replace
printf '\e[1;36m%-25s\e[0m \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "Feature" "vind" "kind"
printf '\e[36m%-25s\e[0m \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "─────────────────────────" "────────────────────" "────────────────────"
printf '%-25s \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "Built-in UI" "via vCluster Platform" "none"
printf '%-25s \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "Sleep/Wake" "native" "delete & recreate"
printf '%-25s \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "Load Balancers" "automatic" "manual setup"
printf '%-25s \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "Image Caching" "via Docker cache" "external registries"
printf '%-25s \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "External Nodes" "supported (VPN)" "local only"
printf '%-25s \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "CNI/CSI Options" "flexible" "limited"
printf '%-25s \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "Snapshots" "coming soon" "none"
```

<!-- end_slide -->

## Resources

```bash +exec_replace
printf '\e[1;36m%s\e[0m\n' "Links:"
printf '\n'
printf '  \e[32m%-20s\e[0m \e[37m%s\e[0m\n' "GitHub" "github.com/loft-sh/vind"
printf '  \e[32m%-20s\e[0m \e[37m%s\e[0m\n' "Docs" "vcluster.com/docs/vcluster/configure/vcluster-yaml/experimental/docker"
printf '  \e[32m%-20s\e[0m \e[37m%s\e[0m\n' "Platform Free" "vcluster.com/blog/launching-vcluster-free"
printf '  \e[32m%-20s\e[0m \e[37m%s\e[0m\n' "Slack" "slack.vcluster.com"
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
