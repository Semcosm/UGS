# Release Guide

This repository uses signed annotated tags as formal release objects.

## Release Object

- Tag form: `v<major>.<minor>.<patch>`
- Tag type: signed annotated tag
- Versioning: `semver`

## Release Preconditions

Before creating a release tag, ensure:

- the target commit is explicit
- release notes are prepared
- compatibility impact is understood
- rollback guidance is available when applicable

## Signing

- Release signers are repository maintainers whose SSH signing keys are trusted
  in `keys/allowed_signers`.
- Revoked or compromised signing keys are recorded in `keys/revoked_signers`.
- Key rotation and revocation events must be documented in release notes or a
  repository notice before the next formal release.
- The same trust registry is used to verify protected-branch commits and formal
  release tags.

## Create A Release

```bash
git checkout main
git pull --ff-only
git tag -s vX.Y.Z -m "UGS vX.Y.Z"
git push origin vX.Y.Z
```

## Verify A Release

```bash
git fetch --tags origin
git -c gpg.format=ssh \
  -c gpg.ssh.allowedSignersFile=keys/allowed_signers \
  -c gpg.ssh.revocationFile=keys/revoked_signers \
  tag -v vX.Y.Z
```

If verification fails:

- do not consume the release
- confirm the signer is present in `keys/allowed_signers`
- check `keys/revoked_signers` and any published key-rotation notice
- report the failure before proceeding
