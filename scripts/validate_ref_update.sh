#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <old-object> <new-object> <ref-name>" >&2
  exit 2
fi

old_object="$1"
new_object="$2"
ref_name="$3"
zeros="0000000000000000000000000000000000000000"

fail() {
  echo "ref update validation failed: $1" >&2
  exit 1
}

case "$ref_name" in
  refs/heads/main)
    [ "$new_object" != "$zeros" ] || fail "deleting main is not allowed"
    [ "$old_object" != "$zeros" ] || exit 0
    git merge-base --is-ancestor "$old_object" "$new_object" \
      || fail "main updates must be fast-forward"
    ;;
  refs/tags/v*)
    [ "$new_object" != "$zeros" ] || fail "deleting formal release tags is not allowed"
    if [ "$old_object" != "$zeros" ] && [ "$old_object" != "$new_object" ]; then
      fail "formal release tags cannot be replaced"
    fi
    tag_name="${ref_name#refs/tags/}"
    scripts/validate_release_tag.sh "$tag_name"
    ;;
esac
