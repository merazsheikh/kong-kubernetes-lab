#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="kong/custom-plugins/request-header-validator"
IMAGE_TAG="kong-request-header-validator:ci-test"

echo "== Check required files =="
test -f "$PLUGIN_DIR/handler.lua"
test -f "$PLUGIN_DIR/schema.lua"
test -f "$PLUGIN_DIR/Dockerfile"

echo "== Check Lua syntax =="
docker run --rm \
  -v "$PWD/$PLUGIN_DIR:/plugin:ro" \
  kong:3.9.3 \
  sh -c '
    resty -e "assert(loadfile(\"/plugin/handler.lua\"))"
    resty -e "assert(loadfile(\"/plugin/schema.lua\"))"
  '

echo "== Build custom Kong image =="
docker build \
  -t "$IMAGE_TAG" \
  "$PLUGIN_DIR"

echo "== Verify plugin files in image =="
docker run --rm \
  --entrypoint sh \
  "$IMAGE_TAG" \
  -c '
    test -f /usr/local/share/lua/5.1/kong/plugins/request-header-validator/handler.lua
    test -f /usr/local/share/lua/5.1/kong/plugins/request-header-validator/schema.lua
    echo "$KONG_PLUGINS" | grep -q request-header-validator
  '

echo "== Validate Helm rendering =="
helm template kong kong/ingress \
  -n kong \
  -f kong/helm-custom-image-values.yaml \
  > /tmp/kong-ci-rendered.yaml

grep -q "request-header-validator" /tmp/kong-ci-rendered.yaml

echo "All custom plugin validation checks passed."
