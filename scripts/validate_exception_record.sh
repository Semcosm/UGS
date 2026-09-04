#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
exception_file="$1"

fail() {
  echo "exception record validation failed: $1" >&2
  exit 1
}

[ -f "$exception_file" ] || fail "record file does not exist"
title="$(sed -n '1p' "$exception_file")"
printf '%s\n' "$title" | grep -Eq '^# EX-[0-9]{4}: .+$' || fail "title is invalid"

require_line() {
  local key="$1"
  local value
  value="$(sed -n "s/^${key}: //p" "$exception_file")"
  [ -n "$value" ] || fail "missing $key"
  if printf '%s\n' "$value" | grep -Eq '^<[^>]+>$'; then
    fail "$key is a placeholder"
  fi
}

for key in Type Status "Authorized By" Reason "Started At" "Expires At" "Event OID" "Post-Event Review"; do
  require_line "$key"
done

type="$(sed -n 's/^Type: //p' "$exception_file")"
status="$(sed -n 's/^Status: //p' "$exception_file")"
authorized_by="$(sed -n 's/^Authorized By: //p' "$exception_file")"
started_at="$(sed -n 's/^Started At: //p' "$exception_file")"
expires_at="$(sed -n 's/^Expires At: //p' "$exception_file")"
event_oid="$(sed -n 's/^Event OID: //p' "$exception_file")"
post_review="$(sed -n 's/^Post-Event Review: //p' "$exception_file")"

printf '%s\n' "$type" | grep -Eq '^(bootstrap|emergency)$' || fail "Type is invalid"
printf '%s\n' "$status" | grep -Eq '^(active|closed)$' || fail "Status is invalid"
printf '%s\n' "$authorized_by" | grep -Eq '^[^@[:space:]]+@[^@[:space:]]+$' || fail "Authorized By is invalid"
printf '%s\n' "$started_at" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' || fail "Started At is invalid"
printf '%s\n' "$expires_at" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' || fail "Expires At is invalid"
[ "$expires_at" \> "$started_at" ] || fail "Expires At must be after Started At"
printf '%s\n' "$event_oid" | grep -Eq '^[0-9a-f]{40}$' || fail "Event OID is invalid"
git cat-file -e "$event_oid^{commit}" 2>/dev/null || fail "Event OID is not a commit"
grep -Fq "$authorized_by" "$repo_root/keys/signer_roles.json" || fail "Authorized By is not a registered signer"

if [ "$status" = "closed" ]; then
  printf '%s\n' "$post_review" | grep -Eq '^main@[0-9a-f]{40}$' || fail "closed exceptions require main@<full commit OID> review"
  review_oid="${post_review#main@}"
  git cat-file -e "$review_oid^{commit}" 2>/dev/null || fail "post-event review is not a commit"
  git merge-base --is-ancestor "$review_oid" refs/heads/main 2>/dev/null \
    || git merge-base --is-ancestor "$review_oid" refs/remotes/origin/main 2>/dev/null \
    || fail "post-event review is not reachable from main"
else
  [ "$post_review" = "pending" ] || fail "active exceptions require pending post-event review"
fi

echo "exception record validation passed"
