# API Design Agent Dispatch Template

Use this template when dispatching `sdlc-planner-api` via `new_task` for a single user story.

## Required Message Structure

```
PLAN: Per-Story API Design

STORY: US-NNN-name
STORY FOLDER: plan/user-stories/US-NNN-name/

CONTEXT:
- plan/user-stories/US-NNN-name/story.md: REQUIRED (scope, acceptance criteria, dependency manifest)
- plan/system-architecture.md: REQUIRED (integration points, API gateway config)
- plan/contracts/: [list consumed contracts — especially shared DTOs and error formats]
- plan/user-stories/US-NNN-name/hld.md: RECOMMENDED (component structure for endpoint mapping)
- [Whether this is initial design or revision based on validation feedback]

SCOPE:
- IN SCOPE: API endpoint design for this story — routes, methods, request/response schemas, authentication/authorization per endpoint, error handling, versioning
- OUT OF SCOPE: Other stories' APIs, data storage implementation (Data Architecture agent), security threat model (Security agent), implementation code

EXISTING PLAN ARTIFACTS:
- plan/user-stories/US-NNN-name/story.md: REQUIRED
- plan/user-stories/US-NNN-name/api.md: [exists / does not exist]
- plan/user-stories/US-NNN-name/hld.md: [exists / does not exist]
- plan/system-architecture.md: REQUIRED
- plan/contracts/: [list relevant contract files, especially api-error-format.md, auth-model.md]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- Story acceptance criteria involving API interactions
- Architecture integration points and API gateway patterns
- Consumed contracts: [list contract names and their definitions]
- Provided contracts: [if this story provides API contracts consumed by others]

SHARED SPARRING RULES:
Read and apply common-skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- Write API design to plan/user-stories/US-NNN-name/api.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that api.md has been written in the story folder
2. Endpoint inventory: method, path, purpose, auth required
3. Contract compliance: how consumed contracts are used in schemas
4. Error handling approach and alignment with error format contract
5. Unresolved questions or blockers

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
