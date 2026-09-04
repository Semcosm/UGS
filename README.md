# Universal Git Standard (UGS)

Universal Git Standard (UGS) is a platform-agnostic, Git-native change governance standard for individual and team collaboration.

The current normative policy and conformance profile is `v0.3`; the v0.2 Core
documents remain the historical baseline while preserving their accepted
history and migration boundary. The workflow model is built from native Git
primitives:

- refs and branches
- commits
- tags
- patch series
- commit trailers
- hooks

## Document Map

- [UGS Core](docs/git/ugs-core.md)
- [UGS v0.3 Policy And Conformance Profile](docs/git/ugs-v0.3-profile.md)
- [Branch Profiles](docs/git/ugs-branch-profiles.md)
- [Commit Convention](docs/git/commit-convention.md)
- [Review Policy](docs/git/review-policy.md)
- [Release Policy](docs/git/release-policy.md)
- [Repository Policy](REPOSITORY_POLICY.md)
- [Contributing](CONTRIBUTING.md)
- [Release Guide](RELEASE.md)
- [v0.2.0 Release Packet](releases/v0.2.0.md)
- [v0.3.0 Release Packet](releases/v0.3.0.md)
- [v0.3 Roadmap](docs/roadmap/v0.3.md)
- [Managed Hooks](.githooks/README.md)

## Version Status

- **v0.2:** historical normative baseline; accepted v0.2 history remains valid
  and is not reinterpreted by the v0.3 adoption.
- **v0.2.0:** release packet is complete; publication still requires a signed
  annotated `v0.2.0` tag by a trusted maintainer.
- **v0.3:** active policy and conformance profile. Pre-1.0 releases do not
  promise compatibility with v0.2 schemas, commands, reports, or validator
  behavior; each change must document migration and rollback impact.

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
- [keys/README.md](keys/README.md)
- [.github/pull_request_template.md](.github/pull_request_template.md)
- [.github/workflows/ugs-validate.yml](.github/workflows/ugs-validate.yml)
- [cr/README.md](cr/README.md)

## Repository Layout

```text
docs/git/     core and adopted profile specification documents
docs/roadmap/ non-normative version and migration plans
.githooks/    managed hooks directory for repository enforcement
.github/      hosting-platform workflow and PR template mapping
cr/           equivalent change request records for off-platform review flows
keys/         trusted SSH signer registry and revocation data
releases/     release packets and verification notes
scripts/      reusable repository validation scripts
```
