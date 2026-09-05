#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -gt 1 ]; then echo "usage: $0 [ref]" >&2; exit 2; fi
repo_root="$(git rev-parse --show-toplevel)"
ref="${1:-HEAD}"
anchor="${UGS_CR_COVERAGE_ANCHOR:-c97638fd59b99583c028885e9361147270d1e256}"
fail() { echo "CR coverage validation failed: $1" >&2; exit 1; }
git rev-parse --verify "$ref^{commit}" >/dev/null 2>&1 || fail "invalid ref: $ref"
git cat-file -e "$anchor^{commit}" 2>/dev/null || fail "coverage anchor is not present: $anchor"
covered_file="$(mktemp)"
missing_file="$(mktemp)"
trap 'rm -f "$covered_file" "$missing_file"' EXIT
for file in "$repo_root"/cr/CR-*.md; do
  [ -f "$file" ] || continue
  sed -n -E 's/^(Head OID|Integrated Result): (main@)?([0-9a-f]{40})$/\3/p; s/^Coverage OIDs: (.*)$/\1/p' "$file" | tr ' ' '\n' | grep -E '^[0-9a-f]{40}$' >> "$covered_file" || true
done
sort -u "$covered_file" -o "$covered_file"
while IFS=$'\t' read -r oid subject; do
  if grep -Fqx "$oid" "$covered_file"; then
    continue
  fi
  if git diff-tree --no-commit-id --name-only -r "$oid" | grep -Eq '^cr/CR-[0-9]{4}-[^/]+\.md$'; then
    continue
  fi
  printf '%s\t%s\n' "$oid" "$subject" >> "$missing_file"
done < <(git log --first-parent --format='%H%x09%s' "$anchor..$ref")
if [ -s "$missing_file" ]; then
  echo "uncovered first-parent commits (after $anchor):" >&2
  cat "$missing_file" >&2
  fail "$(wc -l < "$missing_file" | tr -d ' ') main commits have no CR coverage"
fi
echo "CR coverage validation passed (after $anchor)"
