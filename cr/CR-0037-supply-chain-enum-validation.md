# CR-0037: Align supply-chain enum validation

Base: main
Head or Range: fix/p2-supply-chain-enums / v0.3.8..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: fix(policy): align supply-chain enum validation
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 5a42ad36c30d8df5ebc75b176a9bae0fc685038c
Head OID: 5a42ad36c30d8df5ebc75b176a9bae0fc685038c
Integrated Result: pending

## Summary

Make the manifest and dedicated supply-chain validators reject values that are
valid only for a different supply-chain field.

## Motivation

The shared enum check could accept declarations that contradicted the schema,
creating inconsistent validation results.

## Test Evidence

Run `scripts/test_policy_manifest.sh`, `scripts/validate_repo.sh`, and
`scripts/ugs_check.sh --format json`, including the cross-field negative
fixture.

## Risk

Previously accepted malformed declarations may now fail validation. Correct
declarations are unaffected.

## Rollback

Supersede this CR with a new signed CR if validator behavior needs correction;
do not rewrite published tags.

## Breaking Change

No for valid manifests; malformed supply-chain declarations may be rejected.

## Backport Target

None; this is a v0.3 validator correction.
