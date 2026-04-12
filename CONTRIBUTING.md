# Contributing

This repository follows UGS Core v0.2 as declared in `REPOSITORY_POLICY.md`.

## Local Setup

Configure the managed hooks path after cloning:

```bash
git config core.hooksPath .githooks
```

## Branching

- Start every non-trivial change from `main`.
- Use a short-lived topic branch.
- Recommended names:
  - `docs/<scope>-<slug>`
  - `chore/<scope>-<slug>`
  - `fix/<scope>-<slug>`
  - `feat/<scope>-<slug>`
  - `refactor/<scope>-<slug>`

## Commit Messages

Commit messages must follow the UGS format:

```text
<type>(<scope>): <summary>

<body>

<footer trailers>
```

Minimum expectation for this repository:

- use one of the UGS core types
- keep the second line blank
- end the message with at least one trailer

Example:

```text
docs(repo): clarify release verification steps

Document how to verify signed annotated release tags and where trusted
maintainer keys are published.

Refs: release-guide
Signed-off-by: Semcosm <chenzhipeng.main@gmail.com>
```

## Change Requests

On GitHub, the pull request itself is the CR.

The PR body must include:

- `Summary`
- `Motivation`
- `Test Evidence`
- `Risk`
- `Rollback`
- `Breaking Change`
- `Backport Target`

`base`, `head`, and `title` are provided by GitHub PR metadata and do not need
to be duplicated in the body.

## Review Expectations

- Maintainer-authored changes may self-integrate.
- External contributions require human review before integration.
- Sensitive paths require maintainer acknowledgment.
- Emergency changes require post-merge review.

## Local Validation

Run the repository checks before pushing:

```bash
scripts/validate_repo.sh
scripts/validate_commit_range.sh main..HEAD
```

The managed hooks run the same checks automatically during commit and push.

## Protected Branches

- Do not push directly to `main` during normal operation.
- Push your topic branch and merge through a PR or equivalent CR.
- When integrating without the GitHub web UI, first push the topic branch and
  then fast-forward `main` with `UGS_ALLOW_MAIN_PUSH=cr`.
- The only normal bypass is the one-time bootstrap push that adopts this policy.
