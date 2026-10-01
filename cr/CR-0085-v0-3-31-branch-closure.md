# CR-0085: Implement v0.3.31 branch closure

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: docs/cr-0085-integration / d3a3c9c5ce1d2502d0219d00bbf6a9de64ecda64..d3a3c9c5ce1d2502d0219d00bbf6a9de64ecda64
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Implement v0.3.31 branch closure
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: d3a3c9c5ce1d2502d0219d00bbf6a9de64ecda64
Head OID: d3a3c9c5ce1d2502d0219d00bbf6a9de64ecda64
Integrated Result: main@d3a3c9c5ce1d2502d0219d00bbf6a9de64ecda64
Coverage OIDs: 8b9b2a3f9fe2a47bc6aa840e39dc78cb0760207e
Extensions: {}

## Summary

Add the policy-aware ugs branch close command for retiring integrated topic
branches and explicitly archiving abandoned work. The command emits a stable
ugs-branch-close/v1 report and is shipped in the bootstrap package.

## Motivation

Short-lived topic branches need a safe, auditable retirement path. Manual
deletion can remove protected refs, branches that are not integrated, or work
that is still checked out elsewhere. The command makes the required Git and CR
evidence checks explicit while preserving an archive ref when a maintainer
chooses to retain abandoned work.

## Test Evidence

scripts/test_branch_close.sh uses disposable repositories to cover merged
close, unmerged refusal, archive reason and source OID reporting, protected
refs, linked-worktree conflicts, remote OID mismatch, idempotent repetition,
dry-run side-effect checks, and JSON report shape. scripts/validate_repo.sh
and the branch-close fixture pass on the implementation tip.

## Risk

The command deletes visible local branches and, only when explicitly requested,
remote branches. Preflight checks, compare-and-delete OID leases, protected-ref
rules, and archive-ref no-clobber checks reduce accidental data loss. The
active policy_version remains 0.3.

## Rollback

Do not remove protected refs or release tags. A normal close records the source
OID under refs/ugs/closed/<branch>; restore a visible branch with
git branch <branch> <source-oid> if required. An archive close retains the
source under refs/ugs/archive/<branch>. Revert the signed implementation
commits through a new reviewed CR if the command or package wiring is defective.

## Breaking Change

No. This adds an opt-in command and bootstrap component without changing the
policy schema, protected branch declarations, or existing commands.

## Backport Target

None.
