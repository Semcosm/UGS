#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_policy_manifest.sh"
fixtures="$root_dir/tests/fixtures/policy-manifest"

"$validator" "$fixtures/valid.json"

for fixture in "$fixtures"/invalid-*.json; do
  if "$validator" "$fixture" >/dev/null 2>&1; then
    echo "policy manifest fixture unexpectedly passed: $fixture" >&2
    exit 1
  fi
done
