# CR-0087: Centralize UGS document entry points

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: docs/cr-0087-integration / dd8f42577cc8d70a4d22375c9b743d5ee5c1dd5b..dd8f42577cc8d70a4d22375c9b743d5ee5c1dd5b
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Centralize UGS document entry points
Revision: 3
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: dd8f42577cc8d70a4d22375c9b743d5ee5c1dd5b
Head OID: dd8f42577cc8d70a4d22375c9b743d5ee5c1dd5b
Integrated Result: main@dd8f42577cc8d70a4d22375c9b743d5ee5c1dd5b
Coverage OIDs: e763fabfcda3ea0327c208465636d1057f58f886
Extensions: {}

## Summary

Reorganize the repository documentation before v0.4 planning so the root
README remains a concise portal to the current standard, future planning, and
historical release records. Add stable entry points for the current
specifications, roadmap, and release archive without moving or deleting the
existing historical documents.

## Motivation

The generated root document map had grown into a complete list of every
release packet and mixed current normative material with historical planning.
That made the primary README difficult to maintain and caused old release
status text to remain visible after v0.3.31 became the stable distribution.
Stable portal documents keep navigation durable while preserving existing URLs
for archived packets and planning records.

## Test Evidence

The repository validator, document-map validator, bootstrap package and
equivalence fixtures, profile conformance fixtures, and published v0.3.31
consumer test passed. The published package was consumed in disposable
baseline, standard, high-trust, and document-map repositories. A dry-run
upgrade of this UGS checkout using the published v0.3.31 package detected the
existing high-trust profile without changing files.

## Risk

This is documentation and validation plumbing. Existing release-packet and
roadmap paths remain in place, so historical links and audit records remain
valid. The active policy version remains v0.3 and no release tag or policy
wire value changes.

## Rollback

Revert the signed integration commits through a new reviewed CR if the portal
structure or validation requirements are defective. Restoring the previous
document-map configuration and README section preserves all historical files.

## Breaking Change

No. The change adds navigation entry points and moves required README links to
the current-standard portal; existing document paths remain supported.

## Backport Target

None.
