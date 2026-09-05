# CR-0060: Add configurable Document Map governance

Base: main
Head or Range: working tree based on main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(governance): add configurable Document Map validation
Revision: 5
Status: pending
Decision: pending
Policy Version: v0.3
Base OID: 2f56c8ec2deda73539650d0413ea33eca02c6d92
Head OID: 850e0bb31d250615af8474cf21a08f6335ff610d
Integrated Result: pending

## Summary

Add a versioned recursive `.ugs/document-map.json` configuration and matching
schema for the repository's top-level README. Make the configuration the source
for generated README output, including bilingual titles and nested release
packet groups. Add a dependency-free generator, drift checker, fixtures, and
repository validation integration. Keep the feature optional for consumers by
shipping a minimal bootstrap template and an explicit `--with-document-map`
initializer option.

## Motivation

The README Document Map had become a manually maintained flat list. As UGS
grows, link existence alone is insufficient: the rendered map must remain
complete, ordered, bilingual, and structurally aligned with its intended
hierarchy. A separate recursive configuration plus generator makes the tree
the source of truth without embedding document-specific paths in the policy
manifest. Bootstrap and release tests explicitly enable the feature and verify
generation and validation before accepting the package.
The PR adapter normalization is covered by `scripts/test_pr_cr.sh` with an
API-style trailing blank line in the review body.

## Test Evidence

`scripts/generate_document_map.py`, `scripts/validate_document_map.py`,
`scripts/test_document_map.sh`, `scripts/test_bootstrap_package.sh`,
`scripts/test_bootstrap_equivalence.sh`, `git diff --check`, and
`scripts/validate_repo.sh` pass. Bootstrap tests verify both the default
disabled path and the opt-in path; the opt-in path covers generation and
validation of the minimal map.
The GitHub PR adapter also normalizes API-added trailing blank lines before
comparing the generated PR body with the persisted CR.

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
