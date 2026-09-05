#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

version="v0.0.0-equivalence"
dist_dir="$temp_dir/dist"
SOURCE_DATE_EPOCH=0 "$root_dir/scripts/build_bootstrap_package.sh" "$version" --output-dir "$dist_dir" >/dev/null
archive="$dist_dir/ugs-bootstrap-$version.tar.gz"
manifest="$archive.manifest.json"
unpack_dir="$temp_dir/unpack"
mkdir -p "$unpack_dir"
tar -xzf "$archive" -C "$unpack_dir"
package_root="$unpack_dir/ugs-bootstrap-$version"

source_commit="$(git -C "$root_dir" rev-parse HEAD)"
[ "$(jq -r '.source_commit' "$manifest")" = "$source_commit" ]
jq -e '.profiles == ["baseline", "standard", "high-trust"]' "$manifest" >/dev/null

# These are the source inputs used by the builder. The archive must contain
# byte-for-byte copies, so a package cannot silently drift from its tag.
while IFS=$'\t' read -r source relative; do
  cmp -s "$root_dir/$source" "$package_root/$relative" || {
    echo "bootstrap source/package mismatch: $source -> $relative" >&2
    exit 1
  }
done <<'FILES'
bootstrap/README.md	README.md
bootstrap/templates/policy.json	bootstrap/templates/policy.json
bootstrap/templates/policy-standard.json	bootstrap/templates/policy-standard.json
bootstrap/templates/policy-high-trust.json	bootstrap/templates/policy-high-trust.json
.ugs/schema/policy.schema.json	bootstrap/templates/policy.schema.json
bootstrap/templates/standard-workflow.yml	bootstrap/templates/standard-workflow.yml
.github/workflows/ugs-validate.yml	.github/workflows/ugs-validate.yml
scripts/ugs_init.py	scripts/ugs_init.py
scripts/ugs_init.sh	scripts/ugs_init.sh
scripts/validate_policy_manifest.sh	scripts/validate_policy_manifest.sh
scripts/validate_cr_record.sh	scripts/validate_cr_record.sh
scripts/validate_pr_cr.sh	scripts/validate_pr_cr.sh
scripts/create_pr_from_cr.sh	scripts/create_pr_from_cr.sh
scripts/validate_ref_update.sh	scripts/validate_ref_update.sh
scripts/test_profile_conformance.sh	scripts/test_profile_conformance.sh
scripts/validate_quality_profile.sh	scripts/validate_quality_profile.sh
scripts/validate_supply_chain_profile.sh	scripts/validate_supply_chain_profile.sh
scripts/validate_supply_chain_evidence.sh	scripts/validate_supply_chain_evidence.sh
scripts/validate_action_pinning.sh	scripts/validate_action_pinning.sh
scripts/validate_repository_shape.sh	scripts/validate_repository_shape.sh
scripts/validate_signer_roles.sh	scripts/validate_signer_roles.sh
scripts/validate_commit_signatures.sh	scripts/validate_commit_signatures.sh
scripts/validate_release_tag.sh	scripts/validate_release_tag.sh
scripts/validate_release_attestation.sh	scripts/validate_release_attestation.sh
keys/README.md	keys/README.md
keys/allowed_signers	keys/allowed_signers
keys/revoked_signers	keys/revoked_signers
keys/signer_roles.json	keys/signer_roles.json
.ugs/schema/signer-roles.schema.json	.ugs/schema/signer-roles.schema.json
FILES

for profile in baseline standard high-trust; do
  target="$temp_dir/$profile-repository"
  "$package_root/scripts/ugs_init.sh" --profile "$profile" --no-commit "$target" >/dev/null
  [ "$(jq -r '.profile' "$target/.ugs/bootstrap.json")" = "$profile" ]
  case "$profile" in
    baseline)
      (cd "$target" && scripts/validate_policy_manifest.sh .ugs/policy.json)
      ;;
    standard)
      (cd "$target" && scripts/validate_policy_manifest.sh .ugs/policy.json && scripts/validate_quality_profile.sh .ugs/policy.json && scripts/validate_supply_chain_profile.sh .ugs/policy.json && scripts/validate_action_pinning.sh .ugs/policy.json .github/workflows && scripts/validate_repository_shape.sh .ugs/policy.json)
      ;;
    high-trust)
      (cd "$target" && scripts/validate_policy_manifest.sh .ugs/policy.json && scripts/validate_signer_roles.sh && scripts/validate_action_pinning.sh .ugs/policy.json .github/workflows)
      ;;
  esac
done

if rg -n -- '-----BEGIN (OPENSSH|RSA|EC|DSA) PRIVATE KEY-----' "$package_root" "$temp_dir" >/dev/null 2>&1; then
  echo "bootstrap package unexpectedly contains a private key" >&2
  exit 1
fi

first_archive="$temp_dir/first.tar.gz"
cp "$archive" "$first_archive"
SOURCE_DATE_EPOCH=0 "$root_dir/scripts/build_bootstrap_package.sh" "$version" --output-dir "$dist_dir" >/dev/null
cmp -s "$first_archive" "$archive"

echo "bootstrap source/package equivalence passed"
