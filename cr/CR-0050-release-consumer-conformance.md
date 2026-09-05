# CR-0050: Fix published bootstrap profile conformance consumption

Base: main
Head or Range: fix/release-consumer-suite
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: fix(release): run conformance from published bootstrap package
Revision: 1
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: 369a65bfb2355164182eab95ba9128bbb8014f77
Head OID: 369a65bfb2355164182eab95ba9128bbb8014f77
Integrated Result: pending

## Summary

Update the published bootstrap release consumer test to run the profile
conformance suite from the downloaded package itself.

## Motivation

The bootstrap initializer intentionally does not copy the repository's test
suite into a consumer repository. The release test therefore failed on a clean
runner when it attempted to invoke `scripts/test_profile_conformance.sh` from
the consumer checkout.

## Test Evidence

Run repository validation and the published release consumer test for the next
patch release, including standard and high-trust profile conformance.

## Risk

Low. This changes only the release verification harness and makes its command
location match the package contract.

## Rollback

Revert this change and publish a superseding patch release; do not overwrite an
existing release tag.

## Breaking Change

No.

## Backport Target

None.
