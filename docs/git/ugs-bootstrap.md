# UGS Bootstrap Package

The bootstrap package is generated from the UGS source tree. It is not a
second hand-maintained repository skeleton.

For local development:

```bash
scripts/ugs_init.sh --profile baseline /path/to/empty-repository
scripts/ugs_init.sh --profile standard /path/to/empty-repository
scripts/ugs_init.sh --profile high-trust /path/to/empty-repository
```

The command creates or initializes a Git repository, installs the UGS policy,
schema, CR template, policy validator, and managed hooks, then creates a
commit when Git identity is configured. `standard` additionally installs the
quality profile documents, profile validators, supply-chain evidence landing
area, and an optional GitHub compatibility adapter with a SHA-pinned workflow.
The baseline profile contains only Git-native Core material. Use `--no-commit` for a staged
initialization, `--dry-run` to inspect the plan, and `--migrate` to add only
missing UGS files to an existing repository.

`high-trust` additionally installs the public signer registry and signature
validators. It never generates or packages private keys; a normal high-trust
initialization requires the operator's SSH signing key, while `--no-commit`
supports preparing a repository before trust material is configured.

Every formal release builds `ugs-bootstrap-v<version>.tar.gz` from the tagged
source and publishes it, its manifest, and its SHA-256 file as Release assets.
The manifest binds the package to the source commit and records every payload
file digest. The single package contains all supported profile templates;
`--profile` selects the generated repository shape. Consumers should verify
the signed release tag and checksum before extracting the package.

The release workflow includes a consumer job that downloads the published
assets through the GitHub Releases API on a clean runner. It verifies the
release tag, checksum, source commit, embedded manifest, every payload digest,
and then initializes a second clean repository from the extracted package.
