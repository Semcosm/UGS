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

- **Normative specifications**
  - [UGS Core](docs/git/ugs-core.md)
  - [UGS v0.3 Policy And Conformance Profile](docs/git/ugs-v0.3-profile.md)
  - [UGS Conformance Levels And Profile Matrix](docs/git/ugs-conformance-levels.md)
  - [UGS Quality Profile](docs/git/ugs-quality-profile.md)
  - [UGS Supply-Chain Profile](docs/git/ugs-supply-chain-profile.md)
  - [UGS Repository Shape Capabilities](docs/git/ugs-repository-shapes.md)
  - [UGS Document Map](docs/git/ugs-document-map.md)
  - [Branch Profiles](docs/git/ugs-branch-profiles.md)
  - [Commit Convention](docs/git/commit-convention.md)
  - [Review Policy](docs/git/review-policy.md)
  - [Release Policy](docs/git/release-policy.md)
- **Repository governance**
  - [Repository Policy](REPOSITORY_POLICY.md)
  - [Contributing](CONTRIBUTING.md)
  - [Release Guide](RELEASE.md)
  - [Managed Hooks](.githooks/README.md)
  - [Trusted Signers](keys/README.md)
  - [Change Requests](cr/README.md)
  - [Adapters](adapters/README.md)
- **Roadmap, releases, and implementation**
  - [v0.3 Roadmap](docs/roadmap/v0.3.md)
  - [v0.2.0 Release Packet](releases/v0.2.0.md)
  - [v0.3.0 Release Packet](releases/v0.3.0.md)
  - **Release packets**
    - [v0.3.1 Release Packet](releases/v0.3.1.md)
    - [v0.3.2 Release Packet](releases/v0.3.2.md)
    - [v0.3.3 Release Packet](releases/v0.3.3.md)
    - [v0.3.4 Release Packet](releases/v0.3.4.md)
    - [v0.3.5 Release Packet](releases/v0.3.5.md)
    - [v0.3.6 Release Packet](releases/v0.3.6.md)
    - [v0.3.7 Release Packet](releases/v0.3.7.md)
    - [v0.3.8 Release Packet](releases/v0.3.8.md)
    - [v0.3.9 Release Packet](releases/v0.3.9.md)
    - [v0.3.10 Release Packet](releases/v0.3.10.md)
    - [v0.3.11 Release Packet](releases/v0.3.11.md)
    - [v0.3.12 Release Packet](releases/v0.3.12.md)
    - [v0.3.13 Release Packet](releases/v0.3.13.md)
    - [v0.3.14 Release Packet](releases/v0.3.14.md)
    - [v0.3.15 Release Packet](releases/v0.3.15.md)
    - [v0.3.16 Release Packet](releases/v0.3.16.md)
    - [v0.3.17 Release Packet](releases/v0.3.17.md)
    - [v0.3.18 Release Packet](releases/v0.3.18.md)
    - [v0.3.19 Release Packet](releases/v0.3.19.md)
    - [v0.3.20 Release Packet](releases/v0.3.20.md)
    - [v0.3.21 Release Packet](releases/v0.3.21.md)
    - [v0.3.22 Release Packet](releases/v0.3.22.md)
    - [v0.3.23 Release Packet](releases/v0.3.23.md)
    - [v0.3.24 Release Packet](releases/v0.3.24.md)
    - [v0.3.25 Release Packet](releases/v0.3.25.md)
  - [UGS Bootstrap Package](docs/git/ugs-bootstrap.md)
  - [Portable Conformance Fixtures](docs/git/ugs-conformance-fixtures.md)

The map is configured as a versioned tree in
[`.ugs/document-map.json`](.ugs/document-map.json). Run
`scripts/validate_document_map.py` to verify that every mapped file exists and
that this section has the same titles, links, and nesting. The configuration is
the machine-readable source for the tree; this README remains its human-facing
rendering.

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

Run `scripts/test_conformance.sh` to compare the independent fixture
implementation with the Bash validators.

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
- [adapters/README.md](adapters/README.md)

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
adapters/     platform mappings kept outside UGS Core
```
