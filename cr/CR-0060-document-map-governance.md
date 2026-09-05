# CR-0060: Add configurable Document Map governance

Base: main
Head or Range: working tree based on main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(governance): add configurable Document Map validation
Revision: 1
Status: pending
Decision: pending
Policy Version: v0.3
Base OID: 2f56c8ec2deda73539650d0413ea33eca02c6d92
Head OID: 3c26d5d54560ea5e71b1396e250bc0fb1e3d414c
Integrated Result: pending

## Summary

Add a versioned recursive `.ugs/document-map.json` configuration and matching
schema for the repository's top-level README. Add a dependency-free validator,
fixtures, and repository validation integration. Refresh the README map with
normative specifications, repository governance, roadmap material, and all
historical v0.3 release packets grouped in a nested tree.

## Motivation

The README Document Map had become a manually maintained flat list. As UGS
grows, link existence alone is insufficient: the rendered map must remain
complete, ordered, and structurally aligned with its intended hierarchy. A
separate recursive configuration allows the map to grow without embedding
document-specific paths in the repository validator or policy manifest.

## Test Evidence

`scripts/validate_document_map.py`, `scripts/test_document_map.sh`,
`git diff --check`, and `scripts/validate_repo.sh` pass. The repository test
also covers missing mapped files and duplicate node titles as negative cases.

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
