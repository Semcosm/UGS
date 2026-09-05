#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

body="$temp_dir/body.md"
event="$temp_dir/event.json"
cp "$root_dir/cr/CR-0060-document-map-governance.md" "$body"
printf '\n' >> "$body"
jq -n --rawfile body "$body" '{pull_request: {body: $body}}' > "$event"

base="$(sed -n 's/^Base OID: //p' "$root_dir/cr/CR-0060-document-map-governance.md")"
head="$(git -C "$root_dir" rev-parse HEAD)"
(cd "$root_dir" && adapters/github/validate_pr.sh "$base" "$head" "$event" >/dev/null)
echo "PR body normalization fixture passed"
