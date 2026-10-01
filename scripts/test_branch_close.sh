#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

new_repo() {
  local repo="$1"
  git init --quiet -b main "$repo"
  git -C "$repo" config user.name "UGS Branch Fixture"
  git -C "$repo" config user.email "fixture@example.invalid"
  mkdir -p "$repo/.ugs" "$repo/scripts" "$repo/cr"
  cp "$root_dir/.ugs/policy.json" "$repo/.ugs/policy.json"
  cp "$root_dir/scripts/branch_close.py" "$repo/scripts/branch_close.py"
  cp "$root_dir/scripts/cr_model.py" "$repo/scripts/cr_model.py"
  printf 'base\n' > "$repo/state.txt"
  git -C "$repo" add -A
  git -C "$repo" commit --quiet -m 'docs(fixture): establish branch close base' -m 'Refs: branch-close-fixture'
}

commit_branch() {
  local repo="$1" branch="$2" text="$3"
  git -C "$repo" checkout --quiet -b "$branch" main
  printf '%s\n' "$text" >> "$repo/state.txt"
  git -C "$repo" add state.txt
  git -C "$repo" commit --quiet -m "docs(fixture): $text" -m 'Refs: branch-close-fixture'
}

integrate_with_cr() {
  local repo="$1" branch="$2" cr="$3" tip base
  tip="$(git -C "$repo" rev-parse "refs/heads/$branch")"
  base="$(git -C "$repo" rev-parse main)"
  cat > "$repo/cr/$cr.md" <<EOF
# $cr: branch close fixture

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: $branch / $base..$tip
Integration Target: main
Integration Strategy: merge
Review Evidence: trailers
Title: branch close fixture
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: $base
Head OID: $tip
Integrated Result: main@PLACEHOLDER
Coverage OIDs: none
Extensions: {}

## Summary

Fixture.

## Motivation

Fixture.

## Test Evidence

Fixture.

## Risk

Fixture.

## Rollback

Fixture.

## Breaking Change

No.

## Backport Target

None.
EOF
  git -C "$repo" checkout --quiet main
  git -C "$repo" merge --quiet --no-ff "$branch" -m 'docs(fixture): integrate branch close fixture' -m $'Reviewed-by: UGS Fixture\nTested-by: UGS Fixture\nRefs: branch-close-fixture'
  sed -i "s/main@PLACEHOLDER/main@$(git -C "$repo" rev-parse HEAD)/" "$repo/cr/$cr.md"
}

run_close() {
  local repo="$1"
  shift
  (cd "$repo" && python3 scripts/branch_close.py "$@")
}

merged="$temp_dir/merged"
new_repo "$merged"
commit_branch "$merged" feat/merged "merged"
integrate_with_cr "$merged" feat/merged CR-0001
merged_tip="$(git -C "$merged" rev-parse refs/heads/feat/merged)"
run_close "$merged" feat/merged --format json > "$temp_dir/merged.json"
jq -e --arg tip "$merged_tip" '.format == "ugs-branch-close/v1" and .status == "closed" and .tip_oid == $tip and .matched_cr == "CR-0001" and .local_result == "delete"' "$temp_dir/merged.json" >/dev/null
test "$(git -C "$merged" show-ref --verify --hash refs/ugs/closed/feat/merged)" = "$merged_tip"
run_close "$merged" feat/merged --format json > "$temp_dir/repeat.json"
jq -e '.status == "already_closed" and .local_result == "already_closed"' "$temp_dir/repeat.json" >/dev/null

unmerged="$temp_dir/unmerged"
new_repo "$unmerged"
commit_branch "$unmerged" feat/unmerged "unmerged"
git -C "$unmerged" checkout --quiet main
if run_close "$unmerged" feat/unmerged --format json > "$temp_dir/unmerged.json"; then
  echo "unmerged branch unexpectedly closed" >&2
  exit 1
fi
jq -e '.status == "refused" and .code == "UGS-BRANCH-012"' "$temp_dir/unmerged.json" >/dev/null

archive="$temp_dir/archive"
new_repo "$archive"
commit_branch "$archive" feat/archive "abandoned"
archive_tip="$(git -C "$archive" rev-parse refs/heads/feat/archive)"
git -C "$archive" checkout --quiet main
if run_close "$archive" feat/archive --archive --format json > "$temp_dir/archive-missing.json"; then
  echo "archive without reason unexpectedly passed" >&2
  exit 1
fi
jq -e '.code == "UGS-BRANCH-003"' "$temp_dir/archive-missing.json" >/dev/null
run_close "$archive" feat/archive --archive --reason "superseded" --format json > "$temp_dir/archive.json"
jq -e --arg tip "$archive_tip" '.status == "closed" and .source_oid == $tip and .reason == "superseded" and .archive_ref == "refs/ugs/archive/feat/archive"' "$temp_dir/archive.json" >/dev/null
test "$(git -C "$archive" show-ref --verify --hash refs/ugs/archive/feat/archive)" = "$archive_tip"
run_close "$archive" feat/archive --archive --reason "superseded" --format json > "$temp_dir/archive-repeat.json"
jq -e '.status == "already_closed" and .archive_ref == "refs/ugs/archive/feat/archive"' "$temp_dir/archive-repeat.json" >/dev/null

protected="$temp_dir/protected"
new_repo "$protected"
if run_close "$protected" main --format json > "$temp_dir/protected.json"; then
  echo "protected branch unexpectedly closed" >&2
  exit 1
fi
jq -e '.code == "UGS-BRANCH-005"' "$temp_dir/protected.json" >/dev/null

worktree="$temp_dir/worktree"
new_repo "$worktree"
commit_branch "$worktree" feat/worktree "checked out elsewhere"
git -C "$worktree" checkout --quiet main
git -C "$worktree" worktree add --quiet "$temp_dir/linked-worktree" feat/worktree
if run_close "$worktree" feat/worktree --archive --reason "worktree conflict" --format json > "$temp_dir/worktree.json"; then
  echo "worktree conflict unexpectedly passed" >&2
  exit 1
fi
jq -e '.status == "refused" and .code == "UGS-BRANCH-010"' "$temp_dir/worktree.json" >/dev/null

dry="$temp_dir/dry"
new_repo "$dry"
commit_branch "$dry" feat/dry "preview"
integrate_with_cr "$dry" feat/dry CR-0002
dry_tip="$(git -C "$dry" rev-parse refs/heads/feat/dry)"
run_close "$dry" feat/dry --dry-run --format json > "$temp_dir/dry.json"
jq -e '.status == "dry_run" and .local_result == "delete"' "$temp_dir/dry.json" >/dev/null
test "$(git -C "$dry" show-ref --verify --hash refs/heads/feat/dry)" = "$dry_tip"
if git -C "$dry" show-ref --verify --quiet refs/ugs/closed/feat/dry; then
  echo "dry-run created a close ref" >&2
  exit 1
fi

remote="$temp_dir/remote"
new_repo "$remote"
commit_branch "$remote" feat/remote "remote source"
integrate_with_cr "$remote" feat/remote CR-0003
git -C "$remote" init --bare --quiet "$temp_dir/remote.git"
git -C "$remote" remote add origin "$temp_dir/remote.git"
git -C "$remote" push --quiet origin main feat/remote
git -C "$remote" checkout --quiet main
printf 'race\n' >> "$remote/state.txt"
git -C "$remote" add state.txt
git -C "$remote" commit --quiet -m 'docs(fixture): move remote tip' -m 'Refs: branch-close-fixture'
git -C "$remote" push --quiet origin main
git --git-dir="$temp_dir/remote.git" update-ref refs/heads/feat/remote "$(git -C "$remote" rev-parse main)"
if run_close "$remote" feat/remote --remote origin --format json > "$temp_dir/remote.json"; then
  echo "remote OID mismatch unexpectedly passed" >&2
  exit 1
fi
jq -e '.status == "refused" and .code == "UGS-BRANCH-014"' "$temp_dir/remote.json" >/dev/null

echo "branch-close fixtures validation passed"
