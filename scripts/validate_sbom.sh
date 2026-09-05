#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
  echo "usage: $0 <sbom.json> [release] [commit]" >&2
  exit 2
fi
sbom="$1"
expected_release="${2:-}"
expected_commit="${3:-}"
fail() { echo "SBOM validation failed: $1" >&2; exit 1; }
[ -f "$sbom" ] || fail "file does not exist: $sbom"
command -v jq >/dev/null 2>&1 || fail "jq is required"
jq empty "$sbom" >/dev/null 2>&1 || fail "file is not valid JSON"

format="$(jq -r 'if .spdxVersion then "spdx" elif .bomFormat == "CycloneDX" then "cyclonedx" else "unknown" end' "$sbom")"
case "$format" in
  spdx)
    jq -e '.spdxVersion | type == "string" and startswith("SPDX-")' "$sbom" >/dev/null || fail "invalid SPDX version"
    jq -e '.creationInfo.created | type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T")' "$sbom" >/dev/null || fail "SPDX creation time is missing"
    jq -e '.packages | type == "array" and length > 0 and all(.[]; (.name | type == "string" and length > 0) and (.versionInfo | type == "string" and length > 0) and ((has("SPDXID") and (.SPDXID | type == "string" and length > 0)) or (has("checksums") and (.checksums | type == "array" and length > 0))))' "$sbom" >/dev/null || fail "SPDX packages lack name, version, and identity"
    metadata="$(jq -r '.documentComment // empty' "$sbom")"
    ;;
  cyclonedx)
    jq -e '.specVersion and (.metadata.timestamp | type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T"))' "$sbom" >/dev/null || fail "CycloneDX metadata is incomplete"
    jq -e '.components | type == "array" and length > 0 and all(.[]; (.name | type == "string" and length > 0) and (.version | type == "string" and length > 0) and ((has("bom-ref") and (."bom-ref" | type == "string" and length > 0)) or (has("hashes") and (.hashes | type == "array" and length > 0))))' "$sbom" >/dev/null || fail "CycloneDX components lack name, version, and identity"
    metadata="$(jq -r '[.metadata.properties[]? | select(.name == "ugs:sourceCommit" or .name == "ugs:release") | (.name + "=" + .value)] | join(";")' "$sbom")"
    ;;
  *) fail "unsupported SBOM format; use SPDX or CycloneDX" ;;
esac
printf '%s\n' "$metadata" | grep -Eq '(^|;)ugs:sourceCommit=[0-9a-f]{40}($|;)' || fail "UGS source commit metadata is missing"
printf '%s\n' "$metadata" | grep -Eq '(^|;)ugs:release=v[0-9]+\.[0-9]+\.[0-9]+($|;)' || fail "UGS release metadata is missing"
if [ -n "$expected_release" ]; then printf '%s\n' "$metadata" | grep -Fq "ugs:release=$expected_release" || fail "release metadata does not match $expected_release"; fi
if [ -n "$expected_commit" ]; then printf '%s\n' "$metadata" | grep -Fq "ugs:sourceCommit=$expected_commit" || fail "source commit metadata does not match $expected_commit"; fi
echo "SBOM validation passed ($format)"
