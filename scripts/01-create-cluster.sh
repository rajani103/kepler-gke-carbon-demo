#!/usr/bin/env bash
# Creates a 1-node GKE Standard cluster with Google Managed Service for Prometheus.
# Run this BEFORE you start recording: cluster creation takes several minutes.
set -euo pipefail
source "$(dirname "$0")/00-env.sh"

gcloud services enable container.googleapis.com monitoring.googleapis.com

gcloud container clusters create "$CLUSTER" \
  --zone "$ZONE" \
  --num-nodes 1 \
  --machine-type "$MACHINE_TYPE" \
  --enable-managed-prometheus

gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
kubectl get nodes -o wide
