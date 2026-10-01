# CR-0084: Publish v0.3.30 supply-chain evidence

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: chore/supply-chain-v0-3-30 / 6e1663d29f19ff8780d7e16ef41346a0fd303423..8b251598199b43e6e2677342cbbfbc40fdbe43cd
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Publish v0.3.30 supply-chain evidence
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: 6e1663d29f19ff8780d7e16ef41346a0fd303423
Head OID: 8b251598199b43e6e2677342cbbfbc40fdbe43cd
Integrated Result: main@8b251598199b43e6e2677342cbbfbc40fdbe43cd
Coverage OIDs: none
Extensions: {}

## Summary

Publish the real v0.3.30 release evidence after the immutable signed tag was
created. Add the SPDX SBOM, deterministic build record, and signed
ugs-attestation for the published bootstrap archive, and restore the active
policy to high-trust with v0.3.30 evidence paths.

## Motivation

The v0.3.30 tag target intentionally used the valid basic profile without
evidence paths because evidence that names the tag target commit cannot be
committed into that same commit without a hash cycle. The tag is now immutable,
so the evidence can be generated against its exact target and recorded on
main without changing the published asset.

## Test Evidence

The signed annotated v0.3.30 tag resolves to
6e1663d29f19ff8780d7e16ef41346a0fd303423. Two independent
SOURCE_DATE_EPOCH=0 builds from that tag produced the identical archive
digest sha256:8fd6ce87b060be3d9fce7448340226d4634db0189f97ae0c41dcede312c60ff3,
matching the published GitHub release asset. The evidence files bind that tag,
commit, and digest:

- .ugs/supply-chain/v0.3.30.spdx.json
- .ugs/supply-chain/v0.3.30.build.json
- .ugs/supply-chain/v0.3.30.attestation.json

The SBOM, build record, SSH attestation, high-trust policy/evidence paths,
scripts/validate_release_tag.sh v0.3.30,
scripts/validate_supply_chain_release.sh v0.3.30 .ugs/policy.json Semcosm/UGS,
and repository validation all pass. The attestation is signed by the trusted
chenzhipeng.main@gmail.com signer in the ugs-attestation namespace.

## Risk

The immutable tag checkout remains a documented staging profile and must not be
described as evidence-complete high-trust. The active main policy is now
high-trust and validates the post-tag evidence; its provenance is a local
builder record, not a claim of hosted CI signing. Historical v0.3.29 evidence
is retained but is not declared as active.

## Rollback

Do not delete, replace, or force-update v0.3.29 or v0.3.30, and do not
rewrite the published archive. If the evidence or policy update is defective,
retain the immutable tag and evidence audit record, then revert or supersede
the active declaration through a new signed CR and later release.

## Breaking Change

No. This restores the intended high-trust declaration on main and adds
release evidence without changing consumer commands or branch governance.

## Backport Target

None.
