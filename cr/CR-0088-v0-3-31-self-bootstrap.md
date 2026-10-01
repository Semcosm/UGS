# CR-0088: Self-bootstrap the repository with v0.3.31

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: chore/self-bootstrap-v0-3-31 / 5919bedd0721ae8460826dee9f68a516b1c13970..e188d94830127fc242b03154611e30fb6e5f2a0a
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Self-bootstrap the repository with v0.3.31
Revision: 3
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 5919bedd0721ae8460826dee9f68a516b1c13970
Head OID: e188d94830127fc242b03154611e30fb6e5f2a0a
Integrated Result: pending
Coverage OIDs: none
Extensions: {}

## Summary

Self-bootstrap the UGS repository from the published v0.3.31 component archive.
Refresh installed metadata and offline documentation while preserving the
active high-trust profile, repository-specific document architecture, CR
history, and v0.3.31 release evidence.

## Motivation

The repository code and documentation had reached v0.3.31, but its own
`.ugs/installation.json` and `.ugs/bootstrap.json` still identified v0.3.29.
Aligning those records with the immutable published package verifies that UGS
can consume its own current stable distribution before v0.4.0 work begins.

The package archive is `ugs-bootstrap-v0.3.31.tar.gz` with SHA-256
`9e0d0a1c93f77cfa36126cc1f2c2d83e8ae620e241cf7438940744b9c1ec3e04`; its
manifest binds source commit `92f8de3daf286dd06ac87017f9c95126460dd6e0`, the
signed `v0.3.31` tag target.

## Test Evidence

The published archive download and checksum verification passed. Its dry-run
upgrade detected the existing normal layout and high-trust profile with no
conflicts: 75 components were unchanged, 8 project-owned files were preserved,
and 6 UGS-owned files were updated. The real upgrade wrote
`v0.3.31` to both installation metadata files and produced an external backup
and `ugs-migration/v1` report.

Rollback was then executed from that backup and verified 6 restored files and
the hooks path with `verified: true`; the v0.3.31 upgrade was applied again
with a final external backup at `/tmp/ugs-self-bootstrap-v0.3.31-final-backup.ZjclrB`
and report `/tmp/ugs-self-bootstrap-v0.3.31.Y3qvPm/final-upgrade-report.json`.

Repository validation, JSON conformance, independent conformance, Git and
branch-close fixtures, bootstrap package and upgrade fixtures, v0.3.31 source
package equivalence, all three profile fixtures, Document Map validation, CR
coverage, commit range, and commit signature checks all passed. The v0.3.31
release tag, SBOM, build record, attestation, and supply-chain release checks
also passed. The published archive was consumed successfully in disposable
baseline, standard, high-trust, and Document Map repositories.

## Risk

The change updates UGS-owned installation metadata and offline copies only. The
active `high-trust` profile and `policy_version: 0.3` remain unchanged.
Project-owned README, governance documents, release history, CR records, and
the active v0.3.31 supply-chain evidence remain preserved. The generic package
supply-chain README was replaced in this repository by the current evidence
explanation so the active declaration remains auditable.

## Rollback

Restore the pre-upgrade files with:

```text
scripts/ugs.sh rollback --backup-dir /tmp/ugs-self-bootstrap-v0.3.31-final-backup.ZjclrB /home/chen/git-repos/UGS
```

If the topic is rejected after review, revert the signed implementation and CR
commits through a new reviewed CR. Never delete, replace, or force-update the
immutable v0.3.31 tag or published archive.

## Breaking Change

No. This aligns the repository with an existing stable bootstrap distribution
without changing policy behavior, the active profile, or consumer commands.

## Backport Target

None.
