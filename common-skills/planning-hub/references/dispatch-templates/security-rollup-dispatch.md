# Security Rollup Dispatch Template

**DISPATCH TO**: `sdlc-planner-security`

Use this template when dispatching `sdlc-planner-security` in rollup mode for Phase 4 cross-cutting security overview.

## Required Message Structure

```
PLAN: Security Overview Rollup

CONTEXT:
- Mode: ROLLUP (Phase 4 cross-cutting, NOT per-story)
- All per-story security.md files have been written and validated
- plan/system-architecture.md exists and is validated
- plan/prd.md exists for NFR reference

SCOPE:
- IN SCOPE: Aggregate per-story security controls into a cross-cutting security overview, identify systemic patterns, threat model at system level, authentication/authorization architecture, data protection posture
- OUT OF SCOPE: Per-story security controls (already done), implementation, code

EXISTING PLAN ARTIFACTS:
- plan/prd.md: REQUIRED
- plan/system-architecture.md: REQUIRED
- plan/user-stories/US-NNN-name/security.md: [list all that exist]
- plan/contracts/auth-model.md: [exists / does not exist]
- plan/cross-cutting/security-overview.md: [exists / does not exist]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- PRD NFRs related to security, compliance, data protection
- Architecture security boundaries and trust zones
- All per-story security controls and threat assessments

SHARED SPARRING RULES:
Read and apply skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- Write security overview to plan/cross-cutting/security-overview.md

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Confirmation that plan/cross-cutting/security-overview.md has been written
2. Systemic security patterns identified across stories
3. Aggregate threat model summary
4. Authentication/authorization architecture overview
5. Gaps or inconsistencies found across per-story security controls
6. Recommendations for security testing focus areas

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Re-dispatch (after validation feedback)

When re-dispatching after Plan Validator returns NEEDS WORK, add:

```
VALIDATOR GUIDANCE (from Plan Validator):

REASONED CORRECTIONS:
[Paste the corrections section from the Plan Validator's guidance package.
Each correction includes what's wrong, what the better artifact looks like,
and the reasoning chain explaining why.]

DOCUMENTATION:
[Paste any fetched documentation excerpts from the guidance package.]
[Paste any documentation fetch instructions — if included, use context7 MCP
to retrieve the specified docs before revising. Search for the exact terms,
library, and sections specified.]

IMPROVEMENT INSTRUCTIONS:
[Paste the consolidated improvement instructions from the guidance package.
These are specific, actionable steps to follow.]

Apply the corrections and follow the improvement instructions. If documentation
fetch instructions are included, retrieve the docs via context7 first — they
contain the context needed to produce the correct artifact.
```
