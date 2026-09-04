#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <cr-record-file>" >&2
  exit 2
fi

cr_file="$1"

fail() {
  echo "cr record validation failed: $1" >&2
  exit 1
}

require_metadata_line() {
  local key="$1"
  local value

  value="$(sed -n "s/^${key}: //p" "$cr_file")"
  [ -n "$value" ] || fail "missing ${key}: line"

  if printf '%s\n' "$value" | grep -Eq '^<[^>]+>$'; then
    fail "${key}: must not use an unfilled template placeholder"
  fi
}

require_section() {
  local header="$1"
  local status

  if awk -v header="$header" '
    $0 == header {
      found = 1
      in_section = 1
      next
    }

    /^## / && in_section {
      exit has_content ? 0 : 2
    }

    in_section && NF {
      if ($0 !~ /^<[^>]+>$/) {
        has_content = 1
      }
    }

    END {
      if (!found) {
        exit 1
      }

      if (!has_content) {
        exit 2
      }
    }
  ' "$cr_file"; then
    return 0
  else
    status=$?
  fi

  case "$status" in
    1) fail "missing section: ${header}" ;;
    2) fail "section must include non-placeholder content: ${header}" ;;
    *) fail "unable to validate section: ${header}" ;;
  esac
}

[ -f "$cr_file" ] || fail "record file does not exist: $cr_file"

title_line="$(sed -n '1p' "$cr_file")"
printf '%s\n' "$title_line" | grep -Eq '^# CR-[0-9]{4}: .+$' \
  || fail "title must match # CR-XXXX: <title>"

require_metadata_line "Base"
require_metadata_line "Head or Range"
require_metadata_line "Title"
require_metadata_line "Revision"
require_metadata_line "Status"
require_metadata_line "Decision"
require_metadata_line "Policy Version"
require_metadata_line "Base OID"
require_metadata_line "Head OID"
require_metadata_line "Integrated Result"

revision="$(sed -n 's/^Revision: //p' "$cr_file")"
printf '%s\n' "$revision" | grep -Eq '^[1-9][0-9]*$' \
  || fail "Revision must be a positive integer"

status="$(sed -n 's/^Status: //p' "$cr_file")"
printf '%s\n' "$status" | grep -Eq '^(accepted|integrated|rejected|superseded)$' \
  || fail "Status is invalid"

decision="$(sed -n 's/^Decision: //p' "$cr_file")"
printf '%s\n' "$decision" | grep -Eq '^(accepted|rejected|superseded|pending)$' \
  || fail "Decision is invalid"

policy_version="$(sed -n 's/^Policy Version: //p' "$cr_file")"
printf '%s\n' "$policy_version" | grep -Eq '^v(0\.2|0\.3(-[0-9]+)?|0\.3-(draft-[0-9]+|rc-[0-9]+))$' \
  || fail "Policy Version is invalid"

base_oid="$(sed -n 's/^Base OID: //p' "$cr_file")"
head_oid="$(sed -n 's/^Head OID: //p' "$cr_file")"
integrated_result="$(sed -n 's/^Integrated Result: //p' "$cr_file")"
for oid in "$base_oid" "$head_oid"; do
  printf '%s\n' "$oid" | grep -Eq '^[0-9a-f]{40}$' \
    || fail "CR object IDs must be full lowercase SHA-1 values"
  git cat-file -e "$oid^{commit}" 2>/dev/null \
    || fail "CR object ID is not a commit in this repository: $oid"
done

if [ "$integrated_result" = "pending" ]; then
  [ "$status" != "integrated" ] \
    || fail "integrated CRs must have a main@<full commit OID> result"
else
  printf '%s\n' "$integrated_result" | grep -Eq '^main@[0-9a-f]{40}$' \
    || fail "Integrated Result must match main@<full commit OID>"
  integrated_oid="${integrated_result#main@}"
  git cat-file -e "$integrated_oid^{commit}" 2>/dev/null \
    || fail "integrated result is not a commit in this repository: $integrated_oid"
fi
git merge-base --is-ancestor "$base_oid" "$head_oid" \
  || fail "Base OID must be an ancestor of Head OID"

require_section "## Summary"
require_section "## Motivation"
require_section "## Test Evidence"
require_section "## Risk"
require_section "## Rollback"
require_section "## Breaking Change"
require_section "## Backport Target"
