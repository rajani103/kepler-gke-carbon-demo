#!/usr/bin/env bash
# Delete everything after recording so the cluster stops costing money.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"

kubectl delete namespace carbon-demo --ignore-not-found
helm uninstall kepler -n kepler || true
gcloud container clusters delete "$CLUSTER" --zone "$ZONE" --quiet
