<!--
Note: Commands marked with +exec can be run with Ctrl+E
For better output display, use the spane script in a separate terminal
-->

# vCluster + NVIDIA KAI Scheduler
<!-- new_lines: 5 -->

```bash +exec_replace
echo "vCluster + KAI" | figlet -f small -w 90
```

<!-- jump_to_middle -->
![vCluster Logo](./vcluster-logo-main.png)

<!-- end_slide -->


## Setup Demo Environment

> Running preflight setup for the demo

```bash +exec
# Configure Docker for GPU pass-through
# Create cluster with GPU support (port 5000 exposed for demo app)
# Install metrics server with Kind-specific configuration
# Create secret for OpenAI API (from environment variable)
# Deploy KAI Scheduler
# Label worker node for GPU workloads
# Install NVIDIA device plugin
# Create RuntimeClass for NVIDIA containers
# Apply KAI queues configuration
# Preload images into kind cluster for faster demo
./setup-cluster.sh
```

<!-- end_slide -->


## What is NVIDIA KAI Scheduler?

> **Advanced Kubernetes scheduler for GPU workload optimization**

```mermaid +render
graph LR
    GPU[1 GPU] --> A[0.5 Training]
    GPU --> B[0.25 Inference]
    GPU --> C[0.25 Dev]
```

| **Feature**               | **Benefit**                        |
| ------------------------- | ---------------------------------- |
| Fractional GPU allocation | Share single GPU between workloads |
| Queue-based scheduling    | Hierarchical resource management   |
| Topology awareness        | Optimize for hardware layout       |
| Fair sharing              | Prevent resource monopolization    |

> **Open-sourced 2025:** Enterprise GPU management for the community

<!-- end_slide -->


## Verify GPU Access

> Running nvidia-smi in a test pod to confirm GPU passthrough is working

```bash +exec_replace
kubectl config current-context | sed 's/^/CURRENT_CONTEXT: /'
```

```bash +exec
# Test GPU accessibility
kubectl run gpu-verify --image=nvidia/cuda:12.2.0-base-ubuntu20.04 \
  --rm -it --restart=Never \
  --overrides='{"spec":{"runtimeClassName":"nvidia","nodeSelector":{"nvidia.com/gpu.present":"true"}}}' \
  -- nvidia-smi -L
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

| **Feature**             | **Benefit**                               |
| ----------------------- | ----------------------------------------- |
| Full Kubernetes API     | Certified Kubernetes distribution         |
| Complete isolation      | Separate control plane per team           |
| Resource efficiency     | Shared infrastructure, isolated workloads |
| Sub-minute provisioning | Instant test environments                 |

> **vCluster** = Containerized Kubernetes inside a Pod!

<!-- end_slide -->


## What Actually Runs on GPUs?

> Understanding GPU workloads in modern infrastructure

| **Workload**         | **Examples**                    | **GPU Usage**             |
| -------------------- | ------------------------------- | ------------------------- |
| **Model Training**   | Fine-tuning LLMs, Deep Learning | 100% for hours/days       |
| **Stable Diffusion** | Image generation                | ~50% GPU                  |
| **LLM Inference**    | ChatGPT API, Claude API         | 25-75% depending on model |
| **Video Processing** | Transcoding, streaming          | Variable 20-80%           |
| **CUDA Development** | Jupyter notebooks, testing      | Often < 20%               |
| **Batch Processing** | Scientific computing            | Spikes to 100%            |

<!-- end_slide -->



## Deploy GPU Demo

```bash +exec_replace
kubectl config current-context | sed 's/^/CURRENT_CONTEXT: /'
```

```bash +exec
./deploy-gpu-pod.sh
```

<!-- end_slide -->


## Scan QR Code

<!-- column_layout: [1, 2, 1] -->
<!-- column: 1 -->

```bash +exec_replace
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
echo "$NGROK_URL" | qrencode -t UTF8 -s 1 -m 2
echo ""
echo "$NGROK_URL"
```

<!-- reset_layout -->

<!-- end_slide -->


## Upgrading Schedulers in Production

```mermaid +render
graph TB
    subgraph "Production Cluster"
        PROD["Production Workloads<br/>GPU-Intensive Jobs"]
        SCHED["Current Scheduler<br/>v1.2.3"]

        NEWSCHED["New Scheduler<br/>v2.0.0"]

        PROD --> SCHED
        NEWSCHED -.-> |"Risk"| PROD
    end

    style NEWSCHED fill:#ff6b6b,color:#fff
    style PROD fill:#51cf66,color:#fff
```

```bash +exec_replace
cat << 'EOF'
Current Reality:
• Testing new schedulers affects all workloads
• Rollback procedures take hours
• Teams blocked on single scheduler version
EOF
```

<!-- end_slide -->


## GPU Scheduling: Risk Analysis

| **Failure Mode** | **Impact** | **Recovery Time** | **Business Cost** |
|---|---|---|---|
| Scheduler bug | All pods pending | 2-4 hours | High |
| CRD conflicts | Namespace corruption | 6+ hours | Critical |
| Version mismatch | Random pod failures | 1-2 days | Very High |
| Resource leak | GPU exhaustion | 4-8 hours | Critical |

> **Industry Data:** Enterprise downtime costs $100k-1M+ per hour (New Relic 2024)

<!-- end_slide -->


## Solution: vCluster Isolation (Not New Clusters!)

```mermaid +render
graph LR
    subgraph "Production Cluster"
        subgraph "vCluster Test"
            TEST["Test Environment<br/>KAI v0.9.3"]
        end

        PROD["Production<br/>KAI v0.7 Stable"]

        TEST -.->|"Isolated"| PROD
    end

    ROLLBACK["Failed?<br/>Delete vCluster<br/>30 seconds"]
    SUCCESS["Success?<br/>Upgrade Production<br/>With Confidence"]

    TEST --> ROLLBACK
    TEST --> SUCCESS

    style TEST fill:#4dabf7,color:#fff
    style PROD fill:#51cf66,color:#fff
```

> **Key Point:** vCluster creates isolated Kubernetes inside your existing cluster - NOT new EKS/GKE!

<!-- end_slide -->



## Production Scheduler Risk

```bash +exec_replace
cat << 'EOF'
Host-cluster scheduler:
• Single scheduler controls entire cluster
• Any changes affect all workloads
• No isolation between teams

Impact:
• Blocked innovation due to risk
• Slow adoption of new features
• Teams waiting on scheduler upgrades
EOF
```

> **Question:** How can we test KAI scheduler without risking production?

<!-- end_slide -->



## Deploy KAI in vCluster

```bash +exec_replace
kubectl config current-context | sed 's/^/CURRENT_CONTEXT: /'
```

> vCluster can swap out Kubernetes components like schedulers, providing isolated testing environments

```bash +exec
# Create isolated vCluster with KAI-specific configuration
vcluster create kai-isolated --values kai-vcluster.yaml --connect=false

# Connect to the vCluster
vcluster connect kai-isolated
```

<!-- end_slide -->


## vCluster Resource Footprint

```bash +exec_replace
kubectl config current-context | sed 's/^/CURRENT_CONTEXT: /'
```

> vCluster runs as a single pod with minimal overhead

```bash +exec_replace
echo "━━━ VCLUSTER POD DETAILS ━━━"
kubectl --context kind-kai-demo get pod -n vcluster-kai-isolated -l app=vcluster -o custom-columns=NAME:.metadata.name,CPU:.spec.containers[0].resources.requests.cpu,MEMORY:.spec.containers[0].resources.requests.memory
echo ""
echo "━━━ VCLUSTER CONTAINERS ━━━"
kubectl --context kind-kai-demo get pod -n vcluster-kai-isolated -l app=vcluster -o jsonpath='INIT CONTAINERS:
{range .items[0].spec.initContainers[*]}  {.name}: {.image}
{end}
MAIN CONTAINERS:
{range .items[0].spec.containers[*]}  {.name}: {.image}
{end}'
echo ""
echo ""
echo "━━━ VCLUSTER DATA STORAGE ━━━"
kubectl --context kind-kai-demo exec -n vcluster-kai-isolated -l app=vcluster -c syncer -- ls -lh /data/state.db 2>/dev/null || echo "  SQLite database: /data/state.db"
```

<!-- end_slide -->



## Install KAI Inside vCluster

> Same KAI installation but inside vCluster - production remains untouched

```bash +exec_replace
kubectl config current-context | sed 's/^/CURRENT_CONTEXT: /'
```

```bash +exec
# Connect to vCluster first
vcluster connect kai-isolated

# Install KAI in isolated environment
KAI_VERSION=v0.9.3
helm upgrade -i kai-scheduler \
  oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler --create-namespace \
  --version $KAI_VERSION \
  --set "global.gpuSharing=true"

kubectl wait --for=condition=ready pod -n kai-scheduler --all --timeout=120s
```


<!-- end_slide -->

## KAI Scheduler Pods

> View KAI scheduler components 

```bash +exec +acquire_terminal
k9s -c pods -n kai-scheduler
```

<!-- end_slide -->


## Deploy and Test GPU Workload in vCluster

> GPU sharing works identically inside vCluster but with zero production risk

```bash +exec_replace
kubectl config current-context | sed 's/^/CURRENT_CONTEXT: /'
```

```bash +exec
# Apply queues and deploy two pods with different GPU fractions
kubectl apply -f queues.yaml
kubectl apply -f gpu-demo-pod1.yaml
kubectl apply -f gpu-demo-pod2.yaml

kubectl wait --for=condition=ready pod -n default --all --timeout=120s

# Show both pods sharing the GPU
kubectl get pods -l app=gpu-demo -o custom-columns=NAME:.metadata.name,FRACTION:.metadata.annotations."kai\.scheduler/gpu-fraction",STATUS:.status.phase
```

<!-- end_slide -->



## GPU Sharing Status

```bash +exec_replace
kubectl config current-context | sed 's/^/CURRENT_CONTEXT: /'
```

```bash +exec
vcluster connect kai-isolated > /dev/null 2>&1

kubectl get pods -l app=gpu-demo \
  -o custom-columns='POD:metadata.name,GPU FRACTION:metadata.annotations.kai\.scheduler/gpu-fraction,STATUS:status.phase'
```

<!-- end_slide -->



## Version Switching with vCluster

```bash +exec_replace
kubectl config current-context | sed 's/^/CURRENT_CONTEXT: /'
```

> Switch between scheduler versions instantly. vCluster also supports snapshot/restore for complete state management.

```bash +exec
# Disconnect from vCluster
vcluster disconnect

# Delete the entire vCluster (timed)
time vcluster delete kai-isolated --delete-namespace
```

<!-- end_slide -->


## Multi-Team Requirements

```bash +exec_replace
cat << 'EOF'
Challenge:
  • ML Team needs KAI v0.9.3 for new features
  • Research Team requires stable KAI v0.7
  • Dev Team uses default scheduler

Current approach limitation: One scheduler version for everyone

Question: How can teams run different scheduler versions simultaneously?
EOF
```

<!-- end_slide -->


## Parallel Scheduler Versions

```bash +exec_replace
kubectl config current-context | sed 's/^/CURRENT_CONTEXT: /'
```

> Multiple teams can run different scheduler versions simultaneously

```bash +exec
# Create multiple vClusters for different teams using existing config
# Team 1: Stable version
vcluster create team-stable --values kai-vcluster.yaml --connect=false &

# Team 2: Beta version
vcluster create team-beta --values kai-vcluster.yaml --connect=false &

# Wait for both to create
wait

```

<!-- end_slide -->


## Install Different KAI Versions Per Team

```bash +exec_replace
kubectl config current-context | sed 's/^/CURRENT_CONTEXT: /'
```

> Each team gets their preferred scheduler version in complete isolation

```bash +exec +id:teams
# Team Stable: v0.9.2 (production)
vcluster connect team-stable
helm upgrade -i kai-scheduler \
  oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler --create-namespace \
  --version v0.9.2 --wait &
STABLE_PID=$!

# Team Beta: v0.9.3 (testing)
vcluster connect team-beta
helm upgrade -i kai-scheduler \
  oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler --create-namespace \
  --version v0.9.3 --wait &
BETA_PID=$!

# Wait for both installations
wait $STABLE_PID $BETA_PID

vcluster disconnect
```

<!-- end_slide -->

### Installation Progress

<!-- snippet_output: teams -->

<!-- end_slide -->


## Deploy Workloads to Both Teams

> Each team's workloads are managed by their own scheduler version

```bash +exec_replace
kubectl config current-context | sed 's/^/CURRENT_CONTEXT: /'
```

```bash +exec
# Deploy to team-stable (30% + 50% GPU allocation)
vcluster connect team-stable
kubectl apply -f queues.yaml,gpu-demo-pod1.yaml,gpu-demo-pod2.yaml
vcluster disconnect

# Deploy to team-beta (different allocation strategy)
vcluster connect team-beta
kubectl apply -f queues.yaml,gpu-demo-pod1.yaml,gpu-demo-pod2.yaml
vcluster disconnect
```

<!-- end_slide -->


## Parallel Operations

> Both vClusters are running with different KAI versions

```markdown
PARALLEL SCHEDULER DEPLOYMENTS
- team-stable: KAI v0.9.2 (production)
- team-beta:   KAI v0.9.3 (beta testing)

CLUSTER STATUS
- Host Impact:  NONE
- Isolation:    COMPLETE
- Risk:         ZERO
```

```bash +exec
vcluster list
```

<!-- end_slide -->

## View Running vClusters

> View all vClusters and their resources (Press :q to exit)

```bash +exec +acquire_terminal
k9s -c pods
```

<!-- end_slide -->


## Operational Capabilities Achieved

| **Capability**          | **Time Saved**      | **Risk Reduced** |
| ----------------------- | ------------------- | ---------------- |
| Test scheduler upgrades | 4 hours → 5 min     | 100% → 0%        |
| Rollback bad changes    | 2 hours → 30 sec    | Critical → None  |
| A/B test versions       | Not possible → Easy | High → Zero      |
| Per-team schedulers     | Days → Minutes      | Complex → Simple |
| GPU sharing validation  | Weeks → Hours       | High → None      |

> **Measured Impact:** Based on typical enterprise deployment scenarios

<!-- end_slide -->


## Architecture Example

```mermaid +render
graph TB
    subgraph "Production GPU Cluster"
        subgraph "vCluster: ML Team"
            ML["KAI v0.9.3<br/>Fractional GPU<br/>High Priority"]
        end

        subgraph "vCluster: Research"
            RES["KAI v0.9.2 Stable<br/>Dedicated GPU<br/>Standard Priority"]
        end

        subgraph "vCluster: Development"
            DEV["Default Scheduler<br/>CPU Only<br/>Best Effort"]
        end

        GPU["Physical GPU Pool<br/>Shared Infrastructure"]

        ML --> GPU
        RES --> GPU
        DEV --> GPU
    end

    style ML fill:#4dabf7,color:#fff
    style RES fill:#51cf66,color:#fff
    style DEV fill:#868e96,color:#fff
    style GPU fill:#ffd43b,color:#333
```

<!-- end_slide -->


## Cleanup

> Cleaning up the demo environment

```bash +exec
# Kill ngrok process
pkill -f ngrok || true

# Delete the Kind cluster
kind delete cluster --name kai-demo

# Revert Docker runtime configuration
sudo jq 'del(."default-runtime")' /etc/docker/daemon.json | sudo sponge /etc/docker/daemon.json
sudo systemctl restart docker
```

<!-- end_slide -->


## Resources

```markdown
Documentation:
- vCluster Docs: https://vcluster.com/docs
- KAI Scheduler: https://github.com/NVIDIA/KAI-Scheduler
- vCluster KAI Integration: https://docs.vcluster.com/third-party-integrations/scheduler/kai-scheduler

Community:
- vCluster Slack: https://slack.loft.sh
- Office Hours: https://www.loft.sh/events
```

<!-- end_slide -->
<!-- new_lines: 10 -->
![vCluster Logo](./vcluster-logo-main.png)

<!-- jump_to_middle -->
```bash +exec_replace
echo "Thank You!" | figlet -f small -w 90
```

## Questions?
