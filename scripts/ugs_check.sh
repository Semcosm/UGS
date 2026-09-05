#!/usr/bin/env bash
set -euo pipefail

format="text"
case "${1:-}" in
  "") ;;
  --format)
    format="${2:?missing format}"
    [ "${3:-}" = "" ] || {
      echo "usage: scripts/ugs_check.sh [--format text|json]" >&2
      exit 2
    }
    ;;
  *)
    echo "usage: scripts/ugs_check.sh [--format text|json]" >&2
    exit 2
    ;;
esac

case "$format" in
  text|json) ;;
  *)
    echo "unsupported format: $format" >&2
    exit 2
    ;;
esac

report_dir="$(mktemp -d)"
trap 'rm -rf "$report_dir"' EXIT
check_count=0
failed_count=0

run_check() {
  local name="$1"
  shift
  local output
  local status
  local report_file

  report_file="$report_dir/$(printf '%03d' "$check_count").json"
  check_count=$((check_count + 1))
  set +e
  output="$("$@" 2>&1)"
  status=$?
  set -e
  if [ "$status" -eq 0 ]; then
    status_name="pass"
  else
    status_name="fail"
    failed_count=$((failed_count + 1))
  fi
  jq -n --arg name "$name" --arg status "$status_name" --arg output "$output" \
    '{name: $name, status: $status, output: $output}' > "$report_file"
  if [ "$format" = "text" ]; then
    printf '[%s] %s\n' "$status_name" "$name"
    if [ -n "$output" ] && [ "$status" -ne 0 ]; then
      printf '%s\n' "$output" >&2
    fi
  fi
}

run_check "policy manifest" scripts/validate_policy_manifest.sh
run_check "policy manifest fixtures" scripts/test_policy_manifest.sh
run_check "repository policy" scripts/validate_repo.sh
run_check "Git evidence fixtures" scripts/test_git_fixtures.sh
run_check "review trailer fixtures" scripts/test_review_trailers.sh
run_check "release tag fixtures" scripts/test_release_tag.sh
run_check "ref update fixtures" scripts/test_ref_update.sh
run_check "CR provenance fixtures" scripts/test_cr_provenance.sh
run_check "CR integration strategy fixtures" scripts/test_cr_integration_strategy.sh
run_check "CR review inheritance fixtures" scripts/test_cr_review_inheritance.sh
run_check "signer roles fixtures" scripts/test_signer_roles.sh
run_check "exception record fixtures" scripts/test_exception_records.sh
run_check "quality profile" scripts/validate_quality_profile.sh
run_check "supply-chain profile" scripts/validate_supply_chain_profile.sh
run_check "supply-chain evidence" scripts/validate_supply_chain_evidence.sh
run_check "SBOM fixtures" scripts/test_sbom.sh
run_check "repository shape" scripts/validate_repository_shape.sh

for file in cr/CR-*.md; do
  [ -e "$file" ] || continue
  run_check "CR $(basename "$file")" scripts/validate_cr_record.sh "$file"
done

if [ "$format" = "json" ]; then
  jq -n \
    --arg format "ugs-conformance/v0.3" \
    --arg result "$(if [ "$failed_count" -eq 0 ]; then printf pass; else printf fail; fi)" \
    --argjson checks "$(jq -s . "$report_dir"/*.json)" \
    '{format: $format, result: $result, checks: $checks}'
fi

[ "$failed_count" -eq 0 ]
