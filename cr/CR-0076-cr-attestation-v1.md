# CR-0076: Define signed CR reviewer and test attestations

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: feat/cr-attestation-v1 / 64d1315953419e06fb9c2ba9ef56f29a28c3d727..26dd8447d6b51e059543a02441cc56e47e962f11
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Define signed CR reviewer and test attestations
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: 64d1315953419e06fb9c2ba9ef56f29a28c3d727
Head OID: 26dd8447d6b51e059543a02441cc56e47e962f11
Integrated Result: main@26dd8447d6b51e059543a02441cc56e47e962f11
Coverage OIDs: none
Extensions: {}

## Summary

Define the optional `ugs-cr-attestation/v1` evidence contract for signed
reviewer and test conclusions about canonical `ugs-cr/v1` change requests. Add
deterministic JSON canonicalization, detached SSH signatures with separate
review and test namespaces, exact CR source and integrated-result bindings,
signer role windows, key rotation, revocation handling, fixtures, and
bootstrap distribution.

## Motivation

The canonical CR model now provides a stable binding, but it does not define a
portable wire format for independently signed review and test conclusions.
Without explicit namespaces, principal and role checks, validity boundaries,
and stale-result behavior, consumers could mistake mutable hosting approvals or
release attestations for CR evidence. This contract makes the evidence
verifiable offline while keeping the existing trailer gate authoritative.

## Test Evidence

Passed `scripts/test_cr_attestation.sh`, including signed review and test
fixtures, source-scope validation, role and principal mismatch cases, exact CR
binding checks, canonical payload output, key rotation, raw-key and SSH KRL
revocation, and historical evidence handling. Also passed
`scripts/test_signer_roles.sh`, `scripts/validate_repo.sh`,
`scripts/ugs_check.sh --format json` with `result: pass`, document-map and
bootstrap equivalence/package/upgrade checks, conformance and profile fixtures,
and `git diff --check`.

## Risk

The feature is additive and opt-in. It introduces a new strict validator and
two SSH namespaces, but does not replace commit trailers, alter release
attestation semantics, or add CR namespaces to the trusted signer registry.
Signer-role rotation and revocation checks can reject stale or misbound
evidence, while historical evidence remains auditable by its issued time. The
active supply-chain profile and its evidence level are unchanged.

## Rollback

Revert the signed implementation and CR commits through a new reviewed CR, or
restore the repository to Base OID
`64d1315953419e06fb9c2ba9ef56f29a28c3d727`. Keep any already-published
attestation objects as append-only historical evidence; do not rewrite signer
or CR records.

## Breaking Change

No. The contract, schema, validator, and bootstrap components are additive;
legacy CR records, existing trailer review gates, and supply-chain
attestations remain unchanged.

## Backport Target

None.
