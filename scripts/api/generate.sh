#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf "Usage: %s <SPEC_FILENAME> <API_DIR> <INTERNAL_DIR> \n" "$(basename "$0")"
  printf "Example: %s user.yaml api/ internal/ \n" "$(basename "$0")"
}

readonly SPEC_FILENAME="${1-}"
readonly API_DIR="${2-}"
readonly INTERNAL_DIR="${3-}"

if [[ $# -ne 3 ]]; then
  usage
  exit 64
fi

#readonly COMMON_SPEC_FILENAME="./common.yaml"
readonly MODEL_CFG="configs/openapi/model-cfg.yaml"
readonly SERVER_CFG="configs/openapi/server-cfg.yaml"
readonly OAPI_CLI="oapi-codegen"
readonly COMMON_SPEC="api/common.yaml"

REL_PATH="${SPEC_FILENAME#"${API_DIR}"/}"
DOMAIN="$(basename "$REL_PATH" .yaml)"
OUT_DIR="${INTERNAL_DIR}/${DOMAIN}/gen"
mkdir -p "$OUT_DIR"

require_cmd() {
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || {
      echo "Error: required command '$cmd' not found in PATH" >&2
      exit 127
    }
  done
}

generate_from_config() {
  local cfg_template="$1"
  local output_file="$2"
  local spec_file="${3:-$SPEC_FILENAME}"

  yq "
    .package = \"$DOMAIN\" |
    .output = \"$output_file\"
  " "$cfg_template" > "$TMP_CONFIG"

  "$OAPI_CLI" --config="$TMP_CONFIG" \
    "$spec_file"
}

require_cmd yq "$OAPI_CLI" mktemp
TMP_CONFIG="$(mktemp -t oapi_gen_cfg.XXXXXX)"
trap 'rm -f "$TMP_CONFIG"' EXIT

echo "Generating $SPEC_FILENAME -> $OUT_DIR (package: $DOMAIN)"

# Generate common models
echo "  - common -> ${OUT_DIR}/common.go"
generate_from_config "$MODEL_CFG" "$OUT_DIR/common.go" "$COMMON_SPEC"

# Generate models
echo "  - models -> ${OUT_DIR}/model.go"
generate_from_config "$MODEL_CFG" "$OUT_DIR/model.go"

# Generate go-service-template
echo "  - server -> ${OUT_DIR}/server.go"
generate_from_config "$SERVER_CFG" "$OUT_DIR/server.go"