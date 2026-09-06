# CR-0063: Prepare the v0.3.26 release

Base: main
Head or Range: chore/release-v0-3-26
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(release): prepare v0.3.26 release
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 90be0d0595c9ba520ae1c21616313cbf7c567c68
Head OID: 90be0d0595c9ba520ae1c21616313cbf7c567c68
Integrated Result: pending

## Summary

Add the v0.3.26 release packet for the bootstrap dependency remediation and
the offline UGS documentation included in the downloadable bootstrap asset.

## Motivation

The v0.3.25 bootstrap package could omit a Core validator required by its
installed bare-Git adapter and did not provide enough local guidance for users
who downloaded the release without web access. The v0.3.26 patch documents and
publishes the corrected package without replacing an existing immutable tag.

## Test Evidence

Run repository, CR, commit-range, signature, bootstrap package, equivalence,
profile, bare-Git, release-tag, and clean-runner release-consumer validation
before and after publication.

## Risk

Low. The release is additive for package contents and corrects missing
bootstrap dependencies. Existing release tags remain unchanged.

## Rollback

Do not replace or delete v0.3.25 or v0.3.26. If the package or workflow is
defective, publish a later superseding patch release through a new signed CR.

## Breaking Change

No.

## Backport Target

None.
