#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_supply_chain_release.sh"
tag="v0.3.15"
commit="$(git -C "$root_dir" rev-parse "refs/tags/$tag^{commit}")"
temp_dir="$(mktemp -d "$root_dir/.release-fixture.XXXXXX")"
trap 'rm -rf "$temp_dir"' EXIT
digest="sha256:0123456789012345678901234567890123456789012345678901234567890123"
jq --arg commit "$commit" --arg digest "$digest" --arg tag "$tag" \
  '.metadata.properties |= map(if .name == "ugs:sourceCommit" then .value = $commit elif .name == "ugs:release" then .value = $tag elif .name == "ugs:artifactDigest" then .value = $digest else . end)' \
  "$root_dir/tests/fixtures/sbom/valid-cyclonedx.json" > "$temp_dir/sbom.json"
jq --arg commit "$commit" --arg digest "$digest" --arg tag "$tag" \
  '.documentComment = ("ugs:sourceCommit=" + $commit + ";ugs:release=" + $tag + ";ugs:artifactDigest=" + $digest)' \
  "$root_dir/tests/fixtures/sbom/valid-spdx.json" > "$temp_dir/sbom-spdx.json"
jq -n --arg commit "$commit" --arg digest "$digest" --arg tag "$tag" \
  '{schema_version:1,type:"ugs-build-record",release_tag:$tag,commit:$commit,artifact:{digest:$digest},builder:{id:"fixture"},built_at:"2026-09-05T00:00:00Z"}' > "$temp_dir/build.json"
jq -n --arg commit "$commit" --arg digest "$digest" --arg tag "$tag" \
  '{schema_version:1,type:"ugs-release-attestation",repository:"Semcosm/UGS",release_tag:$tag,commit:$commit,artifact:{name:"fixture",digest:$digest},builder:{id:"fixture"},built_at:"2026-09-05T00:00:00Z"}' > "$temp_dir/attestation.json"
ssh-keygen -q -t ed25519 -N '' -f "$temp_dir/key" </dev/null >/dev/null 2>&1
printf 'fixture@example.com namespaces="ugs-attestation" %s\n' "$(cat "$temp_dir/key.pub")" > "$temp_dir/allowed_signers"
jq -cS 'del(.signature)' "$temp_dir/attestation.json" > "$temp_dir/payload"
ssh-keygen -Y sign -f "$temp_dir/key" -n ugs-attestation < "$temp_dir/payload" > "$temp_dir/signature" 2>/dev/null
signature="$(base64 -w0 "$temp_dir/signature")"
jq --arg signature "$signature" \
  '.signature={format:"ssh",namespace:"ugs-attestation",principal:"fixture@example.com",value:$signature}' \
  "$temp_dir/attestation.json" > "$temp_dir/attestation-signed.json"
jq -n \
  '{supply_chain:{profile:"standard",action_pinning:"full_sha",sbom:"release",reproducible_builds:"declared",release_attestations:"signed",evidence:{sbom_paths:["sbom.json","sbom-spdx.json"],build_record_paths:["build.json"],attestation_paths:["attestation.json"]}}}' \
  > "$temp_dir/manifest.json"
# Evidence paths are repository-relative; place the generated files at the root
# temporarily through explicit copies so the validator exercises normal paths.
cp "$temp_dir/sbom.json" "$root_dir/tests/fixtures/release-sbom.json"
cp "$temp_dir/sbom-spdx.json" "$root_dir/tests/fixtures/release-sbom-spdx.json"
cp "$temp_dir/build.json" "$root_dir/tests/fixtures/release-build.json"
cp "$temp_dir/attestation-signed.json" "$root_dir/tests/fixtures/release-attestation.json"
trap 'rm -rf "$temp_dir"; rm -f "$root_dir/tests/fixtures/release-sbom.json" "$root_dir/tests/fixtures/release-sbom-spdx.json" "$root_dir/tests/fixtures/release-build.json" "$root_dir/tests/fixtures/release-attestation.json"' EXIT
jq '.supply_chain.evidence = {sbom_paths:["tests/fixtures/release-sbom.json","tests/fixtures/release-sbom-spdx.json"],build_record_paths:["tests/fixtures/release-build.json"],attestation_paths:["tests/fixtures/release-attestation.json"]}' "$temp_dir/manifest.json" > "$temp_dir/manifest-relative.json"
UGS_ALLOWED_SIGNERS_FILE="$temp_dir/allowed_signers" "$validator" "$tag" "$temp_dir/manifest-relative.json" "Semcosm/UGS"
jq '.artifact.digest = "sha256:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"' \
  "$root_dir/tests/fixtures/release-build.json" > "$temp_dir/build-mismatch.json"
cp "$temp_dir/build-mismatch.json" "$root_dir/tests/fixtures/release-build.json"
if UGS_ALLOWED_SIGNERS_FILE="$temp_dir/allowed_signers" "$validator" "$tag" "$temp_dir/manifest-relative.json" "Semcosm/UGS" >/dev/null 2>&1; then
  echo "release digest mismatch fixture unexpectedly passed" >&2
  exit 1
fi
echo "supply-chain release fixtures validation passed"
