# CR-0058: Stabilize the bare Git update fixture range

Base: main
Head or Range: fix/bare-git-update-hook
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: test(adapter): stabilize bare Git update fixture range
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 20db5f23a304bc9c1f7738a3ac102a68e3a8a6ce
Head OID: 20db5f23a304bc9c1f7738a3ac102a68e3a8a6ce
Integrated Result: pending

## Summary

Make the bare Git update fixture derive its old object from the CR commit it
is exercising, so multi-commit PR integrations validate the complete range.

## Motivation

The fixture previously used the current remote main ref, which becomes equal
to the new object after integration and incorrectly produced an empty CR range.

## Test Evidence

Run `scripts/test_bare_git_update.sh`, the full repository suite, and remote PR
checks.

## Risk

Test-only change; the fixture must continue to reject ranges without persisted
CR coverage.

## Rollback

Revert through a new signed CR if the fixture no longer models a server update.

## Breaking Change

No.

## Backport Target

None.
