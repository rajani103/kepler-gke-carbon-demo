#!/usr/bin/env bash
# Scene 1: does this GKE node expose a hardware power meter?
# kubectl debug mounts the node's root filesystem at /host inside the debug pod.
set -euo pipefail

NODE="$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')"
echo "Node: $NODE"

echo "--- /sys/class/powercap (RAPL) ---"
kubectl debug "node/$NODE" -it --image=busybox --profile=general -- \
  sh -c 'ls -la /host/sys/class/powercap/ 2>&1; echo; echo "--- hwmon ---"; ls /host/sys/class/hwmon/ 2>&1'

# Remove the leftover debug pods so they don't show up later in the demo
kubectl get pods -o name | grep "node-debugger" | xargs -r kubectl delete --wait=false
