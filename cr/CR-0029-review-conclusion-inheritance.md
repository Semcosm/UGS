# CR-0029: Validate review conclusion inheritance

Base: main
Head or Range: feat/p1-review-inheritance / f083c43..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(review): validate final review conclusion inheritance
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: f083c43b595d7b47e99a1ffa3ea9b25ffc9da322
Head OID: f083c43b595d7b47e99a1ffa3ea9b25ffc9da322
Integrated Result: pending

## Summary

Require new CRs claiming trailer review evidence to carry both `Reviewed-by`
and `Tested-by` on the final integrated commit, regardless of whether the
integration used rebase-ff, merge, or squash.

## Motivation

Review trailers on source commits can disappear during rebase or squash. The
final integrated object must carry the authoritative conclusion that remains
auditable after the source history is no longer the protected result.

## Test Evidence

Run `scripts/test_cr_review_inheritance.sh`, `scripts/validate_repo.sh`,
`scripts/ugs_check.sh --format json`, and all CR validators.

## Risk

New CRs claiming trailer evidence without final review and test trailers are
rejected. Historical CRs remain grandfathered.

## Rollback

Supersede this CR with a new signed CR if the review evidence model changes.
Do not rewrite protected history.

## Breaking Change

Yes for new v0.3 CRs that claim trailer evidence but omit final conclusions.

## Backport Target

None; this is P1 review provenance work.
