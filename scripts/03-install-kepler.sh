#!/usr/bin/env bash
# Installs Kepler as a DaemonSet, shows which power meter it picked,
# and tells Google Cloud Managed Service for Prometheus to scrape it.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

helm upgrade --install kepler oci://quay.io/sustainable_computing_io/charts/kepler \
  --namespace kepler --create-namespace \
  -f "$ROOT/manifests/kepler-values.yaml"

kubectl wait --for=condition=ready --timeout=180s pod -n kepler --all
kubectl get pods -n kepler -o wide

echo "--- Which power meter did Kepler pick? ---"
kubectl logs -n kepler -l app.kubernetes.io/name=kepler --tail=300 \
  | grep -i -E "cpu meter|cpu power meter" || true

kubectl apply -f "$ROOT/manifests/podmonitoring.yaml"
