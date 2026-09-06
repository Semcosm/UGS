# UGS Bootstrap Package

This directory is the source for the versioned UGS bootstrap package. It is
not a hand-maintained copy of an initialized repository. The release builder
packages it together with the generator and the current policy schema.

Start with [OFFLINE-QUICKSTART.md](OFFLINE-QUICKSTART.md) for a complete,
offline consumer walkthrough. Run `scripts/ugs_init.sh --help` for the local
development entry point.
The generated package supports `baseline`, `standard`, and `high-trust`
profiles. High-trust output contains public trust metadata only; private keys
remain with the operator.

## Optional Document Map

Document Map governance is opt-in. Enable it during initialization with:

```bash
scripts/ugs_init.sh --profile standard --with-document-map /path/to/empty-repository
```

This installs `.ugs/document-map.json`, its schema, and the generator/checker
scripts. The starter configuration maps only the repository README; add
document nodes to the configuration and run
`scripts/generate_document_map.py` to render the README section. Run
`scripts/validate_document_map.py` before committing. Standard workflows run
the checker automatically whenever `.ugs/document-map.json` exists.

Repositories that do not opt in receive no Document Map files and are not
required to use this feature. Release tests always exercise the opt-in path so
the published package cannot silently ship a broken Document Map capability.

The baseline profile keeps the GitHub adapter optional. Its CR helper wrappers
report how to enable the adapter instead of failing on a missing target. Use
`--profile standard` or `--profile high-trust` (with `--migrate` for an existing
baseline repository) to install the GitHub adapter;
the bare-Git update adapter and its Core ref-update validator are included in
every profile.

## Offline UGS Documentation

The release archive includes the UGS guidance needed to use the package
without opening the project website. Start with
[`OFFLINE-QUICKSTART.md`](OFFLINE-QUICKSTART.md) and
`docs/git/ugs-bootstrap.md`, then use the local Core, v0.3 profile,
conformance-level, commit, review, and release policy documents under
`docs/git/`. `CONTRIBUTING.md` and `RELEASE.md` are included as local
operational guides. These documents are copied from the same tagged source as
the package and are listed with checksums in `MANIFEST.json`. When available,
`RELEASE-NOTES.md` is the release packet for the archive's version.
