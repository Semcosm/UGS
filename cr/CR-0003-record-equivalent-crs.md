# CR-0003: add in-repository equivalent CR records

Base: `main` at `93b5473`
Head or Range: `docs/repo-cr-records`
Title: `docs(repo): archive equivalent change request records`
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.2
Base OID: 93b54733e794037fc5fe9d161efe0d654085e66d
Head OID: d2b87c54e35f79aab4cda6a1ffe119b7f01b9270
Integrated Result: main@d2b87c54e35f79aab4cda6a1ffe119b7f01b9270

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
