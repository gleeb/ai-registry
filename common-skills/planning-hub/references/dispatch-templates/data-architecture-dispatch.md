# Data Architecture Agent Dispatch Template

Use this template when dispatching `sdlc-planner-data` via the Task tool for a single user story.

## Required Message Structure

```
PLAN: Per-Story Data Architecture

STORY: US-NNN-name
STORY FOLDER: plan/user-stories/US-NNN-name/

CONTEXT:
- plan/user-stories/US-NNN-name/story.md: REQUIRED (scope, acceptance criteria, dependency manifest)
- plan/system-architecture.md: REQUIRED (data stores, technology choices)
- plan/contracts/: [list consumed contracts — especially shared entity definitions]
- plan/user-stories/US-NNN-name/hld.md: RECOMMENDED (component structure for entity mapping)
- [Whether this is initial design or revision based on validation feedback]

SCOPE:
- IN SCOPE: Data models, schemas, entity relationships, storage strategy, migration approach for this story
- OUT OF SCOPE: Other stories' data models, API endpoint design (API Design agent), implementation code

EXISTING PLAN ARTIFACTS:
- plan/user-stories/US-NNN-name/story.md: REQUIRED
- plan/user-stories/US-NNN-name/data.md: [exists / does not exist]
- plan/user-stories/US-NNN-name/hld.md: [exists / does not exist]
- plan/user-stories/US-NNN-name/api.md: [exists / does not exist — useful for schema alignment]
- plan/system-architecture.md: REQUIRED
- plan/contracts/: [list relevant contract files, especially shared entity definitions]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- Story acceptance criteria involving data persistence
- Architecture data store choices and constraints
- Consumed contracts: [list entity contracts and their definitions]
- Provided contracts: [if this story defines entities consumed by others]

SHARED SPARRING RULES:
Read and apply skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- Write data architecture to plan/user-stories/US-NNN-name/data.md

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Confirmation that data.md has been written in the story folder
2. Entity inventory: name, fields, relationships, storage target
3. Contract compliance: how consumed entity contracts are reflected in schemas
4. Migration strategy (if modifying existing data structures)
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
