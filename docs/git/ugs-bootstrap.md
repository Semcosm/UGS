# UGS Bootstrap Package

The bootstrap package is generated from the UGS source tree. It is not a
second hand-maintained repository skeleton.

For local development:

```bash
scripts/ugs_init.sh --profile baseline /path/to/empty-repository
```

The command creates or initializes a Git repository, installs the UGS policy,
schema, CR template, policy validator, and managed hooks, then creates a
signed commit when Git signing and identity are configured. Use `--no-commit`
for a staged initialization, `--dry-run` to inspect the plan, and
`--migrate` to add only missing UGS files to an existing repository.

Every formal release builds `ugs-bootstrap-v<version>.tar.gz` from the tagged
source and publishes it, its manifest, and its SHA-256 file as Release assets.
The manifest binds the package to the source commit and records every payload
file digest. Consumers should verify the signed release tag and checksum
before extracting the package.
