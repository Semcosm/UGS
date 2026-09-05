# CR-0043: Require evidence for elevated supply-chain profiles

Base: main
Head or Range: fix/p2-evidence-required / v0.3.14..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: fix(policy): require evidence for elevated profiles
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: b95c3d704d54812612cdd9abf4734c9174c7aa66
Head OID: b95c3d704d54812612cdd9abf4734c9174c7aa66
Integrated Result: pending

## Summary

Require `standard` and `high-trust` supply-chain declarations to include
traceable SBOM and build-record evidence paths, with an attestation path also
required for `high-trust`.

## Motivation

Previously, an elevated profile could pass the profile declaration checks while
omitting the evidence needed to substantiate its stronger guarantees. Align the
manifest validator, profile validator, evidence validator, and release path.

## Test Evidence

Run `scripts/test_policy_manifest.sh`,
`scripts/test_supply_chain_evidence.sh`, `scripts/validate_repo.sh`, and
`scripts/ugs_check.sh --format json`. Cover omitted supply-chain declarations,
basic declaration-only mode, missing elevated-profile evidence, valid paths,
and traversal paths.

## Risk

Existing repositories claiming `standard` or `high-trust` without evidence
paths will fail validation and must add the required declarations. The current
basic declaration-only repository remains valid.

## Rollback

Supersede this CR with a later signed patch release if the evidence contract
needs correction. Do not delete or replace published tags.

## Breaking Change

Yes for elevated profiles that omitted required evidence paths; no change for
repositories without supply-chain declarations or for basic declaration-only
profiles.

## Backport Target

None; this is a v0.3 supply-chain policy correction.
