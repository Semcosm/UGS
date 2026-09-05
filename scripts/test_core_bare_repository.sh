#!/usr/bin/env bash
set -euo pipefail
root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT
clone="$temp_dir/core-repository"
git clone --quiet "$root_dir" "$clone"
rm -rf "$clone/.github"
(cd "$clone" && scripts/validate_repo.sh)
echo "bare Git Core repository validation passed"
