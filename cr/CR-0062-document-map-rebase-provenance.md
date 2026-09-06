# CR-0062: Refresh Document Map CR provenance after remote rebase

Base: main
Head or Range: chore/release-v0-3-26
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: chore(cr): refresh Document Map CR provenance after remote rebase
Revision: 2
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: a10461f23d9c745d92ec09befec45aa213c390f7
Head OID: b25c81a4641137f58a37afdc4ac7b1902dd10d32
Integrated Result: pending
Coverage OIDs: 23e4945183fde5bfb3a68cd10cbbdd9d93c6bf34 bc19667f7a8fca2f9e132e02ab1390e7951c9fb5 be284844118caa0d3d60ceeb5a9b9c69fb4efe94 02a8da23497f7acd1e2dfcb48e255890e1f5cf53 fa4689827166a0fbdcf5572e34f1acb450e4e537 fdbfc5f90ab49ab363afcccedd934166a2915be8 c4be5e2a9bfebd7ec4dafe0ddc4bf42925876060

## Summary

Refresh CR-0060's head reference from an old local topic object to the
equivalent commit already reachable from the current remote `main` history.

## Motivation

The remote repository contains a signed rebase-equivalent history for the
Document Map governance changes. CR-0060 still named a local topic commit that
was not present when the bare-Git and clean-runner fixtures fetched only
`main`, causing otherwise valid CR validation to fail. The seven historical
first-parent commits listed in `Coverage OIDs` are the related Document Map
and adapter follow-up commits that were not named by an earlier CR record.

## Test Evidence

Run the bare-Git update fixture, PR/CR adapter fixture, CR validation,
repository validation, `scripts/validate_cr_coverage.sh HEAD`, and full
release preflight after the provenance update.

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
