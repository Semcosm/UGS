#!/usr/bin/env bash
set -euo pipefail

root_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir"' EXIT

work_repo="$temp_dir/work"
bare_repo="$temp_dir/bare.git"
hooks_dir="$temp_dir/hooks"
git init --quiet -b main "$work_repo"
git -C "$work_repo" config user.name "UGS Fixture"
git -C "$work_repo" config user.email "fixture@example.invalid"
mkdir -p "$hooks_dir"
printf '#!/usr/bin/env bash\nprintf hook-ran > "$GIT_DIR/hook-marker"\n' > "$hooks_dir/pre-push"
chmod +x "$hooks_dir/pre-push"
git -C "$work_repo" config core.hooksPath "$hooks_dir"
git -C "$work_repo" config --get core.hooksPath | grep -Fqx "$hooks_dir"

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

# Exercise real SSH-signed objects in the disposable repository.  The key is
# generated here and never depends on UGS's trusted signer history.
ssh-keygen -q -t ed25519 -N '' -C fixture@example.invalid -f "$temp_dir/fixture-key"
git -C "$work_repo" config gpg.format ssh
git -C "$work_repo" config user.signingKey "$temp_dir/fixture-key"
printf 'fixture@example.invalid namespaces="git" %s\n' "$(cat "$temp_dir/fixture-key.pub")" > "$temp_dir/allowed_signers"
printf 'signed\n' >> "$work_repo/fixture.txt"
git -C "$work_repo" add fixture.txt
git -C "$work_repo" commit --quiet -S -m 'docs(fixture): add signed evidence' -m 'Refs: fixture'
signed_commit="$(git -C "$work_repo" rev-parse HEAD)"
git -C "$work_repo" -c gpg.ssh.allowedSignersFile="$temp_dir/allowed_signers" verify-commit "$signed_commit" >/dev/null

# Model a multi-commit GitHub rebase: each unsigned integration commit keeps
# the signed source tree, author, and message, while its parent object is a
# rebased equivalent rather than the original parent OID.
git -C "$work_repo" config gpg.format ssh
printf '%s\n' "$(cat "$temp_dir/allowed_signers")" > "$work_repo/.fixture-allowed-signers"
mkdir -p "$work_repo/keys"
cp "$temp_dir/allowed_signers" "$work_repo/keys/allowed_signers"
: > "$work_repo/keys/revoked_signers"
git -C "$work_repo" config user.signingKey "$temp_dir/fixture-key"
printf 'second signed evidence\n' >> "$work_repo/fixture.txt"
git -C "$work_repo" add fixture.txt
git -C "$work_repo" commit --quiet -S -m 'docs(fixture): add second signed evidence' -m 'Refs: fixture'
source_second="$(git -C "$work_repo" rev-parse HEAD)"
source_message="$temp_dir/source-message"
git -C "$work_repo" cat-file commit "$signed_commit" | sed '1,/^$/d' > "$source_message"
source_tree="$(git -C "$work_repo" show -s --format='%T' "$signed_commit")"
source_parent_tree="$(git -C "$work_repo" show -s --format='%T' "$signed_commit^")"
source_author_name="$(git -C "$work_repo" show -s --format='%an' "$signed_commit")"
source_author_email="$(git -C "$work_repo" show -s --format='%ae' "$signed_commit")"
source_author_date="$(git -C "$work_repo" show -s --format='%aI' "$signed_commit")"
alternate_parent="$(printf 'docs(fixture): rebased parent\n\nRefs: fixture\n' | GIT_AUTHOR_NAME='UGS Fixture' GIT_AUTHOR_EMAIL='fixture@example.invalid' GIT_COMMITTER_NAME='UGS Fixture' GIT_COMMITTER_EMAIL='fixture@example.invalid' git -C "$work_repo" commit-tree "$source_parent_tree")"
target_first="$(GIT_AUTHOR_NAME="$source_author_name" GIT_AUTHOR_EMAIL="$source_author_email" GIT_AUTHOR_DATE="$source_author_date" GIT_COMMITTER_NAME="$source_author_name" GIT_COMMITTER_EMAIL="$source_author_email" GIT_COMMITTER_DATE="$source_author_date" git -C "$work_repo" commit-tree "$source_tree" -p "$alternate_parent" < "$source_message")"
second_message="$temp_dir/second-message"
git -C "$work_repo" cat-file commit "$source_second" | sed '1,/^$/d' > "$second_message"
second_tree="$(git -C "$work_repo" show -s --format='%T' "$source_second")"
second_author_name="$(git -C "$work_repo" show -s --format='%an' "$source_second")"
second_author_email="$(git -C "$work_repo" show -s --format='%ae' "$source_second")"
second_author_date="$(git -C "$work_repo" show -s --format='%aI' "$source_second")"
target_second="$(GIT_AUTHOR_NAME="$second_author_name" GIT_AUTHOR_EMAIL="$second_author_email" GIT_AUTHOR_DATE="$second_author_date" GIT_COMMITTER_NAME="$second_author_name" GIT_COMMITTER_EMAIL="$second_author_email" GIT_COMMITTER_DATE="$second_author_date" git -C "$work_repo" commit-tree "$second_tree" -p "$target_first" < "$second_message")"
git -C "$work_repo" update-ref refs/heads/signed-source "$source_second"
git -C "$work_repo" update-ref refs/heads/rebase-target "$target_second"
(cd "$work_repo" && "$root_dir/scripts/validate_commit_signatures.sh" "$alternate_parent..$target_second")

# A changed tree must not be accepted merely because its message and author
# resemble a signed source commit.
tampered_blob="$(printf 'tampered\n' | git -C "$work_repo" hash-object -w --stdin)"
tampered_tree="$(printf '100644 blob %s\tfixture.txt\n' "$tampered_blob" | git -C "$work_repo" mktree)"
tampered_commit="$(GIT_AUTHOR_NAME="$second_author_name" GIT_AUTHOR_EMAIL="$second_author_email" GIT_AUTHOR_DATE="$second_author_date" GIT_COMMITTER_NAME="$second_author_name" GIT_COMMITTER_EMAIL="$second_author_email" GIT_COMMITTER_DATE="$second_author_date" git -C "$work_repo" commit-tree "$tampered_tree" -p "$target_first" < "$second_message")"
if (cd "$work_repo" && "$root_dir/scripts/validate_commit_signatures.sh" "$target_first..$tampered_commit" >/dev/null 2>&1); then
  echo "tampered rebase commit unexpectedly passed signature provenance" >&2
  exit 1
fi

git -C "$work_repo" branch "docs/fixture"
git -C "$work_repo" tag -s v0.3.0-fixture -m "UGS fixture release"
git -C "$work_repo" tag v0.3.0-lightweight-fixture
git -C "$work_repo" -c gpg.ssh.allowedSignersFile="$temp_dir/allowed_signers" verify-tag v0.3.0-fixture >/dev/null
git clone --quiet --bare "$work_repo" "$bare_repo"

[ "$(git --git-dir="$bare_repo" show-ref --verify --hash refs/heads/main)" = "$source_second" ]
[ "$(git --git-dir="$bare_repo" cat-file -t refs/tags/v0.3.0-fixture)" = "tag" ]
[ "$(git --git-dir="$bare_repo" rev-parse refs/tags/v0.3.0-fixture^{commit})" = "$source_second" ]
[ "$(git --git-dir="$bare_repo" cat-file -t refs/tags/v0.3.0-lightweight-fixture)" = "commit" ]
if [ "$(git --git-dir="$bare_repo" cat-file -t refs/tags/v0.3.0-lightweight-fixture)" != "tag" ]; then
  : # A lightweight object is intentionally not a formal release tag.
else
  echo "lightweight release tag unexpectedly annotated" >&2
  exit 1
fi

# Exercise rebase, merge, squash, and protected-ref decisions without using
# any object from this checkout's history.
git -C "$work_repo" checkout --quiet -b docs/rebase-fixture main
printf 'rebase\n' >> "$work_repo/fixture.txt"
git -C "$work_repo" add fixture.txt && git -C "$work_repo" commit --quiet -m 'docs(fixture): rebase candidate' -m 'Refs: fixture'
git -C "$work_repo" rebase --quiet main
git -C "$work_repo" checkout --quiet main
git -C "$work_repo" checkout --quiet -b docs/merge-fixture main
printf 'merge\n' >> "$work_repo/fixture.txt"
git -C "$work_repo" add fixture.txt && git -C "$work_repo" commit --quiet -m 'docs(fixture): merge candidate' -m 'Refs: fixture'
merge_head="$(git -C "$work_repo" rev-parse HEAD)"
git -C "$work_repo" checkout --quiet main
git -C "$work_repo" merge --quiet --no-ff docs/merge-fixture -m 'docs(fixture): merge integration'
merge_result="$(git -C "$work_repo" rev-parse HEAD)"
[ "$(git -C "$work_repo" rev-list --parents -n1 "$merge_result" | wc -w)" -ge 3 ]
git -C "$work_repo" checkout --quiet -b docs/squash-fixture main
printf 'squash\n' >> "$work_repo/fixture.txt"
git -C "$work_repo" add fixture.txt && git -C "$work_repo" commit --quiet -m 'docs(fixture): squash candidate' -m 'Refs: fixture'
git -C "$work_repo" checkout --quiet main
git -C "$work_repo" merge --quiet --squash docs/squash-fixture && git -C "$work_repo" commit --quiet -m 'docs(fixture): squash integration' -m 'Refs: fixture'
squash_result="$(git -C "$work_repo" rev-parse HEAD)"
[ "$(git -C "$work_repo" merge-base --is-ancestor docs/squash-fixture "$squash_result"; echo $?)" -ne 0 ]
old_main="$(git -C "$work_repo" rev-parse HEAD^)"
new_main="$(git -C "$work_repo" rev-parse HEAD)"
(cd "$work_repo" && "$root_dir/scripts/validate_ref_update.sh" "$old_main" "$new_main" refs/heads/main)
if (cd "$work_repo" && "$root_dir/scripts/validate_ref_update.sh" "$new_main" "$old_main" refs/heads/main >/dev/null 2>&1); then
  echo "protected main accepted a non-fast-forward update" >&2
  exit 1
fi
if (cd "$work_repo" && "$root_dir/scripts/validate_ref_update.sh" "$new_main" 0000000000000000000000000000000000000000 refs/heads/main >/dev/null 2>&1); then
  echo "protected main deletion unexpectedly passed" >&2
  exit 1
fi

echo "Git fixture validation passed"
