# CR-0041: Fix evidence path validation

Base: main
Head or Range: fix/p2-evidence-path-jq / v0.3.12..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: fix(policy): correct evidence path validation
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: 93965f1295fd0d0c4b55c4ecb784c85d751b2218
Head OID: 73f2a774fa599229a876d4289f0f5cceb2440569
Integrated Result: main@73f2a774fa599229a876d4289f0f5cceb2440569

## Summary

Fix jq operator precedence in supply-chain evidence path validation and verify
optional, valid, and traversal path cases.

## Motivation

The previous expression could reject valid paths with a jq type error, making
the validation result depend on expression evaluation rather than policy.

## Test Evidence

Run `scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, and the
stability audit for omitted supply-chain declarations, valid evidence, and
`../` traversal rejection.

## Risk

Only malformed path declarations are affected; valid profile declarations are
unchanged.

## Rollback

Supersede this CR with a new signed CR if path semantics change; do not rewrite
published tags.

## Breaking Change

No for valid manifests; malformed evidence paths may now be rejected
consistently.

## Backport Target

None; this is a v0.3 validator correction.
