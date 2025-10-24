# From Physical Servers to Virtual Clusters

<!-- new_lines: 3 -->

![Computing Evolution](./hero.png)

<!-- jump_to_middle -->

<!-- end_slide -->

## 1945: Physical Computers

> Each abstraction solved a problem... and created a new one.

```mermaid +render +width:80%
%%{init: {"theme": "dark", "themeVariables": {"darkMode": true, "background": "#2b2b2b", "mainBkg": "#3a3a3a", "secondBkg": "#4a4a4a"}}}%%
sequenceDiagram
    participant User
    participant Computer

    User->>Computer: Execute program
    Computer->>Computer: Process on local CPU
    Computer-->>User: Return result

    Note over Computer: Single machine<br/>Direct hardware access<br/>No abstraction
```

<!-- end_slide -->

## Demo: Single Computer

```bash +exec
bash /home/decoder/dev/dotfiles/scripts/__layouts.sh 5
```

> Open: https://copy.sh/v86/

<!-- end_slide -->

## 1969: Networked Computing

```mermaid +render +width:80%
%%{init: {"theme": "dark", "themeVariables": {"darkMode": true, "background": "#2b2b2b", "mainBkg": "#3a3a3a", "secondBkg": "#4a4a4a"}}}%%
sequenceDiagram
    participant User
    participant WebServer
    participant DBServer
    participant Worker

    User->>WebServer: HTTP request
    WebServer->>DBServer: Query data
    DBServer-->>WebServer: Return data
    WebServer->>Worker: Background job
    Worker->>Worker: Process
    WebServer-->>User: HTTP response
```

<!-- end_slide -->

## Demo: Networked Machines

```bash +exec
# Show the homelab cluster
kubectl get nodes -o 'custom-columns=NAME:.metadata.name,IP:.status.addresses[0].address'

# Worker1 reaches Worker2
ssh decoder@192.168.178.88 "ping -c 3 192.168.178.89"
```

<!-- end_slide -->

## 1998: Virtual Machines

```mermaid +render +width:80%
%%{init: {"theme": "dark", "themeVariables": {"darkMode": true, "background": "#2b2b2b", "mainBkg": "#3a3a3a", "secondBkg": "#4a4a4a"}}}%%
sequenceDiagram
    participant User
    participant VM1 as VM: Web
    participant VM2 as VM: DB
    participant Hypervisor
    participant Hardware

    User->>VM1: HTTP request
    VM1->>Hypervisor: System call
    Hypervisor->>Hardware: CPU/Memory access
    VM1->>VM2: Network request
    VM2->>Hypervisor: System call
    Hypervisor->>Hardware: CPU/Memory access
    VM2-->>VM1: Response
    VM1-->>User: HTTP response
```

<!-- end_slide -->

## Demo: Virtual Machines

```bash +exec
# Show VMs in homelab (Kubernetes nodes are VMs!)
kubectl get nodes -o 'custom-columns=NAME:.metadata.name,CPU:.status.capacity.cpu,MEMORY:.status.capacity.memory,OS:.status.nodeInfo.osImage'
```

<!-- end_slide -->

## 2013: Containers

```mermaid +render +width:80%
%%{init: {"theme": "dark", "themeVariables": {"darkMode": true, "background": "#2b2b2b", "mainBkg": "#3a3a3a", "secondBkg": "#4a4a4a"}}}%%
sequenceDiagram
    participant User
    participant Container1 as Container: Web
    participant Container2 as Container: DB
    participant Runtime as Container Runtime
    participant Kernel as Shared Kernel
    participant Hardware

    User->>Container1: HTTP request
    Container1->>Runtime: Network call
    Runtime->>Kernel: Namespace isolation
    Container1->>Container2: TCP connection
    Container2->>Runtime: Filesystem access
    Runtime->>Kernel: Cgroup limits
    Kernel->>Hardware: CPU/Memory
    Container2-->>Container1: Response
    Container1-->>User: HTTP response
```

<!-- end_slide -->

## Demo: Containers

```bash +exec
# Start 5 web servers in under a second!
time for i in {1..5}; do
  docker run -d --name web$i nginx:alpine >/dev/null
done

# Show they're all running
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Size}}"

# Cleanup
docker rm -f web{1..5} >/dev/null 2>&1
```

> **1 second. 5 servers. 1 kilobyte each.**

<!-- end_slide -->

## 2014: Kubernetes

```mermaid +render +width:80%
%%{init: {"theme": "dark", "themeVariables": {"darkMode": true, "background": "#2b2b2b", "mainBkg": "#3a3a3a", "secondBkg": "#4a4a4a"}}}%%
sequenceDiagram
    participant User
    participant API as K8s API
    participant Scheduler
    participant Controller
    participant Node1 as Node 1
    participant Node2 as Node 2
    participant Container

    User->>API: kubectl apply deployment
    API->>Controller: Store desired state
    Controller->>Scheduler: Schedule pods
    Scheduler->>Node1: Assign pod 1
    Scheduler->>Node2: Assign pod 2
    Node1->>Container: Start container
    Node2->>Container: Start container
    Controller->>Controller: Monitor health
    Controller->>Node1: Restart failed pod
```

<!-- end_slide -->

## Demo: Kubernetes (My Homelab!)

```bash +exec
# Real production cluster
kubectl get nodes -o wide

# Deploy across nodes
kubectl create deployment demo-app --image=nginx --replicas=3

# Wait for pods to be ready
kubectl wait --for=condition=Ready pod -l app=demo-app --timeout=60s

# Show distribution across nodes
kubectl get pods -l app=demo-app -o 'custom-columns=NAME:.metadata.name,NODE:.spec.nodeName'
```

> **Declarative magic:** "I want 3 replicas" → K8s figures it out

<!-- end_slide -->

## Explore with K9s

```bash +exec +acquire_terminal
k9s
```

<!-- end_slide -->

## But... Multi-Tenancy?

```mermaid +render +width:80%
%%{init: {'theme': 'dark', 'themeVariables': {'darkMode': true, 'background': '#2b2b2b'}, 'flowchart' : {'curve' : 'linear'}}}%%
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

    classDef cluster fill:#3a3a3a,stroke:#2ea043,stroke-width:2px,color:#fff
    classDef workload fill:#3a3a3a,stroke:#3b82f6,stroke-width:2px,color:#fff
    classDef service fill:#3a3a3a,stroke:#FF6600,stroke-width:2px,color:#fff

    class vc1,vc2,vc3 cluster
    class W1,W2,W3 workload
    class Shared,CertManager2,Ingress2 service
```

<!-- end_slide -->

## 2020: Virtual Clusters

```mermaid +render +width:80%
%%{init: {"theme": "dark", "themeVariables": {"darkMode": true, "background": "#2b2b2b", "mainBkg": "#3a3a3a", "secondBkg": "#4a4a4a"}}}%%
sequenceDiagram
    participant User1 as Team A
    participant User2 as Team B
    participant vCluster1 as vCluster A API
    participant vCluster2 as vCluster B API
    participant HostAPI as Host Cluster API
    participant Syncer1 as Syncer A
    participant Syncer2 as Syncer B
    participant Node as Host Nodes

    User1->>vCluster1: kubectl apply (Team A resource)
    vCluster1->>Syncer1: Store in vCluster etcd
    Syncer1->>HostAPI: Sync to host namespace A
    HostAPI->>Node: Schedule pod

    User2->>vCluster2: kubectl apply (Team B resource)
    vCluster2->>Syncer2: Store in vCluster etcd
    Syncer2->>HostAPI: Sync to host namespace B
    HostAPI->>Node: Schedule pod
```

<!-- end_slide -->

## What is vCluster?

| Feature | Benefit |
|---------|---------|
| Full Kubernetes API | Certified Kubernetes distribution |
| Flexible isolation | Separate control plane per team |
| Resource efficiency | Shared infrastructure, isolated workloads |
| Sub-minute provisioning | Instant test/dev/ci environments |

> **vCluster** = Containerized Kubernetes inside a Pod!

<!-- end_slide -->


## Demo: Create Dev Team vCluster

```bash +exec
# Create development team vCluster
vcluster create dev-team --connect=false

# Wait for ready
kubectl wait --for=condition=ready pod -l app=vcluster -n vcluster-dev-team --timeout=300s

# Show what's running
kubectl get pods -n vcluster-dev-team
```

<!-- end_slide -->

## Connect to vCluster

```bash +exec
# Connect to dev team's vCluster
vcluster connect dev-team

# Show we're in a different cluster
kubectl cluster-info
```

<!-- end_slide -->

## Deploy in vCluster

```bash +exec
# Deploy application in vCluster
kubectl create deployment nginx --image=nginx --replicas=3

# Show pods in vCluster
kubectl get pods -o wide
```

<!-- end_slide -->

## Where Do Pods Actually Run?

```bash +exec
# Switch back to host cluster
kubectl config use-context kind-vcluster-multitenancy

# Show pods in vcluster namespace
kubectl get pods -n vcluster-dev-team -o wide
```

<!-- end_slide -->

## Two Views of Same Pods

```bash +exec
# vCluster view
vcluster connect dev-team
kubectl get pods

# Host view
kubectl config use-context kind-vcluster-multitenancy
kubectl get pods -n vcluster-dev-team | grep nginx
```

<!-- end_slide -->

## Delete vCluster

```bash +exec
# Delete entire dev team environment
vcluster delete dev-team

# Everything gone - pods, config, all of it
kubectl get pods -n vcluster-dev-team
```

<!-- end_slide -->

## The Pattern

| Abstraction         | Solved                | Created               |
|---------------------|----------------------|----------------------|
| Physical → VMs      | Stranded resources   | OS overhead          |
| VMs → Containers    | Heavy OS             | Orchestration chaos  |
| Containers → K8s    | Orchestration        | Multi-tenancy broken |
| K8s → vClusters     | Control plane limits | Another layer        |

> **This is how abstraction works**

<!-- end_slide -->

## Resources

| Resource | Link |
|----------|------|
| Blog Post | https://medium.com/itnext/from-physical-servers-to-virtual-kubernetes-clusters-85f931d4cdff |
| Interactive Tutorial | killercoda.com/decoder/course/vcluster/vcluster_introduction |
| vCluster GitHub | github.com/loft-sh/vcluster |

<!-- end_slide -->

## That's All Folks!

<!-- new_lines: 5 -->

```bash +exec_replace
echo "That's All Folks!" | figlet -f small -w 90
```

<!-- jump_to_middle -->
