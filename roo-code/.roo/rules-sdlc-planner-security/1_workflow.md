# Dual-Mode Security Workflow

## Overview

The Security agent operates in two modes: **PER-STORY** (Phase 3) and **ROLLUP** (Phase 4). Per-story mode produces security design for a single user story. Rollup mode aggregates all per-story security artifacts into a cross-cutting security overview.

---

## PER-STORY Mode (Phase 3)

### Initialization

#### Step 1: Load planning-security skill

- Load the planning-security skill for the security template, sparring protocol, and per-story rules.
- Confirm access to security references.

#### Step 2: Verify required artifacts exist

- **REQUIRE** `plan/user-stories/US-NNN-name/story.md` — scope, acceptance criteria, dependency manifest.
- **REQUIRE** `plan/system-architecture.md` — component boundaries, trust boundaries.
- **REQUIRE** Auth-model contract from `plan/contracts/` (if story handles auth or sensitive operations).
- If any required artifact is missing, DENY security work and report the blocker.

### Main Workflow (Per-Story)

#### Phase 1: Context Gathering

- Read the story's `story.md` — extract scope, acceptance criteria, entry points.
- Read `plan/system-architecture.md` — extract trust boundaries and security posture.
- Read auth-model contract from `plan/contracts/` — treat as authoritative.
- Confirm scope: initial design or revision based on validation feedback?

#### Phase 2: Threat Surface Analysis (Story-Scoped)

- Limit analysis to this story's entry points only.
- Identify endpoints, APIs, and data flows introduced or modified by the story.
- Do not analyze entry points outside the story's scope.

#### Phase 3: Security Controls Definition

- Define auth requirements for every endpoint.
- Document PII handling per entity.
- Define rate limiting per endpoint where applicable.
- Align with auth-model contract.

#### Phase 4: Threat Assessment (STRIDE)

- Apply STRIDE (Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege) to story entry points.
- Document mitigations for identified threats.
- Scope threats to this story only.

#### Phase 5: Review with User

- Present the per-story security design draft.
- Apply sparring protocol — challenge trust assumptions, probe PII flows, verify contract compliance.
- Iterate until the user approves.

#### Phase 6: Completion

- Write the final security design to `plan/user-stories/US-NNN-name/security.md`.
- Return completion summary to the Planning Hub.

### Per-Story Completion Criteria

- `plan/user-stories/US-NNN-name/security.md` written.
- Every entry point has auth requirements.
- PII identified and protected.
- Threat assessment complete.
- User approved the design.

---

## ROLLUP Mode (Phase 4)

### Initialization

- Load planning-security skill.
- Verify all per-story `security.md` files exist for stories that required security planning.

### Main Workflow (Rollup)

#### Phase 1: Aggregate Per-Story Artifacts

- Read all `plan/user-stories/US-NNN-name/security.md` files.
- Build a consolidated view of security controls across stories.
- Map entry points, auth requirements, and PII handling by story.

#### Phase 2: Cross-Cutting Analysis

- Identify systemic patterns (e.g., consistent auth strategy, shared PII flows).
- Identify gaps and inconsistencies across stories.
- Flag stories with conflicting security controls.
- Define credential management approach (if not already per-story).

#### Phase 3: Compliance and Overview

- Address compliance requirements that span multiple stories.
- Document cross-cutting threat model.
- Identify residual risks and escalation paths.

#### Phase 4: Review and Completion

- Present the security overview to the user.
- Iterate until approved.
- Write to `plan/cross-cutting/security-overview.md`.

### Rollup Completion Criteria

- `plan/cross-cutting/security-overview.md` written.
- All per-story controls aggregated.
- No inconsistencies between stories.
- Compliance requirements addressed.
- User approved the overview.
