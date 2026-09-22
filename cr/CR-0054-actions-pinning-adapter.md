# CR-0054: Move GitHub Actions pinning into the adapter

Base: main
Head or Range: refactor/github-release-adapter
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: refactor(adapter): move Actions pinning implementation to GitHub adapter
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: ae9ede6d951b311d3de2dac4f9f2aa5ebe8bfc18
Head OID: b22cf9458c33f1642b54e2a5da2c92e7fbbcdd7f
Integrated Result: main@b22cf9458c33f1642b54e2a5da2c92e7fbbcdd7f

## Summary

Place the GitHub Actions pinning implementation under the explicit GitHub
adapter and retain a compatibility forwarding command in `scripts/`.

## Motivation

Action references and workflow layouts are GitHub-specific. The Core layer must
remain usable in a repository that has no `.github` directory or Actions
workflow.

## Test Evidence

Run repository, bootstrap equivalence, bootstrap package, and bare Git Core
tests, then verify the GitHub workflow remotely.

## Risk

The wrapper and adapter must preserve existing standard/high-trust profile and
GitHub workflow validation behavior.

## Rollback

Revert through a new signed CR if adapter invocation or profile validation
regresses.

## Breaking Change

No. The existing script entry point remains available as a compatibility shim.

## Backport Target

None.
