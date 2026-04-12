#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <commit-or-rev-range>" >&2
  exit 2
fi

repo_root="$(git rev-parse --show-toplevel)"
spec="$1"

fail() {
  echo "commit signature validation failed: $1" >&2
  exit 1
}

validate_commit() {
  local commit="$1"

  git rev-parse --quiet --verify "$commit^{commit}" >/dev/null 2>&1 \
    || fail "invalid commit: $commit"

  git cat-file commit "$commit" | grep -q '^gpgsig ' \
    || fail "commit is not signed: $commit"

  git -c gpg.format=ssh \
    -c gpg.ssh.allowedSignersFile="$repo_root/keys/allowed_signers" \
    -c gpg.ssh.revocationFile="$repo_root/keys/revoked_signers" \
    verify-commit "$commit" >/dev/null 2>&1 \
    || fail "commit signature is not trusted: $commit"
}

if [[ "$spec" == *".."* ]]; then
  git rev-list "$spec" >/dev/null
  while IFS= read -r commit; do
    validate_commit "$commit"
  done < <(git rev-list --reverse "$spec")
else
  validate_commit "$spec"
fi
