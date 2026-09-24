# CR-9004: Legacy invalid status fixture

Base: main
Head or Range: fixture-head
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Legacy invalid status fixture
Revision: 1
Status: undecided
Decision: pending
Policy Version: v0.3
Base OID: 1111111111111111111111111111111111111111
Head OID: 2222222222222222222222222222222222222222
Integrated Result: pending

## Summary

Legacy records still validate their declared lifecycle fields.

## Motivation

Exercise independent legacy-v0 validation.

## Test Evidence

This fixture must be rejected by both implementations.

## Risk

Fixture-only behavior.

## Rollback

Remove the fixture.

## Breaking Change

No.

## Backport Target

None.
