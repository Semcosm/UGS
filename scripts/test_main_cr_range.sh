#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
validator="$root_dir/scripts/validate_main_cr_range.sh"
temp_root="$(mktemp -d)"
trap 'rm -rf "$temp_root"' EXIT

fail() {
  echo "main CR range fixture failed: $1" >&2
  exit 1
}

new_case() {
  case_dir="$temp_root/$1"
  mkdir -p "$case_dir/cr"
  git -C "$case_dir" init -q
  git -C "$case_dir" config user.name "UGS Fixture"
  git -C "$case_dir" config user.email "fixture@example.invalid"
  git -C "$case_dir" branch -M main
  printf 'root\n' > "$case_dir/root.txt"
  git -C "$case_dir" add root.txt
  git -C "$case_dir" commit -qm "test(fixture): create root"
  root_oid="$(git -C "$case_dir" rev-parse HEAD)"
  printf 'baseline\n' > "$case_dir/baseline.txt"
  git -C "$case_dir" add baseline.txt
  git -C "$case_dir" commit -qm "test(fixture): create baseline"
  old_oid="$(git -C "$case_dir" rev-parse HEAD)"
}

write_cr() {
  local path="$1" id="$2" title="$3" base="$4" head="$5" strategy="$6"
  cat > "$path" <<EOF
# $id: $title

Format: ugs-cr/v1
Schema Version: 1
Base: main
Head or Range: fixture
Integration Target: main
Integration Strategy: $strategy
Review Evidence: trailers
Title: $title
Revision: 1
Status: pending
Decision: pending
Policy Version: v0.3
Base OID: $base
Head OID: $head
Integrated Result: pending
Coverage OIDs: none
Extensions: {}

## Summary

Exercise main CR range validation.

## Motivation

Verify the integration provenance decision.

## Test Evidence

The disposable fixture exercises the validator.

## Risk

The fixture does not change production behavior.

## Rollback

Remove the disposable repository.

## Breaking Change

No.

## Backport Target

None.
EOF
}

run_validator() {
  (cd "$case_dir" && UGS_REPOSITORY_ROOT="$root_dir" "$validator" "$1" "$2")
}

expect_success() {
  local output
  if ! output="$(run_validator "$1" "$2" 2>&1)"; then
    echo "$output" >&2
    fail "expected validation success"
  fi
  printf '%s\n' "$output"
}

expect_failure() {
  local output
  if output="$(run_validator "$1" "$2" 2>&1)"; then
    echo "$output" >&2
    fail "expected validation failure"
  fi
  printf '%s\n' "$output"
}

literal_case() {
  new_case literal
  git -C "$case_dir" switch -qc topic
  printf 'literal\n' > "$case_dir/change.txt"
  git -C "$case_dir" add change.txt
  git -C "$case_dir" commit -qm "feat(fixture): literal change"
  source_head="$(git -C "$case_dir" rev-parse HEAD)"
  write_cr "$case_dir/cr/CR-0001-literal.md" CR-0001 "literal fixture" "$old_oid" "$source_head" rebase-ff
  git -C "$case_dir" add cr/CR-0001-literal.md
  git -C "$case_dir" commit -qm "docs(cr): record literal fixture"
  git -C "$case_dir" switch -q main
  git -C "$case_dir" merge --ff-only -q topic
  new_oid="$(git -C "$case_dir" rev-parse HEAD)"
  output="$(expect_success "$old_oid" "$new_oid")"
  grep -Fq "literal fast-forward" <<<"$output" || fail "literal result was not reported"
}

rewritten_case() {
  local name="$1" source_text="$2" result_text="$3" source_base_kind="$4" strategy="$5" source_base
  new_case "$name"
  if [ "$source_base_kind" = root ]; then
    source_base="$root_oid"
  else
    source_base="$old_oid"
  fi
  git -C "$case_dir" switch -qc source "$source_base"
  printf '%s\n' "$source_text" > "$case_dir/change.txt"
  git -C "$case_dir" add change.txt
  git -C "$case_dir" commit -qm "feat(fixture): reviewed change"
  source_head="$(git -C "$case_dir" rev-parse HEAD)"
  write_cr "$case_dir/cr/CR-0001-rewritten.md" CR-0001 "rewritten fixture" "$source_base" "$source_head" "$strategy"
  git -C "$case_dir" add cr/CR-0001-rewritten.md
  git -C "$case_dir" commit -qm "docs(cr): bind rewritten fixture"
  cp "$case_dir/cr/CR-0001-rewritten.md" "$case_dir/record.md"
  git -C "$case_dir" switch -q -C main "$old_oid"
  printf '%s\n' "$result_text" > "$case_dir/change.txt"
  git -C "$case_dir" add change.txt
  git -C "$case_dir" commit -qm "feat(fixture): hosted rebase copy"
  mkdir -p "$case_dir/cr"
  cp "$case_dir/record.md" "$case_dir/cr/CR-0001-rewritten.md"
  git -C "$case_dir" add cr/CR-0001-rewritten.md
  git -C "$case_dir" commit -qm "docs(cr): persist rewritten fixture"
  new_oid="$(git -C "$case_dir" rev-parse HEAD)"
}

rewritten_success_case() {
  rewritten_case rewritten source source old rebase-ff
  output="$(expect_success "$old_oid" "$new_oid")"
  grep -Fq "rewritten rebase" <<<"$output" || fail "rewritten result was not reported"
}

changed_patch_case() {
  rewritten_case changed source different old rebase-ff
  output="$(expect_failure "$old_oid" "$new_oid")"
  grep -Fq "tree diff does not match" <<<"$output" || fail "changed patch failure was not reported"
}

stale_base_case() {
  rewritten_case stale-base source source root rebase-ff
  output="$(expect_failure "$old_oid" "$new_oid")"
  grep -Fq "Base OID does not equal old main" <<<"$output" || fail "stale base failure was not reported"
}

wrong_strategy_case() {
  rewritten_case wrong-strategy source result old merge
  output="$(expect_failure "$old_oid" "$new_oid")"
  grep -Fq "strategy is not rebase-ff" <<<"$output" || fail "wrong strategy failure was not reported"
}

unrelated_cr_case() {
  rewritten_case unrelated source source old rebase-ff
  cp "$case_dir/cr/CR-0001-rewritten.md" "$case_dir/cr/CR-0002-unrelated.md"
  sed -i '1s/CR-0001/CR-0002/; 10s/rewritten fixture/unrelated fixture/' "$case_dir/cr/CR-0002-unrelated.md"
  git -C "$case_dir" add cr/CR-0002-unrelated.md
  git -C "$case_dir" commit -qm "docs(cr): add unrelated fixture"
  new_oid="$(git -C "$case_dir" rev-parse HEAD)"
  output="$(expect_failure "$old_oid" "$new_oid")"
  grep -Fq "unrelated persisted CR records" <<<"$output" || fail "unrelated CR failure was not reported"
}

literal_case
rewritten_success_case
changed_patch_case
stale_base_case
wrong_strategy_case
unrelated_cr_case
echo "main CR range fixtures passed"
