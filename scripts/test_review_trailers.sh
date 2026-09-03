#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
fixtures="$root_dir/tests/fixtures/review-trailers"
validator="$root_dir/scripts/validate_review_trailers.sh"

"$validator" "$fixtures/valid.txt"

if "$validator" "$fixtures/invalid-missing-reviewed-by.txt" >/dev/null 2>&1; then
  echo "review trailer fixture unexpectedly passed: invalid-missing-reviewed-by.txt" >&2
  exit 1
fi

if "$validator" "$fixtures/invalid-missing-tested-by.txt" >/dev/null 2>&1; then
  echo "review trailer fixture unexpectedly passed: invalid-missing-tested-by.txt" >&2
  exit 1
fi
