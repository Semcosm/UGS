# CR-0080: Self-bootstrap the repository with v0.3.29

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: chore/self-bootstrap-v0-3-29 / 5f66d4a93b304772d022e67202ef76a9f0837684..1acf34766987bfd9d134d6e9f29361f8bd99d6c1
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Self-bootstrap the repository with v0.3.29
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 5f66d4a93b304772d022e67202ef76a9f0837684
Head OID: 1acf34766987bfd9d134d6e9f29361f8bd99d6c1
Integrated Result: pending
Coverage OIDs: none
Extensions: {}

## Summary

Self-bootstrap the UGS repository from the published v0.3.29 component archive.
Refresh installed metadata, release notes, offline examples, release navigation,
and the bootstrap equivalence default while preserving the active high-trust
supply-chain declaration and release evidence.

## Motivation

The repository remained self-bootstrapped from v0.3.28 after the signed v0.3.29
release and its post-tag evidence integration. The published archive is immutable
and has source commit `0a0278dd20394efcaf77b6f79859c5de8b0b38c7` with digest
`sha256:c5387f414d1f66c1e3f28d68abf525c0b5960a1b6ec5f44e7e5abfe877a2b797`.
Aligning the repository's own installation metadata and navigation makes the
current release discoverable without changing the release tag or asset.

## Test Evidence

The archive checksum passed `sha256sum -c`; its manifest bound v0.3.29 to tag
target `0a0278dd20394efcaf77b6f79859c5de8b0b38c7`. The dry run completed with
no conflicts and reported 88 operations: 4 updates, 76 unchanged files, and 8
project-preserved files. The real upgrade completed with a recoverable backup at
`/tmp/ugs-v0.3.29-self-bootstrap.F95z4n/backup` and report
`/tmp/ugs-v0.3.29-self-bootstrap.F95z4n/upgrade-report.json`. It updated
`.ugs/bootstrap.json`, `.ugs/installation.json`, and
`.ugs/docs/RELEASE-NOTES.md`; the archive's generic supply-chain README was
explicitly restored to the active v0.3.29 high-trust evidence explanation.
The evidence files and `.ugs/policy.json` were not changed.

The document-map generator and validator, repository validator, JSON conformance
check, independent conformance fixtures, Git fixtures, profile conformance,
bootstrap package and upgrade fixtures, default v0.3.29 bootstrap equivalence,
signed release-tag validation, published bootstrap release consumption, and
`scripts/validate_supply_chain_release.sh v0.3.29 .ugs/policy.json
Semcosm/UGS` all passed. The implementation commit and topic range also pass
the commit-message, signature, and whitespace checks.

## Risk

This is an additive self-bootstrap metadata and documentation update. The active
profile remains high-trust, project-owned files remain preserved, and the v0.3.29
tag, archive, checksum, and evidence remain immutable. The post-tag source docs
and examples intentionally describe the current release for future package builds;
they do not rewrite or replace the already-published v0.3.29 asset. Remaining
v0.3.28 references are historical release entries, comparison ranges, retained
evidence, or rollback wording rather than active installation metadata.

## Rollback

Restore the pre-upgrade files with:

```text
scripts/ugs.sh rollback --backup-dir /tmp/ugs-v0.3.29-self-bootstrap.F95z4n/backup /home/chen/git-repos/UGS
```

If the topic is rejected after review, revert the signed implementation and CR
commits through a new reviewed CR. Never delete, replace, or force-update the
immutable v0.3.29 tag or published archive.

## Breaking Change

No. The change aligns repository metadata and documentation with an existing
release without changing policy behavior, active profile, or consumer commands.

## Backport Target

None.
