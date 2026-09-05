#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then echo "usage: $0 <cr-file> [head-branch] [repository]" >&2; exit 2; fi
cr_file="$1"
head_branch="${2:-$(git symbolic-ref --quiet --short HEAD)}"
repository="${3:-}"
fail() { echo "create PR from CR failed: $1" >&2; exit 1; }
[ -f "$cr_file" ] || fail "CR file does not exist: $cr_file"
case "$cr_file" in cr/CR-*.md) ;; *) fail "CR must be under cr/CR-*.md" ;; esac
title="$(sed -n 's/^Title: //p' "$cr_file")"
base="$(sed -n 's/^Base: //p' "$cr_file")"
[ -n "$title" ] || fail "CR Title is missing"
[ -n "$base" ] || fail "CR Base is missing"
[ -n "$head_branch" ] || fail "head branch is missing"
args=(pr create --base "$base" --head "$head_branch" --title "$title" --body-file "$cr_file")
[ -n "$repository" ] && args+=(--repo "$repository")
gh "${args[@]}"
