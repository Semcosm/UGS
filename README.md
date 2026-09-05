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

## Document Map（文档映射）

- **Normative specifications（规范性文档）**
  - [UGS Core（UGS 核心）](docs/git/ugs-core.md)
  - [UGS v0.3 Policy And Conformance Profile（UGS v0.3 政策与合规性配置文件）](docs/git/ugs-v0.3-profile.md)
  - [UGS Conformance Levels And Profile Matrix（UGS 一致性等级与配置文件矩阵）](docs/git/ugs-conformance-levels.md)
  - [UGS Quality Profile（UGS 质量标准）](docs/git/ugs-quality-profile.md)
  - [UGS Supply-Chain Profile（UGS 供应链配置文件）](docs/git/ugs-supply-chain-profile.md)
  - [UGS Repository Shape Capabilities（UGS 仓库形态能力）](docs/git/ugs-repository-shapes.md)
  - [UGS Document Map（UGS 文档映射）](docs/git/ugs-document-map.md)
  - [Branch Profiles（分支配置文件）](docs/git/ugs-branch-profiles.md)
  - [Commit Convention（提交约定）](docs/git/commit-convention.md)
  - [Review Policy（审查政策）](docs/git/review-policy.md)
  - [Release Policy（发布政策）](docs/git/release-policy.md)
- **Repository governance（仓库治理）**
  - [Repository Policy（仓库政策）](REPOSITORY_POLICY.md)
  - [Contributing（贡献指南）](CONTRIBUTING.md)
  - [Release Guide（发布指南）](RELEASE.md)
  - [Managed Hooks（管理式钩子）](.githooks/README.md)
  - [Trusted Signers（可信签名者）](keys/README.md)
  - [Change Requests（变更请求）](cr/README.md)
  - [Adapters（适配器）](adapters/README.md)
- **Roadmap, releases, and implementation（路线图、发布与实现）**
  - [v0.3 Roadmap（v0.3 路线图）](docs/roadmap/v0.3.md)
  - [v0.2.0 Release Packet（v0.2.0 发布包）](releases/v0.2.0.md)
  - [v0.3.0 Release Packet（v0.3.0 发布包）](releases/v0.3.0.md)
  - **Release packets（发布包）**
    - [v0.3.1 Release Packet（v0.3.1 版本发布说明）](releases/v0.3.1.md)
    - [v0.3.2 Release Packet（v0.3.2 版本发布说明）](releases/v0.3.2.md)
    - [v0.3.3 Release Packet（v0.3.3 版本发布说明）](releases/v0.3.3.md)
    - [v0.3.4 Release Packet（v0.3.4 版本发布说明）](releases/v0.3.4.md)
    - [v0.3.5 Release Packet（v0.3.5 版本发布说明）](releases/v0.3.5.md)
    - [v0.3.6 Release Packet（v0.3.6 版本发布说明）](releases/v0.3.6.md)
    - [v0.3.7 Release Packet（v0.3.7 版本发布说明）](releases/v0.3.7.md)
    - [v0.3.8 Release Packet（v0.3.8 版本发布说明）](releases/v0.3.8.md)
    - [v0.3.9 Release Packet（v0.3.9 版本发布说明）](releases/v0.3.9.md)
    - [v0.3.10 Release Packet（v0.3.10 版本发布说明）](releases/v0.3.10.md)
    - [v0.3.11 Release Packet（v0.3.11 版本发布说明）](releases/v0.3.11.md)
    - [v0.3.12 Release Packet（v0.3.12 版本发布说明）](releases/v0.3.12.md)
    - [v0.3.13 Release Packet（v0.3.13 版本发布说明）](releases/v0.3.13.md)
    - [v0.3.14 Release Packet（v0.3.14 版本发布说明）](releases/v0.3.14.md)
    - [v0.3.15 Release Packet（v0.3.15 版本发布说明）](releases/v0.3.15.md)
    - [v0.3.16 Release Packet（v0.3.16 版本发布说明）](releases/v0.3.16.md)
    - [v0.3.17 Release Packet（v0.3.17 版本发布说明）](releases/v0.3.17.md)
    - [v0.3.18 Release Packet（v0.3.18 版本发布说明）](releases/v0.3.18.md)
    - [v0.3.19 Release Packet（v0.3.19 版本发布说明）](releases/v0.3.19.md)
    - [v0.3.20 Release Packet（v0.3.20 版本发布说明）](releases/v0.3.20.md)
    - [v0.3.21 Release Packet（v0.3.21 版本发布说明）](releases/v0.3.21.md)
    - [v0.3.22 Release Packet（v0.3.22 版本发布说明）](releases/v0.3.22.md)
    - [v0.3.23 Release Packet（v0.3.23 版本发布说明）](releases/v0.3.23.md)
    - [v0.3.24 Release Packet（v0.3.24 版本发布说明）](releases/v0.3.24.md)
    - [v0.3.25 Release Packet（v0.3.25 版本发布说明）](releases/v0.3.25.md)
  - [UGS Bootstrap Package（UGS Bootstrap 包）](docs/git/ugs-bootstrap.md)
  - [Portable Conformance Fixtures（便携式一致性测试夹具）](docs/git/ugs-conformance-fixtures.md)

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
