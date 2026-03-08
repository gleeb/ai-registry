# PRD (Initiative) Reference

## Contents
- Purpose
- Contract gates
- Template (14 sections)
- Quality checklist

## Purpose
Use this format when drafting or refining Initiative-level PRD content.

The PRD is the single source of truth for what the product is, who it is for, what it must do, and what constraints govern it. It must be airtight before decomposition into user stories begins.

## Contract gates
- REQUIRE all 14 sections to be substantive before PRD is considered complete.
- REQUIRE explicit decomposition intent into User Story Projects.
- DENY vague language that cannot be validated from external evidence or observable criteria.
- DENY PRD updates without confirmed MCP state snapshot in current iteration.
- DENY proceeding to user story decomposition before passing all 8 validation dimensions at "high" (see [`references/VALIDATION.md`](references/VALIDATION.md)).
- REQUIRE Initiative-level change communication via Initiative updates using the minimal contract in [`references/COMMUNICATION.md`](references/COMMUNICATION.md).
- ALLOW provisional local PRD draft only when clearly marked `PROVISIONAL - NOT SYNCED TO LINEAR`.

## Template

---

### 1) Metadata

| Field | Value |
|-------|-------|
| Document Version | 0.1.0 |
| Last Updated | [date] |
| Product Owner | [name] |
| Status | Draft / Review / Approved |

---

### 2) Executive Summary

2–3 paragraphs:
- What the product is and what it does.
- Who it is for and the context in which it will be used.
- Key architectural and operational constraints (e.g., local-only, BYOK, no backend).

---

### 3) Problem Statement

- What specific user or business problem is being solved?
- Why does this problem exist, and why does it need to be solved now?
- What is the cost of inaction?

---

### 4) Target Audience

**Primary User**
- Persona description (demographics, context, mental model).
- Typical usage scenario — be specific and concrete.
- Key needs that the product must address.

**Secondary Users** (if applicable)
- For each secondary persona: brief description and key needs.

---

### 5) Goals & Objectives

**Primary Goal**
- One clear sentence: what this product delivers and to whom.

**Measurable Success Criteria**
- Each criterion must be verifiable from an observable state (user behavior, metric, test result).
- No subjective criteria — replace with a measurable threshold.

---

### 6) In Scope

Version the scope explicitly. Each version should have a clear boundary.

**V1 — [Platform or phase name]**
- Bulleted list of in-scope capabilities.

**V2 — [Platform or phase name]** (future)
- Bulleted list of planned extensions.

---

### 7) User Stories

Group user stories by feature area. Each group becomes a Linear Project.

The first group should always be **Project Scaffolding and Environment Setup** — covering repository initialization, tooling, documentation structure, and dev environment verification. This is a prerequisite for all other groups.

**[Feature Area Name]**

| Story | As a | I want | So that |
|-------|------|--------|---------|
| US-001 | [actor] | [action] | [outcome] |

For each story, list Acceptance Criteria:
- Use testable, observable conditions.
- Include error cases and boundary behaviors.
- Use Given/When/Then format or explicit bullet checks.

---

### 8) Constraints

**Budget**
- Operational cost constraints (e.g., zero backend cost, no subscription billing).
- Permitted one-time costs.

**Technology**
- Required technology choices and rationale.
- Prohibited technology categories or approaches.
- Compatibility requirements (e.g., must support V2 mobile extension without full rewrite).

**UX & Design**
- Screen count limits, navigation structure.
- Appearance mode requirements (light, dark).
- Design principles or reference products for visual direction.
- Interaction principles (e.g., one-handed operation, no multi-step flows).

**Scope & Timeline**
- Delivery constraints (deadlines, team size, phasing).
- Rules against scope creep.

---

### 9) Non-Functional Requirements

**Security & Privacy**
- Credential storage strategy.
- Data transmission security.
- Telemetry and analytics policy.
- PII handling, retention, and deletion.
- Warnings or disclosures to users.

**Performance**
- Load time target (specific ms/s threshold, connection type).
- Frame rate / smoothness target.
- Streaming vs. batch for AI/LLM features.
- Latency constraints for non-LLM operations.

**Offline Behavior**
- Which features work offline.
- Which features require connectivity — and what the offline state communicates to the user.

**Accessibility**
- Font scaling, minimum touch target sizes.
- Color usage rules (color not sole indicator of state).
- Screen reader support requirements.

**Platform**
- Target platforms and supported versions.
- Frameworks or build targets required.

---

### 10) Dependencies

| Dependency | Type | Purpose | Notes |
|------------|------|---------|-------|
| [name] | External API / SDK / Platform API / Infrastructure | [what it does] | [version, auth method, owner, cost] |

---

### 11) Assumptions

Explicit assumptions that the PRD is built on. Each assumption should be verifiable or falsifiable.

- [Assumption 1]
- [Assumption 2]

---

### 12) Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| [description] | High / Medium / Low | High / Medium / Low | [how it is mitigated] |

---

### 13) Out of Scope

Explicit exclusions — features, capabilities, or user needs the product intentionally does not address in V1 or V2.

- [Excluded feature or capability]
- [Reason for exclusion, if non-obvious]

---

### 14) Success Metrics

**Leading indicators** (proxy signals during development)
- [Metric and target]

**Outcome indicators** (post-launch validation)
- [Metric and target]

---

## Quality checklist
- REQUIRE all 14 sections are present and substantive — no placeholders.
- REQUIRE success criteria in section 5 are measurable and observable.
- REQUIRE acceptance criteria in section 7 are testable — no subjective terms.
- REQUIRE technology choices in section 8 are justified with known trade-offs.
- REQUIRE risks in section 12 have explicit mitigations.
- REQUIRE out-of-scope list in section 13 prevents scope creep.
- REQUIRE user story groups in section 7 form a coherent set of Linear Projects.
- REQUIRE all 8 validation dimensions pass at "high" before proceeding to user story decomposition.
- REQUIRE each meaningful PRD/Initiative change has a traceable Initiative update entry or equivalent comment trail.
