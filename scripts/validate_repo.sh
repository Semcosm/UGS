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
  ".github/pull_request_template.md"
  ".github/CODEOWNERS"
  ".github/workflows/ugs-validate.yml"
  ".githooks/README.md"
  ".githooks/commit-msg"
  ".githooks/pre-push"
  "scripts/validate_commit_message.sh"
  "scripts/validate_commit_range.sh"
  "scripts/validate_commit_signatures.sh"
  "scripts/validate_cr_record.sh"
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
  "scripts/validate_sbom.sh"
  "scripts/test_sbom.sh"
  "scripts/validate_repository_shape.sh"
  "scripts/validate_supply_chain_profile.sh"
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
grep -Fq "## Summary" .github/pull_request_template.md || fail "PR template must include Summary"
grep -Fq "## Motivation" .github/pull_request_template.md || fail "PR template must include Motivation"
grep -Fq "## Test Evidence" .github/pull_request_template.md || fail "PR template must include Test Evidence"
grep -Fq "## Risk" .github/pull_request_template.md || fail "PR template must include Risk"
grep -Fq "## Rollback" .github/pull_request_template.md || fail "PR template must include Rollback"
grep -Fq "## Breaking Change" .github/pull_request_template.md || fail "PR template must include Breaking Change"
grep -Fq "## Backport Target" .github/pull_request_template.md || fail "PR template must include Backport Target"
grep -Fq "scripts/validate_commit_signatures.sh" .github/workflows/ugs-validate.yml || fail "workflow must validate commit signatures"

scripts/validate_policy_manifest.sh
scripts/test_policy_manifest.sh
scripts/validate_quality_profile.sh
scripts/validate_supply_chain_profile.sh
scripts/validate_supply_chain_evidence.sh
scripts/test_sbom.sh
scripts/validate_repository_shape.sh

cr_records=(cr/CR-*.md)
if [ -e "${cr_records[0]}" ]; then
  for file in "${cr_records[@]}"; do
    scripts/validate_cr_record.sh "$file"
  done
fi
