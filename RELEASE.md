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

- Release signers are repository maintainers.
- Trusted release keys are published through the maintainer's GitHub account or
  other repository-linked maintainer key publication channel.
- Key rotation and revocation events must be documented in release notes or a
  repository notice before the next formal release.

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
git tag -v vX.Y.Z
```

If verification fails:

- do not consume the release
- confirm you have the expected maintainer public key
- check for a published revocation or key-rotation notice
- report the failure before proceeding
