# CR-0067: Prepare the v0.3.28 standalone licensing release

Base: main
Head or Range: chore/establish-layered-licensing / 32057d8..33c90bf
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(release): prepare v0.3.28 licensing release
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 32057d8a031d5b07a971f5dfe8f6093f46dd0dcd
Head OID: 33c90bf44d3ea734f441dc4a5a247da85fac0b82
Integrated Result: pending

## Summary

Publish the UGS v0.3.28 standalone patch release for the layered licensing
change. The release packet documents the Apache-2.0 implementation scope and
CC BY 4.0 documentation scope, and identifies the official license source
texts included in the bootstrap distribution.

## Motivation

The licensing change is intentionally released independently from the prior
v0.3.27 bootstrap release. A dedicated signed patch tag gives consumers an
immutable version at which the new license notice, official source texts, and
bootstrap propagation behavior can be adopted and verified.

## Test Evidence

The licensing implementation passed `scripts/validate_repo.sh`,
`scripts/ugs_check.sh --format json`, `scripts/test_bootstrap_package.sh`,
`scripts/test_bootstrap_upgrade.sh`, `scripts/test_bootstrap_equivalence.sh`,
`scripts/test_profile_conformance.sh`, `scripts/test_conformance.sh`,
`scripts/test_git_fixtures.sh`, and `scripts/validate_document_map.py`.
Release preparation additionally requires the v0.3.27-to-HEAD commit-message
and trusted-signature checks, CR coverage validation, local package build, and
signed annotated tag validation for v0.3.28.

## Risk

Low. This is an additive patch release and does not change branch governance,
the active profile, or any existing immutable release tag. The package adds
license materials and preserves the consumer project's independent license
choice.

## Rollback

Do not delete, replace, or force-update v0.3.27 or v0.3.28. If the release
packet or generated bootstrap asset is defective, leave the tag immutable and
publish a later superseding signed patch release. Consumers can continue using
v0.3.27 or restore an installation from the backup created by `scripts/ugs.sh`.

## Breaking Change

No. The release changes license notices and distribution contents only; UGS
branch, review, signing, and integration behavior remain unchanged.

## Backport Target

None.
