#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_exception_record.sh"
fixture="$root_dir/cr/EX-0001-bootstrap-governance.md"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

"$validator" "$fixture"
invalid_file="$temp_dir/invalid.md"
sed 's/^Status: closed$/Status: active/; s/^Post-Event Review: main@.*$/Post-Event Review: main@/' "$fixture" > "$invalid_file"
if "$validator" "$invalid_file" >/dev/null 2>&1; then
  echo "exception record fixture unexpectedly passed" >&2
  exit 1
fi

bootstrap_count="$(find "$root_dir/cr" -maxdepth 1 -type f -name 'EX-*.md' -print | while read -r file; do sed -n 's/^Type: //p' "$file"; done | grep -c '^bootstrap$' || true)"
[ "$bootstrap_count" -eq 1 ] || {
  echo "exception record validation failed: bootstrap must be recorded exactly once" >&2
  exit 1
}

echo "exception record fixtures validation passed"
