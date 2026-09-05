# CR-0046: Publish the v0.3.17 bootstrap package release

Base: main
Head or Range: release/v0-3-17
Integration Strategy: rebase-ff
Title: docs(release): prepare v0.3.17 bootstrap package release
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: afec9df2f98f0375814518654eccdcdc82bd11f8
Head OID: 6190303f7d314dcf849db6b29c112748b4e3c2a5
Integrated Result: pending

## Summary

Prepare the first formal release that publishes the generated UGS baseline
empty-repository bootstrap package, its manifest, and its checksum.

## Motivation

UGS deployment and migration need a versioned package generated from the
release tag rather than a manually copied repository skeleton.

## Test Evidence

Local repository, conformance, bootstrap package, deterministic archive, and
release workflow validation passed. The tag workflow will run the remote
consumer test after publication.

## Risk

The package currently provides the baseline profile only. Existing repositories
are not modified; migration mode preserves existing files.

## Rollback

Do not delete or replace the release tag. Publish a superseding patch release
and leave this release available for audit.

## Breaking Change

No. The new `ugs-bootstrap/v1` package format is additive.

## Backport Target

None.
