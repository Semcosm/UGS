#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ne 2 ]; then echo "usage: $0 <old-sha> <new-sha>" >&2; exit 2; fi
repo_root="$(git rev-parse --show-toplevel)"
old="$1"; new="$2"
fail() { echo "main CR range validation failed: $1" >&2; exit 1; }
git rev-parse --verify "$old^{commit}" >/dev/null 2>&1 || fail "invalid old SHA"
git rev-parse --verify "$new^{commit}" >/dev/null 2>&1 || fail "invalid new SHA"
mapfile -t records < <(git diff --name-only "$old..$new" -- 'cr/CR-*.md')
[ "${#records[@]}" -gt 0 ] || fail "main integration range contains no persisted CR"
for record in "${records[@]}"; do
  "$repo_root/scripts/validate_cr_record.sh" "$record" >/dev/null
  record_head="$(sed -n 's/^Head OID: //p' "$record")"
  git merge-base --is-ancestor "$record_head" "$new" || fail "$record Head OID is not reachable from new main"
done
echo "main CR range validation passed (${#records[@]} record(s))"
