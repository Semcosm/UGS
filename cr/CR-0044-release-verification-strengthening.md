# CR-0044: Strengthen release evidence verification

Base: main
Head or Range: fix/p2-release-verification / 4c145ce..main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: fix(policy): strengthen release evidence verification
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: b5b20086b86d81d8cc2ab1f11ba63f7117ed5c63
Head OID: 52ac3d160de4e8bd03707a41bfd42338c6f6e460
Integrated Result: main@52ac3d160de4e8bd03707a41bfd42338c6f6e460

## Summary

Make release evidence validation self-contained and cross-bind the repository,
release tag, commit, artifact digest, and version across SBOM, build-record,
and attestation evidence. Add JSON Schema constraints, actual workflow action
pinning validation, and disposable release evidence fixtures.

## Motivation

The previous release validator could rely on an earlier validator invocation
and did not independently reject empty elevated-profile evidence. Attestation
repository identity and cross-file artifact digest consistency also needed to
be enforced at the release boundary.

## Test Evidence

Run `scripts/validate_repo.sh` and `scripts/ugs_check.sh --format json`; both
passed. The release fixture covers SPDX and CycloneDX SBOMs, a build record,
an SSH-signed attestation, matching tag/commit/digest metadata, and a failure
case for mismatched evidence digests. Action pinning positive and negative
fixtures also passed. `git diff --check` passed.

## Risk

Repositories claiming `standard` or `high-trust` with incomplete evidence,
unbound repositories, or inconsistent artifact digests will fail validation.
The current declaration-only `basic` repository remains valid. The GitHub
rebase integration object is tracked separately from the signed source commit
by CR-0045.

## Rollback

Supersede this CR with a later signed patch release if the verification
contract needs correction. Do not delete or replace published tags.

## Breaking Change

Yes for elevated profiles with incomplete or inconsistent release evidence;
no for repositories without supply-chain declarations or valid basic profiles.

## Backport Target

None; this is v0.3 verification-strengthening work.
