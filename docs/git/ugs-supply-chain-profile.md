# UGS Supply-Chain Profile

The optional supply-chain profile declares the strength of a repository's
software provenance evidence without prescribing a language, package manager,
or build service.

```json
{
  "supply_chain": {
    "profile": "basic",
    "action_pinning": "declared",
    "sbom": "declared",
    "reproducible_builds": "declared",
    "release_attestations": "declared"
  }
}
```

`basic` requires every capability to be declared. `standard` requires actions
to use full commit-SHA pinning, a release SBOM, build evidence, and signed
release attestations. `high-trust` additionally requires a verified
reproducible build. The reference validator checks the declared contract;
tool-specific production of SBOMs and attestations remains outside the UGS
Core.

The optional `evidence` object lists repository-relative paths for SBOMs,
attestations, and build records. Paths must not be absolute or escape the
repository. `scripts/validate_supply_chain_evidence.sh` checks the path
contract and profile-specific minimums. `scripts/validate_sbom.sh` accepts
SPDX and CycloneDX documents and requires component identity, version, build
time, source commit, and release metadata.

The profile is additive and optional. Repositories without this section remain
valid v0.3 repositories, and a declaration does not retroactively invalidate
older releases or v0.2 history.

Release attestations use `scripts/validate_release_attestation.sh` and bind a
release tag to a commit, artifact SHA-256 digest, builder identity, and build
timestamp. `scripts/validate_supply_chain_release.sh` applies those checks to
the evidence paths during tag validation.
