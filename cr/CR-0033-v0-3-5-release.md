# CR-0033: Release v0.3.5 exception lifecycle capabilities

Base: main
Head or Range: docs/v0-3-5-release / 0c1b061..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(release): publish v0.3.5 exception lifecycle capabilities
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 0c1b061681c1a61fd86af058a7d41c65677d6180
Head OID: 0c1b061681c1a61fd86af058a7d41c65677d6180
Integrated Result: pending

## Summary

Publish the v0.3.5 release packet for the completed P1 exception lifecycle
records, validators, and fixtures.

## Motivation

The exception lifecycle implementation is present on `main` but is not yet
covered by a formal release boundary. A patch release provides stable
verification and compatibility guidance.

## Test Evidence

Run `scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, all CR
validators, exception-record validators and fixtures, and
`scripts/validate_release_tag.sh v0.3.5` after tag creation.

## Risk

This is pre-1.0 v0.3 work. Repositories that claim emergency capability
without valid exception records may fail validation.

## Rollback

Do not replace the tag. Publish a superseding patch release if the packet or
verification guidance needs correction.

## Breaking Change

Yes for v0.3 consumers claiming emergency capability without exception
records that satisfy the adopted lifecycle rules.

## Backport Target

None; this is a v0.3 P1 release.
