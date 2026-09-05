# UGS Bootstrap Package

The bootstrap package is generated from the UGS source tree. It is not a
second hand-maintained repository skeleton.

For local development:

```bash
scripts/ugs_init.sh --profile baseline /path/to/empty-repository
scripts/ugs_init.sh --profile standard /path/to/empty-repository
scripts/ugs_init.sh --profile high-trust /path/to/empty-repository
```

Document Map support is optional and is not installed by default. To enable
the feature, pass `--with-document-map`:

```bash
scripts/ugs_init.sh --profile standard --with-document-map /path/to/empty-repository
```

The bootstrap package then installs a minimal
`.ugs/document-map.json`, `document-map.schema.json`, and the generator and
checker scripts. The minimal template maps only `README.md`; users extend the
tree as their documentation grows. `scripts/generate_document_map.py` renders
the configured tree, while `scripts/validate_document_map.py` checks that the
README has not drifted. Standard workflows invoke the checker only when the
configuration exists.

The published package's release tests must initialize at least one consumer
with `--with-document-map` and pass both generation and validation checks. This
keeps the feature optional for consumers while making it a tested capability
of every UGS bootstrap release.

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
