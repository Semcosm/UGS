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
Extensions: {"x-fixture":{"name":"canonical"}}

## Summary

Exercise a canonical Markdown CR record and its JSON projection.

## Motivation

Ensure offline consumers share one unambiguous CR reader.

## Test Evidence

The parser renders this fixture byte-for-byte.

## Risk

Fixture-only behavior.

## Rollback

Remove the fixture with the feature that introduced it.

## Breaking Change

No.

## Backport Target

None.
