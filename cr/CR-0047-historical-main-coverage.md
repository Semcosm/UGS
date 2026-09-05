# CR-0047: Establish mandatory CR coverage for historical main changes

Base: main
Head or Range: historical first-parent commits after CR-0046; see Coverage OIDs
Integration Strategy: rebase-ff
Title: chore(governance): require persisted CR coverage
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 496db6911fbc93cac600c7ec21f973a447805922
Head OID: 496db6911fbc93cac600c7ec21f973a447805922
Integrated Result: pending
Coverage OIDs: 374ccd95bb0e93711b92dffdf50fb93af4d0f179 2a32dca230e123a568d57d8a05f066a3cf5782c4 cbcff44ec8db8eeb0f467a7f5522ea9c532a55a8 b7ca1d3a78bc046077524ef787417249c4c0bed1 e12c6fafd870be075451bcb62638f95eab5565a4 c1741d58bae93552a7246e63dad938c42950fc2e 7accb588c35cf8535397d596fe2e749eac5caa19 e4d9df25aacc819f2aa245a2d3ee9c4ae5098aee bf7161a4915733a33a3751883181728ed78e86d3 05cc3c2246cf93628a9b713905333955ae8bc734 496db6911fbc93cac600c7ec21f973a447805922

## Summary

Establish persisted CR coverage for historical first-parent changes after
CR-0046 and adopt hard CR-file enforcement for future main integrations.

## Motivation

The repository must remain auditable through bare Git workflows. A PR-only
record is not sufficient for offline archival or request-pull flows. This
migration records the exact historical OIDs not previously covered by a
persisted CR.

## Test Evidence

Run `scripts/validate_cr_coverage.sh origin/main`,
`scripts/validate_repo.sh`, and `scripts/ugs_check.sh --format json`.
The historical OID audit identified 10 uncovered commits after CR-0046.

## Risk

This record documents historical coverage; it does not invent historical
review conclusions or alter existing commit objects.

## Rollback

Revert the enforcement change only with a new accepted CR. Preserve this
historical coverage record as an append-only audit artifact.

## Breaking Change

Yes. New integrations must include a persisted `cr/CR-*.md` record.

## Backport Target

None.
