# CR-0002: allow CR-based fast-forward integration

Base: `main` at `00ea46e`
Head or Range: `chore/repo-cr-main-integration` / `00ea46e..93b5473`
Title: `chore(repo): allow CR-based fast-forward integration`
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.2
Base OID: 00ea46e51f13d2cfedeedebfe72f280b48984c1b
Head OID: 93b54733e794037fc5fe9d161efe0d654085e66d
Integrated Result: main@93b54733e794037fc5fe9d161efe0d654085e66d

## Summary

Add a normal maintainer path for integrating `main` through an equivalent CR:
push the topic branch first, then fast-forward `main` with `UGS_ALLOW_MAIN_PUSH=cr`.

## Motivation

The initial governance adoption installed protected-branch enforcement, but it
still needed a documented and executable non-UI path for equivalent CR-based
integration.

## Test Evidence

- `scripts/validate_repo.sh`
- `bash -n .githooks/pre-push`
- push of `chore/repo-cr-main-integration` to `origin`
- fast-forward push of `main` with `UGS_ALLOW_MAIN_PUSH=cr`

## Risk

The `cr` mode relies on the topic branch being pushed first and visible in the
remote-tracking refs.

## Rollback

Revert commit `93b5473` on a topic branch and re-integrate through the same CR
flow.

## Breaking Change

No. This change broadens the compliant integration path without changing the
document set's normative rule text.

## Backport Target

None.
