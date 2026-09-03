# CR-0013: Add strict CR and review evidence checks

Base: main
Head or Range: feat/v0-3-draft-3-cr-evidence / 71b9f777..780434e
Title: feat(review): add strict CR and review evidence checks
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3-draft-3
Base OID: 71b9f777e866851bb2b3a0b22d23fea8c794d3dd
Head OID: 780434e807be9e9907232249b6b003aa81381a14
Integrated Result: pending

## Summary

Replace legacy CR validation with strict revision, policy-version, and exact
Git object identity fields. Add draft review trailer validation and fixtures.

## Motivation

An archived CR must identify the exact proposed object range and its current
review state without relying on branch-name or substring interpretation.

## Test Evidence

Run `scripts/test_review_trailers.sh`, `scripts/ugs_check.sh`,
`scripts/validate_repo.sh`, and every CR validator. All migrated CR records
validate with full object IDs and the review fixtures reject incomplete
trailers.

## Risk

This is a deliberate pre-1.0 format cutover. Existing CR records are migrated
in place, and draft-3 fields may still change before v0.3 adoption.

## Rollback

Revert the draft-3 commits and restore the prior CR record format through a new
signed CR if the strict model proves unsuitable.

## Breaking Change

Yes for draft CR tooling: records without the new evidence fields are rejected.
This is not applied to v0.2 history as a retroactive policy judgment.

## Backport Target

None; this is v0.3 draft work.
