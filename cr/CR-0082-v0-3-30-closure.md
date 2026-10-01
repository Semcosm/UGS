# CR-0082: Close the v0.3.30 planning boundary

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: docs/post-v0-3-29-tag-audit / 4cbd556..bd653eeee509270edd60e0a76da66dbfb90c4d6b
Integration Target: main
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: Close the v0.3.30 planning boundary
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 4cbd5565e0d118aecff881cfd15cb71df762b3b3
Head OID: bd653eeee509270edd60e0a76da66dbfb90c4d6b
Integrated Result: pending
Coverage OIDs: none
Extensions: {}

## Summary

Close the v0.3.30 planning boundary as a documentation-only release packet. Update the candidate tag audit, reserve v0.3.31 for a branch-closure capability, publish the v0.3.31 command design, and register the v0.3.30 release packet in the document map.

## Motivation

The repository needs one short patch release to finish the post-v0.3.29 governance audit before introducing a branch-cleanup feature. Keeping the branch-closure implementation out of v0.3.30 prevents a convenience feature from being mixed with the current roadmap correction and gives it a separate implementation and validation boundary under v0.3.31.

## Test Evidence

Passed scripts/generate_document_map.py, scripts/validate_document_map.py, and git diff --check. The release packet records the full pre-tag verification required for the eventual v0.3.30 signed tag.

## Risk

This change is documentation-only. It does not change policy_version, branch enforcement, validators, hooks, release objects, or the existing tag history. The v0.3.31 branch-closure document is a design proposal and does not authorize implementation or branch deletion behavior.

## Rollback

Revert the signed implementation and CR commits through a reviewed CR, or restore the documentation to Base OID 4cbd556b4f4ccfe70ee1e3d023d2d6bf0f0f75d4. Keep the v0.3.29 tag immutable and replace the packet through a later reviewed CR if the v0.3.30 scope changes.

## Breaking Change

No. The change only closes the planning boundary and publishes a future feature design.

## Backport Target

None.
