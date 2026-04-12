# CR-0004: enforce equivalent CR record validation

Base: `main` at `8df4eb1`
Head or Range: `chore/repo-cr-record-validation`
Title: `chore(repo): enforce equivalent CR record validation`

## Summary

Add a dedicated validator for `cr/CR-*.md` files and wire it into repository
validation, the managed `pre-push` hook, and the GitHub Actions mapping layer.

## Motivation

The repository already declared an equivalent CR path, but its automation did
not yet verify that archived CR records were present, structurally complete, or
matched `UGS_ALLOW_MAIN_PUSH=cr` integrations.

## Test Evidence

- `bash -n .githooks/pre-push scripts/validate_repo.sh scripts/validate_cr_record.sh`
- `scripts/validate_cr_record.sh` against `cr/CR-0001` through `cr/CR-0005`
- `scripts/validate_repo.sh`
- disposable repository push test covering matching and mismatched equivalent CR records

## Risk

Equivalent CR integrations can now fail if the archived record is missing or
its `Head or Range` field does not identify the branch, tip commit, or range
being integrated.

## Rollback

Revert the commit that introduces `scripts/validate_cr_record.sh` and the
matching-hook enforcement on a topic branch, then re-integrate through the same
CR flow.

## Breaking Change

No. The change tightens repository enforcement but keeps the same equivalent CR
model and field set.

## Backport Target

None.
