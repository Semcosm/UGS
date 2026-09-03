# CR-0012: Add disposable Git conformance fixtures

Base: main
Head or Range: main..docs/v0-3-policy-manifest
Title: test(conformance): add disposable Git evidence fixture
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.3-draft-2
Base OID: 6d7e94a43c8bdb2fef8fa4b0dde170379746bbe6
Head OID: 50a56e5abdf51c06fd445039ae79111efcc0f2d6
Integrated Result: main@71b9f777e866851bb2b3a0b22d23fea8c794d3dd

## Summary

Add a disposable work repository and bare clone fixture covering commit
message evidence, topic branches, annotated release tags, and lightweight tag
detection.

## Motivation

Conformance checks must exercise Git-native evidence outside the UGS repository
itself, especially the distinction between formal annotated tags and lightweight
tags.

## Test Evidence

Run `scripts/test_git_fixtures.sh`, `scripts/ugs_check.sh`, and
`scripts/validate_repo.sh`. The fixture creates a temporary repository, checks
its commit and refs, and removes it on exit.

## Risk

The fixture only exercises the currently implemented draft evidence checks.
The draft scope and fixture contract may change before v0.3 adoption.

## Rollback

Revert this CR's fixture, CI, and executable-file-list changes.

## Breaking Change

No. This is additive pre-1.0 test coverage.

## Backport Target

None; this is v0.3 draft work.
