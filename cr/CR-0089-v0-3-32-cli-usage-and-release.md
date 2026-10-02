# CR-0089: Consolidate UGS CLI usage and prepare v0.3.32

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: docs/v0-3-32-cli-usage / 1d3658ff363f4fbca15147bea62e63907418c471..f1ee93d2787043d06c2cbfe120e01da4fbcd9f8d
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Consolidate UGS CLI usage and prepare v0.3.32
Revision: 1
Status: pending
Decision: pending
Policy Version: v0.3
Base OID: 1d3658ff363f4fbca15147bea62e63907418c471
Head OID: f1ee93d2787043d06c2cbfe120e01da4fbcd9f8d
Integrated Result: pending
Coverage OIDs: f1ee93d2787043d06c2cbfe120e01da4fbcd9f8d
Extensions: {}

## Summary

Add a canonical UGS CLI usage guide, stable top-level wrapper help, and
bootstrap-package documentation fixtures as the v0.3.32 release scope. Stage
the release target with the documented basic supply-chain profile so the
post-tag v0.3.32 evidence can bind the immutable tag target and archive digest.

## Motivation

UGS command usage was distributed across the bootstrap quick start, package
semantics guide, and a short wrapper usage line. Agents and human operators
needed one task-oriented command reference that explained initialization,
offline migration, profile activation, branch closure, rollback, validation,
and the boundary between minimal initialization and full package migration.

## Test Evidence

The implementation commit is SSH-signed and includes CLI help, document-map,
bootstrap-package, and release-package fixtures. The topic must pass:

- scripts/test_cli_help.sh
- scripts/validate_document_map.py
- scripts/test_bootstrap_package.sh
- scripts/test_bootstrap_upgrade.sh
- scripts/test_bootstrap_equivalence.sh
- scripts/test_profile_conformance.sh
- scripts/validate_repo.sh
- scripts/ugs_check.sh --format json
- scripts/validate_commit_range.sh main..HEAD
- scripts/validate_commit_signatures.sh main..HEAD

The v0.3.32 release packet also requires a signed annotated tag, a deterministic
bootstrap package, and a separate post-tag supply-chain evidence CR.

## Risk

The change is additive documentation, help output, and fixture coverage. It
does not change the v0.3 policy schema, migration report format, active branch
rules, or existing command behavior. The tag target temporarily declares basic
supply-chain staging to avoid a hash cycle; high-trust evidence is restored only
after the signed tag and package digest are immutable.

## Rollback

Before the tag, revert the signed implementation and CR commits through a new
reviewed CR. Do not delete, replace, or force-update immutable release tags. A
consumer migration can be restored with its external backup using
scripts/ugs.sh rollback.

## Breaking Change

No. The new guide and help output are additive, and upgrade remains a
compatibility alias for migrate.

## Backport Target

None.
