# CR-0028: Record integration strategy evidence

Base: main
Head or Range: feat/p1-integration-strategy / bf8d5c7..HEAD
Integration Strategy: rebase-ff
Title: feat(cr): validate integration strategy evidence
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: bf8d5c71b4bd781928881e4e90b1de626b736f38
Head OID: bf8d5c71b4bd781928881e4e90b1de626b736f38
Integrated Result: pending

## Summary

Add strategy-specific CR provenance rules for rebase-ff, merge, and squash,
and require new v0.3 CRs to declare their integration strategy.

## Motivation

Base and head reachability alone cannot distinguish a rebase-fast-forward
result from a merge or squash result. Recording the strategy makes the final
object relationship deterministic and auditable.

## Test Evidence

Run `scripts/test_cr_integration_strategy.sh`, `scripts/validate_repo.sh`,
`scripts/ugs_check.sh --format json`, and all CR validators.

## Risk

New CRs with an invalid strategy/result relationship are rejected. Historical
CRs without the field remain grandfathered and accepted.

## Rollback

Supersede this CR with a new signed CR if strategy semantics change. Do not
rewrite protected history.

## Breaking Change

Yes for new v0.3 CRs that omit strategy evidence or claim an incompatible
integration result.

## Backport Target

None; this is P1 provenance work.
