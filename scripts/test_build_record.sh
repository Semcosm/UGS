#!/usr/bin/env bash
set -euo pipefail
root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_build_record.sh"
fixtures="$root_dir/tests/fixtures/build-record"
"$validator" "$fixtures/valid.json"
if "$validator" "$fixtures/invalid-digest.json" >/dev/null 2>&1; then
  echo "build record fixture unexpectedly passed" >&2
  exit 1
fi
echo "build record fixtures validation passed"
