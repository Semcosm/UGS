# CR-0007: close v0.2 and plan v0.3

Base: `main` at `670e72d`
Head or Range: `docs/v0-2-close-v0-3-plan`
Title: `docs(repo): close v0.2 baseline and plan v0.3`

## Summary

Add the v0.2.0 release packet, document the current baseline and its
publication gate, and publish a non-normative v0.3 roadmap with migration
stages, workstreams, and acceptance criteria.

## Motivation

The v0.2 governance and enforcement surface is now coherent, but it has not
yet been packaged as a release record. A visible closure point prevents the
next iteration from silently changing v0.2 semantics and gives v0.3 a
reviewable scope before implementation begins.

## Test Evidence

- `scripts/validate_repo.sh`
- `scripts/validate_commit_range.sh main..HEAD` (for the topic-branch delta)
- `scripts/validate_commit_signatures.sh main..HEAD` (for the topic-branch delta)
- `for file in cr/CR-*.md; do scripts/validate_cr_record.sh "$file"; done`
- `bash -n .githooks/* scripts/*.sh`

## Risk

The release packet may be mistaken for a published release if the signed tag
gate is overlooked. The packet explicitly marks publication as pending and
keeps v0.3 material non-normative.

## Rollback

Revert this documentation change through a new signed CR. Do not rewrite any
published release tag; publish a superseding patch release if the notes need
correction after publication.

## Breaking Change

No. This change records the existing v0.2 baseline and proposes future work;
it does not alter the normative v0.2 rules or enforcement behavior.

## Backport Target

None.
