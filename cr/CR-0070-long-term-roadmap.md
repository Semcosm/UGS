# CR-0070: Publish the UGS long-term roadmap and align adopted profile docs

Base: main
Head or Range: docs/long-term-roadmap-integration / 02665e4..0735ffd
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(roadmap): add long-term UGS evolution plan
Revision: 3
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: 02665e45984f0e92f3ecad3d62f35b68416bde27
Head OID: 0735ffdeb76f521dd6e261d45b26d68866defde7
Integrated Result: main@0735ffdeb76f521dd6e261d45b26d68866defde7

## Summary

Add a non-normative roadmap for the progression from the adopted UGS v0.3
baseline through v0.4 contract hardening, v0.5 evidence interoperability,
v0.6 supply-chain operations, v0.7 adapter ecosystem work, v1.0 stability,
and post-v1.0 extensions. Register the roadmap in the generated document map.

Align the historical v0.3 roadmap with the current v0.3.28 baseline and mark
the delivered quality, supply-chain, and repository-shape capabilities as
implemented optional profiles. Synchronize the normative v0.3 profile with
its checked-in bootstrap documentation mirror.

## Motivation

The adopted v0.3 implementation has outgrown the original v0.3 planning
document: its optional profiles are implemented, while the roadmap still
describes them as pending and offers no staged plan for wire-format
compatibility, independent implementations, adapter capabilities, or v1.0
stability. The new roadmap makes those dependencies, exit criteria, migration
and rollback expectations, and open decisions explicit without changing the
active policy or validator behavior.

## Test Evidence

Passed `git diff --check`, `scripts/generate_document_map.py`,
`scripts/validate_document_map.py`, `scripts/test_bootstrap_equivalence.sh`,
and a byte-for-byte comparison of the updated `docs/git` profile and its
`.ugs/docs/git` mirror. The roadmap and profile edits contain no schema,
validator, hook, workflow, or policy-manifest changes.

## Risk

Low. The new roadmap is non-normative. The profile and historical roadmap
edits correct documentation status and compatibility context without changing
the v0.3 policy contract or enforcement code. A generated README section is
updated from `.ugs/document-map.json`.

## Rollback

Revert the signed topic commit through a reviewed CR, or restore the checkout
before `784e43d`. If the roadmap is superseded, retain this CR as an
append-only audit record and publish a replacement planning document through a
new reviewed change.

## Breaking Change

No. The active v0.3 policy, schemas, commands, validators, hooks, release
artifacts, and accepted history remain unchanged.

## Backport Target

None.
