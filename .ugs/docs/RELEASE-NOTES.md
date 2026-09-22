# UGS v0.3.28

This standalone patch release establishes the UGS layered licensing policy and
ships the complete official license texts with the bootstrap distribution.

## Summary

UGS-authored implementation, configuration, hooks, adapters, and test
components are covered by Apache License 2.0. UGS-authored specifications,
guides, release packets, and change-request records are covered by Creative
Commons Attribution 4.0 International.

The repository includes the official source texts at:

- `LICENSES/Apache-2.0.txt`
- `LICENSES/CC-BY-4.0.txt`

The bootstrap archive carries the same files and installs copies under
`.ugs/docs/` for offline consumers. The consumer repository's root `LICENSE`
remains a project-owned starting template and does not select a license for
the consumer's own work.

## Compatibility

This is an additive, non-breaking patch release. The active UGS v0.3 policy,
high-trust profile, continuous branch profile, `rebase-ff` integration
strategy, and existing release tags are unchanged. Explicit file-level,
third-party, trademark, and attribution terms continue to take precedence
where applicable.

## Verification

Before tagging, run:

```bash
scripts/validate_repo.sh
scripts/ugs_check.sh --format json
scripts/test_bootstrap_package.sh
scripts/test_bootstrap_upgrade.sh
scripts/test_bootstrap_equivalence.sh
scripts/test_profile_conformance.sh
scripts/test_conformance.sh
scripts/test_git_fixtures.sh
scripts/validate_document_map.py
scripts/validate_commit_range.sh v0.3.27..HEAD
scripts/validate_commit_signatures.sh v0.3.27..HEAD
scripts/validate_cr_coverage.sh HEAD
```

After publication, verify the signed release object and downloaded package:

```bash
scripts/validate_release_tag.sh v0.3.28
sha256sum -c ugs-bootstrap-v0.3.28.tar.gz.sha256
scripts/test_bootstrap_release.sh v0.3.28
```

The Apache source hash is
`cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30`; the CC
BY source hash is
`9ba9550ad48438d0836ddab3da480b3b69ffa0aac7b7878b5a0039e7ab429411`.

## Rollback

Do not delete, replace, or force-update `v0.3.27` or `v0.3.28`. If the release
package or notice is defective, preserve the immutable tag and publish a later
superseding patch release through a new signed CR. Consumers can restore a
previous bootstrap installation using the backup created by `scripts/ugs.sh`.

## Breaking Change

No. This release changes licensing notices and distribution contents only; it
does not change UGS branch governance or select a license for consumer work.

## Backport Target

None.
