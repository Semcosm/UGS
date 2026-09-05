#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

repo="$temp_dir/repo"
git init --quiet -b main "$repo"
git -C "$repo" config user.name "Bootstrap Fixture"
git -C "$repo" config user.email "bootstrap@example.invalid"
"$root_dir/scripts/ugs_init.sh" --profile baseline "$repo"
[ -d "$repo/.git" ]
[ "$(git -C "$repo" config --get core.hooksPath)" = ".githooks" ]
git -C "$repo" log -1 --format=%s | grep -Fqx 'chore(bootstrap): initialize UGS governance'
"$root_dir/scripts/validate_policy_manifest.sh" "$repo/.ugs/policy.json"

if "$root_dir/scripts/ugs_init.sh" "$repo" >/dev/null 2>&1; then
  echo "bootstrap unexpectedly overwrote an initialized repository" >&2
  exit 1
fi

"$root_dir/scripts/ugs_init.sh" --dry-run "$temp_dir/dry-run" | grep -Fqx 'would write .ugs/policy.json'
if "$root_dir/scripts/ugs_init.sh" "$temp_dir/non-empty" >/dev/null 2>&1; then
  echo "bootstrap unexpectedly accepted a non-empty directory" >&2
  exit 1
fi

package_dir="$temp_dir/dist"
SOURCE_DATE_EPOCH=0 "$root_dir/scripts/build_bootstrap_package.sh" v0.0.0-test --output-dir "$package_dir" >/dev/null
archive="$package_dir/ugs-bootstrap-v0.0.0-test.tar.gz"
[ -f "$archive" ]
[ -f "$archive.manifest.json" ]
[ -f "$archive.sha256" ]
(cd "$package_dir" && sha256sum -c "$archive.sha256")
cp "$archive" "$temp_dir/first.tar.gz"
SOURCE_DATE_EPOCH=0 "$root_dir/scripts/build_bootstrap_package.sh" v0.0.0-test --output-dir "$package_dir" >/dev/null
cmp -s "$temp_dir/first.tar.gz" "$archive"
tar -tzf "$archive" | grep -Fqx 'ugs-bootstrap-v0.0.0-test/scripts/ugs_init.py'
unpack="$temp_dir/unpack"
mkdir -p "$unpack"
tar -xzf "$archive" -C "$unpack"
package_root="$unpack/ugs-bootstrap-v0.0.0-test"
package_target="$temp_dir/package-repo"
"$package_root/scripts/ugs_init.sh" --no-commit "$package_target" >/dev/null
[ -f "$package_target/.ugs/policy.json" ]

echo "UGS bootstrap package fixtures passed"
