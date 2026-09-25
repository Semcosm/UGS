#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_cr_attestation.sh"
model="$root_dir/cr/CR-0075-cr-coverage-cleanup.md"
fixtures="$root_dir/tests/fixtures/cr-attestation"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }
command -v ssh-keygen >/dev/null 2>&1 || { echo "ssh-keygen is required" >&2; exit 1; }

ssh-keygen -q -t ed25519 -N '' -C fixture@example.invalid -f "$temp_dir/key" </dev/null >/dev/null 2>&1
fingerprint="$(ssh-keygen -lf "$temp_dir/key.pub" -E sha256 | awk '{print $2}')"
printf '%s namespaces="ugs-cr-review,ugs-cr-test" %s\\n' fixture@example.invalid "$(cat "$temp_dir/key.pub")" > "$temp_dir/allowed_signers"
jq -n --arg fingerprint "$fingerprint" '{
  "$schema": "../.ugs/schema/signer-roles.schema.json",
  format: "ugs-signer-roles/v0.3",
  signers: [{principal: "fixture@example.invalid", role: "maintainer", key_fingerprint: $fingerprint, effective_from: "2026-01-01", effective_until: null, status: "active"}]
}' > "$temp_dir/roles.json"
: > "$temp_dir/revoked_signers"

export UGS_ALLOWED_SIGNERS_FILE="$temp_dir/allowed_signers"
export UGS_SIGNER_ROLES_FILE="$temp_dir/roles.json"
export UGS_REVOKED_SIGNERS_FILE="$temp_dir/revoked_signers"

sign_fixture_with_key() {
  local key="$1" source="$2" output="$3" payload signature
  payload="$temp_dir/payload"
  signature="$temp_dir/signature"
  python3 "$root_dir/scripts/cr_attestation.py" "$source" --cr-file "$model" --no-signature --payload > "$payload"
  ssh-keygen -Y sign -f "$key" -n "$(jq -r '.signature.namespace' "$source")" < "$payload" > "$signature" 2>/dev/null
  jq --arg value "$(base64 -w0 "$signature")" '.signature.value=$value' "$source" > "$output"
}

sign_fixture() {
  sign_fixture_with_key "$temp_dir/key" "$1" "$2"
}

signed="$temp_dir/signed.json"
sign_fixture "$fixtures/valid.json" "$signed"
"$validator" "$signed" "$model" Semcosm/UGS >/dev/null

signed_test="$temp_dir/signed-test.json"
sign_fixture "$fixtures/test.json" "$signed_test"
"$validator" "$signed_test" "$model" Semcosm/UGS >/dev/null

signed_source="$temp_dir/signed-source.json"
sign_fixture "$fixtures/source.json" "$signed_source"
"$validator" "$signed_source" "$model" Semcosm/UGS >/dev/null

expect_fail() {
  local file="$1" expected="$2" error status code
  shift 2
  set +e
  UGS_ERROR_FORMAT=json "$validator" "$file" "$model" Semcosm/UGS "$@" >/dev/null 2>"$temp_dir/error"
  status=$?
  set -e
  [ "$status" -ne 0 ] || { echo "fixture unexpectedly passed: $file" >&2; exit 1; }
  code="$(jq -r '.code // empty' "$temp_dir/error")"
  [ "$code" = "$expected" ] || { echo "unexpected code for $file: $code (wanted $expected)" >&2; cat "$temp_dir/error" >&2; exit 1; }
}

expect_fail "$fixtures/invalid-binding.json" UGS-CR-ATTEST-021 --no-signature
expect_fail "$fixtures/invalid-namespace.json" UGS-CR-ATTEST-016 --no-signature
expect_fail "$fixtures/invalid-window.json" UGS-CR-ATTEST-012 --no-signature
expect_fail "$fixtures/invalid-extra-field.json" UGS-CR-ATTEST-004 --no-signature

role_mismatch="$temp_dir/role-mismatch.json"
jq '.attester.role="tester"' "$signed" > "$role_mismatch"
expect_fail "$role_mismatch" UGS-CR-ATTEST-013 --no-signature
principal_mismatch="$temp_dir/principal-mismatch.json"
jq '.signature.principal="other@example.invalid"' "$signed" > "$principal_mismatch"
expect_fail "$principal_mismatch" UGS-CR-ATTEST-016 --no-signature
source_result="$temp_dir/source-result.json"
jq '.subject.result_oid="50f3ed7a10db9de91dd783ae7fa970b18e56fe24"' "$fixtures/source.json" > "$source_result"
expect_fail "$source_result" UGS-CR-ATTEST-023 --no-signature

tampered="$temp_dir/tampered.json"
jq '.conclusion="rejected"' "$signed" > "$tampered"
expect_fail "$tampered" UGS-CR-ATTEST-037

revoked_roles="$temp_dir/revoked-roles.json"
jq '.signers[0].status="revoked" | .signers[0].effective_until="2026-09-24"' "$temp_dir/roles.json" > "$revoked_roles"
UGS_SIGNER_ROLES_FILE="$revoked_roles" expect_fail "$signed" UGS-CR-ATTEST-035
historical_roles="$temp_dir/historical-roles.json"
jq '.signers[0].status="revoked" | .signers[0].effective_until="2026-09-26"' "$temp_dir/roles.json" > "$historical_roles"
UGS_SIGNER_ROLES_FILE="$historical_roles" "$validator" "$signed" "$model" Semcosm/UGS >/dev/null

ssh-keygen -q -k -f "$temp_dir/revoked.krl" "$temp_dir/key.pub"
UGS_REVOKED_SIGNERS_FILE="$temp_dir/revoked.krl" expect_fail "$signed" UGS-CR-ATTEST-035
cp "$temp_dir/key.pub" "$temp_dir/revoked.txt"
UGS_REVOKED_SIGNERS_FILE="$temp_dir/revoked.txt" expect_fail "$signed" UGS-CR-ATTEST-035
printf '# no revoked keys\n' > "$temp_dir/comments-only-revoked"
UGS_REVOKED_SIGNERS_FILE="$temp_dir/comments-only-revoked" "$validator" "$signed" "$model" Semcosm/UGS >/dev/null
printf '%s\n' "$(cat "$temp_dir/key.pub")" > "$temp_dir/revoked.raw"
UGS_REVOKED_SIGNERS_FILE="$temp_dir/revoked.raw" expect_fail "$signed" UGS-CR-ATTEST-035

payload_out="$temp_dir/payload.out"
"$validator" "$signed" "$model" Semcosm/UGS --payload > "$payload_out"
expected_payload="$(jq -cS 'del(.signature)' "$signed")"
printf '%s' "$expected_payload" | cmp -s - "$payload_out"

# A rotated principal may have multiple allowed keys. The verifier must select
# the candidate whose fingerprint and effective role window match the issued
# timestamp, then verify against that candidate's own allowed-signers line.
ssh-keygen -q -t ed25519 -N '' -C fixture@example.invalid -f "$temp_dir/rotated-key" </dev/null >/dev/null 2>&1
rotated_fingerprint="$(ssh-keygen -lf "$temp_dir/rotated-key.pub" -E sha256 | awk '{print $2}')"
printf '%s namespaces="ugs-cr-review,ugs-cr-test" %s\n' fixture@example.invalid "$(cat "$temp_dir/key.pub")" > "$temp_dir/rotation-allowed_signers"
printf '%s namespaces="ugs-cr-review,ugs-cr-test" %s\n' fixture@example.invalid "$(cat "$temp_dir/rotated-key.pub")" >> "$temp_dir/rotation-allowed_signers"
jq -n --arg old_fingerprint "$fingerprint" --arg new_fingerprint "$rotated_fingerprint" '{
  "$schema": "../.ugs/schema/signer-roles.schema.json",
  format: "ugs-signer-roles/v0.3",
  signers: [
    {principal: "fixture@example.invalid", role: "maintainer", key_fingerprint: $old_fingerprint, effective_from: "2026-01-01", effective_until: "2026-09-25", status: "revoked"},
    {principal: "fixture@example.invalid", role: "maintainer", key_fingerprint: $new_fingerprint, effective_from: "2026-09-25", effective_until: null, status: "active"}
  ]
}' > "$temp_dir/rotation-roles.json"
UGS_ALLOWED_SIGNERS_FILE="$temp_dir/rotation-allowed_signers" \
UGS_SIGNER_ROLES_FILE="$temp_dir/rotation-roles.json" \
sign_fixture_with_key "$temp_dir/rotated-key" "$fixtures/valid.json" "$temp_dir/rotated-signed.json"
UGS_ALLOWED_SIGNERS_FILE="$temp_dir/rotation-allowed_signers" \
UGS_SIGNER_ROLES_FILE="$temp_dir/rotation-roles.json" \
  "$validator" "$temp_dir/rotated-signed.json" "$model" Semcosm/UGS >/dev/null

echo "CR attestation fixtures validation passed"
