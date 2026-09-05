#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_action_pinning.sh"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

mkdir -p "$temp_dir/workflows"
cat > "$temp_dir/workflows/valid.yml" <<'EOF'
name: valid
steps:
  - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683
EOF
jq '.supply_chain.profile = "standard" | .supply_chain.action_pinning = "full_sha"' \
  "$root_dir/.ugs/policy.json" > "$temp_dir/manifest.json"
"$validator" "$temp_dir/manifest.json" "$temp_dir/workflows"

sed 's/11bd71901bbe5b1630ceea73d27597364c9af683/v4/' \
  "$temp_dir/workflows/valid.yml" > "$temp_dir/workflows/invalid.yml"
if "$validator" "$temp_dir/manifest.json" "$temp_dir/workflows" >/dev/null 2>&1; then
  echo "action pinning fixture unexpectedly passed" >&2
  exit 1
fi
echo "action pinning fixtures validation passed"
