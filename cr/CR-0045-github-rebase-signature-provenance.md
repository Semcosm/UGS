# CR-0045: Preserve signature provenance across GitHub rebase integration

Base: main
Head or Range: fix/ci-verify-github-rebase / 9632f8b..main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: fix(ci): preserve signature provenance for GitHub rebase integration
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: 52ac3d160de4e8bd03707a41bfd42338c6f6e460
Head OID: 5cf0cc0e59e6ac7dd1b3cf96be289f3692c8e7bd
Integrated Result: main@5cf0cc0e59e6ac7dd1b3cf96be289f3692c8e7bd

## Summary

Fetch retained pull-request source refs during push validation and recognize a
GitHub-generated rebase copy only when it has identical tree, parent, author,
and message content to a separately verified SSH-signed source commit.

## Motivation

GitHub's rebase merge generated `52ac3d1` from signed source commit `4c145ce`
without carrying the SSH signature. The pull-request check passed, but the
post-merge main check rejected the generated integration object. The fix
preserves strict signature validation while retaining verifiable provenance.

## Test Evidence

Reproduced `b5b2008..52ac3d1` locally with the retained `refs/pull/10/head`
source reference; signature validation passed through `4c145ce`. Full
`scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, and
`git diff --check` also passed.

## Risk

An unsigned commit is accepted only when an available source commit matches its
tree, parents, author identity/timestamp, and message exactly and independently
passes trusted SSH signature verification. Ordinary unsigned commits remain
rejected.

## Rollback

Revert this follow-up through a signed rebase-fast-forward change if the
provenance rule needs correction. Do not rewrite the published main history.

## Breaking Change

No for valid signed pull-request integrations; unsigned commits without an
exact signed source remain rejected.

## Backport Target

None; this repairs v0.3 post-merge CI behavior.
