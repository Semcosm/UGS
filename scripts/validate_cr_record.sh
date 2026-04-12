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

require_section "## Summary"
require_section "## Motivation"
require_section "## Test Evidence"
require_section "## Risk"
require_section "## Rollback"
require_section "## Breaking Change"
require_section "## Backport Target"
