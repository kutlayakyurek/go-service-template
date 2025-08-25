#!/usr/bin/env bash
set -euo pipefail

# Ensure Node/npm/npx are available even in non-interactive shells (like make)
# Try to load nvm if installed
if ! command -v npx >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
  fi
fi

# Resolve NPX after attempting to initialize Node environment
NPX="$(command -v npx || echo "npm exec --")"

# Final guard: provide a helpful error if neither npx nor npm is available
if ! command -v npx >/dev/null 2>&1 && ! command -v npm >/dev/null 2>&1; then
  echo "Error: npx/npm not found on PATH. If you use nvm, ensure it's installed and configured."
  echo "Tip: run your Node setup script and/or ensure NVM_DIR is set and nvm.sh is sourced."
  exit 1
fi

# Join all spec files to a single file
declare -a SPEC_FILES
read -r -a SPEC_FILES <<< "$1"

BUNDLE_OUT="$2"

echo "Merging ${SPEC_FILES[*]} -> ${BUNDLE_OUT}"

$NPX @redocly/cli@latest join "${SPEC_FILES[@]}" -o "$BUNDLE_OUT" --without-x-tag-groups

PROJECT_NAME=$(basename "$PWD")

# Change bundled api title to the service name
sed -i "s/^  title:.*$/  title: $PROJECT_NAME/" "$BUNDLE_OUT"