# CR-0039: Validate release attestations

Base: main
Head or Range: feat/p2-release-attestation / v0.3.10..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(policy): validate release attestations
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 20b7269af774a740e8bc0a15f0d7387e9876b571
Head OID: 20b7269af774a740e8bc0a15f0d7387e9876b571
Integrated Result: pending

## Summary

Add a portable release-attestation structure and bind attestation metadata to
release tags, commits, and artifact digests.

## Motivation

SBOMs describe release contents, while attestations provide provenance for
the build that produced those contents. UGS needs a Git-native minimum before
ecosystem-specific adapters are added.

## Test Evidence

Run `scripts/test_release_attestation.sh`, `scripts/validate_repo.sh`, and
`scripts/ugs_check.sh --format json`.

## Risk

The reference validator checks structure, binding, and SSH detached
signatures. Sigstore, in-toto, or builder-specific adapters remain optional.

## Rollback

Supersede this CR with a new signed CR if attestation semantics change; do
not rewrite published tags.

## Breaking Change

No for declaration-only repositories; evidence-enabled profiles gain
attestation checks.

## Backport Target

None; this is optional v0.3 supply-chain profile work.
