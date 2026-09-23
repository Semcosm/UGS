# CR-0072: Add stable error identifiers and JSON conformance reports

Base: main
Head or Range: chore/v0-4-error-contract / 5b6564a..89c7e34
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(conformance): add stable error and report contracts
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 5b6564ace5a5381c72f73fd4e12e31a49d4612f9
Head OID: 89c7e34e2efa2bdd1251e626e44bb69be597c0e2
Integrated Result: pending

## Summary

Add stable machine-readable error identifiers to the core Bash validators and
the independent Python conformance implementation. Define the shared
`ugs-error/v1` diagnostic object, reserve `UGS-0000` for success, and extend
`scripts/ugs_check.sh --format json` with `schema_version` and per-check codes
while preserving the `ugs-conformance/v0.3` report format. Include the shared
runtime in bootstrap initialization, package manifests, and source/package
equivalence checks. Document the report and diagnostic contracts in the v0.4
compatibility guide and its offline mirror.

## Motivation

Consumers currently have to parse human-readable validator output, which makes
cross-implementation automation brittle and allows Bash/Python conformance
drift to go unnoticed. Stable codes and a fixed report field set let CI and
offline tooling branch on contract identifiers instead of prose while keeping
the active v0.3 policy and wire values unchanged.

## Test Evidence

Passed `scripts/test_conformance.sh`, `scripts/test_bootstrap_equivalence.sh`,
`scripts/test_bootstrap_package.sh`, `scripts/test_bootstrap_upgrade.sh`,
`scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, and
`git diff --check`. The JSON report returned `result: pass`; profile, SBOM,
build-record, attestation, CR, document-map, and repository-shape fixtures all
passed.

## Risk

Low to moderate. Existing text diagnostics remain available, but scripts and
fixtures now depend on the stable code mappings and the bootstrap package must
install the shared error runtime in every profile. A mismatch between a
validator's code and the independent implementation could affect automation, so
the Bash/Python fixture comparison and bootstrap equivalence checks are part of
the change.

## Rollback

Revert the signed implementation commit through a reviewed CR, or restore the
checkout to Base OID `5b6564ace5a5381c72f73fd4e12e31a49d4612f9`. Keep the CR as an
append-only audit record and publish a replacement compatibility decision if
the report shape or code registry is superseded.

## Breaking Change

No. The active `ugs-policy/v0.3` manifest contract, accepted policy values,
validator exit behavior, and text diagnostics remain compatible. The JSON
report gains explicitly versioned fields and machine-readable codes.

## Backport Target

None.
