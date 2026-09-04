# CR-0019: Record v0.3 adoption decisions

Base: main
Head or Range: docs/v0-3-adopt / afe98ff
Title: docs(policy): record v0.3 adoption decisions
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3-rc-1
Base OID: afe98ff18847b1549a440c5c4f0128fdd71df14e
Head OID: afe98ff18847b1549a440c5c4f0128fdd71df14e
Integrated Result: pending

## Summary

Record the design decisions that gate normative v0.3 adoption: JSON remains
the canonical policy format, CR records remain Markdown, review conclusions
remain trailers, server enforcement is capability-declared, and conformance
levels remain a companion profile rather than Core.

## Motivation

The v0.3 implementation and RC-1 evidence are complete, but the roadmap still
lists adoption decisions as open. Recording the decisions makes the next CR
auditable and separates design closure from the later normative version
transition.

## Test Evidence

Run `scripts/ugs_check.sh --format json`, `scripts/validate_repo.sh`, and all
CR validators. The existing RC-1 conformance report must remain passing.

## Risk

This closes design decisions for the v0.3 adoption proposal but does not by
itself activate v0.3 or change the v0.2 normative contract.

## Rollback

Supersede this decision record with a new CR if a design decision changes;
leave the accepted record intact for audit history.

## Breaking Change

No. Normative activation is deferred to a separate adoption CR.

## Backport Target

None; this is v0.3 adoption preparation.
