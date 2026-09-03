# Universal Git Standard (UGS)

Universal Git Standard (UGS) is a platform-agnostic, Git-native change governance standard for individual and team collaboration.

The current normative document set is `v0.2`. Its closure is recorded in the
`v0.2.0` release packet, while the next iteration is being designed in the
non-normative `v0.3` roadmap. The workflow model is built from native Git
primitives:

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
- [v0.2.0 Release Packet](releases/v0.2.0.md)
- [v0.3.0 Release Packet](releases/v0.3.0.md)
- [v0.3 Roadmap](docs/roadmap/v0.3.md)
- [Managed Hooks](.githooks/README.md)

## Version Status

- **v0.2:** normative baseline; no new normative requirements are being added
  to this line.
- **v0.2.0:** release packet is complete; publication still requires a signed
  annotated `v0.2.0` tag by a trusted maintainer.
- **v0.3:** planning only. The roadmap does not change the v0.2 contract until
  a future CR adopts it. Pre-1.0 work is rapid iteration and does not promise
  compatibility across draft schemas, commands, reports, or validator
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
docs/git/     core specification documents
docs/roadmap/ non-normative version and migration plans
.githooks/    managed hooks directory for repository enforcement
.github/      hosting-platform workflow and PR template mapping
cr/           equivalent change request records for off-platform review flows
keys/         trusted SSH signer registry and revocation data
releases/     release packets and verification notes
scripts/      reusable repository validation scripts
```
