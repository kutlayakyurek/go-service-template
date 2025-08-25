#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf "Usage: %s <SPEC.yaml> <API_DIR> <INTERNAL_DIR>\n" "$(basename "$0")"
  printf "Example: %s api/product.yaml api internal\n" "$(basename "$0")"
}

readonly SPEC="${1-}"
readonly API_DIR="${2-}"
readonly INTERNAL_DIR="${3-}"

SPEC_FILENAME="${SPEC#"${API_DIR}"/}"
DOMAIN="$(basename "$SPEC_FILENAME" .yaml)"
OUT_DIR="${INTERNAL_DIR}/${DOMAIN}/gen"

echo "Cleaning $OUT_DIR"
rm -rf "$OUT_DIR"