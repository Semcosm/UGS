# CR-0005: ignore local contributor guide

Base: `main` at `d2b87c5`
Head or Range: `chore/repo-ignore-local-guide`
Title: `chore(repo): ignore local contributor guide`
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.2
Base OID: 8df4eb182faf9f0856097d9cb420efc7f16b006c
Head OID: e904990df5b6078e709f2c271d1fedf6076ab8f5
Integrated Result: main@e904990df5b6078e709f2c271d1fedf6076ab8f5

## Summary

Ignore `AGENTS.md` so repository-local contributor instructions do not appear as
untracked changes during local work.

## Motivation

The repository now uses `AGENTS.md` as a local contributor guide artifact, but
that file should remain workstation-local rather than part of the tracked tree.

## Test Evidence

- `git check-ignore -v AGENTS.md`
- `git status --short`

## Risk

Low. The change only updates ignore rules for a local-only documentation file.

## Rollback

Revert the `.gitignore` change on a topic branch and re-integrate through the
same CR flow.

## Breaking Change

No.

## Backport Target

None.
