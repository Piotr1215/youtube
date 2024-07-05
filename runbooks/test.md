# Restarting pods

Reference: https://reference-to-runbook-description.com

<em>
    Make sure to work with the copy of TEMPLATE.md
</em>

## Timestamp the steps

```bash
echo "Steps executed at: $(date)"
```

*Results:* `Steps executed at: Fri  5 Jul 09:49:19 CEST 2024`

## Basic cluster info

```bash
{  
    echo -e "\n=== Status ===\n" && \
    kubectl get --raw '/healthz?verbose'; echo &&  \
    kubectl get nodes; echo && \
    kubectl cluster-info; echo && \
    kubectl version; echo;
} | grep -z 'Ready\| ok\|passed\|running' 
```

*Results:*
```

=== Status ===

[+]ping ok
[+]log ok
[+]etcd ok
[+]poststarthook/start-kube-apiserver-admission-initializer ok
[+]poststarthook/generic-apiserver-start-informers ok
[+]poststarthook/priority-and-fairness-config-consumer ok
[+]poststarthook/priority-and-fairness-filter ok
[+]poststarthook/storage-object-count-tracker-hook ok
[+]poststarthook/start-apiextensions-informers ok
[+]poststarthook/start-apiextensions-controllers ok
[+]poststarthook/crd-informer-synced ok
[+]poststarthook/start-service-ip-repair-controllers ok
[+]poststarthook/rbac/bootstrap-roles ok
[+]poststarthook/scheduling/bootstrap-system-priority-classes ok
[+]poststarthook/priority-and-fairness-config-producer ok
[+]poststarthook/start-system-namespaces-controller ok
[+]poststarthook/bootstrap-controller ok
[+]poststarthook/start-cluster-authentication-info-controller ok
[+]poststarthook/start-kube-apiserver-identity-lease-controller ok
[+]poststarthook/start-kube-apiserver-identity-lease-garbage-collector ok
[+]poststarthook/start-legacy-token-tracking-controller ok
[+]poststarthook/aggregator-reload-proxy-client-cert ok
[+]poststarthook/start-kube-aggregator-informers ok
[+]poststarthook/apiservice-registration-controller ok
[+]poststarthook/apiservice-status-available-controller ok
[+]poststarthook/kube-apiserver-autoregistration ok
[+]autoregister-completion ok
[+]poststarthook/apiservice-openapi-controller ok
[+]poststarthook/apiservice-openapiv3-controller ok
[+]poststarthook/apiservice-discovery-controller ok
healthz check passed

NAME                          STATUS   ROLES           AGE     VERSION
control-plane-control-plane   Ready    control-plane   2d21h   v1.29.2
control-plane-worker          Ready    <none>          2d21h   v1.29.2

[0;32mKubernetes control plane[0m is running at [0;33mhttps://127.0.0.1:33423[0m
[0;32mCoreDNS[0m is running at [0;33mhttps://127.0.0.1:33423/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy[0m

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

Client Version: v1.29.4
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.29.2

```

## Kubectl info

```bash
kubectl version
```

*Results:*
```
Client Version: v1.29.4
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.29.2
```

## Get all pods only in the deployment

Static variables are captures in the `.direnv` file and loaded on session
startup.

Make sure they are correctly captured.

```bash
echo "namespace:" $DEPLOYMENT_NS
echo "deployment:" $DEPLOYMENT
```

## Check pods last restart date

```bash
kubectl get pods -n $DEPLOYMENT_NS -o=custom-columns='NAME:.metadata.name,RESTARTS:.status.containerStatuses[*].restartCount,LAST_STARTED:.status.containerStatuses[*].state.running.startedAt'
```

## Capture pod names for the deployment

This steps captures only pods belonging to a deployment and prevents to
accidentally label-select pods with the same labels.

```bash
RS_NAME=`kubectl describe deployment -n $DEPLOYMENT_NS $DEPLOYMENT | grep "^NewReplicaSet"|awk '{print $2}'`; echo $RS_NAME
POD_HASH_LABEL=`kubectl get rs -n $DEPLOYMENT_NS $RS_NAME -o jsonpath="{.metadata.labels.pod-template-hash}"` ; echo $POD_HASH_LABEL
# export pods names to consume later from other commands
POD_NAMES=`kubectl get pods -n $DEPLOYMENT_NS -l pod-template-hash=$POD_HASH_LABEL --show-labels | tail -n +2 | awk '{print $1}' > pods`
cat pods
```

## Delete pods one by one to force deployment recreation

```bash
while read line
do
  kubectl delete pod -n $DEPLOYMENT_NS $line
done < pods

```

## Check if problem was fixed

```bash
curl -Is https://example-deployment-web-page
```

### Optional: Check health probe

```bash
kubectl port-forward --namespace -n $DEPLOYMENT_NS $(kubectl get pod --namespace $DEPLOYMENT_NS --selector="app=deployment" --output jsonpath='{.items[0].metadata.name}') 8080:5000
```

```bash
curl --header 'Accept: application/json' \
     --header 'x-health-check: check' \
     --include \
     --request GET "http://localhost:8080/health/readiness"
```
