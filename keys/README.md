# Trusted SSH Signers

This directory is the canonical trust registry for SSH-signed commits and
formal release tags in this repository.

Files:

- `allowed_signers`: OpenSSH allowed signers file used for Git signature
  verification. Entries in this repository use `namespaces="git"`.
- `revoked_signers`: OpenSSH revocation file consulted during verification.

Operational rules:

- Add or remove signers only through a topic branch and CR.
- Use the maintainer email address as the signer principal.
- No bot signer is trusted by default.
- Keep at least one standby signing key available when possible.
- If every trusted signing key is lost, use the repository emergency path only
  to rotate trust material and restore signed normal operation.
