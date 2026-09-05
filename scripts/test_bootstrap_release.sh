#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <release-tag>" >&2
  exit 2
fi

tag="$1"
root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

command -v gh >/dev/null 2>&1 || { echo "gh is required" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

git fetch --quiet --tags origin "refs/tags/$tag:refs/tags/$tag" 2>/dev/null || true
"$root_dir/scripts/validate_release_tag.sh" "$tag"

download_dir="$temp_dir/download"
mkdir -p "$download_dir"
gh release download "$tag" --pattern "ugs-bootstrap-${tag}.tar.gz" --pattern "ugs-bootstrap-${tag}.tar.gz.sha256" --pattern "ugs-bootstrap-${tag}.tar.gz.manifest.json" --dir "$download_dir"
archive="$download_dir/ugs-bootstrap-${tag}.tar.gz"
manifest="$archive.manifest.json"
(cd "$download_dir" && sha256sum -c "$(basename "$archive").sha256")

tag_commit="$(git rev-list -n1 "$tag^{commit}")"
manifest_commit="$(jq -r '.source_commit' "$manifest")"
[ "$manifest_commit" = "$tag_commit" ] || {
  echo "bootstrap manifest source commit does not match release tag" >&2
  exit 1
}

unpack_dir="$temp_dir/unpack"
mkdir -p "$unpack_dir"
tar -xzf "$archive" -C "$unpack_dir"
package_root="$unpack_dir/ugs-bootstrap-${tag}"
[ -x "$package_root/scripts/ugs_init.sh" ]
[ -f "$package_root/MANIFEST.json" ]
cmp -s "$manifest" "$package_root/MANIFEST.json"

while IFS=$'\t' read -r relative expected; do
  actual="$package_root/$relative"
  [ -f "$actual" ] || { echo "manifest file missing: $relative" >&2; exit 1; }
  actual_digest="$(sha256sum "$actual" | awk '{print $1}')"
  [ "$actual_digest" = "$expected" ] || { echo "manifest digest mismatch: $relative" >&2; exit 1; }
done < <(jq -r '.files[] | [.path, .sha256] | @tsv' "$manifest")

repo="$temp_dir/consumer-repository"
git init --quiet -b main "$repo"
git -C "$repo" config user.name "UGS Release Consumer"
git -C "$repo" config user.email "ugs-release-consumer@example.invalid"
"$package_root/scripts/ugs_init.sh" "$repo"
(cd "$repo" && scripts/validate_policy_manifest.sh .ugs/policy.json)
[ "$(git -C "$repo" config --get core.hooksPath)" = ".githooks" ]
[ "$(git -C "$repo" log -1 --format=%s)" = "chore(bootstrap): initialize UGS governance" ]

if "$package_root/scripts/ugs_init.sh" "$repo" >/dev/null 2>&1; then
  echo "published bootstrap package overwrote an initialized repository" >&2
  exit 1
fi

echo "published bootstrap asset verified and consumed: $tag"
