#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "repository validation failed: $1" >&2
  exit 1
}

required_files=(
  "README.md"
  "REPOSITORY_POLICY.md"
  "CONTRIBUTING.md"
  "RELEASE.md"
  "cr/README.md"
  "cr/TEMPLATE.md"
  ".github/pull_request_template.md"
  ".github/CODEOWNERS"
  ".github/workflows/ugs-validate.yml"
  ".githooks/README.md"
  ".githooks/commit-msg"
  ".githooks/pre-push"
  "scripts/validate_commit_message.sh"
  "scripts/validate_commit_range.sh"
  "scripts/validate_cr_record.sh"
  "scripts/validate_repo.sh"
)

for file in "${required_files[@]}"; do
  [ -f "$file" ] || fail "missing required file: $file"
done

executable_files=(
  ".githooks/commit-msg"
  ".githooks/pre-push"
  "scripts/validate_commit_message.sh"
  "scripts/validate_commit_range.sh"
  "scripts/validate_cr_record.sh"
  "scripts/validate_repo.sh"
)

for file in "${executable_files[@]}"; do
  [ -x "$file" ] || fail "file must be executable: $file"
done

grep -Fq "UGS Profile: continuous" REPOSITORY_POLICY.md || fail "missing branch profile declaration"
grep -Fq "Merge Strategy: rebase-ff" REPOSITORY_POLICY.md || fail "missing merge strategy declaration"
grep -Fq "Versioning: semver" REPOSITORY_POLICY.md || fail "missing versioning declaration"
grep -Fq "Signing Level: release-tags-signed" REPOSITORY_POLICY.md || fail "missing signing level declaration"
grep -Fq "Protected Long-Lived Branches: main" REPOSITORY_POLICY.md || fail "missing protected branch declaration"
grep -Fq "Hooks Path: .githooks" REPOSITORY_POLICY.md || fail "missing hooks path declaration"

grep -Fq "REPOSITORY_POLICY.md" README.md || fail "README must link repository policy"
grep -Fq "CONTRIBUTING.md" README.md || fail "README must link contributing guide"
grep -Fq "RELEASE.md" README.md || fail "README must link release guide"
grep -Fq "cr/README.md" README.md || fail "README must link CR record guide"
grep -Fq "## Summary" .github/pull_request_template.md || fail "PR template must include Summary"
grep -Fq "## Motivation" .github/pull_request_template.md || fail "PR template must include Motivation"
grep -Fq "## Test Evidence" .github/pull_request_template.md || fail "PR template must include Test Evidence"
grep -Fq "## Risk" .github/pull_request_template.md || fail "PR template must include Risk"
grep -Fq "## Rollback" .github/pull_request_template.md || fail "PR template must include Rollback"
grep -Fq "## Breaking Change" .github/pull_request_template.md || fail "PR template must include Breaking Change"
grep -Fq "## Backport Target" .github/pull_request_template.md || fail "PR template must include Backport Target"

cr_records=(cr/CR-*.md)
if [ -e "${cr_records[0]}" ]; then
  for file in "${cr_records[@]}"; do
    scripts/validate_cr_record.sh "$file"
  done
fi
