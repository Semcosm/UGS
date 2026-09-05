#!/usr/bin/env bash
set -euo pipefail
root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
bare_repo="$temp_dir/server.git"
git init --bare --quiet "$bare_repo"
git --git-dir "$bare_repo" fetch --quiet "$root_dir" main:refs/heads/main
old_object="$(git -C "$root_dir" rev-parse origin/main)"
git --git-dir "$bare_repo" update-ref refs/heads/main "$old_object"
new_object="$(git -C "$root_dir" rev-parse HEAD)"
git --git-dir "$bare_repo" fetch --quiet "$root_dir" "$new_object"
(cd "$bare_repo" && UGS_REPOSITORY_ROOT="$root_dir" \
  "$root_dir/adapters/bare-git/update" refs/heads/main "$old_object" "$new_object")
echo "bare Git receive/update adapter validation passed"
