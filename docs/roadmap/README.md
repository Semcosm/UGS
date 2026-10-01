# UGS Roadmap

This is the single entry point for future UGS planning. A roadmap document may
describe a proposal or historical work, but it does not allocate a release tag
or change the active policy by itself. A release decision requires a reviewed
change request and the evidence required by the current release policy.

## Current state

- Active policy: `policy_version: 0.3`
- Latest stable distribution: `v0.3.31`
- Next decision boundary: whether the v0.4 compatibility work is ready for a
  policy-version change, a distribution-only release, or both.

## Active planning

- [v0.4 Contract And Compatibility Guide](../git/ugs-v0-4-contract.md) —
  proposed vocabulary, compatibility, migration, and error-report rules.
- [Long-Term Roadmap](v1.0-and-beyond.md) — staged exit criteria from v0.4
  through v1.0 and later ecosystem work.

Before a v0.4 release packet is opened, this entry must identify the approved
scope, policy-version transition, migration evidence, rollback path, and the
accepted or grandfathered CR records that form the gate.

## Historical planning records

- [v0.3 Roadmap](v0.3.md) — historical post-adoption work and delivered
  capability notes.
- [Post-v0.3.29 Tag Distribution Audit](post-v0.3.29-tag-audit.md) —
  historical review worksheet superseded by the v0.3.30 and v0.3.31 release
  records.
- [v0.3.31 Branch Closure Design](v0.3.31-branch-closure.md) — completed
  design and implementation record.

## Governance

Keep this index stable as the planning portal. Add or revise planning material
by updating this page and recording the change in a CR. Do not expand the root
README with every proposal or release packet.
