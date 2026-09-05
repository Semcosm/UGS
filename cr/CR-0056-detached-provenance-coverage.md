# CR-0056: Record coverage for detached provenance follow-up

Base: main
Head or Range: chore/record-cr-0056-coverage
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(cr): record detached provenance coverage
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: c841d7169a899812b20424e68a0285d582eabbe1
Head OID: c841d7169a899812b20424e68a0285d582eabbe1
Integrated Result: pending
Coverage OIDs: 37b2bc20810544da906e78172c9f27bdc79b184c

## Summary

Record the previously uncovered main integration commit that completed the
detached-checkout provenance fix associated with CR-0052.

## Motivation

The CR-first audit requires every first-parent main integration commit to be
covered by a persisted CR. The follow-up commit was part of the same change
but was not represented by CR-0052's original head field.

## Test Evidence

Run the full CR coverage validator and main integration range validator after
this record is integrated.

## Risk

Audit-only record; it changes no runtime behavior.

## Rollback

Preserve the audit history and correct it through a subsequent CR if needed;
do not rewrite the existing CR or release tag.

## Breaking Change

No.

## Backport Target

None.
