# CR-0051: Prepare the v0.3.23 release

Base: main
Head or Range: chore/release-v0-3-23-cr
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(release): prepare v0.3.23 release
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: c42fde8e8f080ace30a01e763e929a6a1af63009
Head OID: c42fde8e8f080ace30a01e763e929a6a1af63009
Integrated Result: pending

## Summary

Add release notes for v0.3.23, documenting the bootstrap release-consumer
verification fix.

## Motivation

The v0.3.22 release workflow exposed that clean-runner consumers do not carry
the repository's conformance test scripts. The patch release must publish the
corrected release verification harness without replacing the existing tag.

## Test Evidence

Run repository validation, CR validation, signed commit validation, and the
release workflow consumer validation after the annotated tag is published.

## Risk

Low. This release adds release notes and publishes the already reviewed
release-consumer test fix from v0.3.22's successor commit.

## Rollback

Do not delete or replace an existing tag. If needed, publish a superseding
patch release and preserve this record.

## Breaking Change

No.

## Backport Target

None.
