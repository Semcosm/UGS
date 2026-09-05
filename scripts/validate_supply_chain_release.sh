#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <release-tag>" >&2
  exit 2
fi
tag="$1"
manifest=".ugs/policy.json"
fail() { echo "supply-chain release validation failed: $1" >&2; exit 1; }
[ -f "$manifest" ] || fail "manifest does not exist"
if ! jq -e '.supply_chain? // {} | has("evidence")' "$manifest" >/dev/null; then
  echo "supply-chain release evidence not declared"
  exit 0
fi
commit="$(git rev-parse --verify "refs/tags/$tag^{commit}")" || fail "release tag does not resolve: $tag"
signature_requirement="$(jq -r '.supply_chain.release_attestations == "signed"' "$manifest")"
while IFS= read -r path; do
  scripts/validate_sbom.sh "$path" "$tag" "$commit"
done < <(jq -r '.supply_chain.evidence.sbom_paths // [] | .[]' "$manifest")
while IFS= read -r path; do
  scripts/validate_release_attestation.sh "$path" "$tag" "$commit" "$signature_requirement"
done < <(jq -r '.supply_chain.evidence.attestation_paths // [] | .[]' "$manifest")
echo "supply-chain release validation passed ($tag)"
