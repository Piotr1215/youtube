---
theme: uncover
author: Your Name
date: 2025-01-31
paging: Slide %d / %d
---

# vCluster + NVIDIA KAI Scheduler

```
~~~just intro_toilet "vCluster + KAI"

~~~
```

> Optimize GPU and CPU workloads with NVIDIA's open-source scheduler

---

## What is KAI? 🚀

- **NVIDIA KAI**: Open source version of Run:AI scheduler
- **Apache 2.0** licensed (2025)
- Advanced features:
  - *Fractional GPU allocation*
  - *Smart queuing system*
  - *Topology awareness*

---

## Setup Lab Environment 🧪

> We'll create a kind cluster configured for GPU workloads
> The extraMounts allow NVIDIA container runtime integration

---


## Create kind Cluster

> Single node cluster for faster demo setup

```yaml
# kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30000
    hostPort: 30000
  extraMounts:
  - hostPath: /dev/null
    containerPath: /var/run/nvidia-container-devices
```

---

## Deploy kind Cluster

> Create the cluster with our configuration

```bash
../spane kind create cluster --config=kind-config.yaml --name kai-demo
```

---

## Verify Cluster Ready

> Ensure the cluster is operational

```bash
kubectl get nodes
```

---

## Install NVIDIA Device Plugin (Optional)

> Skip if no real GPUs - KAI works with CPU-only nodes too

```bash
kubectl apply --validate=false -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.16.2/deployments/static/nvidia-device-plugin.yml
```

---

## Get Latest KAI Version

> Check GitHub releases for the latest version

```bash
curl -s https://api.github.com/repos/NVIDIA/KAI-Scheduler/releases | jq -r '.[0].tag_name' || echo "v0.5.1"
```

---

## Deploy KAI Scheduler

> Install from OCI registry with GPU sharing enabled

```bash
../spane helm upgrade -i kai-scheduler \
  oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
  -n kai-scheduler \
  --create-namespace \
  --version v0.5.1 \
  --set "global.gpuSharing=true"
```

---

## The Challenge 🤔

Default vCluster behavior:
- Sets owner references on synced pods
- KAI's pod-grouper traverses owners
- Can't access vCluster Service resources
- **Result**: Scheduling fails

---

## The Solution ✅

> Disable owner references to let KAI's pod-grouper work

```yaml
# kai-scheduler-values.yaml
experimental:
  syncSettings:
    setOwner: false
```

---

## Create vCluster Config File

> Save the configuration for KAI compatibility

```bash
cat > kai-scheduler-values.yaml << 'EOF'
experimental:
  syncSettings:
    setOwner: false
EOF
```

---

## Create vCluster with KAI Support

> Deploy vCluster with the special configuration

```bash
../spane vcluster create my-vcluster \
  --values kai-scheduler-values.yaml \
  --connect=false
```

---

## Connect to vCluster

> When ready, connect to your vCluster

```bash
vcluster connect my-vcluster
```

---

## Check GPU Availability

> Verify GPU resources in your cluster

```bash
nvidia-smi || echo "No GPUs detected - using CPU only"
```

---

## CPU Workload Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cpu-pod
spec:
  schedulerName: kai-scheduler
  containers:
  - name: main
    image: ubuntu
    args: ["sleep", "infinity"]
    resources:
      requests:
        cpu: 100m
        memory: 250M
```

---

## GPU Workload Example 🎮

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  schedulerName: kai-scheduler
  containers:
  - name: main
    image: ubuntu
    command: ["nvidia-smi"]
    resources:
      requests:
        nvidia.com/gpu: '1'
```

---

## Fractional GPU Magic ✨

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-sharing
  annotations:
    gpu-fraction: "0.5"  # Half GPU!
spec:
  schedulerName: kai-scheduler
  containers:
  - name: main
    image: ubuntu
    args: ["sleep", "infinity"]
```

---

## Verify Scheduler 🔍

> Confirm pods are using KAI scheduler

```bash
kubectl get pod <pod-name> -n <namespace> \
  -o jsonpath='{.spec.schedulerName}'
```

---

## Check KAI Components

> Ensure scheduler pods are running

```bash
kubectl get pods -n kai-scheduler
```

---

## Inspect Pod Annotations

> KAI adds pod-group annotations automatically

```bash
kubectl describe pod <pod-name>
```

---

## Troubleshooting 🛠️

**GPU pods stuck pending?**
- Enable GPU sharing: `--set global.gpuSharing=true`
- Check reservation namespace

**Permission errors?**
- Verify `setOwner: false` is applied
- Check KAI logs

---

## Resources 📚

- [NVIDIA KAI Scheduler](https://github.com/NVIDIA/KAI-Scheduler)
- [vCluster Docs](https://www.vcluster.com/docs)
- [GPU Sharing Guide](https://github.com/NVIDIA/KAI-Scheduler/docs)

---

## That's All Folks! 🎬

Questions?

```
~~~just intro "Thank You!"

~~~
```
