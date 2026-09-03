#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

work_repo="$temp_dir/work"
bare_repo="$temp_dir/bare.git"
git init --quiet -b main "$work_repo"
git -C "$work_repo" config user.name "UGS Fixture"
git -C "$work_repo" config user.email "fixture@example.invalid"

cat > "$temp_dir/message" <<'EOF'
docs(fixture): exercise Git evidence

Create a disposable repository for conformance checks.

Refs: fixture
EOF
printf '%s\n' fixture > "$work_repo/fixture.txt"

git -C "$work_repo" add -A
git -C "$work_repo" commit --quiet -F "$temp_dir/message"
commit="$(git -C "$work_repo" rev-parse HEAD)"
"$root_dir/scripts/validate_commit_message.sh" "$temp_dir/message"

git -C "$work_repo" branch "docs/fixture"
git -C "$work_repo" tag -a v0.3.0-fixture -m "UGS fixture release"
git -C "$work_repo" tag v0.3.0-lightweight-fixture
git clone --quiet --bare "$work_repo" "$bare_repo"

[ "$(git --git-dir="$bare_repo" show-ref --verify --hash refs/heads/main)" = "$commit" ]
[ "$(git --git-dir="$bare_repo" cat-file -t refs/tags/v0.3.0-fixture)" = "tag" ]
[ "$(git --git-dir="$bare_repo" rev-parse refs/tags/v0.3.0-fixture^{commit})" = "$commit" ]
[ "$(git --git-dir="$bare_repo" cat-file -t refs/tags/v0.3.0-lightweight-fixture)" = "commit" ]

echo "Git fixture validation passed"
