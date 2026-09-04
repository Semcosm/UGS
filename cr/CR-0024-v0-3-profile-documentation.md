# CR-0024: Document the adopted v0.3 profile

Base: main
Head or Range: docs/v0-3-profile-documentation / a70840a..HEAD
Title: docs(policy): document the adopted v0.3 profile
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: a70840a5933def666e7e8c5bc81349e5373ecd2e
Head OID: a70840a5933def666e7e8c5bc81349e5373ecd2e
Integrated Result: pending

## Summary

Add the normative v0.3 policy and conformance profile document and reconcile
the README, repository policy, and roadmap with the adopted profile.

## Motivation

The v0.3 manifest and enforcement surface are active, while the existing
human-readable Core documents remain v0.2. A dedicated profile makes the
relationship explicit and prevents version ambiguity.

## Test Evidence

Run `scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, all CR
validators, and the recovered-boundary signature validation.

## Risk

This documents the existing adopted v0.3 surface without adding validator
behavior or changing accepted v0.2 history.

## Rollback

Supersede this documentation CR with a new signed CR if the profile boundary
changes. Preserve the v0.3 adoption and release records for audit history.

## Breaking Change

No. This clarifies the adopted v0.3 scope without changing enforcement.

## Backport Target

None; this is v0.3 profile documentation.
