#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <commit-message-file>" >&2
  exit 2
fi

msg_file="$1"

fail() {
  echo "commit message validation failed: $1" >&2
  exit 1
}

[ -f "$msg_file" ] || fail "message file does not exist: $msg_file"

subject="$(sed -n '1p' "$msg_file")"
[ -n "$subject" ] || fail "subject line is empty"

type_pattern='feat|fix|refactor|docs|test|build|ci|chore|perf|revert'
subject_pattern="^(${type_pattern})(\\([A-Za-z0-9._/-]+\\))?: [^ ].+$"
printf '%s\n' "$subject" | grep -Eq "$subject_pattern" || fail "subject must match <type>(<scope>): <summary>"

line_count="$(wc -l < "$msg_file" | tr -d ' ')"
if [ "$line_count" -ge 2 ]; then
  second_line="$(sed -n '2p' "$msg_file")"
  [ -z "$second_line" ] || fail "second line must be blank"
fi

last_nonempty_line="$(awk 'NF { last = NR } END { print last + 0 }' "$msg_file")"
[ "$last_nonempty_line" -gt 0 ] || fail "message body is empty"

trailer_start="$last_nonempty_line"
while [ "$trailer_start" -gt 1 ]; do
  current_line="$(sed -n "${trailer_start}p" "$msg_file")"
  printf '%s\n' "$current_line" | grep -Eq '^[A-Za-z0-9-]+: .+$' || fail "footer must end with trailers only"

  previous_line_number=$((trailer_start - 1))
  previous_line="$(sed -n "${previous_line_number}p" "$msg_file")"
  if [ -z "$previous_line" ]; then
    break
  fi

  trailer_start=$previous_line_number
done

if [ "$trailer_start" -le 2 ]; then
  fail "message must contain a trailer block separated from the subject by a blank line"
fi

trailer_count=$((last_nonempty_line - trailer_start + 1))
[ "$trailer_count" -ge 1 ] || fail "at least one trailer is required"
