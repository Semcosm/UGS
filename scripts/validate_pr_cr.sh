#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ne 3 ]; then echo "usage: $0 <base-sha> <head-sha> <github-event-json>" >&2; exit 2; fi
repo_root="$(git rev-parse --show-toplevel)"
base="$1"; head="$2"; event="$3"
fail() { echo "PR CR validation failed: $1" >&2; exit 1; }
git rev-parse --verify "$base^{commit}" >/dev/null 2>&1 || fail "invalid base SHA"
git rev-parse --verify "$head^{commit}" >/dev/null 2>&1 || fail "invalid head SHA"
[ -f "$event" ] || fail "GitHub event file does not exist"
mapfile -t records < <(git diff --name-only "$base..$head" -- 'cr/CR-*.md')
[ "${#records[@]}" -gt 0 ] || fail "every PR must add or modify a cr/CR-*.md record"
merge_base="$(git merge-base "$base" "$head")"
body_file="$(mktemp)"
trap 'rm -f "$body_file"' EXIT
jq -r '.pull_request.body // empty' "$event" > "$body_file"
[ -s "$body_file" ] || fail "PR body is empty"
# jq prints its own record terminator in addition to a CR file's final newline.
# Normalize that transport artifact while preserving the CR text itself.
sed -i '${/^$/d;}' "$body_file"
for record in "${records[@]}"; do
  "$repo_root/scripts/validate_cr_record.sh" "$record" >/dev/null
  record_base="$(sed -n 's/^Base OID: //p' "$record")"
  record_head="$(sed -n 's/^Head OID: //p' "$record")"
  [ "$record_base" = "$merge_base" ] || fail "$record Base OID does not equal PR merge-base"
  git merge-base --is-ancestor "$record_head" "$head" || fail "$record Head OID is not in the PR history"
  cmp -s "$record" "$body_file" || fail "PR body differs from CR source: $record"
done
echo "PR CR validation passed (${#records[@]} record(s))"
