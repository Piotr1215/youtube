---
title: vCluster + NVIDIA KAI Scheduler
author: Piotr Zaniewski | vCluster Labs
date: 2025-01-31
---

<!--
Note: Commands marked with +exec can be run with Ctrl+E
For better output display, use the spane script in a separate terminal
-->

# vCluster + NVIDIA KAI Scheduler

> Virtual clusters enable safe scheduler experimentation

```bash +exec_replace
echo "vCluster + KAI" | figlet -f small -c -w 90
```

<!-- end_slide -->

## What is vCluster?

```mermaid +render
%%{init: {'flowchart' : {'curve' : 'linear'}}}%%
flowchart TB
    subgraph host["Host Kubernetes Cluster"]
        subgraph vclusters[" "]
            direction LR
            subgraph vc1["vCluster 1"]
                W1["Team 1<br/>Workloads"]
            end
            
            subgraph vc2["vCluster 2"]
                direction TB
                W2["Team 2<br/>Workloads"]
                Ingress2["• Ingress"]
                CertManager2["• Cert Manager"]
            end
            
            subgraph vc3["vCluster 3"]
                W3["Team 3<br/>Workloads"]
            end
        end
        
        Shared["Shared Services<br/>(Cert Manager, Ingress Controller)"]
    end
    
    W1 --> Shared
    W3 --> Shared
    
    classDef cluster fill:#495057,stroke:#fff,stroke-width:2px,color:#fff
    classDef workload fill:#6c757d,stroke:#fff,stroke-width:2px,color:#fff
    classDef service fill:#343a40,stroke:#fff,stroke-width:2px,color:#fff
    
    class vc1,vc2,vc3 cluster
    class W1,W2,W3 workload
    class Shared,CertManager2,Ingress2 service
```

> **vCluster** = Containerized Kubernetes inside a Pod!

<!-- end_slide -->

## Real World: Multi-Tenant GPU Cluster

| **Resource** | **Allocation** | **Team** |
|---|---|---|
| GPU 1 | Shared (4x 0.25) | ML Team - small models |
| GPU 2 | Dedicated (1x 1.0) | Research Team - large training |
| CPU Nodes | Standard | DevOps Team - standard workloads |

> **Benefits of vCluster approach:**
> - Each team chooses their own scheduler
> - No conflicts between team configurations
> - Complete isolation of resources
> - Easy rollback if issues arise

<!-- end_slide -->

## Configure Docker for GPU Support

```bash +exec
# Configure Docker to use NVIDIA runtime (required for GPU passthrough)
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default

# Restart Docker to apply the new runtime
sudo systemctl restart docker

# Verify Docker is active and runtime is available
until sudo systemctl is-active docker | grep -q "active" && docker info >/dev/null 2>&1; do
  echo "Waiting for Docker to restart..."
  sleep 2
done

# Show the new default runtime
echo "Docker restarted successfully!"
echo "Default runtime changed to: $(docker info --format '{{.DefaultRuntime}}')"
```

> **Note**: This enables GPU support in containers. We'll revert this at the end.

<!-- end_slide -->

## Deploy GPU-Enabled Cluster

```bash +exec
# Use nvkind for GPU support
nvkind cluster create --name kai-demo --config-template=nvkind-config.yaml
```

> **Note**: Using nvkind to enable GPU pass-through to the cluster

<!-- end_slide -->

## Check nodes


```bash +exec +id:get_nodes
kubectl get nodes
```

<!-- snippet_output: get_nodes -->

<!-- end_slide -->

## Install NVIDIA Device Plugin

```bash +exec
# Label worker node as having GPU
kubectl label node kai-demo-worker nvidia.com/gpu.present=true

# Install NVIDIA device plugin
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.16.2/deployments/static/nvidia-device-plugin.yml
```

> **Note**: Device plugin enables GPU resource scheduling in Kubernetes

<!-- end_slide -->

## Verify GPU Access

```bash +exec
# Create RuntimeClass for NVIDIA if it doesn't exist
kubectl apply -f - <<EOF
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: nvidia
handler: nvidia
EOF

# Wait for device plugin to be ready
kubectl wait --for=condition=ready pod -n kube-system -l name=nvidia-device-plugin-ds --timeout=60s

# Test GPU access with a simple pod
kubectl run gpu-test --image=nvidia/cuda:12.2.0-base-ubuntu20.04 \
  --rm -it --restart=Never \
  --overrides='{"spec":{"runtimeClassName":"nvidia","nodeSelector":{"nvidia.com/gpu.present":"true"}}}' \
  -- nvidia-smi -L
```


<!-- end_slide -->

## Today's Example: NVIDIA KAI Scheduler

```mermaid +render +width:80%
graph TD
    GPU["1 Physical GPU<br/>(100%)"]
    GPU -->|50%| P1[Training Pod<br/>0.50 GPU]
    GPU -->|25%| P2[Inference Pod<br/>0.25 GPU]
    GPU -->|25%| P3[Dev Pod<br/>0.25 GPU]
```

> KAI enables fractional GPU allocation!

<!-- end_slide -->

## Deploy KAI Scheduler


```bash +exec
KAI_VERSION=${KAI_VERSION:-v0.7.11}
helm upgrade -i kai-scheduler \
  oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler \
  --create-namespace \
  --version $KAI_VERSION
```

> **KAI Scheduler**: NVIDIA's Kubernetes scheduler that enables fractional GPU sharing and advanced scheduling policies through a queue-based system

<!-- end_slide -->

## Wait for KAI Scheduler to be Ready


```bash +exec
kubectl wait --for=condition=ready pod -n kai-scheduler --all --timeout=300s
```

<!-- end_slide -->

## Verify KAI Webhooks are Ready


> KAI scheduler uses webhooks for queue validation - let's ensure they're ready

```bash +exec
# Check webhook endpoints are available
kubectl get validatingwebhookconfigurations | grep kai || echo "Waiting for KAI webhooks..."
kubectl get endpoints -n kai-scheduler
```

<!-- end_slide -->

## Configure KAI Scheduler Queues


> KAI uses a parent/child queue hierarchy for resource allocation and scheduling priorities
> The queues.yaml file defines a default parent queue and a test child queue with unlimited quotas

```bash +exec
head -n 20 queues.yaml
kubectl apply -f queues.yaml
```

<!-- end_slide -->

## vCluster's Superpower: Custom Schedulers!

```mermaid +render
graph LR
    subgraph "Traditional Approach"
        T1[Install Custom Scheduler]
        T1 --> T2[Affects ALL workloads]
        T2 --> T3[Risk & Conflicts]
    end
    
    subgraph "vCluster Approach"
        V1[Team A: KAI Scheduler]
        V2[Team B: Default]
        V3[Team C: Custom Scheduler]
        V1 --> S[Safe Isolation]
        V2 --> S
        V3 --> S
    end
```

> **Key Insight**: vCluster lets each team choose their scheduler!

<!-- end_slide -->

## Why KAI Scheduler + vCluster?

| **KAI Scheduler Requirements** | → | **Perfect for vCluster because** |
|---|---|---|
| Needs queue hierarchy (parent/child) | → | ✅ Isolated CRDs don't affect other teams |
| Requires custom CRDs | → | ✅ Queue configs stay within vCluster |
| Modifies scheduling behavior globally | → | ✅ Scheduling changes are contained |
| Complex configuration | → | ✅ Easy rollback - just delete vCluster |

> **The Challenge**: KAI uses owner references that vCluster must handle specially

<!-- end_slide -->

## Create vCluster with KAI Support


> Deploy vCluster with the special configuration

```bash +exec +id:create_vcluster
cat kai-scheduler-values.yaml

# Delete if exists, then create fresh
vcluster delete my-vcluster --delete-namespace || true
vcluster create my-vcluster \
  --values kai-scheduler-values.yaml \
  --connect=false
```

> The kai-scheduler-values.yaml disables owner references to allow KAI's pod-grouper to work

<!-- snippet_output: create_vcluster -->

<!-- end_slide -->

## Wait for vCluster to be Ready


> Ensure vCluster is fully deployed

```bash +exec
kubectl wait --for=condition=ready pod -l app=vcluster -n vcluster-my-vcluster --timeout=300s
```

<!-- end_slide -->

## Connect to vCluster


> When ready, connect to your vCluster

```bash +exec
vcluster connect my-vcluster
```

> **Note**: This updates your current kubeconfig context

<!-- end_slide -->

## vCluster Architecture: What's Inside?


```bash +exec
# Show all containers in the vCluster pod
kubectl --context kind-kai-demo get pod -n vcluster-my-vcluster -l app=vcluster -o json | \
  jq -r '.items[0] | 
    "INIT CONTAINERS:\n" + 
    (.spec.initContainers[] | "  \(.name): \(.image)") + 
    "\n\nMAIN CONTAINERS:\n" + 
    (.spec.containers[] | "  \(.name): \(.image)")'
```

> **Architecture**: Init container prepares the environment, syncer synchronizes resources between host and virtual cluster!

<!-- end_slide -->

## vCluster Data Storage: SQLite Inside!


```bash +exec
# Check the SQLite database file inside vCluster pod
kubectl --context kind-kai-demo exec -n vcluster-my-vcluster my-vcluster-0 -c syncer -- ls -lh /data/state.db

# Also check for kine database (k3s uses kine as SQLite wrapper)
kubectl --context kind-kai-demo exec -n vcluster-my-vcluster my-vcluster-0 -c syncer -- ls -lh /data/
```

> **Storage**: vCluster uses embedded SQLite - all K8s data in a single file!

<!-- end_slide -->

## The Multi-Tenancy Challenge

| **The Problem** | → | **vCluster Solution** |
|---|---|---|
| Teams need different Kubernetes configurations | → | ✅ Each team gets a **full** Kubernetes API |
| Testing new schedulers/operators is risky | → | ✅ Complete isolation from other teams |
| Resource conflicts between teams | → | ✅ Test anything without fear |
| No true multi-tenancy in vanilla K8s | → | ✅ KAI scheduler is just one example! |

<!-- end_slide -->

## vCluster Multi-Tenancy Models

```mermaid +render
graph LR
    subgraph "Host Cluster"
        subgraph "Shared Services"
            S[Monitoring, Logging, Ingress]
        end
        
        subgraph "High Trust"
            A[Team A vCluster]
            B[Team B vCluster]
        end
        
        subgraph "Partial Trust"
            P[Partner vCluster<br/>+ Resource Quotas]
        end
        
        subgraph "Zero Trust"
            C[Client vCluster<br/>+ Dedicated Nodes]
        end
        
        S ===|full access| A
        S ===|full access| B
        S ---|limited| P
        S -.->|isolated| C
    end
```

> vCluster adapts to your trust requirements!

<!-- end_slide -->

## CPU Workload Example


> Deploy a CPU-only pod with KAI scheduler
> The cpu-pod.yaml includes queue assignment label and specifies the KAI scheduler

```bash +exec
cat cpu-pod.yaml
kubectl apply -f cpu-pod.yaml

# Verify it's using KAI
echo "Scheduler: $(kubectl get pod cpu-pod -o jsonpath='{.spec.schedulerName}')"
echo "Queue: $(kubectl get pod cpu-pod -o jsonpath='{.metadata.labels.kai\.scheduler/queue}')"
```

> **What makes it special?** Uses KAI scheduler with queue assignment!

<!-- end_slide -->

## GPU Workload Example

> Deploy a GPU pod with KAI scheduler for fractional GPU allocation
> The gpu-pod.yaml includes GPU fraction annotation for sharing

```bash +exec
cat gpu-pod.yaml
kubectl apply -f gpu-pod.yaml

# Verify GPU access
kubectl wait --for=condition=ready pod gpu-pod --timeout=30s
kubectl exec gpu-pod -- nvidia-smi | grep "GTX 1060"
```

> **GPU Sharing**: KAI allows multiple pods to share the same GPU!

<!-- end_slide -->


## Demo 2: Second Team, Different Setup


> Create another vCluster for Research team:

```bash +exec
# First disconnect from current vCluster, then create new one
vcluster disconnect
vcluster create research-cluster --connect=false

# Wait for it to be ready
kubectl wait --for=condition=ready pod -l app=vcluster -n vcluster-research-cluster --timeout=300s
```

<!-- end_slide -->

## Connect to Research Cluster

> Connect to the research team's virtual cluster

```bash +exec
# Connect to research cluster
vcluster connect research-cluster
```

<!-- end_slide -->

## Research Team: Standard Kubernetes

> Research team uses vanilla K8s without KAI scheduler

```bash +exec
# Create web app deployment and service
cat web-app.yaml
kubectl apply -f web-app.yaml

# Show it uses default scheduler (not KAI)
kubectl get deployment web-app -o jsonpath='{.spec.template.spec.schedulerName}'
echo " (empty = default scheduler)"
```

<!-- end_slide -->

## Web Page

```bash +exec
kubectl port-forward deployment/web-app 8081:80 &
curl http://localhost:8081/
```

<!-- end_slide -->

## Compare Both Virtual Clusters

> Let's see the key differences between the two teams' setups

```bash +exec
# Show all workload pods across both virtual clusters with their schedulers
kubectl get pods -A --context kind-kai-demo \
  -o custom-columns='NAMESPACE:.metadata.namespace,POD:.metadata.name,SCHEDULER:.spec.schedulerName' | \
  grep -E "(vcluster-my-vcluster|vcluster-research-cluster)" | \
  grep -v -E "(coredns|my-vcluster-0|research-cluster-0)" | \
  sort | column -t
```

> Each team has their own isolated environment with different schedulers!

<!-- end_slide -->

## vCluster: The Multi-Tenancy Solution

| **Feature** | → | **Use Case** |
|---|---|---|
| Complete Kubernetes API per team | → | ✅ Dev/Test environments that spin up/down quickly |
| Install ANY operator/CRD without conflicts | → | ✅ Customer isolation with true multi-tenancy |
| Test schedulers, controllers, webhooks safely | → | ✅ Experimentation with K8s upgrades and operators |
| Resource isolation and quotas | → | ✅ CI/CD with ephemeral clusters for testing |
| No namespace limitations | → | ✅ Full flexibility for any K8s customization |

> **KAI was just an example - vCluster enables ANY K8s customization!**

<!-- end_slide -->

## Cleanup: Revert Docker Runtime

```bash +exec
# Remove the default-runtime setting to revert to runc
sudo jq 'del(."default-runtime")' /etc/docker/daemon.json | sudo sponge /etc/docker/daemon.json

# Restart Docker to apply changes
sudo systemctl restart docker

# Verify Docker is active and runtime is available
until sudo systemctl is-active docker | grep -q "active" && docker info >/dev/null 2>&1; do
  echo "Waiting for Docker to restart..."
  sleep 2
done

# Verify default runtime is back to runc
echo "Default runtime: $(docker info --format '{{.DefaultRuntime}}')"
```

> **Important**: This restores Docker to use runc (the standard runtime)

<!-- end_slide -->

## That's All Folks!

> Questions?

```bash +exec_replace
echo "Thank You!" | figlet -f small -c -w 90
```
