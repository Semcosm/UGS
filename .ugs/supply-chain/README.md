# Supply-chain evidence

The active `high-trust` declaration binds the immutable v0.3.32 release tag,
the published bootstrap archive, and the evidence files stored in this
directory.

- release tag: `v0.3.32`
- tag target: `5e64de215dc6d61206763c7ff83d4b4c1a435124`
- bootstrap archive: `ugs-bootstrap-v0.3.32.tar.gz`
- archive digest: `sha256:f336e16ca0d92e491ea7e22c319def153d86461748b7fc88a96a026b595ce0d0`
- builder: `local/chenzhipeng.main@gmail.com`
- reproducibility: two `SOURCE_DATE_EPOCH=0` builds with identical digests

Evidence paths declared by `.ugs/policy.json`:

- `.ugs/supply-chain/v0.3.32.spdx.json`
- `.ugs/supply-chain/v0.3.32.build.json`
- `.ugs/supply-chain/v0.3.32.attestation.json`

Validate the active declaration and release evidence with:

    scripts/validate_supply_chain_profile.sh .ugs/policy.json
    scripts/validate_supply_chain_evidence.sh .ugs/policy.json
    scripts/validate_supply_chain_release.sh v0.3.32 .ugs/policy.json Semcosm/UGS

The release attestation is SSH-signed in the `ugs-attestation` namespace by
the trusted `chenzhipeng.main@gmail.com` signer. The provenance records a local
trusted builder and does not claim hosted CI signing.
