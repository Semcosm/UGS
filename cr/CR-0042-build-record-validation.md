# CR-0042: Validate build records in release evidence

Base: main
Head or Range: feat/p2-build-record / v0.3.13..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(policy): validate build records
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 73f2a774fa599229a876d4289f0f5cceb2440569
Head OID: 73f2a774fa599229a876d4289f0f5cceb2440569
Integrated Result: pending

## Summary

Add build-record validation and bind build records to release tags, commits,
and artifact digests alongside SBOMs and attestations.

## Motivation

Release provenance is incomplete if an attestation exists but the build record
cannot be independently checked for the same release identity.

## Test Evidence

Run `scripts/test_build_record.sh`, `scripts/validate_repo.sh`, and
`scripts/ugs_check.sh --format json`.

## Risk

Evidence-enabled profiles may reject records with mismatched release identity.
Declaration-only profiles remain unaffected.

## Rollback

Supersede this CR with a new signed CR if build-record semantics change; do not
rewrite published tags.

## Breaking Change

No for declaration-only repositories; evidence-enabled profiles gain checks.

## Backport Target

None; this is optional v0.3 supply-chain profile work.
