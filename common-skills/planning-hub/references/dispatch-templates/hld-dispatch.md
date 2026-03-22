# HLD Agent Dispatch Template

Use this template when dispatching `sdlc-planner-hld` via `new_task` for a single user story.

## Required Message Structure

```
PLAN: Per-Story High-Level Design

STORY: US-NNN-name
STORY FOLDER: plan/user-stories/US-NNN-name/

CONTEXT:
- plan/user-stories/US-NNN-name/story.md: REQUIRED (scope, acceptance criteria, dependency manifest)
- plan/system-architecture.md: REQUIRED (component boundaries, technology stack)
- plan/contracts/: [list consumed contracts from story.md dependency manifest]
- [Whether this is initial design or revision based on validation feedback]

SCOPE:
- IN SCOPE: High-level design for this specific story — component structure, data flow, integration points, technology choices within architecture constraints
- OUT OF SCOPE: Other stories' designs, detailed API specs (API Design agent), data schema details (Data Architecture agent), security controls (Security agent), implementation code

EXISTING PLAN ARTIFACTS:
- plan/user-stories/US-NNN-name/story.md: REQUIRED
- plan/user-stories/US-NNN-name/hld.md: [exists / does not exist]
- plan/system-architecture.md: REQUIRED
- plan/prd.md: REQUIRED (for traceability)
- plan/contracts/: [list relevant contract files]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- Story acceptance criteria from story.md
- Architecture components from dependency manifest: [list]
- Consumed contracts: [list contract names and what they define]
- PRD sections referenced by story: [list section numbers]

SHARED SPARRING RULES:
Read and apply common-skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- Write HLD to plan/user-stories/US-NNN-name/hld.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that hld.md has been written in the story folder
2. Traceability: each acceptance criterion → HLD section mapping
3. Components and modules defined in this story's HLD
4. Integration points with other stories (via contracts)
5. Technology choices and rationale
6. Unresolved questions or blockers

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
