# CR-0083: Prepare the v0.3.30 staging release

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: docs/post-v0-3-29-tag-audit / a33eea7eb9728e9854473c86186c08655f545b94..d24e10faf70217a80f37ac5eac6c15e1af928379
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Prepare the v0.3.30 staging release
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: a33eea7eb9728e9854473c86186c08655f545b94
Head OID: d24e10faf70217a80f37ac5eac6c15e1af928379
Integrated Result: pending
Coverage OIDs: none
Extensions: {}

## Summary

Prepare the signed v0.3.30 governance release packet and its immutable staging
tag target. Close the post-v0.3.29 documentation audit, reserve v0.3.31 for
branch closure, and document the temporary basic supply-chain state required
before post-tag evidence can bind the release to its target commit.

## Motivation

The repository is ready to close the v0.3.30 documentation boundary before
starting the v0.3.31 branch-closure implementation. The current high-trust
policy still names v0.3.29 evidence, so the v0.3.30 tag target must use the
validated basic profile without evidence paths. A follow-up signed evidence
CR will restore high-trust on main after the immutable tag exists.

## Test Evidence

The staging target must pass repository, policy, profile, conformance,
bootstrap, document-map, CR coverage, commit-range, and trusted-signature
checks before integration. After publication, validate the annotated signed
tag and run the post-tag evidence CR with two deterministic bootstrap builds,
matching digests, a signed ugs-attestation, and
scripts/validate_supply_chain_release.sh v0.3.30 .ugs/policy.json Semcosm/UGS.

## Risk

The immutable v0.3.30 tag target is a documented basic staging profile and is
not evidence-complete high-trust. Consumers must rely on the post-tag evidence
CR and its validation on main for the active v0.3.30 supply-chain declaration.
The v0.3.29 tag and evidence remain unchanged.

## Rollback

Do not delete, replace, or force-update the v0.3.29 or v0.3.30 tags. If the
staging target or packet is defective, leave the immutable tag untouched and
publish a later signed superseding patch through a new CR. If the post-tag
evidence update fails, retain this record and the tag and retry through a
separate signed evidence CR.

## Breaking Change

No. The release packet and staging policy are documentation and release-boundary
changes only; runtime commands and consumer branch governance are unchanged.

## Backport Target

None.
