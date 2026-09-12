#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="kong-learning"
CLIENT_POD="kong-ha-client"
KONG_URL="http://kong-gateway-proxy.kong.svc.cluster.local/"

echo "Testing Kong Gateway availability"

for i in $(seq 1 30); do
  CODE=$(kubectl exec \
    -n "$NAMESPACE" \
    "$CLIENT_POD" \
    -- curl \
    -s \
    -o /dev/null \
    --max-time 2 \
    -w "%{http_code}" \
    "$KONG_URL" || true)

  printf "Request %02d -> %s\n" "$i" "${CODE:-FAILED}"

  sleep 0.5
done
