# CR-9002: Canonical CR model fixture

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: test/cr-model / 1111111111111111111111111111111111111111..2222222222222222222222222222222222222222
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Canonical CR model fixture
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 1111111111111111111111111111111111111111
Head OID: 2222222222222222222222222222222222222222
Integrated Result: pending
Coverage OIDs: none
Extensions: { "x-fixture": { "name": "canonical" } }

## Summary

Noncanonical extension JSON must fail.

## Motivation

Exercise canonical JSON rendering.

## Test Evidence

None.

## Risk

None.

## Rollback

Remove the fixture.

## Breaking Change

No.

## Backport Target

None.
