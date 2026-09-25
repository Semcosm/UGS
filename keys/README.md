# Trusted SSH Signers

This directory is the canonical trust registry for SSH-signed commits, formal
release tags, and opt-in UGS evidence attestations in this repository.

Files:

- `allowed_signers`: OpenSSH allowed signers file used for Git and attestation
  signature verification. The release signer uses
  `namespaces="git,ugs-attestation"`. CR reviewer and test attestations use
  the distinct `ugs-cr-review` and `ugs-cr-test` namespaces; a principal must
  be explicitly authorized for the namespace it uses.
- `revoked_signers`: OpenSSH revocation file consulted during verification.
- `signer_roles.json`: v0.3 signer roles, fingerprints, status, and effective dates.

Operational rules:

- Add or remove signers only through a topic branch and CR.
- Use the maintainer email address as the signer principal.
- No bot signer is trusted by default.
- Keep at least one standby signing key available when possible.
- If every trusted signing key is lost, use the repository emergency path only
  to rotate trust material and restore signed normal operation.

Signer role records are append-only audit metadata. An active signer MUST be
present in `allowed_signers`; a revoked signer MUST have an effective end date.
The release signer is authorized for both the `git` and `ugs-attestation`
signature namespaces. Release signatures must use the latter namespace. CR
review and test signatures are separate evidence and must use
`ugs-cr-review` and `ugs-cr-test`, respectively; they must not be relabeled as
release attestations. The current registry need not authorize either CR
namespace until a reviewer or test attester is intentionally added.

`ugs-cr-attestation/v1` attestations bind a CR revision and its derived
`binding.sha256` to either the source identity or the exact integrated result.
The attester principal must match the SSH signature principal and its
`reviewer` or `tester` role must be valid for the attestation's issued time;
the role must also match the attestation type.
Signer rotation is append-only: add the replacement key with its effective
date and close the old role entry with an exclusive `effective_until` boundary;
do not rewrite old attestations. A revocation applies on its effective date,
so newly issued evidence is rejected on and after revocation while historical
evidence remains tied to the key and time at which it was issued.
