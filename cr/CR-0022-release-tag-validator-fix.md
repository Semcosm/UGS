# CR-0022: Fix annotated tag validation in CI

Base: main
Head or Range: fix/release-tag-validator / 5288f58..f220ef4
Title: fix(release): recognize annotated tag objects in CI
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 5288f584f31b254053debfdd5be38987ece10312
Head OID: f220ef409b0ee3ac5551e92902e372933bab82c6
Integrated Result: pending

## Summary

Require an explicit annotated tag object when validating formal releases and
add `v0.3.0` coverage to the release-tag fixture.

## Motivation

The first `v0.3.0` tag workflow failed because GitHub checkout ref resolution
peeled the annotated tag to its commit before the validator inspected it.

## Test Evidence

Run `scripts/validate_release_tag.sh v0.3.0`, `scripts/test_release_tag.sh`,
`scripts/validate_repo.sh`, and `scripts/ugs_check.sh --format json`.

## Risk

This changes only tag-object detection and does not alter release-tag policy.
The existing `v0.3.0` tag remains immutable and its failed workflow remains
part of the audit history.

## Rollback

Do not replace `v0.3.0`. If this correction is insufficient, publish another
superseding patch release with a new signed annotated tag.

## Breaking Change

No. The validator now correctly enforces the existing annotated-tag rule.

## Backport Target

None; this is a v0.3 release correction.
