# CR-9001: Portable conformance fixture

Base: main
Head or Range: fixture-head
Integration Strategy: rebase-ff
Review Evidence: trailers
Title: docs(test): portable conformance fixture
Revision: 1
Status: integrated
Decision: accepted
Policy Version: v0.3
Base OID: {{BASE_OID}}
Head OID: {{HEAD_OID}}
Integrated Result: main@{{HEAD_OID}}

## Summary

Exercise a valid CR in a repository created for this test.

## Motivation

Ensure CR validation does not depend on UGS history.

## Test Evidence

The independent and reference implementations agree.

## Risk

Fixture only.

## Rollback

Delete the disposable repository.

## Breaking Change

None.

## Backport Target

None.
