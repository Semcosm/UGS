# CR-0011: Add a draft conformance command

Base: main
Head or Range: main..docs/v0-3-policy-manifest
Title: feat(conformance): add draft local conformance command
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.3-draft-2
Base OID: 6d7e94a43c8bdb2fef8fa4b0dde170379746bbe6
Head OID: 50a56e5abdf51c06fd445039ae79111efcc0f2d6
Integrated Result: main@71b9f777e866851bb2b3a0b22d23fea8c794d3dd

## Summary

Add a local conformance entry point that runs the draft policy, fixture,
repository, and CR checks and emits either concise text or a stable JSON
report.

## Motivation

The draft manifest validator checks one declaration, but independent
implementations also need a single reproducible command for repository-level
results.

## Test Evidence

Run `scripts/ugs_check.sh`, `scripts/ugs_check.sh --format json`,
`scripts/validate_repo.sh`, and all CR validators. The JSON report is checked
for the draft-2 format, a passing result, and only passing checks.

## Risk

The draft command and report vocabulary may change before v0.3 adoption. They
are additive and do not change the v0.2 normative contract.

## Rollback

Revert this CR's changes to the command, workflow, documentation, and
repository executable-file list. Existing v0.2 validators remain available.

## Breaking Change

No. This is a pre-1.0 draft capability and is not applied retroactively.

## Backport Target

None; this is v0.3 draft work.
