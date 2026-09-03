# CR-0009: fix initial-push validation range

Base: `main` at `670e72d`
Head or Range: `docs/v0-2-close-v0-3-plan`
Title: `fix(ci): validate new-branch commits against the protected baseline`
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.2
Base OID: 670e72d4b87beb6b7aee8a06c90c3bd44c8300d9
Head OID: 6d7e94a43c8bdb2fef8fa4b0dde170379746bbe6
Integrated Result: main@6d7e94a43c8bdb2fef8fa4b0dde170379746bbe6

## Summary

Fix the GitHub Actions range selection used when a branch is pushed for the
first time. Compare the new branch with `origin/main` (with a root-commit
fallback) instead of passing a single tip SHA to the range validator.

## Motivation

The first push of this branch failed before signature validation because
`git rev-list <tip>` traversed the entire historical ancestry and rechecked an
old bootstrap commit. A new-branch run must validate the commits introduced by
that branch relative to the protected baseline, matching the pull-request and
normal update paths.

## Test Evidence

- Reproduced the failure locally with
  `scripts/validate_commit_range.sh 02473c5e150deb03891da770629324e7fabb4407`,
  which reached the historical bootstrap message.
- `scripts/validate_commit_range.sh main..HEAD` passes for the topic delta.
- `scripts/validate_commit_signatures.sh main..HEAD` passes for both signed
  topic commits.
- `scripts/validate_repo.sh`, all CR validators, `git diff --check`, and
  `bash -n .githooks/* scripts/*.sh` pass after the workflow change.
- GitHub Actions run `33589545240` identified the old single-SHA range as the
  failing step.

## Risk

When `origin/main` is unavailable, a non-root tip is checked with a
single-commit `tip^..tip` range; a root commit uses the single SHA because it
has no parent. Neither fallback can establish a protected branch baseline.
Normal UGS repositories have a protected `main` ref and use the baseline
comparison path.

## Rollback

Revert this workflow and CR change through a new signed CR. Do not rewrite the
existing branch history or alter the protected `main` baseline.

## Breaking Change

No. This corrects CI range calculation without changing the commit, signature,
or branch-policy requirements.

## Backport Target

None.
