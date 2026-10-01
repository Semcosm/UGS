# Post-v0.3.29 Tag Distribution Audit

**Status:** draft for manual review; no future tag is approved by this file

**Audit date:** 2026-09-30

**Current formal release:** v0.3.29

## Audit conclusion

v0.3.29 is the latest formal tag. The commits after the tag are limited to
the release supply-chain evidence and self-bootstrap closure:

- v0.3.29 tag target: 0a0278d
- post-tag evidence commit: 18bd36d
- post-tag evidence CR closure: 5f66d4a
- self-bootstrap commit: 1acf347
- self-bootstrap CR closure: a33eea7

These commits complete the v0.3.29 release boundary on main; they do not
justify a new patch, minor, or major tag by themselves.

## Candidate tag distribution

The table below is a review proposal only. It separates work already shipped
under policy version v0.3 from work that still needs an explicit release
decision.

| Candidate tag | Planning scope | Current evidence | Review decision needed |
| --- | --- | --- | --- |
| v0.3.30 | Governance and roadmap closure before the next feature tag | The tag-distribution audit, v0.3.29 baseline correction, and the v0.3.31 branch-closure design are documented; no runtime behavior changes | Approve the v0.3.30 packet as a documentation-only release and keep the active policy at v0.3 |
| v0.3.31 | Branch closure for merged and abandoned topic branches | Design only: convenient close command, merged-branch safety checks, optional archive refs for abandoned work, idempotent local/remote cleanup, and machine-readable reports | Approve the command surface and audit model before implementation; keep this work out of v0.3.30 |
| v0.4.0 | Contract hardening and compatibility boundary | CR-0071 vocabulary/compatibility, CR-0072 stable error reports, and CR-0073 offline migration/rollback are integrated while policy_version remains v0.3; seven older accepted CRs still have pending integrated results | Decide whether these delivered capabilities should be released as a v0.4 policy declaration, backported as v0.3.x documentation/tooling, or split across both; close or explicitly grandfather the remaining CR records before declaring the exit criteria complete |
| v0.5.0 | Interoperability and evidence | Canonical CR model (CR-0074) and signed CR attestations (CR-0076) are delivered; cross-binding to release evidence, adapter portability, and retention/recovery remain open | Confirm the cross-release evidence and independent-adapter work as the v0.5 gate |
| v0.6.0 | Supply-chain and operations | v0.3 already validates release SBOMs, build records, attestations, and reproducibility; offline mirror/air-gap procedures, key-transparency evidence, and disaster-recovery exercises remain open | Confirm whether these operational procedures belong in v0.6 and define their evidence gate |
| v0.7.0 | Adapter and repository ecosystem | GitHub and bare-Git adapters exist; versioned multi-adapter capability semantics, non-GitHub conformance, and repository-shape migration guidance remain open | Confirm the adapter matrix and the first non-GitHub conformance target |
| v1.0.0 | Core stability milestone | Depends on completion and review of the v0.4-v0.7 exit criteria | Approve only after the Core vocabulary, policy wire format, CR binding, report schema, signature namespaces, and conformance semantics are frozen |

## Explicit exclusions

- No v0.4, v0.5, v0.6, v0.7, or v1.0 tag currently exists.
- No future tag should be created solely because a roadmap phase has a name.
- SemVer prerelease tags such as -rc.1 are not proposed here because the
  current release policy describes formal tags as v<major>.<minor>.<patch>;
  adding prerelease tags would require a separate policy decision.
- The Phase A-F labels in the long-term roadmap are historical planning labels
  from CR-0070, not user-approved release assignments.

## Manual review checklist

Before changing the roadmap or creating a future release packet, record a new
CR that answers these questions:

1. Which candidate tag receives each already delivered capability?
2. Is v0.4.0 a policy-version change, a distribution-only release, or both?
3. Which of the seven accepted records with Integrated Result: pending are
   closed, grandfathered, or still excluded from the v0.4 gate?
4. What exact evidence is required before each candidate tag is eligible?
5. Which candidate tags, if any, are intentionally skipped?

Until those answers are recorded, this audit remains a review worksheet and
does not change the active v0.3 policy or release history.
