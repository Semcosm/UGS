# CR-0020: Record the trusted-signing boundary recovery

Base: main
Head or Range: docs/v0-3-adopt / afe98ff
Title: docs(repo): record trusted-signing boundary recovery
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3-rc-1
Base OID: afe98ff18847b1549a440c5c4f0128fdd71df14e
Head OID: afe98ff18847b1549a440c5c4f0128fdd71df14e
Integrated Result: pending

## Summary

Record that the v0.3 draft commits `71b9f777`, `69ac42c`, `da80d34`, and
`e4f0d24` are retained for audit history but are outside the recovered
high-trust signing claim. Signed fast-forward integration resumes at
`459572b` and continues through the current release-candidate tip.

## Motivation

The repository adopted trusted commit signing before a short GitHub-mediated
draft integration sequence produced unsigned commits. The subsequent signed
fast-forward recovery restored the intended enforcement boundary without
rewriting protected history.

## Test Evidence

Run `scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`, and
`scripts/validate_commit_signatures.sh 459572bf2910267659b3bb590fdf1b00b26ed94f^..HEAD`.

## Risk

The historical draft sequence remains visible but is not covered by the
high-trust signing claim. Future release verification must use the recovered
boundary rather than the original v0.2 signing anchor.

## Rollback

Supersede this record with a new signed CR if the repository establishes a
different auditable signing boundary. Do not rewrite protected history.

## Breaking Change

No. This clarifies the existing recovery boundary and does not alter accepted
Git objects.

## Backport Target

None; this is repository audit and v0.3 adoption preparation.
