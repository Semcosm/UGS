# CR-0071: Publish the UGS v0.4 vocabulary and compatibility contract

Base: main
Head or Range: chore/v0-4-contract-hardening / a82686d..6e5cd61
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(contract): publish v0.4 vocabulary rules
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: a82686d4113be830687f6ef2eec53ee85f7dc369
Head OID: 6e5cd61e31e9a5f4a7235ae112fc210e1743bf7f
Integrated Result: pending

## Summary

Publish the first v0.4 contract document for UGS vocabulary and policy
compatibility. Define release-line and merge-commit as canonical semantic
terms while retaining the v0.3 wire aliases release and merge. Record the
policy-version versus distribution-SemVer boundary, closed-field behavior,
the x- extension namespace, deprecation classes, and explicit downgrade and
rollback requirements. Register the contract in the document map, generated
README, bootstrap checks, and the offline documentation mirror.

## Motivation

The v0.3 schema and validators use release and merge while normative prose
uses release-line and merge-commit. Without a published compatibility contract,
independent implementations could treat those spellings as different
semantics, infer policy compatibility from a distribution version, or silently
drop unknown fields during migration. This record makes the vocabulary and
compatibility boundary explicit before CR-0072 and CR-0073 add executable
reports and migration tooling.

## Test Evidence

Passed git diff --check, scripts/validate_document_map.py,
scripts/test_document_map.sh, bootstrap source/package equivalence,
scripts/test_bootstrap_package.sh, scripts/validate_repo.sh,
scripts/ugs_check.sh --format json, and scripts/test_conformance.sh. The
document and its offline mirror were also compared byte-for-byte.

## Risk

Low. This change publishes documentation and generated-map/test coverage only;
it does not change the active v0.3 schema, policy manifest, validators, hooks,
protected refs, or accepted Git history. The main risk is a future
implementation interpreting the alias rules inconsistently, which is why the
canonical vocabulary and downgrade behavior are stated explicitly.

## Rollback

Revert the signed topic commit through a reviewed CR, or restore the checkout
to the main base a82686d. Retain this CR as an append-only audit record if the
contract is superseded, and publish a replacement compatibility decision in a
new CR.

## Breaking Change

No. Existing v0.3 manifests, including branching.profile release and
branching.merge_strategy merge, remain valid. The document introduces no new
required field or validator behavior.

## Backport Target

None.
