# CR-0075: Restore first-parent CR coverage after the v0.4 governance sequence

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: chore/cr-coverage-cleanup / 58f4e7bcc7851a3ec9476384af42e54963874005
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Restore first-parent CR coverage after the v0.4 governance sequence
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 58f4e7bcc7851a3ec9476384af42e54963874005
Head OID: 58f4e7bcc7851a3ec9476384af42e54963874005
Integrated Result: pending
Coverage OIDs: 40d31ead8fe5f008ed2011df29243b3cfee55e31 94aa56b7154ab5c86ab4b2e960a41a04fd0f3af7 ac78a13251e2978d0e1f519ae3acf601788f91d7 ebca89f2cee03a1300ad3de1a4a6f8ea6eab4f00
Extensions: {}

## Summary

Restore the offline CR coverage gate by recording the four first-parent main
commits that currently lack explicit coverage: the CR-0073 migration follow-up
and implementation commits, the CR-0070 roadmap implementation commit, and the
CR-0069 supply-chain evidence implementation commit. This is an audit-only
record; it does not rewrite historical CR records or change policy behavior.

## Motivation

The repository's `scripts/validate_cr_coverage.sh HEAD` gate scans first-parent
history after the historical coverage anchor and requires every non-CR commit
to be named by a CR head, integrated result, or `Coverage OIDs`. The ordinary
repository validator checks each CR record but does not invoke this range-wide
gate, so the missing coverage was not visible in the default validation path.
Persisting the four OIDs in one reviewed record makes the coverage boundary
offline-auditable and lets the range-wide gate pass without altering history.

## Test Evidence

Before this record, `scripts/validate_cr_coverage.sh HEAD` reported exactly four
uncovered commits: `40d31ead`, `ac78a132`, `94aa56b`, and `ebca89f`. The OIDs in
this record are full lowercase SHA-1 values in lexical order and each resolves
to a first-parent commit after the coverage anchor. Focused validation after
the record commit will run `scripts/cr_model.py --json`,
`scripts/validate_cr_record.sh`, `scripts/test_cr_model.sh`,
`scripts/test_conformance.sh`, and `scripts/validate_cr_coverage.sh HEAD`.

## Risk

This change only adds append-only audit metadata. It does not alter source,
validators, hooks, workflows, release objects, signer files, or the active
supply-chain profile and therefore has no runtime compatibility impact. The
coverage declarations are intentionally conservative: they identify commits
already described by CR-0069, CR-0070, and CR-0073 without asserting new
implementation behavior.

Seven older records remain `accepted` with `Integrated Result: pending`:
CR-0029, CR-0030, CR-0031, CR-0032, CR-0050, CR-0051, and CR-0066. They are
not rewritten here because closing them requires independently verified final
integration objects and trailer evidence, while their historical records are
append-only. A follow-up governance CR should reconcile those records against
reachable main history or document a scoped exception; this CR does not claim
that unresolved lifecycle work is complete.

## Rollback

Revert the signed CR record commit through a new reviewed CR if the coverage
declarations are found to be inaccurate, then restore coverage with corrected
OIDs. Do not rewrite or delete the historical CR records or the covered main
commits. The active policy and supply-chain evidence remain unchanged.

## Breaking Change

No. The record only makes existing first-parent provenance explicit and adds no
new validator or policy requirement.

## Backport Target

None.
