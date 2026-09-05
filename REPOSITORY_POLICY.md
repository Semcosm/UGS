# UGS Repository Policy

This file is the legacy repository-local declaration retained for v0.3
migration and compatibility reporting.

## Effective Conformance

The repository's UGS conformance claim begins with the first non-bootstrap
change integrated on `main` after the governance layer is installed.

The bootstrap adoption commit that introduces this policy, the managed hooks,
the contribution guide, and the remote validation workflow is a one-time
exception used only to install the enforcement layer.

Earlier bootstrap commits are preserved for traceability but are outside the
repository's conformance claim.

The repository's high-trust commit-signing claim begins at the recovered
signed fast-forward integration `459572b`. The earlier v0.3 draft integration
sequence contains unsigned commits and remains outside that claim for
traceability; it is recorded in `cr/CR-0020-signing-boundary-recovery.md`.

The UGS Core v0.2 normative baseline is retained as historical compatibility
context. The v0.3 policy manifest and conformance profile in
`docs/git/ugs-v0.3-profile.md` are active under the adoption recorded in
`cr/CR-0021-v0-3-normative-adoption.md`.

## Repository Declaration

```text
UGS Profile: continuous
Merge Strategy: rebase-ff
Versioning: semver
Signing Level: high-trust-commits-signed
Conformance Level: high-trust
Core Commit Types: feat, fix, refactor, docs, test, build, ci, chore, perf, revert
Extended Commit Types: <none>
Review Model: change-level
Human Review Required: no for maintainer-authored changes; yes for external contributions
Test Evidence Required: yes
Maintainer Ack Required for Sensitive Paths: yes
Review Conclusion Storage: trailers
Review Discussion Storage: GitHub pull request comments or patch cover letters
Hooks Path: .githooks
Protected Long-Lived Branches: main
Emergency Path: defined
```

## Branching And Integration

- `main` is the only long-lived branch.
- Every non-trivial change MUST start on a short-lived topic branch from `main`.
- Recommended topic branch prefixes are `feat/`, `fix/`, `docs/`, `chore/`,
  `refactor/`, `test/`, `build/`, `ci/`, and `perf/`.
- Normal integration into `main` happens through a GitHub pull request or an
  equivalent CR that preserves the branch and commit range.
- The main integration strategy is `rebase-ff`.

## Protected Branch Handling

- `main` is a protected branch.
- Local direct pushes to `main` are rejected by `.githooks/pre-push`.
- Normal maintainer integration without the GitHub web UI is allowed only when
  the topic branch has already been pushed and `main` is fast-forwarded using
  `UGS_ALLOW_MAIN_PUSH=cr`.
- The only planned exception is the one-time bootstrap push that lands this
  policy and its enforcement layer on `main`.
- Emergency direct pushes require `UGS_ALLOW_MAIN_PUSH=emergency` and a non-empty
  `UGS_EMERGENCY_REASON`, and MUST receive post-merge review.

## Trusted Signer Registry

- The canonical SSH signer registry is `keys/allowed_signers`.
- The canonical SSH revocation file is `keys/revoked_signers`.
- Signer additions and removals MUST be proposed on a topic branch and
  integrated through a CR.
- No bot signer is trusted by default. Automation MAY sign commits only when
  its key is explicitly registered and a human maintainer owns that identity.
- Maintainers SHOULD keep at least one standby signing key. If all trusted
  signing keys are unavailable, the emergency path MAY be used once to rotate
  trust material and restore signed normal operation, and the incident MUST be
  documented in the recovery CR or repository notice.

## Commit Policy

- Commits MUST use the UGS commit format.
- Commits in this repository MUST end with at least one trailer.
- Commits proposed for integration in this repository MUST be SSH-signed and
  verifiable against `keys/allowed_signers`, and MUST NOT match
  `keys/revoked_signers`.
- Accepted core types are the UGS core types only; this repository does not
  define any extended commit type.
- Recommended trailers are `Signed-off-by:`, `Refs:`, `Fixes:`, `Reviewed-by:`,
  `Tested-by:`, `Acked-by:`, `Co-developed-by:`, and `Backport-to:`.

## Change Request Policy

Every non-trivial integration MUST have a persisted `cr/CR-*.md` record.
The record is the authoritative CR; a GitHub pull request is a generated
review view of that record, not a substitute for it.

On GitHub pull requests:

- `base`, `head`, and `title` are satisfied by PR metadata.
- The PR body MUST include:
  - `Summary`
  - `Motivation`
  - `Test Evidence`
  - `Risk`
  - `Rollback`
  - `Breaking Change`
  - `Backport Target`

Outside GitHub, the same CR fields MUST be carried explicitly in the cover
letter, request-pull text, or equivalent review medium.

The default PR template in `.github/pull_request_template.md` is the canonical
GitHub mapping for the CR minimum field set. PRs SHOULD be created with
`scripts/create_pr_from_cr.sh`, which uses the CR file as the PR body.

For off-platform or archive-friendly flows, this repository stores equivalent
CR records under `cr/`.

The persisted CR MUST have a matching `Head OID` in the proposed history and
its PR body MUST be byte-for-byte identical to the CR source. CI MUST reject a
PR or main integration that has no matching persisted CR.

GitHub-hosted enforcement SHOULD additionally enable:

- required status checks including `ugs-validate`
- PR-based integration into `main`
- CODEOWNERS review on sensitive paths

## Review Policy

- Review model: `change-level`
- Human review is not required for maintainer-authored changes.
- Human review is required for external contributions before integration.
- Test evidence is required for every CR; docs-only wording updates may use
  `not applicable` when no executable behavior changes.
- Maintainer acknowledgment is required for changes touching sensitive paths.
- Final accepted review conclusions SHOULD be reflected in commit trailers when
  the change is integrated.

Sensitive paths:

- `docs/git/ugs-core.md`
- `docs/git/ugs-branch-profiles.md`
- `docs/git/commit-convention.md`
- `docs/git/review-policy.md`
- `docs/git/release-policy.md`
- `.githooks/*`
- `.github/workflows/*`
- `keys/*`
- `scripts/validate_*`
- `REPOSITORY_POLICY.md`
- `CONTRIBUTING.md`
- `RELEASE.md`

GitHub CODEOWNERS for these paths is declared in `.github/CODEOWNERS`.

## Versioning Policy

This repository uses `semver`.

Public API for this repository consists of:

- the normative meaning of files under `docs/git/`
- the repository-local governance contract in `REPOSITORY_POLICY.md`,
  `CONTRIBUTING.md`, and `RELEASE.md`
- the contributor-visible enforcement behavior of `.githooks/commit-msg`,
  `.githooks/pre-push`, and `.github/workflows/ugs-validate.yml`

Compatibility rules:

- `PATCH`: editorial fixes and clarifications with no normative change
- `MINOR`: backwards-compatible additions such as new guidance, templates, or
  non-breaking automation coverage
- `MAJOR`: normative rule changes, removal or rename of stable public files, or
  stricter contributor-facing enforcement that invalidates previously accepted
  compliant commits or CRs

## Release Policy

- Formal releases are represented by signed annotated tags.
- Formal release tags MUST be signed by a key currently trusted in
  `keys/allowed_signers` and not listed in `keys/revoked_signers`.
- Release tag names SHOULD use `v<major>.<minor>.<patch>`.
- Release notes are required for every formal release.
- Release notes MUST be stored under `releases/v<major>.<minor>.<patch>.md`.
- Release signers are repository maintainers.
- Release verification guidance is published in `RELEASE.md`.
