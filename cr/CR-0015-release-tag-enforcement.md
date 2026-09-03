# CR-0015: Add signed release tag enforcement

Base: main
Head or Range: feat/v0-3-draft-4-release-enforcement / 5b423aa..88fc8e8
Title: feat(release): validate signed release tags
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3-draft-4
Base OID: 5b423aa897d61f54092d6e1d3152f00c50bc6215
Head OID: 88fc8e85078682bb0eed87de4a93eabc4ea9b7c0
Integrated Result: pending

## Summary

Add a reusable validator for formal release tags and fixtures covering semantic
version names, annotated tag objects, trusted signatures, and release notes.

## Motivation

Release tags are Git-native release objects and need the same deterministic
validation surface as commits, CRs, and policy manifests.

## Test Evidence

Run `scripts/test_release_tag.sh`, `scripts/ugs_check.sh`,
`scripts/validate_repo.sh`, and all CR validators. The signed `v0.2.0` tag
passes while an invalid version is rejected.

## Risk

Draft release vocabulary and enforcement details may change before v0.3; no
v0.x compatibility is promised.

## Rollback

Revert this CR's validator, fixture, workflow, and executable-file-list changes
through a new signed CR.

## Breaking Change

No. This adds draft validation without changing the v0.2 normative contract.

## Backport Target

None; this is v0.3 draft work.
