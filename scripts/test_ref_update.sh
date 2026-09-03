#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_ref_update.sh"
zeros="0000000000000000000000000000000000000000"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

git init --quiet -b main "$temp_dir/repo"
git -C "$temp_dir/repo" config user.name "UGS Fixture"
git -C "$temp_dir/repo" config user.email "fixture@example.invalid"
printf '%s\n' one > "$temp_dir/repo/file"
git -C "$temp_dir/repo" add file
git -C "$temp_dir/repo" commit --quiet -m 'docs(fixture): create ref evidence' -m 'Exercise ref update validation.' -m 'Refs: fixture'
first_commit="$(git -C "$temp_dir/repo" rev-parse HEAD)"
printf '%s\n' two > "$temp_dir/repo/file"
git -C "$temp_dir/repo" commit --quiet -am 'docs(fixture): advance ref' -m 'Advance the disposable branch.' -m 'Refs: fixture'
second_commit="$(git -C "$temp_dir/repo" rev-parse HEAD)"

if (cd "$temp_dir/repo" && "$validator" "$first_commit" "$zeros" refs/heads/main) >/dev/null 2>&1; then
  echo "main deletion unexpectedly passed" >&2
  exit 1
fi

if (cd "$temp_dir/repo" && "$validator" "$second_commit" "$first_commit" refs/heads/main) >/dev/null 2>&1; then
  echo "non-fast-forward main update unexpectedly passed" >&2
  exit 1
fi

git -C "$temp_dir/repo" tag -a v9.9.9 -m 'fixture tag'
tag_object="$(git -C "$temp_dir/repo" rev-parse refs/tags/v9.9.9)"

if (cd "$temp_dir/repo" && "$validator" "$tag_object" "$zeros" refs/tags/v9.9.9) >/dev/null 2>&1; then
  echo "release tag deletion unexpectedly passed" >&2
  exit 1
fi

if (cd "$temp_dir/repo" && "$validator" "$tag_object" "$first_commit" refs/tags/v9.9.9) >/dev/null 2>&1; then
  echo "release tag replacement unexpectedly passed" >&2
  exit 1
fi

echo "ref update fixture validation passed"
