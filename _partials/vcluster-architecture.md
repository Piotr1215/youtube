## vCluster Technical Architecture
<!-- new_lines: 1 -->
> Understanding how vCluster achieves Kubernetes isolation
<!-- new_lines: 1 -->
```mermaid +render
graph TB
    subgraph "vCluster Pod Components"
        API["API Server<br/>(k8s)"]
        ETCD["Data Store<br/>(SQLite/etcd)"]
        SYNC["Syncer<br/>(bi-directional)"]
        CTRL["Controller Manager"]
        SCHED["Scheduler<br/>(optional)"]
    end

    subgraph "Host Cluster"
        PODS["Synced Pods"]
        SVCS["Synced Services"]
        PVC["Synced PVCs"]
    end

    API --> ETCD
    API --> SYNC
    SYNC <--> PODS
    SYNC <--> SVCS
    SYNC <--> PVC
```
<!-- new_lines: 1 -->
| **Component** | **Purpose** | **Resource Usage** |
|--------------|-------------|--------------------|
| API Server | Full K8s API compatibility | ~100MB RAM |
| Syncer | Resource translation | ~50MB RAM |
| Data Store | Complete state isolation | ~10MB disk |
| Total Overhead | **< 200MB per vCluster** | Minimal impact |
<!-- new_lines: 1 -->
> **Key Innovation:** Containerized control plane with intelligent resource syncing