# CR-0003: add in-repository equivalent CR records

Base: `main` at `93b5473`
Head or Range: `docs/repo-cr-records`
Title: `docs(repo): archive equivalent change request records`

## Summary

Add an in-repository `cr/` directory, a reusable template, and archive records
for the governance bootstrap and normal CR-based integration changes.

## Motivation

UGS requires every CR to carry a minimum field set. The repository already had
PR and topic-branch paths, but it still needed a repository-local archive
format for equivalent CR records.

## Test Evidence

- `scripts/validate_repo.sh`
- `bash -n .githooks/pre-push .githooks/commit-msg scripts/validate_commit_message.sh scripts/validate_commit_range.sh scripts/validate_repo.sh`

## Risk

Low. The change adds documentation and validation requirements for a new
directory but does not alter the enforcement behavior of existing hooks.

## Rollback

Revert the commit that introduces `cr/` on a topic branch and re-integrate
through the same CR flow.

## Breaking Change

No.

## Backport Target

None.
