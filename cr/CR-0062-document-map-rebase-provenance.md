# CR-0062: Refresh Document Map CR provenance after remote rebase

Base: main
Head or Range: chore/release-v0-3-26
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: chore(cr): refresh Document Map CR provenance after remote rebase
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: a10461f23d9c745d92ec09befec45aa213c390f7
Head OID: b25c81a4641137f58a37afdc4ac7b1902dd10d32
Integrated Result: pending

## Summary

Refresh CR-0060's head reference from an old local topic object to the
equivalent commit already reachable from the current remote `main` history.

## Motivation

The remote repository contains a signed rebase-equivalent history for the
Document Map governance changes. CR-0060 still named a local topic commit that
was not present when the bare-Git and clean-runner fixtures fetched only
`main`, causing otherwise valid CR validation to fail.

## Test Evidence

Run the bare-Git update fixture, PR/CR adapter fixture, CR validation,
repository validation, and full release preflight after the provenance update.

## Risk

Audit-only correction. It does not alter the Document Map implementation or
change the meaning of any policy requirement.

## Rollback

Preserve the existing CR history and correct the reference through a later
signed CR if the remote integration history changes again.

## Breaking Change

No.

## Backport Target

None.
