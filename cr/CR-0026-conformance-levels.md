# CR-0026: Define conformance levels and profile matrix

Base: main
Head or Range: feat/p1-conformance-levels / 9145670..HEAD
Title: feat(policy): define conformance levels and profile matrix
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 9145670bb8a5e3e1e317a369d5b29675e0f5f108
Head OID: 9145670bb8a5e3e1e317a369d5b29675e0f5f108
Integrated Result: pending

## Summary

Add `baseline`, `standard`, and `high-trust` conformance levels, define their
minimum evidence, and publish the profile × merge-strategy compatibility
matrix. Declare this repository as `high-trust`.

## Motivation

The v0.3 profile described enforcement requirements but did not distinguish
the evidence strength a repository claims or explain which merge strategies
are compatible with each branch profile.

## Test Evidence

Run `scripts/test_policy_manifest.sh`, `scripts/validate_policy_manifest.sh`,
`scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, and all CR
validators.

## Risk

This adds a required v0.3 manifest field and rejects declarations that claim a
level without its minimum evidence. It does not change v0.2 history.

## Rollback

Supersede this CR with a new signed CR that restores the prior v0.3 manifest
schema and documents the compatibility impact.

## Breaking Change

Yes for v0.3 manifests that omit `conformance_level`; v0.2 history is retained.

## Backport Target

None; this is P1 v0.3 profile work.
