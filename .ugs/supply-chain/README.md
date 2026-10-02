# Supply-chain evidence

The v0.3.32 tag target is a documented basic supply-chain staging point. The
active high-trust declaration on main still names the post-tag v0.3.31 evidence
until the v0.3.32 tag and bootstrap digest are immutable.

After the signed v0.3.32 tag exists, a separate evidence CR will add:

- the v0.3.32 SPDX SBOM;
- the deterministic v0.3.32 build record; and
- the signed v0.3.32 release attestation.

That post-tag change will restore the high-trust evidence paths in
.ugs/policy.json. Historical evidence files remain retained and are not active
paths during staging.

Validate the staged declaration with:

    scripts/validate_supply_chain_profile.sh .ugs/policy.json
    scripts/validate_supply_chain_evidence.sh .ugs/policy.json

Validate the completed release after the evidence CR is integrated with:

    scripts/validate_supply_chain_release.sh v0.3.32 .ugs/policy.json Semcosm/UGS
