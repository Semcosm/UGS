# CR-0025: Release v0.3.3 profile clarification

Base: main
Head or Range: docs/v0-3-3-release / 9afa382..HEAD
Title: docs(release): publish v0.3.3 profile clarification
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 9afa382e6a00e80a76fc5c85625ac6cbd2b3aab0
Head OID: 9afa382e6a00e80a76fc5c85625ac6cbd2b3aab0
Integrated Result: pending

## Summary

Add the v0.3.3 patch release notes for the adopted profile documentation.

## Motivation

The v0.3 profile boundary is now documented, and a patch release keeps the
published release record aligned with the active specification.

## Test Evidence

Run `scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, all CR
validators, and `scripts/validate_release_tag.sh v0.3.3` after tag creation.

## Risk

This is a documentation-only patch and does not change validator behavior or
accepted history.

## Rollback

Do not replace the tag. Publish a superseding patch release if needed.

## Breaking Change

No. This release clarifies the existing v0.3 profile boundary.

## Backport Target

None; this is a v0.3 patch release.
