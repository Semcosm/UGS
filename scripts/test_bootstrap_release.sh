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

command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

git fetch --quiet --tags origin "refs/tags/$tag:refs/tags/$tag" 2>/dev/null || true
"$root_dir/scripts/validate_release_tag.sh" "$tag"

download_dir="$temp_dir/download"
mkdir -p "$download_dir"
"$root_dir/adapters/github/download_release.sh" "$tag" "$download_dir"
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
[ -f "$package_root/RELEASE-NOTES.md" ] || {
  echo "published bootstrap asset missing release notes" >&2
  exit 1
}
cmp -s "$root_dir/releases/${tag}.md" "$package_root/RELEASE-NOTES.md" || {
  echo "published bootstrap asset has mismatched release notes" >&2
  exit 1
}
for document in \
  OFFLINE-QUICKSTART.md \
  CONTRIBUTING.md \
  RELEASE.md \
  docs/git/commit-convention.md \
  docs/git/release-policy.md \
  docs/git/review-policy.md \
  docs/git/ugs-bootstrap.md \
  docs/git/ugs-branch-profiles.md \
  docs/git/ugs-conformance-fixtures.md \
  docs/git/ugs-conformance-levels.md \
  docs/git/ugs-core.md \
  docs/git/ugs-document-map.md \
  docs/git/ugs-quality-profile.md \
  docs/git/ugs-repository-shapes.md \
  docs/git/ugs-supply-chain-profile.md \
  docs/git/ugs-v0.3-profile.md; do
  [ -f "$package_root/$document" ] || {
    echo "published bootstrap asset missing offline documentation: $document" >&2
    exit 1
  }
done
cmp -s "$manifest" "$package_root/MANIFEST.json"

while IFS=$'\t' read -r relative expected; do
  actual="$package_root/$relative"
  [ -f "$actual" ] || { echo "manifest file missing: $relative" >&2; exit 1; }
  actual_digest="$(sha256sum "$actual" | awk '{print $1}')"
  [ "$actual_digest" = "$expected" ] || { echo "manifest digest mismatch: $relative" >&2; exit 1; }
done < <(jq -r '.files[] | [.path, .sha256] | @tsv' "$manifest")

# The downloaded package must be byte-for-byte equivalent to the source tree
# checked out at the signed release tag, not merely internally self-consistent.
source_root="$temp_dir/release-source"
mkdir -p "$source_root"
git archive "$tag" | tar -x -C "$source_root"
while IFS= read -r relative; do
  case "$relative" in
    README.md) source="bootstrap/README.md" ;;
    OFFLINE-QUICKSTART.md) source="bootstrap/OFFLINE-QUICKSTART.md" ;;
    RELEASE-NOTES.md) source="releases/${tag}.md" ;;
    bootstrap/templates/policy.schema.json) source=".ugs/schema/policy.schema.json" ;;
    *) source="$relative" ;;
  esac
  cmp -s "$source_root/$source" "$package_root/$relative" || {
    echo "published package differs from release source: $source -> $relative" >&2
    exit 1
  }
done < <(jq -r '.files[].path' "$manifest")

if rg -n -- '-----BEGIN (OPENSSH|RSA|EC|DSA) PRIVATE KEY-----' "$package_root" >/dev/null 2>&1; then
  echo "published bootstrap package unexpectedly contains a private key" >&2
  exit 1
fi

repo="$temp_dir/consumer-repository"
git init --quiet -b main "$repo"
git -C "$repo" config user.name "UGS Release Consumer"
git -C "$repo" config user.email "ugs-release-consumer@example.invalid"
"$package_root/scripts/ugs_init.sh" "$repo"
(cd "$repo" && scripts/validate_policy_manifest.sh .ugs/policy.json)
[ "$(git -C "$repo" config --get core.hooksPath)" = ".githooks" ]
[ "$(git -C "$repo" log -1 --format=%s)" = "chore(bootstrap): initialize UGS governance" ]
[ -x "$repo/adapters/bare-git/update" ]
[ -x "$repo/scripts/validate_ref_update.sh" ]
[ ! -e "$repo/adapters/github" ]
if (cd "$repo" && ./scripts/create_pr_from_cr.sh >"$temp_dir/release-create-pr-output" 2>&1); then
  echo "published baseline create_pr_from_cr wrapper unexpectedly passed" >&2
  exit 1
fi
grep -Fq 'optional GitHub adapter is not installed' "$temp_dir/release-create-pr-output"

if "$package_root/scripts/ugs_init.sh" "$repo" >/dev/null 2>&1; then
  echo "published bootstrap package overwrote an initialized repository" >&2
  exit 1
fi

echo "published bootstrap asset verified and consumed: $tag"

standard_repo="$temp_dir/standard-consumer-repository"
git init --quiet -b main "$standard_repo"
"$package_root/scripts/ugs_init.sh" --profile standard --no-commit "$standard_repo"
(cd "$standard_repo" && \
  scripts/validate_policy_manifest.sh .ugs/policy.json && \
  scripts/validate_quality_profile.sh .ugs/policy.json && \
  scripts/validate_supply_chain_profile.sh .ugs/policy.json && \
  scripts/validate_action_pinning.sh .ugs/policy.json .github/workflows && \
  scripts/validate_repository_shape.sh .ugs/policy.json)
[ "$(jq -r '.conformance_level' "$standard_repo/.ugs/policy.json")" = "standard" ]
[ "$(git -C "$standard_repo" config --get core.hooksPath)" = ".githooks" ]
"$package_root/scripts/test_profile_conformance.sh"

echo "published bootstrap standard profile verified and consumed: $tag"

document_map_repo="$temp_dir/document-map-consumer-repository"
git init --quiet -b main "$document_map_repo"
"$package_root/scripts/ugs_init.sh" --profile standard --with-document-map --no-commit "$document_map_repo"
[ "$(jq -r '.document_map' "$document_map_repo/.ugs/bootstrap.json")" = "true" ]
(cd "$document_map_repo" && scripts/generate_document_map.py --check && scripts/validate_document_map.py)
echo "published bootstrap optional Document Map verified and consumed: $tag"

if jq -e '.profiles | index("high-trust")' "$manifest" >/dev/null 2>&1; then
  high_trust_repo="$temp_dir/high-trust-consumer-repository"
  git init --quiet -b main "$high_trust_repo"
  "$package_root/scripts/ugs_init.sh" --profile high-trust --no-commit "$high_trust_repo"
  (cd "$high_trust_repo" && \
    scripts/validate_policy_manifest.sh .ugs/policy.json && \
    scripts/validate_signer_roles.sh && \
    scripts/validate_action_pinning.sh .ugs/policy.json .github/workflows)
  [ "$(jq -r '.conformance_level' "$high_trust_repo/.ugs/policy.json")" = "high-trust" ]
  [ -f "$high_trust_repo/keys/allowed_signers" ]
  "$package_root/scripts/test_profile_conformance.sh"
  echo "published bootstrap high-trust profile verified and consumed: $tag"
fi
