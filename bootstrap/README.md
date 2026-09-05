# UGS Bootstrap Package

This directory is the source for the versioned UGS bootstrap package. It is
not a hand-maintained copy of an initialized repository. The release builder
packages it together with the generator and the current policy schema.

Run `scripts/ugs_init.sh --help` for the local development entry point.
The generated package supports `baseline`, `standard`, and `high-trust`
profiles. High-trust output contains public trust metadata only; private keys
remain with the operator.
