# CR-0057: Make the bare Git update adapter server-compatible

Base: main
Head or Range: fix/bare-git-update-hook
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: fix(adapter): support bare Git update hooks
Revision: 2
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: 778481d83be07706aa4543268a71a53ab34dc67e
Head OID: c52cdc55e47e0ca0af41b5dc3ff7e17eb6285c79
Integrated Result: main@c52cdc55e47e0ca0af41b5dc3ff7e17eb6285c79

## Summary

Make the bare Git update adapter operate without a work tree and validate
persisted CR files directly from the proposed commit object.

## Motivation

The bare Git receive/update path is a first-class platform-independent adapter.
Server-side hooks cannot use `git rev-parse --show-toplevel` or read CR files
from a work tree that does not exist.

## Test Evidence

Run the bare update fixture against a temporary bare repository, plus the full
repository, bootstrap, CR coverage, and signature validation suites.

## Risk

The configured `UGS_REPOSITORY_ROOT` must point to the checkout containing the
Core scripts while Git commands continue to execute against the bare server.

## Rollback

Revert through a new signed CR and remove the server-side adapter installation
if the receive hook rejects valid updates.

## Breaking Change

No. The adapter gains a documented bare-repository environment configuration.

## Backport Target

None.
