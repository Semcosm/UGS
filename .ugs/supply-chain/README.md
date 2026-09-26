# Supply-chain evidence

The active `high-trust` declaration is backed by the v0.3.29 release evidence:

- `v0.3.29.spdx.json` is the SPDX SBOM for the published bootstrap archive.
- `v0.3.29.build.json` records two deterministic local builds and their matching digest.
- `v0.3.29.attestation.json` binds the release, tag target commit, artifact digest, and
  builder identity with an SSH signature in the `ugs-attestation` namespace.

The immutable v0.3.29 tag itself was intentionally a documented `basic`
staging point because evidence that names a tag target cannot be committed
into that same commit without a hash cycle. The post-tag evidence CR restored
`high-trust` on `main`; the tag checkout must not be described as evidence-
complete high-trust. The historical v0.3.28 evidence files remain retained but
are not active paths.

Validate the declaration and evidence with:

```text
scripts/validate_supply_chain_profile.sh .ugs/policy.json
scripts/validate_supply_chain_evidence.sh .ugs/policy.json
scripts/validate_supply_chain_release.sh v0.3.29 .ugs/policy.json Semcosm/UGS
```
