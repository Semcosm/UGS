# CR-0066: Establish layered UGS licensing with official source texts

Base: main
Head or Range: chore/establish-layered-licensing / 32057d8..8acd52c
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: chore(licensing): add layered license propagation
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 32057d8a031d5b07a971f5dfe8f6093f46dd0dcd
Head OID: 8acd52c0e825c24ea7a7b6314d4be7eb1691411f
Integrated Result: pending

## Summary

Establish a layered license notice for UGS: Apache-2.0 covers implementation,
configuration, hooks, adapters, and test components; CC BY 4.0 covers UGS
specifications, guides, release packets, and change-request records. Add the
complete license texts downloaded from the respective official websites and
propagate them through bootstrap packages and initialized repositories.

The official source files are:

- Apache License 2.0:
  https://www.apache.org/licenses/LICENSE-2.0.txt
  SHA-256: cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30
- Creative Commons Attribution 4.0 International:
  https://creativecommons.org/licenses/by/4.0/legalcode.txt
  SHA-256: 9ba9550ad48438d0836ddab3da480b3b69ffa0aac7b7878b5a0039e7ab429411

## Motivation

UGS previously had no selected repository license and its bootstrap template
asked consumers to replace a placeholder without clearly licensing the UGS
components that were copied into consumer repositories. A layered notice
matches the different legal character of reusable implementation material and
attribution-based governance documentation while keeping the consumer
project's own license decision independent.

## Test Evidence

Passed shell and Python syntax checks, `git diff --check` for all non-source
license whitespace, `scripts/validate_repo.sh`,
`scripts/ugs_check.sh --format json`, `scripts/test_bootstrap_equivalence.sh`,
`scripts/test_bootstrap_package.sh`, `scripts/test_bootstrap_upgrade.sh`,
`scripts/test_profile_conformance.sh`, `scripts/test_conformance.sh`,
`scripts/test_git_fixtures.sh`, and `scripts/validate_document_map.py`.
The bootstrap package tests verify that the official texts are included in the
archive and installed under `.ugs/docs/` during initialization and upgrade.

The CC BY source file retains the official downloaded trailing blank line;
therefore Git's optional `blank-at-eof` whitespace warning is excluded only
when checking the staged patch so the source text remains byte-for-byte intact.

## Risk

Low to moderate. The path-based notice could be misunderstood for files with
third-party or explicit file-level terms, so explicit notices and third-party
licenses continue to take precedence. Consumers might also mistake the
project-owned bootstrap `LICENSE` template for a license selection; its text
explicitly requires the consumer to choose a license.

## Rollback

Revert the two signed topic commits through a reviewed CR, or restore the
previous checkout before integration. Do not alter the downloaded official
license source texts or any immutable release tag. If the topic branch has not
been integrated, remove it through the normal branch cleanup process after
review rejection.

## Breaking Change

No. Existing UGS policy profiles and branch-governance behavior are unchanged.
The change adds license declarations, source texts, bootstrap propagation, and
validation coverage; it does not select a license for a consumer project's
own work.

## Backport Target

None.
