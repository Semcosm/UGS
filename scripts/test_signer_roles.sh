#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_signer_roles.sh"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

"$validator"
invalid_file="$temp_dir/invalid.json"
jq '.signers[0].status = "revoked"' "$root_dir/keys/signer_roles.json" > "$invalid_file"
if "$validator" "$invalid_file" >/dev/null 2>&1; then
  echo "signer roles fixture unexpectedly passed" >&2
  exit 1
fi

echo "signer roles fixture validation passed"
