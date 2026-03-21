#!/usr/bin/env bash
set +e

echo "=== Ensuring bridge kernel module ==="
sudo modprobe br_netfilter
sudo sysctl -q -w net.bridge.bridge-nf-call-iptables=1

echo "=== Setting docker driver ==="
vcluster use driver docker

echo "=== Killing port-forwards ==="
pkill -f "port-forward" 2>/dev/null || true

echo "=== Deleting all vclusters ==="
for vc in $(vcluster list --output name 2>/dev/null); do
  vcluster delete "$vc" 2>/dev/null || true
done

echo "=== Cleaning up platform instances ==="
platform_host=$(cat ~/.vcluster/config.json 2>/dev/null | jq -r '.platform.host // ""')
if [[ "$platform_host" == *".loft.host"* ]] && docker ps --format '{{.Names}}' | grep -q vcluster-platform; then
  for vc in $(vcluster platform list vclusters 2>/dev/null | awk 'NR>2 && NF>1 {print $1}' | grep -v '^-'); do
    vcluster platform delete vcluster "$vc" --project default 2>/dev/null || true
  done
else
  echo "Skipping platform cleanup (not a local Docker platform)"
fi

echo "=== Cleaning up vcluster containers (keeping platform) ==="
for c in $(docker ps -aq --filter "name=vcluster" 2>/dev/null); do
  name=$(docker inspect --format '{{.Name}}' "$c" 2>/dev/null | tr -d '/')
  [[ "$name" == "vcluster-platform" ]] && continue
  docker rm -f "$c" 2>/dev/null || true
done

echo "=== Cleaning up kubeconfig contexts ==="
kubectl config unset current-context 2>/dev/null || true
for ctx in $(kubectl config get-contexts -o name 2>/dev/null | grep vcluster); do
  kubectl config delete-context "$ctx" 2>/dev/null || true
done
for cluster in $(kubectl config get-clusters 2>/dev/null | grep vcluster); do
  kubectl config delete-cluster "$cluster" 2>/dev/null || true
done
for user in $(kubectl config get-users 2>/dev/null | grep vcluster); do
  kubectl config delete-user "$user" 2>/dev/null || true
done

echo "=== Cleaning up docker networks ==="
for net in $(docker network ls --format '{{.Name}}' | grep '^vcluster\.' 2>/dev/null); do
  docker network rm "$net" 2>/dev/null || true
done

echo "=== Done ==="
docker ps --format "table {{.Names}}\t{{.Status}}"
