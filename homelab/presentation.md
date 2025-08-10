---
title: Kubernetes Homelab
author: Cloud Native Corner
date: 2025-01-10
---


# Kubernetes Homelab

> Your Experimentation Playground

```bash +exec_replace
echo "Kubernetes Homelab" | figlet -f slant -c -w 90
```

<!-- end_slide -->


## Why Homelab?

> **Anyone can set up a homelab on almost any hardware**

```mermaid +render
%%{init: {'theme': 'dark', 'flowchart': {'curve': 'linear'}}}%%
flowchart LR
    Proxmox --> K8s
    K8s --> Services
    
    Proxmox -.-> NAS
    Services -.-> NAS
```

<!-- end_slide -->




## Kubernetes Cluster

```mermaid +render
%%{init: {'theme': 'dark', 'flowchart': {'curve': 'linear'}}}%%
flowchart TB
    subgraph Proxmox["Proxmox Hypervisor"]
        subgraph VM101["VM 101: kube-main"]
            CP[Control Plane]
        end
        
        subgraph VM102["VM 102: kube-worker1"]
            W1[Worker Node]
        end
        
        subgraph VM103["VM 103: kube-worker2"]
            W2[Worker Node]
        end
    end
    
    CP -.-> W1
    CP -.-> W2
    
    style Proxmox fill:#1a365d,stroke:#2c5282,color:#fff
    style VM101 fill:#2c5282,stroke:#2b6cb0,color:#fff
    style VM102 fill:#065666,stroke:#0891b2,color:#fff
    style VM103 fill:#065666,stroke:#0891b2,color:#fff
```

> **3 VMs**: One control plane, two workers

<!-- end_slide -->


## GitOps Flow

```mermaid +render
%%{init: {'theme': 'dark', 'flowchart': {'curve': 'linear'}}}%%
flowchart LR
    Dev[Git Push] --> GitHub[GitHub]
    GitHub --> ArgoCD[ArgoCD<br/>Auto Sync]
    ArgoCD --> K8s[Kubernetes]
    K8s --> Self[Self-Healing]
    Self -.-> ArgoCD
    
    style Dev fill:#2d3748,stroke:#4a5568,color:#fff
    style GitHub fill:#1a365d,stroke:#2c5282,color:#fff
    style ArgoCD fill:#065666,stroke:#0891b2,color:#fff
    style K8s fill:#134e4a,stroke:#14b8a6,color:#fff
    style Self fill:#047857,stroke:#10b981,color:#fff
```

<!-- end_slide -->





## Service Ecosystem

```mermaid +render
%%{init: {'theme': 'dark', 'flowchart': {'curve': 'linear'}}}%%
flowchart TD
    subgraph Management["Management"]
        ArgoCD[ArgoCD<br/>GitOps]
        Portainer[Portainer<br/>Containers]
    end
    
    subgraph Observability["Observability"]
        Homepage[Homepage<br/>Dashboard]
        Hubble[Hubble UI<br/>Network]
    end
    
    subgraph Storage["Storage"]
        MinIO[MinIO<br/>S3 Storage]
        Velero[Velero<br/>Backup]
        Vault[Vault<br/>Secrets]
    end
    
    subgraph Apps["Applications"]
        UserApps[Your Apps]
    end
    
    ArgoCD --> UserApps
    ArgoCD --> Velero
    Homepage -.-> Management
    Homepage -.-> Observability
    Homepage -.-> Storage
    Velero --> MinIO
    
    style Management fill:#2d3748,stroke:#4a5568,color:#fff
    style Observability fill:#1a365d,stroke:#2c5282,color:#fff
    style Storage fill:#065666,stroke:#0891b2,color:#fff
    style Apps fill:#134e4a,stroke:#14b8a6,color:#fff
```
<!-- end_slide -->


## Key Takeaways

| Icon | Benefit |
|------|--------|
| > | Experimentation platform |
| > | Your own useful tools |
| > | Data sovereignty |

<!-- end_slide -->


## Resources

| Tool | URL |
|------|-----|
| ArgoCD | https://argo-cd.readthedocs.io/ |
| Velero | https://velero.io/docs/ |
| MinIO | https://min.io/docs/ |
| Homepage | https://gethomepage.dev/ |

<!-- end_slide -->


## That's All Folks!

```bash +exec_replace
echo "That's all folks" | figlet -f slant -c -w 90
```
