#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$script_dir/ugs_errors.sh"

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
  echo "usage: $0 <sbom.json> [release] [commit]" >&2
  exit 2
fi
sbom="$1"
expected_release="${2:-}"
expected_commit="${3:-}"
fail() {
  local message="$1"
  local code="UGS-SBOM-999"
  case "$message" in
    "file does not exist:"*) code="UGS-SBOM-001" ;;
    "jq is required") code="UGS-SBOM-002" ;;
    "file is not valid JSON") code="UGS-SBOM-003" ;;
    "invalid SPDX version") code="UGS-SBOM-004" ;;
    "SPDX creation time is missing") code="UGS-SBOM-005" ;;
    "SPDX packages lack name, version, and identity") code="UGS-SBOM-006" ;;
    "CycloneDX metadata is incomplete") code="UGS-SBOM-007" ;;
    "CycloneDX components lack name, version, and identity") code="UGS-SBOM-008" ;;
    "unsupported SBOM format;"*) code="UGS-SBOM-009" ;;
    "UGS source commit metadata is missing") code="UGS-SBOM-010" ;;
    "UGS release metadata is missing") code="UGS-SBOM-011" ;;
    "UGS artifact digest metadata is missing") code="UGS-SBOM-012" ;;
    "release metadata does not match"*) code="UGS-SBOM-013" ;;
    "source commit metadata does not match"*) code="UGS-SBOM-014" ;;
  esac
  ugs_fail "$code" "$message"
}
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
    metadata="$(jq -r '[.metadata.properties[]? | select(.name == "ugs:sourceCommit" or .name == "ugs:release" or .name == "ugs:artifactDigest") | (.name + "=" + .value)] | join(";")' "$sbom")"
    ;;
  *) fail "unsupported SBOM format; use SPDX or CycloneDX" ;;
esac
printf '%s\n' "$metadata" | grep -Eq '(^|;)ugs:sourceCommit=[0-9a-f]{40}($|;)' || fail "UGS source commit metadata is missing"
printf '%s\n' "$metadata" | grep -Eq '(^|;)ugs:release=v[0-9]+\.[0-9]+\.[0-9]+($|;)' || fail "UGS release metadata is missing"
printf '%s\n' "$metadata" | grep -Eq '(^|;)ugs:artifactDigest=sha256:[0-9a-f]{64}($|;)' || fail "UGS artifact digest metadata is missing"
if [ -n "$expected_release" ]; then printf '%s\n' "$metadata" | grep -Fq "ugs:release=$expected_release" || fail "release metadata does not match $expected_release"; fi
if [ -n "$expected_commit" ]; then printf '%s\n' "$metadata" | grep -Fq "ugs:sourceCommit=$expected_commit" || fail "source commit metadata does not match $expected_commit"; fi
echo "SBOM validation passed ($format)"
