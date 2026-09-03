# CR-0018: Mark the release-candidate report format

Base: main
Head or Range: release/v0-3-rc / c4b1fc8..05d5488
Title: feat(conformance): mark release candidate report
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3-rc-1
Base OID: c4b1fc8c86c90c7a5d3f2e830c1db9ef7b574ded
Head OID: 05d5488128370bebfce8c48618b634ced0f99d5c
Integrated Result: pending

## Summary

Advance the machine-readable conformance report identifier to
`ugs-conformance/v0.3-rc-1` and update the pre-release packet scope.

## Motivation

The report had remained labeled draft-2 after later draft capabilities were
integrated, which made the RC evidence ambiguous.

## Test Evidence

Run `scripts/ugs_check.sh --format json`, `scripts/validate_repo.sh`, and all
CR validators. The report must contain the RC-1 format and a passing result.

## Risk

This is an intentional pre-1.0 report identifier change; no v0.x compatibility
is promised.

## Rollback

Revert this CR's report and release-packet changes through a new signed CR.

## Breaking Change

Yes for draft report consumers; the report format identifier changes before
v1.0.

## Backport Target

None; this is v0.3 RC work.
