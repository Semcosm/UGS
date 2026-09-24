# CR-0074: Add the canonical UGS change request model

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: chore/v0-5-cr-model / 6e60dbcc98f9d8eb2ec57e9c389c7304e1977f66..1158349418bea64bfe5f12359386f967c5e58396
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Add the canonical UGS change request model
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: 6e60dbcc98f9d8eb2ec57e9c389c7304e1977f66
Head OID: 1158349418bea64bfe5f12359386f967c5e58396
Integrated Result: main@1158349418bea64bfe5f12359386f967c5e58396
Coverage OIDs: none
Extensions: {}

## Summary

Define the portable `ugs-cr/v1` change-request representation as a canonical
flat Markdown record with a deterministic JSON projection and SHA-256 binding.
Distribute the schema, parser, fixtures, documentation, and bootstrap wiring,
and keep the historical `ugs-cr/legacy-v0` records readable without rewriting
them.

## Motivation

The repository has accumulated CR records consumed by Bash validators, Python
conformance checks, GitHub adapters, and bootstrap packages. Without one
lossless representation and projection, those consumers can disagree about
field meaning, ordering, lifecycle, or evidence identity. This change provides
one offline contract while leaving reviewer attestations and supply-chain
evidence upgrades for later CRs.

## Test Evidence

Passed `scripts/ugs_check.sh --format json` with `result: pass`, including
repository validation, CR model and independent conformance fixtures, profile
conformance, Git fixture checks, bootstrap equivalence/package/upgrade tests,
document-map validation, and all supply-chain fixture checks. Also passed
`scripts/validate_commit_signatures.sh main..HEAD`, Python syntax checks, and
`git diff --check`. The reference and independent projections match for all
73 historical CR records and the published v1 fixtures.

## Risk

The CR validator and consumers now use the canonical parser, so malformed or
noncanonical v1 records that previously passed may be rejected. Legacy-v0
records retain their historical acceptance path. The active supply-chain
profile remains `basic`; this CR does not claim SBOM, build-record, or release
attestation evidence.

## Rollback

Revert the signed implementation and CR commits through a new reviewed CR, or
restore the repository to Base OID
`6e60dbcc98f9d8eb2ec57e9c389c7304e1977f66`. Retain this record as append-only
audit evidence if a replacement CR is needed.

## Breaking Change

No. The v1 record format is additive, legacy records remain parseable, and
existing policy, integration, and supply-chain profile levels are unchanged.

## Backport Target

None.
