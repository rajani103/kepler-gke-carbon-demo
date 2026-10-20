#!/usr/bin/env bash
# Estimated watts and yearly CO2e per demo container.
#
#   cores       = rate of kepler_container_cpu_seconds_total   (real, from Kepler)
#   est. watts  = cores x (MAX_W - MIN_W)                      (Cloud Carbon Footprint GCP average)
#   kg CO2e/yr  = watts x 8760 h / 1000 x GRID / 1000
#
# This is an ESTIMATE. Use it when the node has no RAPL (cloud VMs), where
# Kepler falls back to its fake meter and its own watts are synthetic.
set -euo pipefail

MIN_W="${MIN_W:-1.34}"        # W per vCPU at 0% utilisation (CCF, GCP average)
MAX_W="${MAX_W:-4.98}"        # W per vCPU at 100% utilisation (CCF, GCP average)
GRID="${GRID_INTENSITY:-598}" # gCO2e per kWh, asia-south1 (Google, 2025)
WINDOW="${WINDOW:-30}"        # seconds between the two samples
PORT="${PORT:-28282}"

PF_PID=""
if ! curl -s -o /dev/null "localhost:$PORT/metrics"; then
  kubectl port-forward -n kepler svc/kepler "$PORT:$PORT" >/dev/null 2>&1 &
  PF_PID=$!
  sleep 3
fi
trap '[ -n "$PF_PID" ] && kill "$PF_PID" 2>/dev/null || true' EXIT

snap() {
  curl -s "localhost:$PORT/metrics" \
    | grep '^kepler_container_cpu_seconds_total' \
    | grep -E 'container_name="(busy|sleepy)-poller"' \
    | sed -E 's/.*container_name="([^"]+)".* ([0-9.e+-]+)$/\1 \2/' \
    | sort
}

A="$(snap)"; sleep "$WINDOW"; B="$(snap)"

printf '%-15s %8s %12s %14s\n' CONTAINER CORES 'EST. WATTS' 'kg CO2e/YEAR'
join <(echo "$A") <(echo "$B") | awk -v w="$WINDOW" -v min="$MIN_W" -v max="$MAX_W" -v g="$GRID" '{
  c = ($3 - $2) / w
  watts = c * (max - min)
  printf "%-15s %8.3f %12.3f %14.2f\n", $1, c, watts, watts * 8.76 * g / 1000
}'
