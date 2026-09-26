# CR-0079: Publish v0.3.29 supply-chain evidence

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: chore/supply-chain-v0-3-29 / 0a0278dd20394efcaf77b6f79859c5de8b0b38c7..18bd36d0ffc6a39b6cb10afcab0b65d262bd03e7
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Publish v0.3.29 supply-chain evidence
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: 0a0278dd20394efcaf77b6f79859c5de8b0b38c7
Head OID: 18bd36d0ffc6a39b6cb10afcab0b65d262bd03e7
Integrated Result: main@18bd36d0ffc6a39b6cb10afcab0b65d262bd03e7
Coverage OIDs: none
Extensions: {}

## Summary

Publish the real v0.3.29 release evidence after the immutable signed tag was
created. Add the SPDX SBOM and deterministic build record plus a signed
`ugs-attestation` for the published bootstrap archive, and restore the active
policy to `high-trust`. CR-0078 remains an accepted staging record until its
separate closure metadata is recorded after this evidence integration.

## Motivation

The v0.3.29 tag target intentionally used the valid `basic` profile without
evidence paths because the current builder embeds its source commit in the
archive manifest and the evidence must name both that commit and the archive
digest. Committing the evidence into the tag target would create a
self-referential hash cycle. The tag is now immutable, so the evidence can be
generated against its exact target and recorded on `main` without changing the
published asset.

## Test Evidence

The signed annotated tag `v0.3.29` resolves to
`0a0278dd20394efcaf77b6f79859c5de8b0b38c7`. Two independent
`SOURCE_DATE_EPOCH=0` builds from that detached tag produced the identical
archive digest
`sha256:c5387f414d1f66c1e3f28d68abf525c0b5960a1b6ec5f44e7e5abfe877a2b797`,
matching the GitHub release asset and sidecar checksum. The evidence files
bind that commit, tag, and digest:

- `.ugs/supply-chain/v0.3.29.spdx.json`
- `.ugs/supply-chain/v0.3.29.build.json`
- `.ugs/supply-chain/v0.3.29.attestation.json`

The SBOM, build record, SSH attestation, high-trust policy/evidence paths,
repository validation, bootstrap equivalence, and explicit
`scripts/validate_supply_chain_release.sh v0.3.29 .ugs/policy.json
Semcosm/UGS` check all pass. The attestation is signed by the trusted
`chenzhipeng.main@gmail.com` signer in the `ugs-attestation` namespace.

## Risk

The immutable tag checkout remains a documented staging profile and must not
be described as evidence-complete high-trust. The active `main` policy is now
high-trust and validates the post-tag evidence; its provenance is a local
builder record, not a claim of hosted CI signing. Historical v0.3.28 evidence
is retained but not declared as active.

## Rollback

Do not delete, replace, or force-update `v0.3.28` or `v0.3.29`, and do not
rewrite the published archive. If the evidence or policy update is defective,
retain the immutable tag and evidence audit record, then revert or supersede
the active declaration through a new signed CR and later release.

## Breaking Change

No. This restores the intended high-trust declaration on `main` and adds
release provenance after publication without changing runtime behavior, the
bootstrap archive, or branch integration contracts.

## Backport Target

None.
