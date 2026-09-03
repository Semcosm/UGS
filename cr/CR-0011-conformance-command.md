# CR-0011: Add a draft conformance command

Base: main
Head or Range: main..docs/v0-3-policy-manifest
Title: feat(conformance): add draft local conformance command

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
