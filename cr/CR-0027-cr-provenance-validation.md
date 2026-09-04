# CR-0027: Validate CR integrated provenance

Base: main
Head or Range: feat/p1-cr-provenance / 65d572c..HEAD
Title: feat(cr): validate integrated provenance
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 65d572cb22579478f825493fd9fdd9e029ec34f9
Head OID: 65d572cb22579478f825493fd9fdd9e029ec34f9
Integrated Result: pending

## Summary

Require every non-pending CR integrated result to be a full commit reachable
from `main` and descended from the CR's base object. Add a negative fixture for
an unrelated integrated result.

## Motivation

CR records already identify source and integration objects, but the validator
previously checked only that those objects existed. Reachability checks make
the provenance claim independently auditable while allowing merge and squash
to produce a result different from the source head.

## Test Evidence

Run `scripts/test_cr_provenance.sh`, `scripts/validate_repo.sh`,
`scripts/ugs_check.sh --format json`, all CR validators, and the recovered
boundary signature validator.

## Risk

An archived CR with a stale or unrelated integrated result is now rejected.
Existing accepted history is not rewritten; all current records pass.

## Rollback

Supersede this CR with a new signed CR if the provenance model changes. Do not
rewrite protected history.

## Breaking Change

Yes for malformed or stale v0.3 CR records that claim an unreachable
integrated result.

## Backport Target

None; this is P1 provenance work.
