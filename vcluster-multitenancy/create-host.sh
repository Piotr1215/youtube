#!/usr/bin/env bash
set -eo pipefail

name="${1:?usage: create-host.sh <name>}"
shift

# start vcluster create in background — it will block waiting for node
vcluster create "$name" "$@" &
create_pid=$!

# wait for the container to exist
echo "Waiting for container vcluster.cp.${name}..."
until docker inspect "vcluster.cp.${name}" &>/dev/null; do sleep 1; done

# workaround: vcluster 0.33 mounts vcluster.yaml read-only but the
# binary needs to write to it (PR #3721). use nsenter to rebind as
# writable in the container's mount namespace.
pid=$(docker inspect "vcluster.cp.${name}" --format '{{.State.Pid}}')
sudo nsenter -t "$pid" -m -- bash -c \
  "cp /etc/vcluster/vcluster.yaml /tmp/vc.yaml && \
   mount --bind /tmp/vc.yaml /etc/vcluster/vcluster.yaml"
echo "Config file remounted writable"

# wait for vcluster create to finish
wait "$create_pid"
