#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_cr_record.sh"
fixture="$root_dir/cr/CR-0003-record-equivalent-crs.md"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

rebase_record="$temp_dir/rebase.md"
sed '/^Head or Range:/a Integration Strategy: rebase-ff' "$fixture" > "$rebase_record"
"$validator" "$rebase_record"

for strategy in merge squash; do
  invalid_record="$temp_dir/$strategy.md"
  sed "/^Head or Range:/a Integration Strategy: $strategy" "$fixture" > "$invalid_record"
  if "$validator" "$invalid_record" >/dev/null 2>&1; then
    echo "$strategy integration strategy fixture unexpectedly passed" >&2
    exit 1
  fi
done

echo "CR integration strategy fixture validation passed"
