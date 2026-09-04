# CR-0021: Adopt the v0.3 policy and conformance profile

Base: main
Head or Range: docs/v0-3-adopt / e29d5fd..HEAD
Title: docs(policy): adopt v0.3 policy and conformance profile
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: e29d5fd60e9cec76f51547e124482f9e367e6882
Head OID: e29d5fd60e9cec76f51547e124482f9e367e6882
Integrated Result: pending

## Summary

Activate the v0.3 machine-readable policy and conformance profile, including
strict CR evidence, review trailers, release-tag validation, and protected-ref
update rules. Retain v0.2 history as historical compatibility context.

## Motivation

The v0.3 manifest, fixtures, local conformance command, and enforcement
adapters have passed the RC-1 checks. The profile now needs an explicit
normative adoption boundary instead of remaining draft-only.

## Test Evidence

Run `scripts/ugs_check.sh --format json`, `scripts/validate_repo.sh`, all CR
validators, and the recovered-boundary commit and signature validators.

## Risk

This is a pre-1.0 normative transition. v0.3 tooling and declarations are not
promised to be compatible with v0.2 tooling, but accepted v0.2 history is not
retroactively invalidated.

## Rollback

Supersede this CR with a new signed CR that restores the prior active policy
declaration and documents the migration rollback. Do not rewrite protected
history or published tags.

## Breaking Change

Yes. The active policy declaration and conformance vocabulary move from the
v0.3 draft/RC identifiers to v0.3.

## Backport Target

None; this is the v0.3 normative adoption.
