#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <commit-message-file>" >&2
  exit 2
fi

message_file="$1"

fail() {
  echo "review trailer validation failed: $1" >&2
  exit 1
}

[ -f "$message_file" ] || fail "message file does not exist: $message_file"
grep -Eq '^Reviewed-by: .+$' "$message_file" \
  || fail "message must contain a Reviewed-by trailer"
grep -Eq '^Tested-by: .+$' "$message_file" \
  || fail "message must contain a Tested-by trailer"
