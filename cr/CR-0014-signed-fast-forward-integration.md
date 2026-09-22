# CR-0014: Require signed fast-forward integration

Base: main
Head or Range: docs/fix-signed-main-integration / e4f0d247..459572b
Title: docs(repo): require signed fast-forward integration
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3-draft-3
Base OID: e4f0d2477c12b9391e3d50d36770427e720297ac
Head OID: 5b423aa897d61f54092d6e1d3152f00c50bc6215
Integrated Result: main@5b423aa897d61f54092d6e1d3152f00c50bc6215

## Summary

Document the local CR-based fast-forward path for high-trust integration when
a hosting platform cannot produce a trusted SSH-signed integration commit.

## Motivation

The GitHub rebase merge used for PR #4 created an unsigned commit and caused
the main push Actions check to fail. The repository's existing hook already
supports a signed local fast-forward path.

## Test Evidence

Run `scripts/ugs_check.sh`, `scripts/validate_repo.sh`, all CR validators, and
the pre-push checks during integration.

## Risk

The integration procedure is more manual, but preserves the high-trust signing
requirement. Pre-1.0 workflow details may change without compatibility promise.

## Rollback

Revert this documentation and restore the prior integration instructions with
a new signed CR. Do not rewrite the protected main history.

## Breaking Change

No. This documents the existing high-trust requirement and integration hook.

## Backport Target

None; this is v0.3 draft work.
