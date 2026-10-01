# UGS v0.3.31

This release adds safe, auditable branch closure for short-lived topic
branches and publishes the command in the bootstrap package.

## Summary

The new scripts/ugs.sh branch close command validates policy-protected refs,
declared topic prefixes, target reachability, integrated CR evidence, worktree
use, and remote OID leases before deleting a branch. Archive mode preserves an
abandoned branch tip under refs/ugs/archive/<branch> with an explicit reason.
Dry-run and ugs-branch-close/v1 JSON reports support review and automation.

The disposable branch-close fixtures cover merged and unmerged branches,
archive mode, protected refs, linked worktrees, remote OID mismatch,
idempotence, dry-run side effects, and report shape. The bootstrap component
manifest includes scripts/branch_close.py for all profiles.

## Included scope

- add the branch close and archive command to scripts/ugs.sh;
- enforce policy, CR, worktree, target, and remote OID safety checks;
- add idempotent local close markers and archive refs;
- add disposable branch-close fixtures and documentation; and
- publish the v0.3.31 bootstrap component and release packet.

## Compatibility

The policy schema and policy_version 0.3 remain unchanged. The command is
opt-in. Existing bootstrap commands and active profiles continue to work.

## Verification

The release candidate must pass:

    scripts/validate_repo.sh
    scripts/ugs_check.sh --format json
    scripts/test_conformance.sh
    scripts/test_git_fixtures.sh
    scripts/test_branch_close.sh
    scripts/test_bootstrap_package.sh
    scripts/test_bootstrap_upgrade.sh
    scripts/test_bootstrap_equivalence.sh
    scripts/test_profile_conformance.sh
    scripts/validate_document_map.py
    scripts/validate_cr_coverage.sh HEAD
    scripts/validate_commit_range.sh v0.3.30..HEAD
    scripts/validate_commit_signatures.sh v0.3.30..HEAD

The tag target uses the validated basic supply-chain staging profile because
post-tag evidence must bind the immutable target commit. After publication,
CR-0086 adds the v0.3.31 SPDX SBOM, deterministic build record, signed
attestation, and high-trust evidence paths on main.

## Rollback

Release tags are append-only. Do not delete, replace, or force-update v0.3.30
or v0.3.31. If the command, archive, or evidence is defective, retain the
immutable objects and publish a later signed superseding patch through a new
CR. A normal branch close can be recovered from its recorded source OID.

## Breaking Change

No. This release adds an opt-in branch management command and its bootstrap
component.

## Backport Target

None.
