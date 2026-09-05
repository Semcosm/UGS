# CR-0052: Establish the Core CR review and GitHub adapter boundary

Base: main
Head or Range: refactor/core-cr-adapter
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: refactor(core): isolate GitHub PR metadata from CR review validation
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 32e4575abee237d18f085887f4bd444f7c934186
Head OID: 32e4575abee237d18f085887f4bd444f7c934186
Integrated Result: pending

## Summary

Introduce a platform-neutral CR review validator and move GitHub PR event
translation and PR creation into an explicit GitHub adapter namespace.

## Motivation

The persisted CR and Git-native history are the governance authority. Core
validation must remain usable by bare Git, email patch, and non-GitHub flows
without reading GitHub event metadata.

## Test Evidence

Run shell syntax checks and the repository validation suite after the adapter
and bootstrap migration is complete.

## Risk

The compatibility entry points and GitHub workflow must continue to produce
the same CR body and history checks while the implementation moves.

## Rollback

Revert this signed CR through a new CR if adapter translation or existing
GitHub validation regresses.

## Breaking Change

No. Existing script entry points remain compatibility shims during migration.

## Backport Target

None.
