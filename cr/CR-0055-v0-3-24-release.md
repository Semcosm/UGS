# CR-0055: Prepare the v0.3.24 core and adapter release

Base: main
Head or Range: chore/release-v0-3-24-cr
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(release): prepare v0.3.24 core adapter release
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: b22cf9458c33f1642b54e2a5da2c92e7fbbcdd7f
Head OID: b22cf9458c33f1642b54e2a5da2c92e7fbbcdd7f
Integrated Result: pending

## Summary

Add release notes for v0.3.24, documenting the completed Core and platform
adapter separation.

## Motivation

UGS Core must remain implementable through bare Git and portable review media;
GitHub PR, Actions, Releases, and repository identity are compatibility
concerns rather than governance primitives.

## Test Evidence

Run repository, CR, commit-range, signature, bootstrap equivalence, GitHub
adapter, bare Git Core, and release workflow validation before publishing the
signed annotated tag.

## Risk

Low to moderate. Adapter boundaries and bootstrap profile output changed while
existing compatibility entry points remain available.

## Rollback

Do not replace existing tags. Revert through a new signed CR and publish a
superseding patch release if release validation regresses.

## Breaking Change

No. Existing script entry points remain compatibility shims.

## Backport Target

None.
