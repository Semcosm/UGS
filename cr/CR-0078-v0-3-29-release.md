# CR-0078: Prepare the v0.3.29 governance release

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: chore/release-v0-3-29 / ee8527d95facce0c22e932dc0cb2dc4ec50f6b87..c9c3f0529e321838655f90ce393846ffadeb8c0d
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Prepare the v0.3.29 governance release
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: ee8527d95facce0c22e932dc0cb2dc4ec50f6b87
Head OID: c9c3f0529e321838655f90ce393846ffadeb8c0d
Integrated Result: pending
Coverage OIDs: none
Extensions: {}

## Summary

Prepare the signed v0.3.29 governance release packet and its immutable tag
target. Reconcile the delivered documentation and attestation status in the
release notes, and explicitly document the two-phase supply-chain evidence
publication required by the current validator contract.

## Motivation

The repository has completed the documentation reconciliation after CR-0076,
while the active main branch currently carries high-trust v0.3.28 evidence.
For v0.3.29, evidence that names the tag target commit cannot be committed
into that same target without a self-referential hash. The release therefore
needs a recorded staging boundary: the tag target temporarily uses the valid
basic profile without evidence paths, and a separate post-tag CR restores
high-trust with real v0.3.29 SBOM, build, and signed attestation evidence.

## Test Evidence

The topic must pass repository, policy, profile, conformance, bootstrap,
document-map, CR coverage, commit-range, and trusted-signature checks before
integration. The tag target must pass the release-tag validator and the
bootstrap package fixtures while its supply-chain profile is explicitly
basic. The follow-up evidence CR must build the v0.3.29 archive twice with
`SOURCE_DATE_EPOCH=0`, verify equal digests, validate all evidence files, and
pass `scripts/validate_supply_chain_release.sh v0.3.29 .ugs/policy.json
Semcosm/UGS` on `main`.

## Risk

The immutable v0.3.29 tag target is a documented staging profile and is not
evidence-complete high-trust. A consumer must not infer high-trust supply-
chain evidence from the tag checkout alone; the post-tag evidence CR and its
validation on `main` are required. Existing v0.3.28 evidence and release
objects remain unchanged.

## Rollback

Do not delete, replace, or force-update either immutable release tag. If the
release packet or staging target is defective, leave the tag untouched and
publish a later signed superseding patch through a new CR. If the post-tag
evidence update fails, retain this record and the tag, keep the main policy at
the last validated state, and retry through a separate signed evidence CR.

## Breaking Change

No. The release packet and status wording are additive. The temporary staging
profile is an explicitly recorded release-boundary procedure and does not
alter the consumer runtime or normal branch integration contracts.

## Backport Target

None.
