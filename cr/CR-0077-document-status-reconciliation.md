# CR-0077: Reconcile roadmap and CR attestation status

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: docs/cr-0077-document-status / 77f2bc329a62cf71ae3a204addaa939c4acd929a..7e2f66d72b96bcbc94930ee57ff196e3a8b8b416
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Reconcile roadmap and CR attestation status
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: 77f2bc329a62cf71ae3a204addaa939c4acd929a
Head OID: 7e2f66d72b96bcbc94930ee57ff196e3a8b8b416
Integrated Result: main@7e2f66d72b96bcbc94930ee57ff196e3a8b8b416
Coverage OIDs: none
Extensions: {}

## Summary

Reconcile current roadmap and canonical CR-contract wording with the delivered
`ugs-cr-attestation/v1` capability. Keep the historical CR-0074 record
append-only while making the active planning documents describe the optional
attestation contract and the remaining cross-release evidence work accurately.

## Motivation

CR-0076 defines and integrates signed reviewer and test attestations, but the
v0.3 and long-term roadmaps still describe that contract as future work. The
canonical CR contract also used an outdated Phase B description. Leaving those
statements unchanged can make an audit misread delivered capability as
unimplemented. The CR-0074 risk paragraph is retained as a historical snapshot
of the earlier change and is not rewritten.

## Test Evidence

The topic changes passed `git diff --check`, kept
`docs/git/ugs-cr-contract.md` byte-for-byte identical to
`.ugs/docs/git/ugs-cr-contract.md`, and passed `scripts/validate_repo.sh`,
`scripts/ugs_check.sh --format json`, document-map validation, bootstrap
equivalence/package/upgrade fixtures, CR model and attestation fixtures,
commit-range/signature checks, and the two GitHub `ugs-validate` Actions on PR
#53.

## Risk

Low. This change updates planning and explanatory prose only. It does not alter
policy schemas, validators, hooks, signer metadata, CR history, or the optional
attestation wire format. The remaining roadmap items explicitly retain
cross-release binding, adapter portability, and evidence retention work.

## Rollback

Revert the signed topic commit through a reviewed CR, or restore the checkout to
Base OID `77f2bc329a62cf71ae3a204addaa939c4acd929a`. Keep this record as an
append-only audit artifact and publish a replacement governance CR if the
status wording needs another correction.

## Breaking Change

No. The change only clarifies already integrated behavior and does not change
the active v0.3 policy or any validator contract.

## Backport Target

None.
