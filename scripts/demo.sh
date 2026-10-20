#!/usr/bin/env bash
# Run of show for a live or recorded demo: one scene per keypress.
# Prerequisite: scripts 01, 03 and 04 have run, and the workloads have been up for a few minutes.
set -uo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
Y='\033[1;33m'; N='\033[0m'
scene()   { clear; echo -e "${Y}== $1 ==${N}"; echo; }
waitkey() { echo; read -r -n1 -s -p '[press any key]'; }

scene '0. What we created'
echo '$ gcloud container clusters list'
gcloud container clusters list --format='table(name,location,currentMasterVersion,currentNodeCount,status)'
echo; echo '$ kubectl get nodes'
kubectl get nodes -o custom-columns='NODE:.metadata.name,MACHINE:.metadata.labels.node\.kubernetes\.io/instance-type,OS:.status.nodeInfo.osImage'
echo; echo '$ helm list -n kepler'
helm list -n kepler
echo; echo '$ kubectl get daemonset,service,podmonitoring -n kepler'
kubectl get daemonset,service,podmonitoring -n kepler
echo; echo '$ kubectl get deployments,pods -n carbon-demo'
kubectl get deployments,pods -n carbon-demo
waitkey

scene '1. Does this GKE node have a power meter?'
NODE="$(kubectl get nodes -o jsonpath='{.items[0].metadata.name}')"
echo "$ kubectl debug node/$NODE -- ls /host/sys/class/powercap"
kubectl debug "node/$NODE" --image=busybox --profile=general -q -- \
  sh -c 'sleep 2; ls -la /host/sys/class/powercap; ls /host/sys/class/hwmon 2>&1' >/dev/null 2>&1
sleep 8
kubectl logs "$(kubectl get pods -o name | grep node-debugger | tail -1)"
kubectl get pods -o name | grep node-debugger | xargs -r kubectl delete --wait=false >/dev/null
waitkey

scene '2. Kepler: which power meter did it pick?'
echo '$ kubectl get pods -n kepler'; kubectl get pods -n kepler
echo; echo '$ kubectl logs -n kepler ds/kepler | grep "cpu meter\|cpu power meter"'
kubectl logs -n kepler ds/kepler | grep -i 'cpu meter\|cpu power meter' | sed -E 's/source=[^ ]+ //'
waitkey

scene '3. Same image, same job: check a queue'
echo '$ kubectl top pod -n carbon-demo'; kubectl top pod -n carbon-demo
waitkey

scene "4. Kepler CPU split x GCP power model (ESTIMATE, grid ${GRID_INTENSITY:-598} g/kWh)"
"$DIR/estimate.sh"
echo; echo 'No RAPL on this VM: watts are estimated from real CPU time, not measured.'
