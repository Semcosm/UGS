# CR-0038: Add supply-chain evidence paths and SBOM validation

Base: main
Head or Range: feat/p2-supply-chain-evidence / v0.3.9..HEAD
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(policy): validate supply-chain evidence and SBOMs
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: 159baa192d60f86ce972864ff93f5afe25261e6e
Head OID: 20b7269af774a740e8bc0a15f0d7387e9876b571
Integrated Result: main@20b7269af774a740e8bc0a15f0d7387e9876b571

## Summary

Add safe evidence path declarations and minimum SPDX/CycloneDX SBOM
validation.

## Motivation

Supply-chain profiles need traceable evidence locations and a portable minimum
format contract without requiring a particular package manager or builder.

## Test Evidence

Run `scripts/test_sbom.sh`, `scripts/validate_repo.sh`, and
`scripts/ugs_check.sh --format json`.

## Risk

Repositories opting into stronger profiles may need to add evidence files.
Declaration-only basic profiles remain supported.

## Rollback

Supersede this CR with a new signed CR if evidence or SBOM semantics change;
do not rewrite published tags.

## Breaking Change

No for declaration-only repositories; stronger opt-in profiles gain evidence
requirements.

## Backport Target

None; this is optional v0.3 supply-chain profile work.
