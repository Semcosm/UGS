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

rotation_file="$temp_dir/rotation.json"
jq '.signers as $signers | .signers = [
  ($signers[0] | .effective_from = "2026-01-01" | .effective_until = "2026-06-01" | .status = "revoked"),
  ($signers[0] | .key_fingerprint = "SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" | .effective_from = "2026-06-01" | .effective_until = null | .status = "active")
]' "$root_dir/keys/signer_roles.json" > "$rotation_file"
"$validator" "$rotation_file" >/dev/null

overlap_file="$temp_dir/overlap.json"
jq '.signers as $signers | .signers = [
  ($signers[0] | .effective_from = "2026-01-01" | .effective_until = "2026-09-01" | .status = "revoked"),
  ($signers[0] | .key_fingerprint = "SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=" | .effective_from = "2026-06-01" | .effective_until = null | .status = "active")
]' "$root_dir/keys/signer_roles.json" > "$overlap_file"
if "$validator" "$overlap_file" >/dev/null 2>&1; then
  echo "overlapping signer role fixture unexpectedly passed" >&2
  exit 1
fi

tester_file="$temp_dir/tester.json"
jq '.signers[0] |= (.role = "tester")' "$root_dir/keys/signer_roles.json" > "$tester_file"
"$validator" "$tester_file" >/dev/null

echo "signer roles fixture validation passed"
