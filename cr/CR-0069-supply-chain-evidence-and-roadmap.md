# CR-0069: Upgrade supply-chain assurance with v0.3.28 evidence

Base: main
Head or Range: chore/supply-chain-evidence / 0a4d508..ebca89f
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(supply-chain): publish v0.3.28 provenance evidence
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 0a4d5088866008b912235ab83b048e5950ea5058
Head OID: ebca89f2cee03a1300ad3de1a4a6f8ea6eab4f00
Integrated Result: pending

## Summary

Upgrade the active supply-chain declaration from `basic` to `high-trust` and
publish real evidence for the signed v0.3.28 release. The evidence consists of
an SPDX SBOM, a deterministic build record, and an SSH-signed release
attestation. Clean up the v0.3 roadmap sentence that still described the
already-implemented P2 supply-chain and repository-shape capabilities as
pending.

## Motivation

The repository already had the high-trust commit and release-signing
foundations, full-SHA GitHub Actions pinning, and validators for SBOMs, build
records, and attestations, but its active supply-chain profile remained
`basic` without release evidence. The v0.3.28 bootstrap archive is a stable
release target for establishing the first complete evidence set. Two builds
with `SOURCE_DATE_EPOCH=0` produced the same SHA-256 digest, so the active
declaration can truthfully require verified reproducibility.

## Test Evidence

The v0.3.28 archive was built twice from signed commit
`ded9bc0f6b9dd519473ba5e33367e3ee80fd62f6`; both runs produced
`sha256:51291747b9378313f73c25ec867ce6972b323fba99cad99af6d4cedb869f7c8a`.
The SPDX SBOM, build record, and `ugs-attestation` SSH signature all bind that
release, commit, and digest. These checks pass:

- `scripts/validate_policy_manifest.sh .ugs/policy.json`
- `scripts/validate_supply_chain_profile.sh .ugs/policy.json`
- `scripts/validate_supply_chain_evidence.sh .ugs/policy.json`
- `scripts/validate_supply_chain_release.sh v0.3.28 .ugs/policy.json Semcosm/UGS`
- `adapters/github/validate_action_pinning.sh .ugs/policy.json .github/workflows`
- `scripts/validate_document_map.py`

## Risk

The active policy now requires future release evidence to meet the high-trust
contract; a release without a matching SBOM, build record, and signed
attestation will fail tag validation. The current evidence is local-builder
provenance for the already-published v0.3.28 archive, not a claim of a hosted
CI build. Existing immutable release tags and commit history are unchanged.

## Rollback

If the upgrade is rejected, revert these signed topic commits through a new CR
or restore the pre-integration `basic` policy and remove the three v0.3.28
evidence files in a reviewed change. Do not delete or replace the immutable
v0.3.28 tag or its signed artifact.

## Breaking Change

No runtime or Git integration behavior changes. This is a governance-level
profile strengthening: release validation becomes stricter for future tagged
releases, and the existing v0.3.28 release now has the required evidence.

## Backport Target

None.
