#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <rev-range>" >&2
  exit 2
fi

repo_root="$(git rev-parse --show-toplevel)"
range="$1"

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

if ! git rev-parse --quiet --verify "$range" >/dev/null 2>&1; then
  git rev-list "$range" >/dev/null
fi

while IFS= read -r commit; do
  git log -1 --format=%B "$commit" > "$tmp_file"
  "$repo_root/scripts/validate_commit_message.sh" "$tmp_file"
done < <(git rev-list --reverse "$range")
