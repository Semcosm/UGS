# CR-0006: require trusted commit signatures

Base: `main` at `e904990`
Head or Range: `chore/repo-high-trust-signing`
Title: `chore(repo): require trusted commit signatures`

## Summary

Upgrade the repository from release-tag-only signing to high-trust SSH commit
signing with a repository-tracked signer registry, local hook enforcement, and
GitHub workflow verification.

## Motivation

The repository already enforced commit structure and equivalent CR records, but
it still relied on a lower signing baseline. A self-hosted trust registry and
automated signature verification close that remaining gap.

## Test Evidence

- `bash -n .githooks/pre-push scripts/validate_repo.sh scripts/validate_commit_signatures.sh scripts/validate_cr_record.sh`
- `scripts/validate_commit_signatures.sh main..HEAD`
- `scripts/validate_repo.sh`
- disposable repository tests for SSH-signed commit and tag verification with `keys/allowed_signers`

## Risk

Contributors using an unregistered SSH signing key, an unsigned workflow, or a
revoked key will be blocked by hooks and CI until their local setup matches the
trusted signer registry.

## Rollback

Revert the signing-enforcement change on a topic branch and re-integrate
through the same CR flow, or rotate signer trust material through the emergency
path if the failure is caused by key compromise.

## Breaking Change

Yes. Commits proposed for integration must now be SSH-signed and trusted by the
repository's signer registry.

## Backport Target

None.
