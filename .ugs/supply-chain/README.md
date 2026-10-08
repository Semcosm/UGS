# Supply-chain evidence

The active high-trust declaration binds the immutable v0.3.33 release tag,
the published bootstrap archive, and the evidence files stored in this
directory.

- release tag: v0.3.33
- tag target: 5a75abe5534b5e66066571e7d6c0b2428d6258cf
- bootstrap archive: ugs-bootstrap-v0.3.33.tar.gz
- archive digest: sha256:ae01352f5e6ecc934fd226795de2512d5b970851d4b4eff2d0b564df8ec6f1e8
- builder: local/chenzhipeng.main@gmail.com
- reproducibility: two SOURCE_DATE_EPOCH=0 builds with identical digests

Evidence paths declared by .ugs/policy.json:

- .ugs/supply-chain/v0.3.33.spdx.json
- .ugs/supply-chain/v0.3.33.build.json
- .ugs/supply-chain/v0.3.33.attestation.json

Validate the active declaration and release evidence with:

    scripts/validate_supply_chain_profile.sh .ugs/policy.json
    scripts/validate_supply_chain_evidence.sh .ugs/policy.json
    scripts/validate_supply_chain_release.sh v0.3.33 .ugs/policy.json Semcosm/UGS

The release attestation is SSH-signed in the ugs-attestation namespace by
the trusted chenzhipeng.main@gmail.com signer. The provenance records a local
trusted builder and does not claim hosted CI signing.
