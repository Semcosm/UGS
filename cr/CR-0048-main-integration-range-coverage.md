# CR-0048: Record generated commits from persisted CR integration

Base: main
Head or Range: generated integration commits from CR-0047
Integration Strategy: rebase-ff
Title: fix(governance): validate CR coverage across main integration ranges
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 33ad5d867d7fd6c9d7c32e62b843a42e42bd8653
Head OID: 33ad5d867d7fd6c9d7c32e62b843a42e42bd8653
Integrated Result: pending
Coverage OIDs: 5cb8a6afb080471e1b155f21077176262c89516f 33ad5d867d7fd6c9d7c32e62b843a42e42bd8653

## Summary

Record the generated integration commits produced when CR-0047 was merged and
enforce CR coverage for each future main integration range.

## Motivation

A hosting platform may create additional integration commits after the CR
commit itself. The authoritative main boundary must validate the whole pushed
range, while preserving the CR as the review source.

## Test Evidence

Run `scripts/validate_main_cr_range.sh`,
`scripts/validate_cr_coverage.sh origin/main`, and
`scripts/validate_repo.sh`.

## Risk

This adds a fail-closed main integration check and records only observed
generated commit OIDs.

## Rollback

Revert the validator change with a new accepted CR.

## Breaking Change

No. This enforces the persisted CR requirement already declared by CR-0047.

## Backport Target

None.
