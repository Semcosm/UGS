# CR-0073: Add offline migration reports and verified rollback

Base: main
Head or Range: chore/v0-4-migration-rollback / ac78a13251e2978d0e1f519ae3acf601788f91d7
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: feat(bootstrap): add offline migration reports and verified rollback
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: abea026e06c91c50df837a86f2c0794f696ded38
Head OID: ac78a13251e2978d0e1f519ae3acf601788f91d7
Integrated Result: pending

## Summary

Add an explicit offline `migrate` command for full-component bootstrap
transitions while preserving `upgrade` as a compatibility alias. Emit the
versioned `ugs-migration/v1` inventory report, write digest-and-mode backup
metadata, and verify file, permission, and `core.hooksPath` restoration during
rollback. Keep the active profile unchanged during migration and document the
flow in the online and offline bootstrap mirrors.

## Motivation

The bootstrap upgrade path can already install a complete component set, but
consumers need an auditable dry-run preview, machine-readable migration
evidence, and a verified recovery path before using it for repository
migrations. The v0.4 roadmap requires an offline migration command that can
preview changes, create a recoverable backup, and emit a post-migration report.

## Test Evidence

Passed `scripts/test_bootstrap_equivalence.sh`,
`scripts/test_bootstrap_package.sh`, `scripts/test_bootstrap_upgrade.sh`,
`scripts/test_conformance.sh`, `scripts/test_profile_conformance.sh`,
`scripts/test_git_fixtures.sh`, `scripts/validate_repo.sh`,
`scripts/ugs_check.sh --format json`, `python3 -m py_compile
scripts/ugs_upgrade.py`, and `git diff --check`. The JSON conformance report
returned `result: pass`; migration fixtures verified dry-run reporting, backup
metadata, rollback verification, unchanged Git HEAD, and the `migrate` alias.

## Risk

Low to moderate. The migration writes the complete package component set and
touches Git hook configuration, so an incorrect inventory or rollback check
could affect a consumer repository. Existing project-owned files and CR
history remain preserved by default, conflicts abort before writes, and the
backup metadata plus post-rollback verification provide an auditable recovery
boundary.

## Rollback

Revert the signed implementation and CR commits through a reviewed CR, or
restore the checkout to Base OID
`abea026e06c91c50df837a86f2c0794f696ded38`. For a consumer migration, invoke
the printed `scripts/ugs.sh rollback --backup-dir <path> <repository>` command
and confirm the generated `ROLLBACK-REPORT.json` reports `verified: true`.

## Breaking Change

No. `upgrade` remains available as a compatibility alias, the active profile is
preserved during migration, and existing project-owned files and CR history
remain protected by default. The new report and backup formats are additive and
versioned.

## Backport Target

None.
