# CR-0023: Restore annotated release tags in CI

Base: main
Head or Range: fix/release-tag-workflow / f28ecc7..HEAD
Title: fix(ci): restore annotated release tags before validation
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: f28ecc78ad7bbf84ac376bcbc6f8398236ee0ceb
Head OID: f28ecc78ad7bbf84ac376bcbc6f8398236ee0ceb
Integrated Result: pending

## Summary

Fetch the annotated tag ref again after `actions/checkout` before invoking the
release-tag validator, and publish the correction as v0.3.2.

## Motivation

GitHub Actions checkout resolves a tag event to its target commit and
overwrites the local tag ref. The validator then cannot inspect the annotated
tag object even though the remote tag is correctly signed and annotated.

## Test Evidence

Run `scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, all CR
validators, and `scripts/validate_release_tag.sh v0.3.2`.

## Risk

This changes only CI checkout preparation. Existing release tags remain
immutable and the release-tag policy is unchanged.

## Rollback

Supersede this CR with a new signed correction if the checkout behavior
changes. Do not replace published tags.

## Breaking Change

No. This restores the tag object required by the existing validator.

## Backport Target

None; this is a v0.3 CI correction.
