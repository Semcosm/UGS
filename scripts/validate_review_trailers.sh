#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$script_dir/ugs_errors.sh"

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <commit-message-file>" >&2
  exit 2
fi

message_file="$1"

fail() {
  local message="$1"
  local code="UGS-REVIEW-999"
  case "$message" in
    "message file does not exist:"*) code="UGS-REVIEW-001" ;;
    "message must contain a Reviewed-by trailer") code="UGS-REVIEW-002" ;;
    "message must contain a Tested-by trailer") code="UGS-REVIEW-003" ;;
  esac
  ugs_fail "$code" "$message"
}

[ -f "$message_file" ] || fail "message file does not exist: $message_file"
grep -Eq '^Reviewed-by: .+$' "$message_file" \
  || fail "message must contain a Reviewed-by trailer"
grep -Eq '^Tested-by: .+$' "$message_file" \
  || fail "message must contain a Tested-by trailer"
