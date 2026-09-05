# UGS Bootstrap Package

This directory is the source for the versioned UGS bootstrap package. It is
not a hand-maintained copy of an initialized repository. The release builder
packages it together with the generator and the current policy schema.

Run `scripts/ugs_init.sh --help` for the local development entry point.
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
