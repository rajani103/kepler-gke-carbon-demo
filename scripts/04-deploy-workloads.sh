#!/usr/bin/env bash
# Deploys the two demo workloads: same image, same job, different polling.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

kubectl apply -f "$ROOT/manifests/workloads.yaml"
kubectl rollout status deploy -n carbon-demo --timeout=180s

echo "Waiting 60s for CPU metrics..."
sleep 60
kubectl top pod -n carbon-demo
