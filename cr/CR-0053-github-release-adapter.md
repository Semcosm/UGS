# CR-0053: Isolate GitHub release and workflow adapters

Base: main
Head or Range: refactor/github-release-adapter
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: refactor(adapter): isolate GitHub release operations
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 31dcdbc20945b8888a75208e6971090ad8e82e9a
Head OID: 31dcdbc20945b8888a75208e6971090ad8e82e9a
Integrated Result: pending

## Summary

Move GitHub Releases operations and Actions pinning behind explicit GitHub
adapter scripts, and make bootstrap output profile-dependent.

## Motivation

GitHub PR, Actions, and Releases are compatibility mappings rather than the
UGS Core governance object. Bare Git consumers must be able to run Core checks
without GitHub APIs or `.github` files.

## Test Evidence

Run bootstrap equivalence, bootstrap fixture, bare Git Core, repository, and
supply-chain release fixture tests, followed by the remote GitHub workflow.

## Risk

The GitHub release workflow and standard profile adapter paths must preserve
existing published package behavior.

## Rollback

Revert through a new signed CR and publish a superseding patch release if the
adapter migration regresses release consumption.

## Breaking Change

No. Existing script entry points remain compatible during the migration.

## Backport Target

None.
