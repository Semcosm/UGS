# CR-0091: Accept patch-equivalent hosted rebase integrations

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: fix/cr-rebase-coverage / c1b23935d2089ecfa00d8accf778b7b1a07ca8a6
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Accept patch-equivalent hosted rebase integrations
Revision: 1
Status: pending
Decision: pending
Policy Version: v0.3
Base OID: f4248044f320c7c49ad0089f751fcec43fbd3f92
Head OID: c1b23935d2089ecfa00d8accf778b7b1a07ca8a6
Integrated Result: pending
Coverage OIDs: none
Extensions: {}

## Summary

Allow main CR coverage validation to recognize a GitHub Rebase and merge result
when the hosted commit series has equivalent content to the reviewed topic.

## Motivation

Hosted rebase integration changes commit object IDs, so the reviewed Head OID is
not necessarily reachable from the resulting main tip even when the patch is
unchanged. The current validator reports a false failure in this case.

## Test Evidence

Add disposable repository fixtures for literal fast-forward validation,
patch-equivalent rewritten rebase validation, and rejection of stale, unrelated,
or mismatched integrations. Run the focused fixture and repository checks.

## Risk

The rewritten path is restricted to rebase-ff records with a pending integrated
result, a base equal to the previous main tip, valid source ancestry, and an
exact canonical tree diff match. Other strategies retain strict provenance.

## Rollback

Revert the validator, fixture, workflow, and documentation changes through a
new reviewed CR. Existing main history and persisted records remain intact.

## Breaking Change

No. This only accepts an additional verifiable hosted integration form.

## Backport Target

None.
