# CR-0030: Define signer lifecycle and review attestations

Base: main
Head or Range: feat/p1-signer-lifecycle / 014d1d0..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(trust): define signer lifecycle metadata
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 014d1d0075115dab1f47973a9aa4d59d7ed15b44
Head OID: 014d1d0075115dab1f47973a9aa4d59d7ed15b44
Integrated Result: pending

## Summary

Add signer role metadata with key fingerprints, effective dates, active/revoked
status, and validation against the allowed signer registry. Define reviewer
trailers as attestations bound to the final signed integration commit rather
than introduce a separate reviewer-signature wire format.

## Motivation

The v0.3 profile required trusted signers but did not make identity roles,
rotation, and revocation auditable as structured data. Independent reviewer
signatures also need an explicit boundary so trailer claims are not confused
with cryptographic signatures.

## Test Evidence

Run `scripts/validate_signer_roles.sh`, `scripts/test_signer_roles.sh`,
`scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, and all CR
validators.

## Risk

The new signer metadata is required for repository validation and rejects
unknown, duplicate, or date-incomplete entries. Existing trusted keys remain
unchanged.

## Rollback

Supersede this CR with a new signed CR that changes the signer metadata model.
Do not remove historical signer records or rewrite protected history.

## Breaking Change

Yes for v0.3 repositories that do not publish valid signer lifecycle metadata.

## Backport Target

None; this is P1 trust and attestation work.
