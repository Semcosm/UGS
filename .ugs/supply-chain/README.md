# Supply-chain evidence

The v0.3.29 release tag is an explicitly documented staging point. Its
`supply_chain.profile` is temporarily `basic` and it carries no active
evidence paths, because evidence that names the tag target commit cannot be
committed into that same commit without a hash cycle. The tag checkout is not
a claim of evidence-complete high-trust provenance.

The existing `v0.3.28.*` files are retained as historical evidence for the
previous release but are not declared by the staging policy. A post-tag signed
CR will add the v0.3.29 SPDX SBOM, deterministic build record, and signed
`ugs-attestation`, then restore the active `high-trust` policy and evidence
paths on `main`.

For the staging checkout, validate the declaration with:

```text
scripts/validate_supply_chain_profile.sh .ugs/policy.json
scripts/validate_supply_chain_evidence.sh .ugs/policy.json
```

After the evidence CR is integrated, validate the active release with:

```text
scripts/validate_supply_chain_profile.sh .ugs/policy.json
scripts/validate_supply_chain_evidence.sh .ugs/policy.json
scripts/validate_supply_chain_release.sh v0.3.29 .ugs/policy.json Semcosm/UGS
```
