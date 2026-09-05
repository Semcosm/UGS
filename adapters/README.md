# Platform adapters

UGS Core validation uses Git-native objects, commit trailers, hooks, CR files,
and signed tags. Platform-specific integrations live below this directory and
translate platform metadata into Core validator inputs.

The `github/` adapter may use `gh`, GitHub Actions, GitHub Releases, and GitHub event fields.
Those dependencies are not part of UGS Core. The `bare-git/` adapter is reserved
for receive/update and request-pull flows without a hosting platform. A bare
repository hook sets `UGS_REPOSITORY_ROOT` to the checkout containing the Core
scripts and invokes `update <ref> <old-object> <new-object>`.
