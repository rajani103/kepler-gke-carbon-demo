#!/usr/bin/env bash
# Shared settings for the Kepler on GKE demo. Source this first:  source ./00-env.sh
export PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null)}"
export ZONE="${ZONE:-asia-south1-a}"          # Mumbai. Grid intensity 598 gCO2e/kWh (Google, 2025)
export CLUSTER="carbon-demo"
export MACHINE_TYPE="e2-standard-4"  # small and cheap; one node is enough
export GRID_INTENSITY="${GRID_INTENSITY:-598}"  # gCO2e per kWh for asia-south1. Change if you change ZONE.

echo "project=$PROJECT_ID zone=$ZONE cluster=$CLUSTER machine=$MACHINE_TYPE"
