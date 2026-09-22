# CR-0017: Enforce release refs in adapters

Base: main
Head or Range: feat/v0-3-draft-6-enforcement-adapters / bf4a678..53f89c5
Title: feat(ci): enforce release refs in adapters
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3-draft-6
Base OID: bf4a678afc3795837feb7b7447a82db51ad5b0ef
Head OID: c4b1fc8c86c90c7a5d3f2e830c1db9ef7b574ded
Integrated Result: main@c4b1fc8c86c90c7a5d3f2e830c1db9ef7b574ded

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
