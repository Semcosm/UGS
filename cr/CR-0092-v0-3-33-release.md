# CR-0092: Prepare the v0.3.33 hosted rebase provenance release

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: main / 753ee0bae2856c8a3f6da5480b7f835621e3c5ad
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Prepare the v0.3.33 hosted rebase provenance release
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: f4248044f320c7c49ad0089f751fcec43fbd3f92
Head OID: 753ee0bae2856c8a3f6da5480b7f835621e3c5ad
Integrated Result: main@753ee0bae2856c8a3f6da5480b7f835621e3c5ad
Coverage OIDs: none
Extensions: {}

## Summary

Prepare the v0.3.33 release packet for the hosted rebase provenance and
metadata-only CR closure improvements.

## Motivation

The implementation is complete and integrated on `main`; a signed patch release
provides a stable bootstrap package and documents the updated Core behavior.

## Test Evidence

The release packet includes the focused hosted-rebase fixtures, current
conformance and repository checks, bootstrap package checks, and signed commit
range validation. The release tag and post-tag artifact evidence are validated
as separate immutable steps.

## Risk

The release changes provenance validation and documentation while retaining
strict signatures, trailers, protected refs, and rollback behavior.

## Rollback

Retain the append-only tag and publish a later signed patch if the packet or
bootstrap artifact is defective. Consumers can continue using v0.3.32.

## Breaking Change

No.

## Backport Target

None.
