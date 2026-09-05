#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "repository validation failed: $1" >&2
  exit 1
}

required_files=(
  "README.md"
  "docs/git/ugs-core.md"
  "docs/git/ugs-branch-profiles.md"
  "docs/git/ugs-quality-profile.md"
  "docs/git/ugs-supply-chain-profile.md"
  "docs/git/ugs-repository-shapes.md"
  "docs/git/commit-convention.md"
  "docs/git/review-policy.md"
  "docs/git/release-policy.md"
  "REPOSITORY_POLICY.md"
  ".ugs/policy.json"
  ".ugs/schema/policy.schema.json"
  "CONTRIBUTING.md"
  "RELEASE.md"
  "releases/v0.2.0.md"
  "releases/v0.3.0.md"
  "docs/roadmap/v0.3.md"
  "cr/README.md"
  "cr/TEMPLATE.md"
  "keys/README.md"
  "keys/allowed_signers"
  "keys/revoked_signers"
  "keys/signer_roles.json"
  "cr/EX-0001-bootstrap-governance.md"
  ".ugs/schema/signer-roles.schema.json"
  ".githooks/README.md"
  ".githooks/commit-msg"
  ".githooks/pre-push"
  "scripts/validate_commit_message.sh"
  "scripts/validate_commit_range.sh"
  "scripts/validate_commit_signatures.sh"
  "scripts/validate_cr_record.sh"
  "scripts/validate_cr_review.sh"
  "scripts/test_core_bare_repository.sh"
  "scripts/validate_policy_manifest.sh"
  "scripts/test_policy_manifest.sh"
  "scripts/validate_repo.sh"
  "scripts/ugs_check.sh"
  "scripts/test_git_fixtures.sh"
  "scripts/validate_review_trailers.sh"
  "scripts/test_review_trailers.sh"
  "scripts/validate_release_tag.sh"
  "scripts/test_release_tag.sh"
  "scripts/validate_ref_update.sh"
  "scripts/test_ref_update.sh"
  "scripts/test_cr_provenance.sh"
  "scripts/test_cr_integration_strategy.sh"
  "scripts/test_cr_review_inheritance.sh"
  "scripts/validate_signer_roles.sh"
  "scripts/test_signer_roles.sh"
  "scripts/validate_exception_record.sh"
  "scripts/test_exception_records.sh"
  "scripts/validate_quality_profile.sh"
  "scripts/validate_supply_chain_profile.sh"
  "scripts/validate_supply_chain_evidence.sh"
  "scripts/test_supply_chain_evidence.sh"
  "scripts/validate_action_pinning.sh"
  "scripts/validate_sbom.sh"
  "scripts/test_sbom.sh"
  "scripts/validate_release_attestation.sh"
  "scripts/test_release_attestation.sh"
  "scripts/validate_supply_chain_release.sh"
  "scripts/validate_build_record.sh"
  "scripts/test_build_record.sh"
  "scripts/test_supply_chain_release.sh"
  "scripts/validate_repository_shape.sh"
  "scripts/conformance.py"
  "scripts/test_conformance.sh"
  "scripts/test_profile_conformance.sh"
  "scripts/validate_cr_coverage.sh"
  "scripts/validate_pr_cr.sh"
  "scripts/create_pr_from_cr.sh"
  "scripts/validate_main_cr_range.sh"
  "tests/conformance/manifest.json"
  "tests/conformance/profile-matrix.json"
  "tests/fixtures/cr/valid-template.md"
  "bootstrap/README.md"
  "bootstrap/templates/policy.json"
  "scripts/ugs_init.py"
  "scripts/ugs_init.sh"
  "scripts/build_bootstrap_package.py"
  "scripts/build_bootstrap_package.sh"
  "scripts/test_bootstrap_package.sh"
  "scripts/test_bootstrap_equivalence.sh"
  "scripts/test_bootstrap_release.sh"
  "docs/git/ugs-bootstrap.md"
)

for file in "${required_files[@]}"; do
  [ -f "$file" ] || fail "missing required file: $file"
done

executable_files=(
  ".githooks/commit-msg"
  ".githooks/pre-push"
  "scripts/validate_commit_message.sh"
  "scripts/validate_commit_range.sh"
  "scripts/validate_commit_signatures.sh"
  "scripts/validate_cr_record.sh"
  "scripts/validate_cr_review.sh"
  "scripts/test_core_bare_repository.sh"
  "scripts/validate_policy_manifest.sh"
  "scripts/test_policy_manifest.sh"
  "scripts/validate_repo.sh"
  "scripts/ugs_check.sh"
  "scripts/test_git_fixtures.sh"
  "scripts/validate_review_trailers.sh"
  "scripts/test_review_trailers.sh"
  "scripts/validate_release_tag.sh"
  "scripts/test_release_tag.sh"
  "scripts/validate_ref_update.sh"
  "scripts/test_ref_update.sh"
  "scripts/test_cr_provenance.sh"
  "scripts/test_cr_integration_strategy.sh"
  "scripts/test_cr_review_inheritance.sh"
  "scripts/validate_supply_chain_evidence.sh"
  "scripts/validate_sbom.sh"
  "scripts/test_sbom.sh"
  "scripts/validate_release_attestation.sh"
  "scripts/test_release_attestation.sh"
  "scripts/validate_supply_chain_release.sh"
  "scripts/validate_build_record.sh"
  "scripts/test_build_record.sh"
  "scripts/test_supply_chain_evidence.sh"
  "scripts/validate_action_pinning.sh"
  "scripts/test_action_pinning.sh"
  "scripts/test_supply_chain_release.sh"
  "scripts/conformance.py"
  "scripts/test_conformance.sh"
  "scripts/test_profile_conformance.sh"
  "scripts/validate_cr_coverage.sh"
  "scripts/validate_pr_cr.sh"
  "scripts/create_pr_from_cr.sh"
  "scripts/validate_main_cr_range.sh"
  "scripts/ugs_init.py"
  "scripts/ugs_init.sh"
  "scripts/build_bootstrap_package.py"
  "scripts/build_bootstrap_package.sh"
  "scripts/test_bootstrap_package.sh"
  "scripts/test_bootstrap_equivalence.sh"
  "scripts/test_bootstrap_release.sh"
)

for file in "${executable_files[@]}"; do
  [ -x "$file" ] || fail "file must be executable: $file"
done

grep -Fq "UGS Profile: continuous" REPOSITORY_POLICY.md || fail "missing branch profile declaration"
grep -Fq "Merge Strategy: rebase-ff" REPOSITORY_POLICY.md || fail "missing merge strategy declaration"
grep -Fq "Versioning: semver" REPOSITORY_POLICY.md || fail "missing versioning declaration"
grep -Fq "Signing Level: high-trust-commits-signed" REPOSITORY_POLICY.md || fail "missing signing level declaration"
grep -Fq "Protected Long-Lived Branches: main" REPOSITORY_POLICY.md || fail "missing protected branch declaration"
grep -Fq "Hooks Path: .githooks" REPOSITORY_POLICY.md || fail "missing hooks path declaration"
grep -Eq '^[^#[:space:]]+ namespaces="git" ssh-' keys/allowed_signers || fail "allowed signers must declare at least one git-scoped SSH signer"
scripts/validate_signer_roles.sh
for file in cr/EX-*.md; do
  scripts/validate_exception_record.sh "$file"
done

grep -Fq "REPOSITORY_POLICY.md" README.md || fail "README must link repository policy"
grep -Fq "CONTRIBUTING.md" README.md || fail "README must link contributing guide"
grep -Fq "RELEASE.md" README.md || fail "README must link release guide"
grep -Fq "releases/v0.2.0.md" README.md || fail "README must link v0.2.0 release packet"
grep -Fq "docs/roadmap/v0.3.md" README.md || fail "README must link v0.3 roadmap"
grep -Fq "docs/git/ugs-quality-profile.md" README.md || fail "README must link quality profile"
grep -Fq "docs/git/ugs-supply-chain-profile.md" README.md || fail "README must link supply-chain profile"
grep -Fq "docs/git/ugs-repository-shapes.md" README.md || fail "README must link repository shapes"
grep -Fq "cr/README.md" README.md || fail "README must link CR record guide"
grep -Fq "keys/README.md" README.md || fail "README must link trusted signer guide"
grep -Fq "scripts/test_conformance.sh" README.md || fail "README must document conformance fixtures"
grep -Fq "docs/git/ugs-bootstrap.md" README.md || fail "README must document bootstrap package"

scripts/validate_policy_manifest.sh
scripts/test_policy_manifest.sh
scripts/validate_quality_profile.sh
scripts/validate_supply_chain_profile.sh
scripts/validate_supply_chain_evidence.sh
if [ -d .github ]; then
  scripts/validate_action_pinning.sh .ugs/policy.json .github/workflows
fi
scripts/test_action_pinning.sh
scripts/test_supply_chain_evidence.sh
scripts/test_sbom.sh
scripts/test_release_attestation.sh
scripts/test_build_record.sh
scripts/test_supply_chain_release.sh
scripts/validate_repository_shape.sh

cr_records=(cr/CR-*.md)
if [ -e "${cr_records[0]}" ]; then
  for file in "${cr_records[@]}"; do
    scripts/validate_cr_record.sh "$file"
  done
fi
