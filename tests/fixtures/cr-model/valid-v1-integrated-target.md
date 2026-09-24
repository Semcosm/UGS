# CR-9003: Integrated target fixture

Format: ugs-cr/v1
Schema Version: 1
Base: release/foo
Head or Range: test/cr-model / 1111111111111111111111111111111111111111..2222222222222222222222222222222222222222
Integration Target: release/foo
Integration Strategy: rebase-ff
Review Evidence: none
Title: Integrated target fixture
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: 1111111111111111111111111111111111111111
Head OID: 2222222222222222222222222222222222222222
Integrated Result: release/foo@2222222222222222222222222222222222222222
Coverage OIDs: none
Extensions: {}

## Summary

Exercise an integrated result on a non-main target.

## Motivation

Integration targets are part of the v1 contract.

## Test Evidence

The independent and reference parsers agree.

## Risk

Fixture-only behavior.

## Rollback

Remove the fixture.

## Breaking Change

No.

## Backport Target

None.
