#!/usr/bin/env bash
set -euo pipefail
root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_sbom.sh"
fixtures="$root_dir/tests/fixtures/sbom"
"$validator" "$fixtures/valid-spdx.json"
"$validator" "$fixtures/valid-cyclonedx.json"
if "$validator" "$fixtures/invalid-missing-version.json" >/dev/null 2>&1; then
  echo "SBOM fixture unexpectedly passed: invalid-missing-version.json" >&2
  exit 1
fi
echo "SBOM fixtures validation passed"
