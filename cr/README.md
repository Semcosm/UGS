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
Records are append-only audit artifacts: do not rewrite an integrated record
to change its historical decision or commit identity.
