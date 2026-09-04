# CR-0032: Define exception lifecycle records

Base: main
Head or Range: feat/p1-exception-lifecycle / 0cf2f1b..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(policy): define exception lifecycle records
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 0cf2f1bf8d2a24c28440893e77fe90259d4da6f1
Head OID: 0cf2f1bf8d2a24c28440893e77fe90259d4da6f1
Integrated Result: pending

## Summary

Add append-only `cr/EX-*.md` exception records and validate authorization,
reason, bounded timestamps, event OID, post-event review, and one-time
bootstrap use.

## Motivation

The emergency path previously relied on environment variables and prose. A
structured record makes exceptions attributable, time-bounded, and auditable.

## Test Evidence

Run `scripts/validate_exception_record.sh`, `scripts/test_exception_records.sh`,
`scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, and all CR
validators.

## Risk

Exception records with missing authorization, invalid windows, or incomplete
post-event review are rejected. Existing bootstrap history is recorded as one
closed exception.

## Rollback

Supersede this CR with a new signed CR if exception semantics change. Preserve
historical exception records and do not rewrite protected history.

## Breaking Change

Yes for v0.3 repositories that claim emergency capability without valid
exception records.

## Backport Target

None; this is P1 exception lifecycle work.
