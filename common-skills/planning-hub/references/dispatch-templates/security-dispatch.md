# Security Agent Dispatch Template

Use this template when dispatching `sdlc-planner-security` via `new_task` for per-story security controls (Phase 3).

For security overview rollup (Phase 4), use `security-rollup-dispatch.md` instead.

## Required Message Structure

```
PLAN: Per-Story Security Controls

MODE: PER-STORY (Phase 3)
STORY: US-NNN-name
STORY FOLDER: plan/user-stories/US-NNN-name/

CONTEXT:
- plan/user-stories/US-NNN-name/story.md: REQUIRED (scope, acceptance criteria, dependency manifest)
- plan/system-architecture.md: REQUIRED (security boundaries, trust zones)
- plan/contracts/auth-model.md: [exists / does not exist — read if present]
- plan/prd.md: REQUIRED (security NFRs, compliance requirements)
- [Whether this is initial assessment or revision based on validation feedback]

SCOPE:
- IN SCOPE: Security controls for this story — authentication requirements, authorization rules, data protection, input validation, threat assessment scoped to this story's functionality
- OUT OF SCOPE: System-wide security overview (Phase 4 rollup), other stories' security controls, implementation code

EXISTING PLAN ARTIFACTS:
- plan/user-stories/US-NNN-name/story.md: REQUIRED
- plan/user-stories/US-NNN-name/security.md: [exists / does not exist]
- plan/user-stories/US-NNN-name/api.md: [exists / does not exist — useful for endpoint auth mapping]
- plan/user-stories/US-NNN-name/data.md: [exists / does not exist — useful for PII identification]
- plan/system-architecture.md: REQUIRED
- plan/contracts/auth-model.md: [exists / does not exist]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- Story acceptance criteria involving security or auth
- Architecture security boundaries and trust zones
- Auth model contract (if consumed by this story)
- PRD security and compliance NFRs

SHARED SPARRING RULES:
Read and apply common-skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- Write security controls to plan/user-stories/US-NNN-name/security.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that security.md has been written in the story folder
2. Threat assessment scoped to this story
3. Auth requirements per API endpoint (if applicable)
4. Data protection measures for PII/sensitive fields
5. Alignment with auth-model contract (if consumed)
6. Unresolved security questions or risks

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
