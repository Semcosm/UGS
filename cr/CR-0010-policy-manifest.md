# CR-0010: Add a draft canonical policy manifest

Base: main
Head or Range: main..docs/v0-3-policy-manifest
Title: docs(policy): add v0.3 draft policy manifest
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.3-draft-1
Base OID: 6d7e94a43c8bdb2fef8fa4b0dde170379746bbe6
Head OID: 50a56e5abdf51c06fd445039ae79111efcc0f2d6
Integrated Result: main@71b9f777e866851bb2b3a0b22d23fea8c794d3dd

## Summary

Introduce the versioned `.ugs/policy.json` draft declaration, its JSON Schema,
reference validator, and portable positive and negative fixtures. The manifest
expresses the existing repository policy without changing the v0.2 normative
documents.

## Motivation

v0.2 keeps the repository declaration in prose. A canonical machine-readable
form is needed so independent implementations can identify the same branch,
commit, review, automation, release, and exception capabilities.

## Test Evidence

Run `scripts/validate_policy_manifest.sh`,
`scripts/test_policy_manifest.sh`, and `scripts/validate_repo.sh`. The fixture
suite accepts the valid manifest and rejects unknown top-level fields and
unprefixed extension keys.

## Risk

The draft vocabulary may need revision before v0.3 adoption. During migration,
the validator therefore only warns about mismatches with `REPOSITORY_POLICY.md`.

## Rollback

Revert this CR's commit. The v0.2 prose policy and its existing validators
remain authoritative throughout the draft period.

## Breaking Change

No. The manifest is an additive draft and no existing accepted history is
re-evaluated under a stricter rule.

## Backport Target

None; this is v0.3 planning and reference work.
