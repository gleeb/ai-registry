# Data Architecture Agent Dispatch Template

Use this template when dispatching `sdlc-planner-data` via `new_task` for a single user story.

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
Read and apply common-skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- Write data architecture to plan/user-stories/US-NNN-name/data.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that data.md has been written in the story folder
2. Entity inventory: name, fields, relationships, storage target
3. Contract compliance: how consumed entity contracts are reflected in schemas
4. Migration strategy (if modifying existing data structures)
5. Unresolved questions or blockers

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
