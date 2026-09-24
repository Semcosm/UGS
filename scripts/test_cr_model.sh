#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
parser="$root_dir/scripts/cr_model.py"
fixtures="$root_dir/tests/fixtures/cr-model"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

expect_code() {
  local file="$1" expected="$2" status
  set +e
  UGS_ERROR_FORMAT=json "$parser" --json "$file" >"$temp_dir/output" 2>"$temp_dir/error"
  status=$?
  set -e
  [ "$status" -ne 0 ] || {
    echo "CR model fixture unexpectedly passed: $file" >&2
    exit 1
  }
  [ "$(jq -r '.code' "$temp_dir/error")" = "$expected" ] || {
    echo "unexpected CR model code for $file" >&2
    cat "$temp_dir/error" >&2
    exit 1
  }
}

jq empty "$root_dir/.ugs/schema/cr.schema.json"
"$parser" --json "$fixtures/valid-v1.md" >"$temp_dir/model.json"
jq -S . "$temp_dir/model.json" >"$temp_dir/model.sorted.json"
jq -S . "$fixtures/valid-v1.expected.json" >"$temp_dir/expected.sorted.json"
cmp -s "$temp_dir/model.sorted.json" "$temp_dir/expected.sorted.json"
jq -e '
  .format == "ugs-cr/v1" and
  .schema_version == 1 and
  .id == "CR-9002" and
  .integration.result_oid == null and
  .extensions["x-fixture"].name == "canonical" and
  .binding.format == "ugs-cr-binding/v1" and
  (.binding.sha256 | test("^sha256:[0-9a-f]{64}$"))
' "$temp_dir/model.json" >/dev/null
"$parser" --render "$fixtures/valid-v1.md" >"$temp_dir/rendered.md"
cmp -s "$fixtures/valid-v1.md" "$temp_dir/rendered.md"
"$parser" --json "$fixtures/valid-v1.md" >"$temp_dir/first.json"
"$parser" --json "$fixtures/valid-v1.md" >"$temp_dir/second.json"
cmp -s "$temp_dir/first.json" "$temp_dir/second.json"

expect_code "$fixtures/invalid-duplicate-field.md" UGS-CR-016
expect_code "$fixtures/invalid-lifecycle.md" UGS-CR-022
expect_code "$fixtures/invalid-unknown-metadata.md" UGS-CR-018
expect_code "$fixtures/invalid-noncanonical-extensions.md" UGS-CR-021
expect_code "$fixtures/invalid-nonstandard-json.md" UGS-CR-019

for record in "$root_dir"/cr/CR-*.md; do
  "$parser" --json "$record" > /dev/null
done

echo "CR model fixtures passed"
