# CR-0064: Add the full-component bootstrap upgrade flow

Base: main
Head or Range: feat/bootstrap-upgrade-flow
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(bootstrap): add full-component upgrade flow
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: ac9119c8dc96886ebe279da2527d94ff35a1bbf6
Head OID: fa1537cfd37e41223ebcf15f3b414bc5541707e4
Integrated Result: pending

## Summary

Add an offline, full-component upgrade path for existing UGS repositories.
The release package now carries `scripts/ugs.sh`, the upgrade implementation,
profile templates, project-owned bootstrap documents, complete component
metadata, and versioned offline release guidance. The installer supports
dry-run planning, archive and manifest verification, conflict detection,
recoverable backups, rollback, and normal, linked-worktree, and managed-
worktree layouts.

## Motivation

Existing UGS consumers could initialize from a release package but had no
supported way to bring an older repository up to the complete current
component set without manually visiting the web repository and copying files.
The new flow lets a downloaded release stand alone, preserves the active
profile until an explicit activation, protects project-owned files and CR
history, and rejects unsafe archives, paths, special files, and bare Git
object stores.

## Test Evidence

Passed shell syntax checks, Python compilation, `scripts/validate_repo.sh`,
`scripts/ugs_check.sh --format json`, `scripts/test_bootstrap_upgrade.sh`,
`scripts/test_bootstrap_package.sh`, `scripts/test_bootstrap_equivalence.sh`,
`scripts/test_profile_conformance.sh`, `scripts/validate_document_map.py`,
`scripts/test_document_map.sh`, `scripts/validate_cr_coverage.sh HEAD`, and
`git diff --check`. The upgrade fixture covers tampered archives and
manifests, dry-run behavior, profile preservation and activation, rollback,
project-file preservation, filesystem conflicts, all supported worktree
layouts, and bare-repository rejection.

## Risk

Low to moderate. The package installer writes into an existing consumer
worktree and updates `core.hooksPath`; malformed or unexpected project paths
could cause disruption. Archive, manifest, path, mode, ownership, conflict,
and backup checks occur before writes, and project-owned files are preserved
unless explicitly overridden. The release remains additive and does not
alter immutable prior tags.

## Rollback

Use the backup directory printed by a successful upgrade or activation:

```bash
scripts/ugs.sh rollback --backup-dir /path/to/backup /path/to/repository
```

If a published asset is defective, retain `v0.3.26` and publish a later
superseding signed patch release. Do not replace or delete an immutable tag.

## Breaking Change

No. Existing initialization and profile behavior remains available. The new
upgrade protocol requires the component sidecar for releases beginning with
v0.3.27; legacy releases remain downloadable without it.

## Backport Target

None.
