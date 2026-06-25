#!/usr/bin/env bash
# setup.sh - prepare the external-node demo VM (Demo 4) before a presentation run.
#
# reset.sh deletes vclusters but NOT the cloud-node VM. A VM left over from a
# previous run is still joined to the old (now deleted) cluster, so the next
# join fails. This script recreates the VM from the pristine cloud image, which
# wipes any prior join, then runs sanity checks so the join slide works every time.
#
# Usage:  bash reset.sh && bash setup.sh   (then run the deck)
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VM_NAME="cloud-node"
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=8"

pass=0
fail=0
ok()   { printf '  \e[32mPASS\e[0m  %s\n' "$1"; pass=$((pass + 1)); }
bad()  { printf '  \e[31mFAIL\e[0m  %s\n' "$1"; fail=$((fail + 1)); }
info() { printf '\e[1;36m==>\e[0m %s\n' "$1"; }

# 1. (Re)create the VM. create-cloud-vm.sh destroys any existing cloud-node first,
#    so this also removes a stale kubelet join from a previous run.
info "Recreating ${VM_NAME} VM (clean image, no prior cluster join)"
bash "${SCRIPT_DIR}/create-cloud-vm.sh"

# 2. Wait for a DHCP lease (up to ~90s).
info "Waiting for ${VM_NAME} to get an IP address"
VM_IP=""
for _ in $(seq 1 30); do
    VM_IP=$(sudo virsh domifaddr "$VM_NAME" 2>/dev/null | awk '/ipv4/ {print $4}' | cut -d/ -f1)
    [ -n "$VM_IP" ] && break
    sleep 3
done

# Drop any stale host key for this IP so the demo's plain `ssh root@$VM_IP` does
# not trip over a changed key after recreation.
[ -n "$VM_IP" ] && ssh-keygen -R "$VM_IP" >/dev/null 2>&1 || true

# 3. Wait for SSH to come up (up to ~60s).
if [ -n "$VM_IP" ]; then
    info "Waiting for SSH on ${VM_IP}"
    for _ in $(seq 1 20); do
        ssh $SSH_OPTS root@"$VM_IP" true 2>/dev/null && break
        sleep 3
    done
fi

# 4. Sanity checks.
info "Sanity checks"
if [ -n "$VM_IP" ]; then
    ok "DHCP lease: ${VM_IP}"

    host=$(ssh $SSH_OPTS root@"$VM_IP" hostname 2>/dev/null)
    [ "$host" = "$VM_NAME" ] && ok "SSH as root + hostname (${host})" || bad "SSH/hostname (got '${host}')"

    rw=$(ssh $SSH_OPTS root@"$VM_IP" 'touch /root/.wtest 2>/dev/null && echo rw && rm -f /root/.wtest || echo ro' 2>/dev/null)
    [ "$rw" = "rw" ] && ok "root filesystem writable (not corrupted)" || bad "root filesystem not writable (${rw})"

    joined=$(ssh $SSH_OPTS root@"$VM_IP" 'test -d /etc/kubernetes -o -e /etc/systemd/system/kubelet.service && echo yes || echo no' 2>/dev/null)
    [ "$joined" = "no" ] && ok "clean node (no prior cluster join)" || bad "node already joined (kubelet/etc present)"

    # vnode-runtime needs kernel >= 6.1; jammy's 5.15 crash-loops and hangs the vNode demo.
    kver=$(ssh $SSH_OPTS root@"$VM_IP" 'uname -r' 2>/dev/null)
    kmaj=${kver%%.*}; krest=${kver#*.}; kmin=${krest%%.*}
    if [ "${kmaj:-0}" -gt 6 ] || { [ "${kmaj:-0}" -eq 6 ] && [ "${kmin:-0}" -ge 1 ]; }; then
        ok "kernel ${kver} (>= 6.1, vnode-runtime supported)"
    else
        bad "kernel ${kver} too old for vnode-runtime (needs >= 6.1)"
    fi

    net="no"
    for _ in 1 2 3; do
        net=$(ssh $SSH_OPTS root@"$VM_IP" 'curl -fsS -m 8 -o /dev/null -w ok https://github.com 2>/dev/null || echo no' 2>/dev/null)
        [ "$net" = "ok" ] && break
        sleep 3
    done
    [ "$net" = "ok" ] && ok "outbound internet (binary download will work)" || bad "no outbound internet"
else
    bad "no DHCP lease (VM did not get an IP)"
fi

# 5. Summary.
echo ""
if [ "$fail" -eq 0 ] && [ -n "$VM_IP" ]; then
    printf '\e[1;32mREADY\e[0m  %s is up at %s and clean. Demo 4 join will work.\n' "$VM_NAME" "$VM_IP"
    printf '       ssh root@%s\n' "$VM_IP"
    exit 0
else
    printf '\e[1;31mNOT READY\e[0m  %d check(s) failed. Fix before recording Demo 4.\n' "$fail"
    exit 1
fi
