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
- [Repository Policy](REPOSITORY_POLICY.md)
- [Contributing](CONTRIBUTING.md)
- [Release Guide](RELEASE.md)
- [Managed Hooks](.githooks/README.md)

## Scope

UGS defines:

- repository-level declarations such as branch profile, merge strategy, versioning, and signing level
- a topic-branch or patch-series based change model
- commit message and trailer conventions
- review evidence placement rules
- signed annotated tag based release requirements
- a minimum automation baseline through managed hooks or equivalent enforcement

## This Repository

This repository stores the UGS documents and also applies UGS to itself.

Repository-local governance is declared in:

- [REPOSITORY_POLICY.md](REPOSITORY_POLICY.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [RELEASE.md](RELEASE.md)
- [.github/pull_request_template.md](.github/pull_request_template.md)
- [.github/workflows/ugs-validate.yml](.github/workflows/ugs-validate.yml)
- [cr/README.md](cr/README.md)

## Repository Layout

```text
docs/git/     core specification documents
.githooks/    managed hooks directory for repository enforcement
.github/      hosting-platform workflow and PR template mapping
cr/           equivalent change request records for off-platform review flows
scripts/      reusable repository validation scripts
```
