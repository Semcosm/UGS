#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
PYTHONDONTWRITEBYTECODE=1 python3 "$root_dir/scripts/conformance.py" >/dev/null

run_expected() {
  local expected="$1"; shift
  if "$@" >/dev/null 2>&1; then
    [ "$expected" = pass ] || { echo "reference implementation unexpectedly passed: $*" >&2; return 1; }
  else
    [ "$expected" = fail ] || { echo "reference implementation unexpectedly failed: $*" >&2; return 1; }
  fi
}

fixtures="$root_dir/tests/fixtures"
run_expected pass "$root_dir/scripts/validate_policy_manifest.sh" "$fixtures/policy-manifest/valid.json"
run_expected fail "$root_dir/scripts/validate_policy_manifest.sh" "$fixtures/policy-manifest/invalid-conformance-level.json"
run_expected fail "$root_dir/scripts/validate_policy_manifest.sh" "$fixtures/policy-manifest/invalid-unknown-field.json"
run_expected pass "$root_dir/scripts/validate_review_trailers.sh" "$fixtures/review-trailers/valid.txt"
run_expected fail "$root_dir/scripts/validate_review_trailers.sh" "$fixtures/review-trailers/invalid-missing-reviewed-by.txt"
run_expected pass "$root_dir/scripts/validate_sbom.sh" "$fixtures/sbom/valid-spdx.json"
run_expected fail "$root_dir/scripts/validate_sbom.sh" "$fixtures/sbom/invalid-missing-version.json"
run_expected pass "$root_dir/scripts/validate_build_record.sh" "$fixtures/build-record/valid.json"
run_expected fail "$root_dir/scripts/validate_build_record.sh" "$fixtures/build-record/invalid-digest.json"
run_expected pass "$root_dir/scripts/validate_release_attestation.sh" "$fixtures/attestation/valid.json"
run_expected fail "$root_dir/scripts/validate_release_attestation.sh" "$fixtures/attestation/invalid-digest.json"

temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
repo="$temp_dir/repo"
git init --quiet -b main "$repo"
git -C "$repo" config user.name "Conformance Fixture"
git -C "$repo" config user.email "fixture@example.invalid"
printf 'base\n' > "$repo/file"
git -C "$repo" add file
git -C "$repo" commit --quiet -m 'docs(test): create conformance base' -m 'Refs: fixture'
base_oid="$(git -C "$repo" rev-parse HEAD)"
git -C "$repo" checkout --quiet -b fixture-head
printf 'head\n' >> "$repo/file"
git -C "$repo" add file
git -C "$repo" commit --quiet -m 'docs(test): create conformance head' -m 'Refs: fixture' -m 'Reviewed-by: Fixture Reviewer <reviewer@example.invalid>' -m 'Tested-by: scripts/test_conformance.sh'
head_oid="$(git -C "$repo" rev-parse HEAD)"
git -C "$repo" checkout --quiet main
git -C "$repo" merge --quiet --ff-only fixture-head
sed "s/{{BASE_OID}}/$base_oid/g; s/{{HEAD_OID}}/$head_oid/g" "$fixtures/cr/valid-template.md" > "$repo/valid-cr.md"
run_expected pass bash -c "cd '$repo' && '$root_dir/scripts/validate_cr_record.sh' valid-cr.md"
sed '/^## Risk$/,/^## Rollback$/d' "$repo/valid-cr.md" > "$repo/invalid-cr.md"
run_expected fail bash -c "cd '$repo' && '$root_dir/scripts/validate_cr_record.sh' invalid-cr.md"
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH="$root_dir/scripts" python3 - "$repo/valid-cr.md" "$repo/invalid-cr.md" <<'PY'
import sys
from conformance import cr
assert cr(open(sys.argv[1]).read())[0] == "pass"
assert cr(open(sys.argv[2]).read())[0] == "fail"
PY

echo "independent conformance fixtures passed (Python + Bash)"
