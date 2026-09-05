# CR-0034: Define optional quality profile

Base: main
Head or Range: feat/p2-quality-profile / v0.3.5..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(policy): define optional quality profile
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 6d8cbaa7bb61d489418ade33af9e09404cf1b5e0
Head OID: 6d8cbaa7bb61d489418ade33af9e09404cf1b5e0
Integrated Result: pending

## Summary

Add optional `basic` and `standard` quality profile declarations, schema
support, a reference validator, fixtures, and normative documentation.

## Motivation

The v0.3 Core governs Git evidence but does not describe repository quality
entry points or operator-facing documents. An opt-in profile makes these
expectations machine-checkable without burdening Core adopters.

## Test Evidence

Run `scripts/validate_repo.sh`, `scripts/test_policy_manifest.sh`,
`scripts/validate_quality_profile.sh`, and `scripts/ugs_check.sh --format json`.

## Risk

Repositories opting into `standard` must provide additional operator-facing
documents. The profile is optional, so existing v0.3 repositories are not
invalidated.

## Rollback

Supersede this CR with a new signed CR if quality profile semantics change.
Do not rewrite accepted v0.2 history or published release tags.

## Breaking Change

No for Core conformance; opt-in repositories may receive new validation
failures when their declared quality requirements are incomplete.

## Backport Target

None; this is optional v0.3 P2 profile work.
