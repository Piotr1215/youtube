# Restarting pods

Reference: https://reference-to-runbook-description.com

<em>
    Make sure to work with the copy of TEMPLATE.md
</em>

## Timestamp the steps

```bash
echo "Steps executed at: $(date)"
```

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

## Kubectl info

```bash
kubectl version
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
