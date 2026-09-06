# CR-0061: Close bootstrap package dependency gaps

Base: main
Head or Range: chore/release-v0-3-26
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: fix(bootstrap): close release package dependency gaps
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: a10461f23d9c745d92ec09befec45aa213c390f7
Head OID: b25c81a4641137f58a37afdc4ac7b1902dd10d32
Integrated Result: pending

## Summary

Make initialized repositories self-consistent with the bootstrap package's
profile boundaries. Include the Core ref-update validator wherever the
bare-Git update adapter is installed, and make GitHub CR compatibility wrappers
report a clear optional-adapter message when the baseline profile does not
install that adapter. Extend package, equivalence, and published-asset consumer
fixtures to cover these paths, and include offline UGS guidance in every
release archive.

## Motivation

The v0.3.25 bootstrap consumer could receive wrappers or hooks whose referenced
files were not initialized into the target repository. This made the advertised
CR and bare-Git ref-update automation fail immediately after initialization and
made the failure mode depend on an unhelpful shell "file not found" error.
The release archive also contained only a short bootstrap README, forcing users
to open the web repository for the normative and operational guidance.

## Test Evidence

`scripts/test_bootstrap_package.sh`,
`scripts/test_bootstrap_equivalence.sh`, `scripts/test_ref_update.sh`,
`scripts/test_bare_git_update.sh`, `scripts/test_profile_conformance.sh`,
`scripts/validate_repo.sh`, shell syntax checks, and `git diff --check` pass.
The package manifest and release-consumer fixtures also verify the offline UGS
documents copied into the release archive.

## Risk

Low. The baseline profile remains GitHub-adapter-free, while its existing
compatibility wrappers now fail explicitly. The Core bare-Git path gains the
validator that its installed hook already requires.

## Rollback

Revert the bootstrap initializer, wrapper diagnostics, ref-update path,
documentation, fixtures, and this CR in one reviewed reversion. Do not replace
the immutable v0.3.25 release tag; publish a superseding patch release if a
published asset must be corrected.

## Breaking Change

No. Existing baseline initialization gains a missing Core file, and attempts to
use GitHub helpers without the optional adapter now produce a deliberate,
actionable failure.

## Backport Target

None.
