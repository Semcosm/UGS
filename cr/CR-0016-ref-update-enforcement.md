# CR-0016: Enforce protected ref update rules

Base: main
Head or Range: feat/v0-3-draft-5-ref-enforcement / 3ad1efe..a704a4d
Title: feat(refs): enforce protected ref update rules
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3-draft-5
Base OID: 3ad1efe0940eee8aceaa330261d376ba6e2bbf06
Head OID: a704a4d0101f0fdad8105d7042708fa675703823
Integrated Result: pending

## Summary

Add a reusable ref-update validator and disposable fixtures for protected main
fast-forward updates and formal release-tag deletion or replacement.

## Motivation

Remote and bare-Git adapters need deterministic ref transition rules in addition
to the existing local pre-push hook.

## Test Evidence

Run `scripts/test_ref_update.sh`, `scripts/ugs_check.sh`,
`scripts/validate_repo.sh`, and all CR validators. The fixture rejects main
deletion, non-fast-forward updates, release-tag deletion, and replacement.

## Risk

This is pre-1.0 draft enforcement and may change without v0.x compatibility
promises.

## Rollback

Revert this CR's validator, fixture, workflow, and conformance changes through
a new signed CR.

## Breaking Change

No. The adapter adds draft checks without changing the v0.2 normative contract.

## Backport Target

None; this is v0.3 draft work.
