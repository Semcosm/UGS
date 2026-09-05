#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
  echo "usage: $0 <release-tag> [manifest] [repository]" >&2
  exit 2
fi
tag="$1"
root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
manifest="${2:-$root_dir/.ugs/policy.json}"
repository="${3:-}"
fail() { echo "supply-chain release validation failed: $1" >&2; exit 1; }
[ -f "$manifest" ] || fail "manifest does not exist: $manifest"
cd "$root_dir"
profile="$(jq -r '.supply_chain.profile // "none"' "$manifest")"
scripts/validate_supply_chain_profile.sh "$manifest" >/dev/null
scripts/validate_supply_chain_evidence.sh "$manifest" >/dev/null
if ! jq -e '.supply_chain? // {} | has("evidence")' "$manifest" >/dev/null; then
  echo "supply-chain release evidence not declared"
  exit 0
fi
commit="$(git rev-parse --verify "refs/tags/$tag^{commit}")" || fail "release tag does not resolve: $tag"
signature_requirement="$(jq -r '.supply_chain.release_attestations == "signed"' "$manifest")"
[ -n "$repository" ] || fail "repository identity must be provided explicitly"
declare -a evidence_digests=()
collect_common() {
  local path="$1" kind="$2" release commit_value digest
  [ -f "$path" ] || fail "evidence file does not exist: $path"
  case "$kind" in
    sbom)
      release="$(jq -r 'if .spdxVersion then (.documentComment // "") | capture("ugs:release=(?<v>v[0-9]+\\.[0-9]+\\.[0-9]+)").v elif .bomFormat == "CycloneDX" then ([.metadata.properties[]? | select(.name == "ugs:release") | .value][0] // "") else "" end' "$path")" || fail "SBOM release metadata is invalid: $path"
      commit_value="$(jq -r 'if .spdxVersion then (.documentComment // "") | capture("ugs:sourceCommit=(?<v>[0-9a-f]{40})").v elif .bomFormat == "CycloneDX" then ([.metadata.properties[]? | select(.name == "ugs:sourceCommit") | .value][0] // "") else "" end' "$path")" || fail "SBOM commit metadata is invalid: $path"
      digest="$(jq -r 'if .spdxVersion then (.documentComment // "") | capture("ugs:artifactDigest=(?<v>sha256:[0-9a-f]{64})").v elif .bomFormat == "CycloneDX" then ([.metadata.properties[]? | select(.name == "ugs:artifactDigest") | .value][0] // "") else "" end' "$path")" || fail "SBOM digest metadata is invalid: $path"
      ;;
    build|attestation)
      release="$(jq -r '.release_tag // empty' "$path")"
      commit_value="$(jq -r '.commit // empty' "$path")"
      digest="$(jq -r '.artifact.digest // empty' "$path")"
      ;;
  esac
  [ "$release" = "$tag" ] || fail "$kind release does not match $tag: $path"
  [ "$commit_value" = "$commit" ] || fail "$kind commit does not match release tag: $path"
  [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]] || fail "$kind artifact digest is missing or invalid: $path"
  evidence_digests+=("$digest")
}
while IFS= read -r path; do
  scripts/validate_sbom.sh "$path" "$tag" "$commit"
  collect_common "$path" sbom
done < <(jq -r '.supply_chain.evidence.sbom_paths // [] | .[]' "$manifest")
while IFS= read -r path; do
  scripts/validate_build_record.sh "$path" "$tag" "$commit"
  collect_common "$path" build
done < <(jq -r '.supply_chain.evidence.build_record_paths // [] | .[]' "$manifest")
while IFS= read -r path; do
  scripts/validate_release_attestation.sh "$path" "$tag" "$commit" "$signature_requirement" "$repository"
  collect_common "$path" attestation
done < <(jq -r '.supply_chain.evidence.attestation_paths // [] | .[]' "$manifest")
[ "${#evidence_digests[@]}" -gt 0 ] || fail "evidence lists are empty"
first_digest="${evidence_digests[0]}"
for digest in "${evidence_digests[@]}"; do
  [ "$digest" = "$first_digest" ] || fail "evidence artifact digests do not match"
done
echo "supply-chain release validation passed ($tag)"
