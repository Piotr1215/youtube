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
docker rm -f vcluster-platform 2>/dev/null; vcluster platform start
```

<!-- end_slide -->

## Cluster Config

```bash +exec_replace
bat --color=always --style=plain vcluster.yaml
```

<!-- end_slide -->

## Create the Cluster

```bash +exec
vcluster delete my-cluster 2>/dev/null; vcluster create my-cluster --values vcluster.yaml
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

> Works with LoadBalancer out of the box

```bash +exec
kubectl create deployment web --image=nginx:alpine && \
  kubectl rollout status deployment/web --timeout=60s && \
  kubectl expose deployment web --port=80 --type=LoadBalancer && \
  sleep 3 && \
  kubectl get svc web
```

<!-- end_slide -->


## Registry Proxy

> Images pulled from host Docker cache - no "kind load" needed

```bash +exec_replace
just boxart registry-proxy
```

<!-- end_slide -->

## VPN Config

> VPN flat network allows for adding arbitrary nodes

```bash +exec_replace
bat --color=always --style=plain vpn-cluster/vcluster.yaml
```

<!-- end_slide -->

## Create VPN Cluster

```bash +exec
vcluster create vpn-cluster --values vpn-cluster/vcluster.yaml
```

<!-- end_slide -->

## Connect + Join Token

> Token outputs a curl command - paste it on any machine

```bash +exec
vcluster connect vpn-cluster && \
  echo "Waiting for node to register..." && \
  until kubectl get nodes --no-headers 2>/dev/null | grep -q Ready; do sleep 2; done && \
  kubectl get nodes && \
  vcluster token create --expires=1h | xclip -selection clipboard && echo "Token copied to clipboard"
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



## Private Nodes

> Add any Linux machine to the cluster - local or cloud

```bash +exec_replace
printf '\e[1;36m%s\e[0m\n\n' "How private nodes work:"
printf '\e[35m•\e[0m %s\n' "VPN tunnel connects external machines to the cluster"
printf '\e[35m•\e[0m %s\n' "One curl command to join - installs kubelet automatically"
printf '\e[35m•\e[0m %s\n' "Works with: KVM, cloud VMs, bare metal, Raspberry Pi"
```

<!-- end_slide -->


## Pull Ollama Model

```bash +exec
gcloud compute ssh vind-node --project=eng-sandbox-02 --zone=us-central1-a --command="ollama pull llama3.2:1b"
```

<!-- end_slide -->
## Cloud Join Token

```bash +exec
vcluster token create --expires=1h | xclip -selection clipboard && echo "Token copied to clipboard"
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

## VPN Architecture

```bash +exec_replace
just boxart vpn-architecture
```

<!-- end_slide -->
## GPU Demo App

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
echo "http://$SRE_IP"
echo ""
echo "http://$SRE_IP" | qrencode -t UTF8 -s 1 -m 2
```

<!-- end_slide -->

## Sleep / Wake

> Pause clusters to save resources, resume instantly

```bash +exec
vcluster pause my-cluster
```

<!-- end_slide -->

## Resume Cluster

> Picks up exactly where it left off

```bash +exec
vcluster resume my-cluster && \
  kubectl get pods -A
```

<!-- end_slide -->

## kind vs vind

```bash +exec_replace
printf '\e[1;36m%-25s\e[0m \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "Feature" "vind" "kind"
printf '\e[36m%-25s\e[0m \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "─────────────────────────" "────────────────────" "────────────────────"
printf '%-25s \e[32m%-20s\e[0m \e[33m%-20s\e[0m\n' "Built-in UI" "vCluster Platform" "none"
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
