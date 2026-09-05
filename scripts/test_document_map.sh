#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_document_map.py"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

"$validator"
cp "$root_dir/.ugs/document-map.json" "$temp_dir/valid.json"
"$validator" "$temp_dir/valid.json"

jq '.nodes[0].children[0].path = "docs/git/missing.md"' \
  "$root_dir/.ugs/document-map.json" > "$temp_dir/missing.json"
if "$validator" "$temp_dir/missing.json" >/dev/null 2>&1; then
  echo "missing document fixture unexpectedly passed" >&2
  exit 1
fi

jq '.nodes[0].children[1].title = .nodes[0].children[0].title' \
  "$root_dir/.ugs/document-map.json" > "$temp_dir/duplicate.json"
if "$validator" "$temp_dir/duplicate.json" >/dev/null 2>&1; then
  echo "duplicate title fixture unexpectedly passed" >&2
  exit 1
fi

echo "document map fixtures passed"
