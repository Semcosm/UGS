#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
zeros="0000000000000000000000000000000000000000"
first_object="1111111111111111111111111111111111111111"

version="v0.3.27"
dist_dir="$temp_dir/dist"
SOURCE_DATE_EPOCH=0 "$root_dir/scripts/build_bootstrap_package.sh" "$version" --output-dir "$dist_dir" >/dev/null
archive="$dist_dir/ugs-bootstrap-$version.tar.gz"
manifest="$archive.manifest.json"
components="$archive.components.json"
unpack_dir="$temp_dir/unpack"
mkdir -p "$unpack_dir"
tar -xzf "$archive" -C "$unpack_dir"
package_root="$unpack_dir/ugs-bootstrap-$version"

source_commit="$(git -C "$root_dir" rev-parse HEAD)"
[ "$(jq -r '.source_commit' "$manifest")" = "$source_commit" ]
jq -e '.profiles == ["baseline", "standard", "high-trust"]' "$manifest" >/dev/null
[ -f "$components" ]
cmp -s "$components" "$package_root/COMPONENTS.json"

# These are the source inputs used by the builder. The archive must contain
# byte-for-byte copies, so a package cannot silently drift from its tag.
while IFS=$'\t' read -r source relative; do
  cmp -s "$root_dir/$source" "$package_root/$relative" || {
    echo "bootstrap source/package mismatch: $source -> $relative" >&2
    exit 1
  }
done <<'FILES'
bootstrap/README.md	README.md
bootstrap/OFFLINE-QUICKSTART.md	OFFLINE-QUICKSTART.md
CONTRIBUTING.md	CONTRIBUTING.md
RELEASE.md	RELEASE.md
docs/git/commit-convention.md	docs/git/commit-convention.md
docs/git/release-policy.md	docs/git/release-policy.md
docs/git/review-policy.md	docs/git/review-policy.md
docs/git/ugs-bootstrap.md	docs/git/ugs-bootstrap.md
docs/git/ugs-branch-profiles.md	docs/git/ugs-branch-profiles.md
docs/git/ugs-conformance-fixtures.md	docs/git/ugs-conformance-fixtures.md
docs/git/ugs-conformance-levels.md	docs/git/ugs-conformance-levels.md
docs/git/ugs-core.md	docs/git/ugs-core.md
docs/git/ugs-document-map.md	docs/git/ugs-document-map.md
docs/git/ugs-quality-profile.md	docs/git/ugs-quality-profile.md
docs/git/ugs-repository-shapes.md	docs/git/ugs-repository-shapes.md
docs/git/ugs-supply-chain-profile.md	docs/git/ugs-supply-chain-profile.md
docs/git/ugs-v0.3-profile.md	docs/git/ugs-v0.3-profile.md
bootstrap/templates/policy.json	bootstrap/templates/policy.json
bootstrap/templates/policy-standard.json	bootstrap/templates/policy-standard.json
bootstrap/templates/policy-high-trust.json	bootstrap/templates/policy-high-trust.json
bootstrap/templates/CODE_OF_CONDUCT.md	bootstrap/templates/CODE_OF_CONDUCT.md
bootstrap/templates/LICENSE	bootstrap/templates/LICENSE
bootstrap/templates/README.md	bootstrap/templates/README.md
bootstrap/templates/RELEASE.md	bootstrap/templates/RELEASE.md
bootstrap/templates/SECURITY.md	bootstrap/templates/SECURITY.md
bootstrap/templates/SUPPORT.md	bootstrap/templates/SUPPORT.md
bootstrap/templates/cr/README.md	bootstrap/templates/cr/README.md
bootstrap/templates/cr/TEMPLATE.md	bootstrap/templates/cr/TEMPLATE.md
bootstrap/templates/githooks/README.md	bootstrap/templates/githooks/README.md
bootstrap/templates/githooks/commit-msg	bootstrap/templates/githooks/commit-msg
bootstrap/templates/repository-policy.md	bootstrap/templates/repository-policy.md
bootstrap/templates/supply-chain-README.md	bootstrap/templates/supply-chain-README.md
.ugs/schema/policy.schema.json	bootstrap/templates/policy.schema.json
bootstrap/templates/document-map.json	bootstrap/templates/document-map.json
.ugs/schema/document-map.schema.json	bootstrap/templates/document-map.schema.json
bootstrap/templates/standard-workflow.yml	bootstrap/templates/standard-workflow.yml
.github/workflows/ugs-validate.yml	.github/workflows/ugs-validate.yml
scripts/ugs_init.py	scripts/ugs_init.py
scripts/ugs_init.sh	scripts/ugs_init.sh
scripts/ugs.sh	scripts/ugs.sh
scripts/ugs_upgrade.py	scripts/ugs_upgrade.py
scripts/ugs_upgrade.sh	scripts/ugs_upgrade.sh
scripts/validate_policy_manifest.sh	scripts/validate_policy_manifest.sh
scripts/validate_cr_record.sh	scripts/validate_cr_record.sh
scripts/validate_cr_review.sh	scripts/validate_cr_review.sh
scripts/validate_pr_cr.sh	scripts/validate_pr_cr.sh
scripts/create_pr_from_cr.sh	scripts/create_pr_from_cr.sh
adapters/github/validate_pr.sh	adapters/github/validate_pr.sh
adapters/github/create_pr_from_cr.sh	adapters/github/create_pr_from_cr.sh
adapters/github/validate_adapter.sh	adapters/github/validate_adapter.sh
adapters/github/validate_action_pinning.sh	adapters/github/validate_action_pinning.sh
adapters/github/download_release.sh	adapters/github/download_release.sh
adapters/github/publish_release.sh	adapters/github/publish_release.sh
adapters/bare-git/update	adapters/bare-git/update
scripts/validate_main_cr_range.sh	scripts/validate_main_cr_range.sh
scripts/validate_ref_update.sh	scripts/validate_ref_update.sh
scripts/test_profile_conformance.sh	scripts/test_profile_conformance.sh
scripts/validate_quality_profile.sh	scripts/validate_quality_profile.sh
scripts/validate_supply_chain_profile.sh	scripts/validate_supply_chain_profile.sh
scripts/validate_supply_chain_evidence.sh	scripts/validate_supply_chain_evidence.sh
scripts/validate_action_pinning.sh	scripts/validate_action_pinning.sh
scripts/validate_repository_shape.sh	scripts/validate_repository_shape.sh
scripts/generate_document_map.py	scripts/generate_document_map.py
scripts/validate_document_map.py	scripts/validate_document_map.py
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

if [ -f "$root_dir/releases/${version}.md" ]; then
  cmp -s "$root_dir/releases/${version}.md" "$package_root/RELEASE-NOTES.md" || {
    echo "bootstrap source/package mismatch: releases/${version}.md -> RELEASE-NOTES.md" >&2
    exit 1
  }
fi

for profile in baseline standard high-trust; do
  target="$temp_dir/$profile-repository"
  init_args=(--profile "$profile" --no-commit)
  [ "$profile" = standard ] && init_args+=(--with-document-map)
  "$package_root/scripts/ugs_init.sh" "${init_args[@]}" "$target" >/dev/null
  [ "$(jq -r '.profile' "$target/.ugs/bootstrap.json")" = "$profile" ]
  case "$profile" in
    baseline)
      (cd "$target" && scripts/validate_policy_manifest.sh .ugs/policy.json)
      [ ! -e "$target/.github" ]
      [ -x "$target/adapters/bare-git/update" ]
      [ -x "$target/scripts/validate_ref_update.sh" ]
      [ ! -e "$target/adapters/github" ]
      (cd "$target" && ./adapters/bare-git/update refs/heads/main "$zeros" "$first_object" >/dev/null)
      if (cd "$target" && ./scripts/create_pr_from_cr.sh >"$temp_dir/baseline-create-pr-output" 2>&1); then
        echo "baseline create_pr_from_cr wrapper unexpectedly passed" >&2
        exit 1
      fi
      grep -Fq 'optional GitHub adapter is not installed' "$temp_dir/baseline-create-pr-output"
      ;;
    standard)
      (cd "$target" && scripts/validate_policy_manifest.sh .ugs/policy.json && scripts/validate_quality_profile.sh .ugs/policy.json && scripts/validate_supply_chain_profile.sh .ugs/policy.json && scripts/validate_action_pinning.sh .ugs/policy.json .github/workflows && scripts/validate_repository_shape.sh .ugs/policy.json)
      [ -x "$target/adapters/github/validate_pr.sh" ]
      [ -x "$target/adapters/github/validate_action_pinning.sh" ]
      [ -x "$target/scripts/validate_ref_update.sh" ]
      (cd "$target" && scripts/generate_document_map.py --check && scripts/validate_document_map.py)
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
