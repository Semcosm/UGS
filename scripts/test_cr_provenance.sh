#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_cr_record.sh"
fixture="$root_dir/cr/CR-0003-record-equivalent-crs.md"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

invalid_record="$temp_dir/invalid-provenance.md"
sed 's/^Integrated Result: main@.*/Integrated Result: main@00ea46e51f13d2cfedeedebfe72f280b48984c1b/' \
  "$fixture" > "$invalid_record"

if "$validator" "$invalid_record" >/dev/null 2>&1; then
  echo "CR provenance fixture unexpectedly passed" >&2
  exit 1
fi

echo "CR provenance fixture validation passed"
