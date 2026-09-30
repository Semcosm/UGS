# CR-0081: Audit post-v0.3.29 tag distribution

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: docs/post-v0-3-29-tag-audit / a33eea7eb9728e9854473c86186c08655f545b94..f17a445ae4457a60b91de133f01755354924566a
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Audit post-v0.3.29 tag distribution
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: a33eea7eb9728e9854473c86186c08655f545b94
Head OID: f17a445ae4457a60b91de133f01755354924566a
Integrated Result: pending
Coverage OIDs: none
Extensions: {}

## Summary

Audit the documentation status after the latest formal v0.3.29 tag and publish a manual-review worksheet for the candidate v0.3.30 through v1.0.0 tag distribution. Mark the historical Phase A-F grouping from CR-0070 as non-normative and pending maintainer review.

## Motivation

The repository has no formal tag after v0.3.29. The commits after that tag close its supply-chain evidence and self-bootstrap records, while the existing long-term roadmap describes future phases without an explicit approval status. The audit must distinguish shipped capabilities, open work, and candidate release allocation before the next development cycle.

## Test Evidence

Passed scripts/generate_document_map.py, scripts/validate_document_map.py, git diff --check, scripts/validate_repo.sh, and scripts/ugs_check.sh --format json. Confirmed that v0.3.29 is the latest tag and that no v0.4, v0.5, v0.6, v0.7, or v1.0 tag exists.

## Risk

This is a documentation-only audit. It does not change the active v0.3 policy, schemas, validators, hooks, release objects, or tag history. The candidate table is intentionally non-committal until a maintainer records the version allocation and exit evidence in a later CR.

## Rollback

Revert the signed implementation and CR commits through a reviewed CR, or restore the documentation to Base OID a33eea7eb9728e9854473c86186c08655f545b94. Keep this audit record append-only if a replacement allocation is approved.

## Breaking Change

No. The change clarifies planning status and release history only.

## Backport Target

None.
