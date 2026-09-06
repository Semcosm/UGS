#!/usr/bin/env bash
set -euo pipefail

# Exercise the package consumer flow from the package directory. The source
# checkout additionally tests archive verification in test_bootstrap_package.sh.
root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

version="v0.0.0-upgrade-fixture"
dist_dir="$temp_dir/dist"
SOURCE_DATE_EPOCH=0 "$root_dir/scripts/build_bootstrap_package.sh" "$version" --output-dir "$dist_dir" >/dev/null
archive="$dist_dir/ugs-bootstrap-${version}.tar.gz"
unpack_dir="$temp_dir/unpack"
mkdir -p "$unpack_dir"
tar -xzf "$archive" -C "$unpack_dir"
package_root="$unpack_dir/ugs-bootstrap-${version}"

run_upgrade() {
  "$package_root/scripts/ugs.sh" upgrade --archive "$archive" "$@"
}

jq -e '
  .format == "ugs-components/v1" and
  .active_profile == "preserved-until-explicit-activation" and
  (.files | length > 0) and
  ([.files[].kind] | index("core") != null) and
  ([.files[].kind] | index("profile-specific") != null) and
  ([.files[].kind] | index("documentation") != null) and
  ([.files[].kind] | index("release-only") != null)
' "$package_root/COMPONENTS.json" >/dev/null

tamper_repo="$temp_dir/tamper-repository"
git init --quiet -b main "$tamper_repo"
git -C "$tamper_repo" config user.name "UGS Tamper Fixture"
git -C "$tamper_repo" config user.email "ugs-tamper-fixture@example.invalid"
"$package_root/scripts/ugs_init.sh" --profile baseline --no-commit "$tamper_repo" >/dev/null

tampered_manifest="$temp_dir/tampered.manifest.json"
jq '.version = "v0.0.0-tampered"' "$archive.manifest.json" > "$tampered_manifest"
if "$package_root/scripts/ugs.sh" upgrade \
  --archive "$archive" \
  --manifest "$tampered_manifest" \
  --components "$archive.components.json" \
  "$tamper_repo" > "$temp_dir/manifest-tamper-output" 2>&1; then
  echo "upgrade unexpectedly accepted a tampered external manifest" >&2
  exit 1
fi
grep -Fq 'external package manifest differs' "$temp_dir/manifest-tamper-output"
[ ! -e "$tamper_repo/.ugs/installation.json" ]

tampered_components="$temp_dir/tampered.components.json"
jq '.active_profile = "unexpected-profile"' "$archive.components.json" > "$tampered_components"
if "$package_root/scripts/ugs.sh" upgrade \
  --archive "$archive" \
  --manifest "$archive.manifest.json" \
  --components "$tampered_components" \
  "$tamper_repo" > "$temp_dir/components-tamper-output" 2>&1; then
  echo "upgrade unexpectedly accepted a tampered external component manifest" >&2
  exit 1
fi
grep -Fq 'external component manifest differs' "$temp_dir/components-tamper-output"
[ ! -e "$tamper_repo/.ugs/installation.json" ]

tampered_archive="$temp_dir/tampered.tar.gz"
cp "$archive" "$tampered_archive"
printf '%s' 'tampered archive payload' >> "$tampered_archive"
printf '%s  %s\n' "$(cut -d' ' -f1 "$archive.sha256")" "$(basename "$tampered_archive")" > "$tampered_archive.sha256"
cp "$archive.manifest.json" "$tampered_archive.manifest.json"
cp "$archive.components.json" "$tampered_archive.components.json"
if "$package_root/scripts/ugs.sh" upgrade --archive "$tampered_archive" "$tamper_repo" > "$temp_dir/archive-tamper-output" 2>&1; then
  echo "upgrade unexpectedly accepted a tampered archive" >&2
  exit 1
fi
grep -Fq 'checksum does not match' "$temp_dir/archive-tamper-output"
[ ! -e "$tamper_repo/.ugs/installation.json" ]

repo="$temp_dir/conventional"
git init --quiet -b main "$repo"
git -C "$repo" config user.name "UGS Upgrade Fixture"
git -C "$repo" config user.email "ugs-upgrade-fixture@example.invalid"
"$package_root/scripts/ugs_init.sh" --profile baseline --no-commit "$repo" >/dev/null
printf '%s\n' 'project-owned README' > "$repo/README.md"
printf '%s\n' 'historical project CR' > "$repo/cr/project-history.md"
before_readme="$(cat "$repo/README.md")"

dry_run_output="$temp_dir/dry-run-output"
run_upgrade --dry-run "$repo" > "$dry_run_output"
grep -Fq 'repository layout: normal' "$dry_run_output"
grep -Fq 'project-preserved: README.md' "$dry_run_output"
[ "$(cat "$repo/README.md")" = "$before_readme" ]
[ ! -e "$repo/.ugs/installation.json" ]

backup="$temp_dir/conventional-backup"
run_upgrade --backup-dir "$backup" "$repo" > "$temp_dir/upgrade-output"
grep -Fq 'active profile: baseline' "$temp_dir/upgrade-output"
grep -Fq 'project-preserved: README.md' "$temp_dir/upgrade-output"
[ "$(jq -r '.conformance_level' "$repo/.ugs/policy.json")" = "baseline" ]
[ "$(jq -r '.active_profile' "$repo/.ugs/installation.json")" = "baseline" ]
[ -x "$repo/adapters/github/validate_pr.sh" ]
[ -x "$repo/scripts/ugs_upgrade.sh" ]
[ -f "$repo/.ugs/docs/git/ugs-core.md" ]
[ -f "$repo/.ugs/docs/OFFLINE-QUICKSTART.md" ]
[ -f "$repo/cr/project-history.md" ]
[ "$(cat "$repo/README.md")" = "$before_readme" ]
(cd "$repo" && scripts/validate_policy_manifest.sh .ugs/policy.json)

activation_backup="$temp_dir/activation-backup"
"$package_root/scripts/ugs.sh" activate --profile standard --archive "$archive" --backup-dir "$activation_backup" "$repo" >/dev/null
[ "$(jq -r '.conformance_level' "$repo/.ugs/policy.json")" = "standard" ]
(cd "$repo" && \
  scripts/validate_policy_manifest.sh .ugs/policy.json && \
  scripts/validate_quality_profile.sh .ugs/policy.json && \
  scripts/validate_supply_chain_profile.sh .ugs/policy.json && \
  scripts/validate_action_pinning.sh .ugs/policy.json .github/workflows && \
  scripts/validate_repository_shape.sh .ugs/policy.json)
"$package_root/scripts/ugs.sh" rollback --backup-dir "$activation_backup" "$repo" >/dev/null
[ "$(jq -r '.conformance_level' "$repo/.ugs/policy.json")" = "baseline" ]

high_trust_backup="$temp_dir/high-trust-backup"
"$package_root/scripts/ugs.sh" activate --profile high-trust --archive "$archive" --backup-dir "$high_trust_backup" "$repo" >/dev/null
[ "$(jq -r '.conformance_level' "$repo/.ugs/policy.json")" = "high-trust" ]
(cd "$repo" && \
  scripts/validate_policy_manifest.sh .ugs/policy.json && \
  scripts/validate_signer_roles.sh && \
  scripts/validate_action_pinning.sh .ugs/policy.json .github/workflows)
"$package_root/scripts/ugs.sh" rollback --backup-dir "$high_trust_backup" "$repo" >/dev/null
[ "$(jq -r '.conformance_level' "$repo/.ugs/policy.json")" = "baseline" ]

"$package_root/scripts/ugs.sh" rollback --backup-dir "$backup" "$repo" >/dev/null
[ "$(jq -r '.conformance_level' "$repo/.ugs/policy.json")" = "baseline" ]
[ ! -e "$repo/.ugs/installation.json" ]
[ ! -e "$repo/adapters/github/validate_pr.sh" ]
[ "$(cat "$repo/README.md")" = "$before_readme" ]
[ -f "$repo/cr/project-history.md" ]

overwrite_backup="$temp_dir/overwrite-backup"
run_upgrade --overwrite-project-files --backup-dir "$overwrite_backup" "$repo" >/dev/null
grep -Fq 'UGS-governed repository' "$repo/README.md"
"$package_root/scripts/ugs.sh" rollback --backup-dir "$overwrite_backup" "$repo" >/dev/null
[ "$(cat "$repo/README.md")" = "$before_readme" ]

conflict="$temp_dir/conflict"
git init --quiet -b main "$conflict"
"$package_root/scripts/ugs_init.sh" --profile baseline --no-commit "$conflict" >/dev/null
mkdir -p "$conflict/adapters/github/validate_pr.sh"
if run_upgrade "$conflict" > "$temp_dir/conflict-output" 2>&1; then
  echo "upgrade unexpectedly ignored a filesystem conflict" >&2
  exit 1
fi
grep -Fq 'conflicts detected; no files were changed' "$temp_dir/conflict-output"
[ ! -e "$conflict/.ugs/installation.json" ]

managed="$temp_dir/managed"
git init --quiet --separate-git-dir "$managed/.git-worktree" -b main "$managed"
git -C "$managed" config user.name "UGS Managed Fixture"
git -C "$managed" config user.email "ugs-managed-fixture@example.invalid"
"$package_root/scripts/ugs_init.sh" --profile baseline --migrate --no-commit "$managed" >/dev/null
printf '%s\n' 'git metadata is managed externally' > "$managed/.git"
managed_output="$temp_dir/managed-output"
run_upgrade "$managed" > "$managed_output"
grep -Fq 'repository layout: managed-worktree' "$managed_output"
[ "$(jq -r '.conformance_level' "$managed/.ugs/policy.json")" = "baseline" ]
[ -f "$managed/.ugs/installation.json" ]

linked="$temp_dir/linked"
linked_git_dir="$temp_dir/linked-git"
git init --quiet --separate-git-dir "$linked_git_dir" -b main "$linked"
git -C "$linked" config user.name "UGS Linked Fixture"
git -C "$linked" config user.email "ugs-linked-fixture@example.invalid"
"$package_root/scripts/ugs_init.sh" --profile baseline --migrate --no-commit "$linked" >/dev/null
linked_output="$temp_dir/linked-output"
run_upgrade "$linked" > "$linked_output"
grep -Fq 'repository layout: linked-worktree' "$linked_output"
[ "$(jq -r '.conformance_level' "$linked/.ugs/policy.json")" = "baseline" ]

bare="$temp_dir/bare.git"
git init --quiet --bare "$bare"
if run_upgrade "$bare" > "$temp_dir/bare-output" 2>&1; then
  echo "upgrade unexpectedly accepted a bare Git repository" >&2
  exit 1
fi
grep -Fq 'detected bare Git repository' "$temp_dir/bare-output"

echo "UGS bootstrap upgrade fixtures passed"
