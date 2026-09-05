# CR-0036: Define repository-shape capabilities

Base: main
Head or Range: feat/p2-repository-shapes / v0.3.7..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(policy): define repository-shape capabilities
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 2b149f8f7a28f35782a70033dfd74768f7ccfde4
Head OID: 2b149f8f7a28f35782a70033dfd74768f7ccfde4
Integrated Result: pending

## Summary

Add optional declarations and validation for monorepos, submodules, generated
files, and large-file handling.

## Motivation

Repositories have different shapes that affect evidence collection, but UGS
must remain independent of any one build system or hosting platform. Explicit
capability declarations let tools adapt without changing Core requirements.

## Test Evidence

Run `scripts/validate_repo.sh`, `scripts/test_policy_manifest.sh`,
`scripts/validate_repository_shape.sh`, and `scripts/ugs_check.sh --format json`.

## Risk

The declaration describes capability rather than proving repository-specific
behavior. Implementations may add shape-specific checks later.

## Rollback

Supersede this CR with a new signed CR if repository-shape semantics change.
Do not rewrite accepted history or published release tags.

## Breaking Change

No; the declaration is optional and does not alter UGS Core conformance.

## Backport Target

None; this completes optional v0.3 P2 capability guidance.
