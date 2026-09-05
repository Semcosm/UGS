#!/usr/bin/env bash
set -euo pipefail
root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_release_attestation.sh"
fixtures="$root_dir/tests/fixtures/attestation"
"$validator" "$fixtures/valid.json"
if "$validator" "$fixtures/invalid-digest.json" >/dev/null 2>&1; then
  echo "attestation fixture unexpectedly passed: invalid-digest.json" >&2
  exit 1
fi
if "$validator" "$fixtures/invalid-commit.json" >/dev/null 2>&1; then
  echo "attestation fixture unexpectedly passed: invalid-commit.json" >&2
  exit 1
fi
echo "release attestation fixtures validation passed"
