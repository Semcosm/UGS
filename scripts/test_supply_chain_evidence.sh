#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
manifest_validator="$root_dir/scripts/validate_policy_manifest.sh"
profile_validator="$root_dir/scripts/validate_supply_chain_profile.sh"
evidence_validator="$root_dir/scripts/validate_supply_chain_evidence.sh"
fixture="$root_dir/tests/fixtures/policy-manifest/invalid-supply-chain-missing-evidence.json"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

"$evidence_validator" "$root_dir/.ugs/policy.json"

jq 'del(.supply_chain)' "$root_dir/.ugs/policy.json" > "$temp_dir/no-supply-chain.json"
"$profile_validator" "$temp_dir/no-supply-chain.json"
"$evidence_validator" "$temp_dir/no-supply-chain.json"

for validator in "$manifest_validator" "$profile_validator" "$evidence_validator"; do
  if "$validator" "$fixture" >/dev/null 2>&1; then
    echo "validator unexpectedly accepted missing evidence: $validator" >&2
    exit 1
  fi
done
jq '.supply_chain.evidence = {sbom_paths: ["README.md"], build_record_paths: ["REPOSITORY_POLICY.md"], attestation_paths: []}' \
  "$root_dir/.ugs/policy.json" > "$temp_dir/valid-evidence.json"
"$evidence_validator" "$temp_dir/valid-evidence.json"

jq '.supply_chain.evidence = {sbom_paths: ["../outside.json"]}' \
  "$root_dir/.ugs/policy.json" > "$temp_dir/traversal.json"
if "$evidence_validator" "$temp_dir/traversal.json" >/dev/null 2>&1; then
  echo "evidence validator unexpectedly accepted traversal path" >&2
  exit 1
fi

echo "supply-chain evidence fixtures validation passed"
