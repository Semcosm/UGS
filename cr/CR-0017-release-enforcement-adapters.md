# CR-0017: Enforce release refs in adapters

Base: main
Head or Range: feat/v0-3-draft-6-enforcement-adapters / bf4a678..53f89c5
Title: feat(ci): enforce release refs in adapters
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3-draft-6
Base OID: bf4a678afc3795837feb7b7447a82db51ad5b0ef
Head OID: 53f89c530245d6241143cbd4a35ba0b1084421e3
Integrated Result: pending

## Summary

Run release-tag validation for v-tag pushes, exclude tag events from branch
commit-range checks, and add the v0.3 release-candidate packet.

## Motivation

GitHub Actions must validate formal release tags when they are pushed, while
bare-Git enforcement already uses the shared ref-update rules.

## Test Evidence

Run `scripts/ugs_check.sh`, `scripts/validate_repo.sh`, all CR validators, and
the existing signed `v0.2.0` release-tag fixture.

## Risk

This is pre-1.0 draft enforcement and may change without v0.x compatibility
promises.

## Rollback

Revert this CR's workflow, release packet, and repository-list changes through
a new signed CR. Never rewrite a published formal tag.

## Breaking Change

No. This adds draft enforcement and release preparation material.

## Backport Target

None; this is v0.3 draft work.
