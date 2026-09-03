# CR-0001: adopt UGS governance and enforcement

Base: `main` at `67923ba`
Head or Range: `chore/repo-ugs-compliance` / `67923ba..00ea46e`
Title: `chore(repo): adopt UGS governance and enforcement`
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.2
Base OID: 67923ba4a95d286edc527c03402c6a9dbb0ed044
Head OID: 00ea46e51f13d2cfedeedebfe72f280b48984c1b
Integrated Result: main@00ea46e51f13d2cfedeedebfe72f280b48984c1b

## Summary

Declare the repository's own UGS profile, review rules, versioning, and
release process. Add managed hooks, CODEOWNERS, and a GitHub workflow so
commit messages, CR fields, and protected branch expectations are checked
consistently.

## Motivation

The repository previously stored the UGS documents but did not declare its own
repository profile or enforce the standard locally and remotely.

## Test Evidence

- `scripts/validate_repo.sh`
- `bash -n .githooks/commit-msg .githooks/pre-push scripts/validate_commit_message.sh scripts/validate_commit_range.sh scripts/validate_repo.sh`
- `scripts/validate_commit_message.sh` against a sample compliant commit message

## Risk

New hooks can block pushes or commits if contributor environments are not set
up to use `.githooks`.

## Rollback

Revert commit `00ea46e` on a topic branch and re-integrate through the same CR
flow.

## Breaking Change

No. The repository governance surface becomes stricter for contributors, but no
published UGS document path or rule text is removed.

## Backport Target

None.
