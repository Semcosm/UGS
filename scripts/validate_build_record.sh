#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
  echo "usage: $0 <build-record.json> [release-tag] [commit]" >&2
  exit 2
fi
record="$1"; expected_tag="${2:-}"; expected_commit="${3:-}"
fail() { echo "build record validation failed: $1" >&2; exit 1; }
[ -f "$record" ] || fail "file does not exist: $record"
command -v jq >/dev/null 2>&1 || fail "jq is required"
jq empty "$record" >/dev/null 2>&1 || fail "file is not valid JSON"
jq -e '.schema_version == 1 and .type == "ugs-build-record"' "$record" >/dev/null || fail "invalid build record header"
jq -e '.release_tag | type == "string" and test("^v[0-9]+\\.[0-9]+\\.[0-9]+$")' "$record" >/dev/null || fail "invalid release tag"
jq -e '.commit | type == "string" and test("^[0-9a-f]{40}$")' "$record" >/dev/null || fail "invalid commit SHA"
jq -e '.artifact.digest | type == "string" and test("^sha256:[0-9a-f]{64}$")' "$record" >/dev/null || fail "invalid artifact digest"
jq -e '.builder.id | type == "string" and length > 0' "$record" >/dev/null || fail "builder identity is missing"
jq -e '.built_at | type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T")' "$record" >/dev/null || fail "build timestamp is missing"
tag="$(jq -r '.release_tag' "$record")"; commit="$(jq -r '.commit' "$record")"
[ -z "$expected_tag" ] || [ "$tag" = "$expected_tag" ] || fail "release tag does not match $expected_tag"
[ -z "$expected_commit" ] || [ "$commit" = "$expected_commit" ] || fail "commit does not match $expected_commit"
if [ -n "$expected_tag" ] && git rev-parse --verify --quiet "refs/tags/$expected_tag^{commit}" >/dev/null; then
  [ "$(git rev-parse "refs/tags/$expected_tag^{commit}")" = "$commit" ] || fail "build record commit differs from release tag target"
fi
echo "build record validation passed"
