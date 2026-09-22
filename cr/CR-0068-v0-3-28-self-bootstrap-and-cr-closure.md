# CR-0068: Self-bootstrap v0.3.28 and close verified historical CR records

Base: main
Head or Range: chore/establish-layered-licensing / ded9bc0..b470202
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: chore(bootstrap): self-bootstrap v0.3.28
Revision: 4
Status: accepted
Decision: accepted
Policy Version: v0.3
Base OID: ded9bc0f6b9dd519473ba5e33367e3ee80fd62f6
Head OID: b470202b1b34b80f10de3c386b2c0a30b28505af
Integrated Result: pending
Coverage OIDs: 18747c201e47ff23d86cf71d2a6ecfef6fa37ede

## Summary

Install the published v0.3.28 bootstrap component set in the UGS repository,
refresh release navigation and bootstrap examples, make the equivalence test
default to the current release, and close historical CR records whose final
record commits are reachable from main with the required review evidence.

## Motivation

The repository was still self-bootstrapped from v0.3.27 even though v0.3.28
was the current signed release. Its installed metadata and offline license
files therefore lagged the published package. The README document map and
bootstrap examples also omitted the current release. Historical accepted CRs
with complete final trailers can be closed deterministically; records lacking
those trailers or still awaiting acceptance must remain pending until their
evidence is supplied.

## Test Evidence

The v0.3.28 archive passed dry-run conflict detection and the real upgrade with
a recoverable backup. The upgrade persisted v0.3.28 metadata and installed the
official Apache-2.0 and CC BY 4.0 source texts under .ugs/docs/. Document-map
generation, shell/Python syntax checks, and all modified CR records pass their
validators. The 41 closed historical records point to reachable final record
commits and retain their required review evidence.

## Risk

The bootstrap upgrade is additive and preserves the active high-trust profile,
project-owned files, and immutable release tags. CR status changes are audit
metadata only; seven records remain pending because their historical commits do
not carry the required review trailer, and CR-0060 remains pending by decision.

## Rollback

Restore the pre-upgrade filesystem with the rollback command printed by the
upgrade, using backup directory /tmp/ugs-v0.3.28-self-bootstrap.gcS2ZH/backup.

If this topic is rejected, revert the signed commits through a new CR. Do not
replace or delete the immutable v0.3.28 tag.

## Breaking Change

No. The active policy and profile remain unchanged; this aligns installed
components and audit metadata with the already-published v0.3.28 release.

## Backport Target

None.
