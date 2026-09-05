#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
  echo "usage: $0 <attestation.json> [release-tag] [commit]" >&2
  exit 2
fi
attestation="$1"
expected_tag="${2:-}"
expected_commit="${3:-}"
fail() { echo "release attestation validation failed: $1" >&2; exit 1; }
[ -f "$attestation" ] || fail "file does not exist: $attestation"
command -v jq >/dev/null 2>&1 || fail "jq is required"
jq empty "$attestation" >/dev/null 2>&1 || fail "file is not valid JSON"
jq -e '.schema_version == 1 and .type == "ugs-release-attestation" and (.repository | type == "string" and length > 0)' "$attestation" >/dev/null || fail "invalid attestation header"
jq -e '.release_tag | type == "string" and test("^v[0-9]+\\.[0-9]+\\.[0-9]+$")' "$attestation" >/dev/null || fail "invalid release tag"
jq -e '.commit | type == "string" and test("^[0-9a-f]{40}$")' "$attestation" >/dev/null || fail "invalid commit SHA"
jq -e '.artifact.name | type == "string" and length > 0' "$attestation" >/dev/null || fail "artifact name is missing"
jq -e '.artifact.digest | type == "string" and test("^sha256:[0-9a-f]{64}$")' "$attestation" >/dev/null || fail "invalid artifact digest"
jq -e '.builder.id | type == "string" and length > 0' "$attestation" >/dev/null || fail "builder identity is missing"
jq -e '.built_at | type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T")' "$attestation" >/dev/null || fail "build timestamp is missing"
tag="$(jq -r '.release_tag' "$attestation")"
commit="$(jq -r '.commit' "$attestation")"
[ -z "$expected_tag" ] || [ "$tag" = "$expected_tag" ] || fail "release tag does not match $expected_tag"
[ -z "$expected_commit" ] || [ "$commit" = "$expected_commit" ] || fail "commit does not match $expected_commit"
if [ -n "$expected_tag" ] && git rev-parse --verify --quiet "refs/tags/$expected_tag^{commit}" >/dev/null; then
  [ "$(git rev-parse "refs/tags/$expected_tag^{commit}")" = "$commit" ] || fail "attestation commit differs from release tag target"
fi
if jq -e '.signature != null' "$attestation" >/dev/null; then
  jq -e '.signature.verified == true and (.signature.algorithm | IN("ssh", "sigstore")) and (.signature.signer | type == "string" and length > 0)' "$attestation" >/dev/null || fail "invalid attestation signature metadata"
fi
echo "release attestation validation passed"
