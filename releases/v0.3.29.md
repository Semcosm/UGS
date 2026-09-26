# UGS v0.3.29

This governance patch release records the current UGS v0.3 documentation and
attestation status and publishes the repository state needed for the next
post-tag supply-chain evidence update.

## Summary

The release includes the reconciled roadmap and canonical CR-contract wording
for the delivered `ugs-cr-attestation/v1` capability. It also carries the
release packet for the two-phase v0.3.29 supply-chain publication.

The signed tag target intentionally uses `supply_chain.profile: basic` and
does not carry evidence paths. This is a staging state required by the
current evidence contract: an evidence file that names the tag target commit
cannot be committed into that same commit without a hash cycle. The tag is
therefore not a claim that the tag checkout is high-trust evidence-complete.

After the immutable tag is published, a separate signed CR will build the
bootstrap archive twice with `SOURCE_DATE_EPOCH=0`, record the matching
artifact digest, generate an SPDX SBOM and build record, create a signed
`ugs-attestation`, and restore the main branch to `high-trust` with v0.3.29
evidence paths.

## Compatibility

This is an additive, non-breaking governance release. The branch, review,
commit-signing, release-tag, and bootstrap contracts remain unchanged. The
temporary basic profile applies only to the immutable v0.3.29 tag target and
is explicitly superseded by the post-tag evidence CR on `main`. Existing
v0.3.28 evidence and tag objects are not modified.

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
scripts/validate_commit_range.sh v0.3.28..HEAD
scripts/validate_commit_signatures.sh v0.3.28..HEAD
scripts/validate_cr_coverage.sh HEAD
```

After publication and the evidence CR, verify:

```bash
scripts/validate_release_tag.sh v0.3.29
scripts/test_bootstrap_release.sh v0.3.29
scripts/validate_supply_chain_release.sh v0.3.29 .ugs/policy.json Semcosm/UGS
```

The post-tag CR must record the tag target commit, both deterministic build
runs, the final archive digest, all evidence paths, and the signed attestation
verification result.

## Rollback

Release tags are append-only. Do not delete, replace, or force-update
`v0.3.28` or `v0.3.29`. If the staging tag, archive, or evidence is
defective, leave the immutable objects in place and publish a later signed
superseding patch through a new CR. If the post-tag policy update is rejected,
revert it through a reviewed CR while retaining the audit records and tag.

## Breaking Change

No. This release adds documentation and an explicitly documented, temporary
release staging step; it does not change runtime behavior or consumer branch
governance.

## Backport Target

None.
