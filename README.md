# Universal Git Standard (UGS)

Universal Git Standard (UGS) is a platform-agnostic, Git-native change governance standard for individual and team collaboration.

The current document set is `v0.2` and focuses on a portable workflow model built from native Git primitives:

- refs and branches
- commits
- tags
- patch series
- commit trailers
- hooks

## Document Map

- [UGS Core](docs/git/ugs-core.md)
- [Branch Profiles](docs/git/ugs-branch-profiles.md)
- [Commit Convention](docs/git/commit-convention.md)
- [Review Policy](docs/git/review-policy.md)
- [Release Policy](docs/git/release-policy.md)
- [Managed Hooks](.githooks/README.md)

## Scope

UGS defines:

- repository-level declarations such as branch profile, merge strategy, versioning, and signing level
- a topic-branch or patch-series based change model
- commit message and trailer conventions
- review evidence placement rules
- signed annotated tag based release requirements
- a minimum automation baseline through managed hooks or equivalent enforcement

## Repository Layout

```text
docs/git/     core specification documents
.githooks/    managed hooks directory for repository enforcement
```
