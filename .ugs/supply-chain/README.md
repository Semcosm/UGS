# Supply-chain evidence

This directory contains the release evidence for the active high-trust supply-chain profile.

- `v0.3.28.spdx.json` is the SPDX SBOM for the published bootstrap archive.
- `v0.3.28.build.json` records two deterministic local builds and their matching digest.
- `v0.3.28.attestation.json` binds the release, source commit, artifact digest, and builder
  identity with an SSH signature in the `ugs-attestation` namespace.

Validate the declaration and evidence with:

```text
scripts/validate_supply_chain_profile.sh
scripts/validate_supply_chain_evidence.sh
scripts/validate_supply_chain_release.sh v0.3.28 .ugs/policy.json Semcosm/UGS
```
