# CR-0035: Define optional supply-chain profile

Base: main
Head or Range: feat/p2-supply-chain-profile / v0.3.6..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(policy): define optional supply-chain profile
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 23f893c3a5a6796b23ce6032258bda896650b704
Head OID: 23f893c3a5a6796b23ce6032258bda896650b704
Integrated Result: pending

## Summary

Add optional supply-chain declarations and validation for action pinning, SBOM,
reproducible builds, and release attestations.

## Motivation

UGS currently validates Git governance evidence but does not provide a
portable declaration for release provenance. This profile makes provenance
expectations explicit without prescribing a build ecosystem.

## Test Evidence

Run `scripts/validate_repo.sh`, `scripts/test_policy_manifest.sh`,
`scripts/validate_supply_chain_profile.sh`, and `scripts/ugs_check.sh --format json`.

## Risk

Higher profiles require stronger evidence that may need ecosystem-specific
tooling. The profile is optional and the reference validator checks only the
declared contract.

## Rollback

Supersede this CR with a new signed CR if supply-chain semantics change. Do
not rewrite accepted history or published release tags.

## Breaking Change

No for Core conformance; opt-in repositories may fail validation when their
declared provenance level is incomplete.

## Backport Target

None; this is optional v0.3 P2 profile work.
