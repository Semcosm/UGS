# CR-0049: Prepare the v0.3.22 release

Base: main
Head or Range: docs/release-v0-3-22-cr
Integration Strategy: rebase-ff
Title: docs(release): prepare v0.3.22 release
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 99d7c36c4779cf3295cbd4a1eb2c1b1899c06f3b
Head OID: 99d7c36c4779cf3295cbd4a1eb2c1b1899c06f3b
Integrated Result: pending

## Summary

Add release notes for v0.3.22, documenting the persisted CR requirement and
profile conformance release-consumer verification.

## Motivation

The release tag validator requires a matching release-notes artifact, and the
release package must identify the governance behavior being published.

## Test Evidence

Run `scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, and the
release workflow consumer validation after the annotated tag is published.

## Risk

Documentation-only release metadata; no runtime or policy implementation is
changed by this release-notes change.

## Rollback

Do not delete or replace an existing tag. Publish a superseding patch release
and preserve this record.

## Breaking Change

No.

## Backport Target

None.
