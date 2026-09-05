# CR-0040: Require cryptographic attestation verification

Base: main
Head or Range: fix/p2-attestation-signature / v0.3.11..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: fix(policy): verify signed release attestations
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: c9455bfa7f48a26a2645982daead493298c0b9f8
Head OID: c9455bfa7f48a26a2645982daead493298c0b9f8
Integrated Result: pending

## Summary

Verify SSH detached signatures over canonical attestation payloads and permit
the attestation namespace for the trusted release signer.

## Motivation

An attestation marked `verified` without cryptographic verification is only a
claim. Signed supply-chain profiles need an independently checkable proof.

## Test Evidence

Run `scripts/test_release_attestation.sh`, a real SSH-signed temporary
attestation verification, `scripts/validate_repo.sh`, and
`scripts/ugs_check.sh --format json`.

## Risk

Repositories with malformed or unverifiable signed attestations may fail
validation. Declaration-only profiles are unaffected.

## Rollback

Supersede this CR with a new signed CR if signature semantics change; never
rewrite published tags.

## Breaking Change

No for declaration-only repositories; signed evidence must now be genuinely
verifiable.

## Backport Target

None; this is a v0.3 supply-chain correctness patch.
