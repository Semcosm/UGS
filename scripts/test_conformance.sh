#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
python_report="$temp_dir/python-report.jsonl"
PYTHONDONTWRITEBYTECODE=1 python3 "$root_dir/scripts/conformance.py" >"$python_report"

assert_equivalent_fixture() {
  local id="$1" kind="$2" path="$3" expected="$4" expected_code="$5"
  local validator status output actual_code python_code
  case "$kind" in
    policy) validator="$root_dir/scripts/validate_policy_manifest.sh" ;;
    review) validator="$root_dir/scripts/validate_review_trailers.sh" ;;
    sbom) validator="$root_dir/scripts/validate_sbom.sh" ;;
    build) validator="$root_dir/scripts/validate_build_record.sh" ;;
    attestation) validator="$root_dir/scripts/validate_release_attestation.sh" ;;
    *) return 0 ;;
  esac
  output="$temp_dir/$id.json"
  set +e
  UGS_ERROR_FORMAT=json "$validator" "$root_dir/$path" >"$output" 2>&1
  status=$?
  set -e
  if [ "$expected" = "pass" ]; then
    [ "$status" -eq 0 ] || { echo "Bash validator unexpectedly failed: $id" >&2; return 1; }
    actual_code="UGS-0000"
  else
    [ "$status" -ne 0 ] || { echo "Bash validator unexpectedly passed: $id" >&2; return 1; }
    actual_code="$(jq -r '.code // empty' "$output")"
  fi
  [ "$actual_code" = "$expected_code" ] || {
    echo "Bash/Python error code mismatch for $id: $actual_code != $expected_code" >&2
    return 1
  }
  python_code="$(jq -r --arg id "$id" 'select(.id == $id) | .code' "$python_report")"
  [ "$python_code" = "$expected_code" ] || {
    echo "Python fixture code mismatch for $id: $python_code != $expected_code" >&2
    return 1
  }
}

while IFS=$'\t' read -r id kind path expected code; do
  assert_equivalent_fixture "$id" "$kind" "$path" "$expected" "$code"
done < <(jq -r '.fixtures[] | [.id, .kind, .path, .expected, (.code // "UGS-0000")] | @tsv' "$root_dir/tests/conformance/manifest.json")

assert_cr_fixture() {
  local id="$1" path="$2" expected="$3" expected_code="$4" projection="$5"
  local ref_status independent_status ref_code independent_code
  set +e
  UGS_ERROR_FORMAT=json "$root_dir/scripts/cr_model.py" --json "$root_dir/$path" >"$temp_dir/$id.reference.json" 2>"$temp_dir/$id.reference.err"
  ref_status=$?
  PYTHONDONTWRITEBYTECODE=1 python3 "$root_dir/scripts/conformance.py" --cr-json "$root_dir/$path" >"$temp_dir/$id.independent.json" 2>"$temp_dir/$id.independent.err"
  independent_status=$?
  set -e
  if [ "$expected" = pass ]; then
    [ "$ref_status" -eq 0 ] || { echo "reference CR parser unexpectedly failed: $id" >&2; cat "$temp_dir/$id.reference.err" >&2; return 1; }
    [ "$independent_status" -eq 0 ] || { echo "independent CR parser unexpectedly failed: $id" >&2; cat "$temp_dir/$id.independent.err" >&2; return 1; }
  else
    [ "$ref_status" -ne 0 ] || { echo "reference CR parser unexpectedly passed: $id" >&2; return 1; }
    [ "$independent_status" -ne 0 ] || { echo "independent CR parser unexpectedly passed: $id" >&2; return 1; }
    ref_code="$(jq -r '.code // empty' "$temp_dir/$id.reference.err")"
    independent_code="$(sed -n 's/^\([^:]*\):.*/\1/p' "$temp_dir/$id.independent.err" | head -n 1)"
    [ "$ref_code" = "$expected_code" ] || { echo "reference CR error code mismatch for $id: $ref_code != $expected_code" >&2; return 1; }
    [ "$independent_code" = "$expected_code" ] || { echo "independent CR error code mismatch for $id: $independent_code != $expected_code" >&2; return 1; }
  fi
  if [ -n "$projection" ]; then
    cmp -s "$temp_dir/$id.reference.json" "$root_dir/$projection" || { echo "reference CR projection mismatch: $id" >&2; return 1; }
    cmp -s "$temp_dir/$id.independent.json" "$root_dir/$projection" || { echo "independent CR projection mismatch: $id" >&2; return 1; }
  fi
  if [ "$expected" = pass ]; then
    cmp -s "$temp_dir/$id.reference.json" "$temp_dir/$id.independent.json" || { echo "reference/independent CR projection mismatch: $id" >&2; return 1; }
  fi
}

while IFS=$'\t' read -r id path expected code projection; do
  assert_cr_fixture "$id" "$path" "$expected" "$code" "$projection"
done < <(jq -r '.fixtures[] | select(.kind == "cr") | [.id, .path, .expected, (.code // "UGS-0000"), (.projection // "")] | @tsv' "$root_dir/tests/conformance/manifest.json")

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
awk '{ print; if ($0 == "## Summary") { print ""; print "Format: legacy prose" } }' "$repo/valid-cr.md" > "$repo/legacy-format-body.md"
run_expected pass bash -c "cd '$repo' && '$root_dir/scripts/validate_cr_record.sh' legacy-format-body.md"
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH="$root_dir/scripts" python3 - "$repo/valid-cr.md" "$repo/invalid-cr.md" "$repo/legacy-format-body.md" <<'PY'
import sys
from conformance import cr
assert cr(open(sys.argv[1]).read())[0] == "pass"
assert cr(open(sys.argv[2]).read())[0] == "fail"
assert cr(open(sys.argv[3]).read())[0] == "pass"
PY

echo "independent conformance fixtures passed (Python + Bash)"
