# CR-0031: Release v0.3.4 P1 evidence capabilities

Base: main
Head or Range: docs/v0-3-4-release / 5fa5249..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(release): publish v0.3.4 P1 evidence capabilities
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 5fa5249bb4df2961178bafa754c4e0325fee380d
Head OID: 5fa5249bb4df2961178bafa754c4e0325fee380d
Integrated Result: pending

## Summary

Add the v0.3.4 release packet for the completed P1 conformance, provenance,
review inheritance, and signer lifecycle capabilities.

## Motivation

The current `main` contains the completed P1 evidence surface but the latest
published release is v0.3.3. A formal packet provides a stable verification
and compatibility boundary.

## Test Evidence

Run `scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, all CR
validators, and `scripts/validate_release_tag.sh v0.3.4` after tag creation.

## Risk

This is pre-1.0 v0.3 work. New CR metadata and signer lifecycle validation may
require migration for consumers of earlier v0.3 drafts.

## Rollback

Do not replace the tag. Publish a superseding patch release if the packet or
verification guidance needs correction.

## Breaking Change

Yes for consumers that do not support the new v0.3 P1 evidence metadata.

## Backport Target

None; this is a v0.3 P1 release.
