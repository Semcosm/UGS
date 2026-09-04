# Change Request Records

This directory stores equivalent CR records when a change is reviewed or
archived outside the GitHub PR UI.

Use cases:

- a branch and commit range are the primary CR object
- a maintainer wants an archive-friendly CR record inside the repository
- a patch-series or request-pull flow needs the same minimum fields as a PR

Use `cr/TEMPLATE.md` for new records.

`CR-0007-close-v0-2-plan-v0-3.md` records the repository's v0.2 closure and
the decision to keep v0.3 planning non-normative until a future adoption CR.
`CR-0008-add-ugs-signing-key.md` records the addition of the dedicated
maintainer key used for commit and release signatures.
`CR-0009-fix-initial-push-validation.md` records the correction for first-push
CI range calculation.
`CR-0019-v0-3-adoption-decisions.md` records the design decisions that gate
normative v0.3 adoption.
`CR-0020-signing-boundary-recovery.md` records the recovered high-trust
signing boundary after the unsigned draft integration sequence.
`CR-0022-release-tag-validator-fix.md` records the CI correction for annotated
release-tag detection.
`CR-0023-release-tag-workflow-fix.md` records the checkout fix that restores
annotated release tags before CI validation.
`CR-0024-v0-3-profile-documentation.md` records the human-readable adopted
v0.3 profile boundary.
`CR-0025-v0-3-3-release.md` records the v0.3.3 profile clarification release.
`CR-0026-conformance-levels.md` records v0.3 conformance levels and the
profile/merge-strategy matrix.
CR provenance validation is exercised by `scripts/test_cr_provenance.sh`.
`CR-0027-cr-provenance-validation.md` records the integrated-result
reachability rule.
`CR-0028-integration-strategy-evidence.md` records strategy-specific CR
provenance validation.
`CR-0029-review-conclusion-inheritance.md` records final review trailer
inheritance validation.
`CR-0030-signer-lifecycle-and-attestation.md` records signer lifecycle
metadata and the v0.3 attestation boundary.
`CR-0031-v0-3-4-release.md` records the v0.3.4 P1 capabilities release.
`CR-0032-exception-lifecycle.md` records structured bootstrap and emergency
exception lifecycle validation.
Records are append-only audit artifacts: do not rewrite an integrated record
to change its historical decision or commit identity.
