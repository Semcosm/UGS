# CR-0008: add dedicated UGS signing key

Base: `main` at `670e72d`
Head or Range: `docs/v0-2-close-v0-3-plan`
Title: `chore(repo): add dedicated UGS commit and release signing key`
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.2
Base OID: 670e72d4b87beb6b7aee8a06c90c3bd44c8300d9
Head OID: 6d7e94a43c8bdb2fef8fa4b0dde170379746bbe6
Integrated Result: main@6d7e94a43c8bdb2fef8fa4b0dde170379746bbe6

## Summary

Add the maintainer's dedicated UGS SSH signing key to the trusted signer
registry for commit and annotated release-tag signatures. Keep the existing
trusted key active while the new key is verified and adopted.

## Motivation

The repository transport key used for GitHub access is intentionally separate
from the key used to attest commits and releases. A dedicated signing key
allows the transport credential to be rotated or revoked without changing the
provenance of UGS history and release objects.

## Test Evidence

- `ssh-keygen -lf ~/.ssh/ugs-signing.pub` reports
  `SHA256:VWD+zcyeXSeY7RdeXxcnFYSt+r5DA4dhrYrNMfP5tjU`.
- The public key line is recorded in `keys/allowed_signers`; private key
  material is not stored in the repository.
- Existing high-trust commits remain verifiable with the pre-existing signer.
- After the signed integration commit is created, run
  `scripts/validate_repo.sh`,
  `scripts/validate_commit_range.sh main..HEAD`, and
  `scripts/validate_commit_signatures.sh main..HEAD`.

## Risk

Adding a signer expands the set of identities that can attest repository
changes. The existing signer is retained during transition so that a failed
new-key setup does not strand the repository; the new private key must remain
passphrase-protected and must never be committed or uploaded as a deploy key.

## Rollback

Revoke or remove the new public-key entry through a subsequent signed CR if
the key is lost or compromised. Do not rewrite commits or release tags that
were already signed with the key; publish a superseding release if necessary.

## Breaking Change

No. This adds a trusted signer and does not invalidate existing keys, commits,
or release objects.

## Backport Target

None.
