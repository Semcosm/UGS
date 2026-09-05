# CR-0060: Add configurable Document Map governance

Base: main
Head or Range: working tree based on main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(governance): add configurable Document Map validation
Revision: 2
Status: pending
Decision: pending
Policy Version: v0.3
Base OID: 2f56c8ec2deda73539650d0413ea33eca02c6d92
Head OID: 413f93a852eadd2351e1aa596664efb26ab026e8
Integrated Result: pending

## Summary

Add a versioned recursive `.ugs/document-map.json` configuration and matching
schema for the repository's top-level README. Make the configuration the source
for generated README output, including bilingual titles and nested release
packet groups. Add a dependency-free generator, drift checker, fixtures, and
repository validation integration.

## Motivation

The README Document Map had become a manually maintained flat list. As UGS
grows, link existence alone is insufficient: the rendered map must remain
complete, ordered, bilingual, and structurally aligned with its intended
hierarchy. A separate recursive configuration plus generator makes the tree
the source of truth without embedding document-specific paths in the policy
manifest.

## Test Evidence

`scripts/generate_document_map.py`, `scripts/validate_document_map.py`,
`scripts/test_document_map.sh`, `git diff --check`, and
`scripts/validate_repo.sh` pass. The repository test also covers missing
mapped files and duplicate node titles as negative cases.

## Risk

Low. The change adds validation for repository documentation and does not alter
UGS policy semantics, Git hooks, release behavior, or existing document
contents outside the README map.

## Rollback

Revert the Document Map configuration, schema, validator, fixture, design
document, README changes, and the `validate_repo.sh` integration in one
reversion. Existing policy and Git governance files remain independently
usable.

## Breaking Change

No. Repositories are not required to adopt the Document Map format; this CR
governs the UGS repository itself and only adds a repository-local validation
gate.

## Backport Target

None.
