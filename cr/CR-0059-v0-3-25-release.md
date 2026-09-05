# CR-0059: Prepare the v0.3.25 superseding release

Base: main
Head or Range: chore/release-v0-3-25-cr
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(release): prepare v0.3.25 superseding release
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 72c19cd0fdc5249c12c2f2ba79913cb791a6a031
Head OID: 72c19cd0fdc5249c12c2f2ba79913cb791a6a031
Integrated Result: pending

## Summary

Add release notes for v0.3.25, superseding v0.3.24 with the final bare-Git
receive/update adapter and audit coverage corrections.

## Motivation

Formal release tags are immutable. The final bare-Git server fixture and CR
coverage corrections landed after v0.3.24, so they require a new patch tag.

## Test Evidence

Run repository, CR range, signature, CR coverage, bootstrap, GitHub adapter,
bare-Git receive/update, and clean-runner release workflow validation.

## Risk

Low. This is a corrective patch release over the already validated v0.3.24
Core/adapter separation.

## Rollback

Do not replace v0.3.24 or v0.3.25. Publish a later superseding patch through a
new signed CR if necessary.

## Breaking Change

No.

## Backport Target

None.
