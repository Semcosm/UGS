# CR-0065: Self-bootstrap UGS repository from the v0.3.27 release

Base: main
Head or Range: chore/self-bootstrap-v0-3-27
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: chore(bootstrap): self-bootstrap repository with v0.3.27
Revision: 1
Status: pending
Decision: pending
Policy Version: v0.3
Base OID: 33827e98046ee41c7b919700f681748871086400
Head OID: fbec7f716aa92c7f92d5b485a16d26c8309c02bc
Integrated Result: pending

## Summary

Upgrade the UGS repository itself from the remote GitHub Release
`v0.3.27` bootstrap archive. Install the complete component set and persist
the `ugs-bootstrap/v1` and `ugs-installation/v1` metadata for the upgraded
worktree.

## Motivation

The repository had the v0.3 policy and source components but did not carry the
consumer-facing bootstrap installation metadata or the complete offline,
template, documentation, and supply-chain component set. Self-bootstrapping
through the published release exercises the same upgrade path provided to UGS
consumers and binds the installation to a signed, immutable release artifact.

## Test Evidence

The remote assets were downloaded with the GitHub release adapter and passed
SHA-256 verification. The archive manifest source commit matched
`33827e98046ee41c7b919700f681748871086400`. Dry-run reported no conflicts and
preserved the active `high-trust` profile and project-owned files. The upgrade
created a recoverable backup at
`/tmp/ugs-v0.3.27-upgrade-backup-1788848129731`.

Passed `scripts/validate_repo.sh`, `scripts/ugs_check.sh --format json`,
`scripts/test_bootstrap_package.sh`, `scripts/test_bootstrap_upgrade.sh`,
`scripts/test_bootstrap_equivalence.sh`, `scripts/test_profile_conformance.sh`,
`scripts/validate_document_map.py`, `scripts/validate_release_tag.sh v0.3.27`,
and the remote `scripts/test_bootstrap_release.sh v0.3.27` consumer check.

## Risk

Low. The upgrade is additive, preserves project-owned files and CR history,
does not change the active policy profile, and has a recoverable backup. The
main operational risk is accidental replacement of project-owned files during
a future upgrade; this operation used the default preservation behavior.

## Rollback

Restore the pre-upgrade worktree with:

```bash
scripts/ugs.sh rollback \
  --backup-dir /tmp/ugs-v0.3.27-upgrade-backup-1788848129731 \
  /home/chen/git-repos/UGS
```

If the committed upgrade is rejected, revert the signed upgrade commit through
a new reviewed CR. Do not replace or delete the immutable `v0.3.27` tag.

## Breaking Change

No. The active `high-trust` profile, `continuous` branch profile,
`rebase-ff` strategy, project-owned files, and existing CR history remain
unchanged.

## Backport Target

None.
