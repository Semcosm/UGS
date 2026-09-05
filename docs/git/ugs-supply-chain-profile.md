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

The profile is additive and optional. Repositories without this section remain
valid v0.3 repositories, and a declaration does not retroactively invalidate
older releases or v0.2 history.
