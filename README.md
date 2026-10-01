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

- **Current standard（当前标准）**
  - [UGS Current Standard（UGS 当前标准入口）](docs/git/README.md)
  - [UGS Core（UGS 核心）](docs/git/ugs-core.md)
  - [UGS v0.3 Policy And Conformance Profile（UGS v0.3 政策与合规性配置文件）](docs/git/ugs-v0.3-profile.md)
  - [UGS v0.3.31 Release Packet（UGS v0.3.31 发布包）](releases/v0.3.31.md)
  - [UGS Bootstrap Package（UGS Bootstrap 包）](docs/git/ugs-bootstrap.md)
- **Repository governance（仓库治理）**
  - [Repository Policy（仓库政策）](REPOSITORY_POLICY.md)
  - [Contributing（贡献指南）](CONTRIBUTING.md)
  - [Release Guide（发布指南）](RELEASE.md)
  - [Managed Hooks（管理式钩子）](.githooks/README.md)
  - [Trusted Signers（可信签名者）](keys/README.md)
  - [Change Requests（变更请求）](cr/README.md)
  - [Adapters（适配器）](adapters/README.md)
- **Future planning（未来规划）**
  - [UGS Roadmap（UGS 路线图入口）](docs/roadmap/README.md)
- **Historical archive（历史归档）**
  - [Release Archive（发布包归档）](releases/README.md)
  - [UGS Document Map（UGS 文档映射）](docs/git/ugs-document-map.md)

## Version Status

- **v0.2:** historical normative baseline; accepted v0.2 history remains valid
  and is not reinterpreted by the v0.3 adoption.
- **v0.2.0:** release packet is complete; publication still requires a signed
  annotated `v0.2.0` tag by a trusted maintainer.
- **v0.3:** active policy and conformance profile. Pre-1.0 releases do not
  promise compatibility with v0.2 schemas, commands, reports, or validator
  behavior; each change must document migration and rollback impact.
- **Latest stable distribution:** v0.3.31. Its signed release packet,
  bootstrap asset, and post-tag supply-chain evidence are indexed from the
  [release archive](releases/README.md).
- **Future planning:** all proposed work and release-boundary decisions now
  enter through the [roadmap](docs/roadmap/README.md). The v0.4 contract is
  still a draft and does not change `policy_version: 0.3`.

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

For an existing consumer repository, use the release package's offline
`scripts/ugs.sh upgrade` flow to install all components while preserving the
active profile, then run `scripts/ugs.sh activate --profile ...` explicitly
when a profile change is intended. See [UGS Bootstrap Package](docs/git/ugs-bootstrap.md).

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
docs/git/     current standard and adopted profile specification documents
docs/roadmap/ single entry point for future and historical planning
.githooks/    managed hooks directory for repository enforcement
.github/      hosting-platform workflow and PR template mapping
cr/           equivalent change request records for off-platform review flows
keys/         trusted SSH signer registry and revocation data
releases/     release packets and the historical release archive index
scripts/      reusable repository validation scripts
adapters/     platform mappings kept outside UGS Core
```

## Licensing

UGS uses a layered license policy:

- implementation, hooks, adapters, configuration, and test components use
  Apache-2.0;
- specifications, guides, release packets, and change-request records use
  CC BY 4.0.

The [license overview](LICENSE) and complete texts for [Apache-2.0](LICENSES/Apache-2.0.txt)
and [CC BY 4.0](LICENSES/CC-BY-4.0.txt) are kept in the repository. The
bootstrap package also carries these texts and installs them under
`.ugs/docs/` for offline consumers. Its root `LICENSE` is a project-owned
starting template and does not choose a license for the consumer's own work.

Neither license grants permission to use the UGS name, logo, or conformance
claim to imply endorsement, certification, or official status.
