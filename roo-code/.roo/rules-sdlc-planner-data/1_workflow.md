# Per-Story Data Architecture Workflow

## Overview

The Data Architecture agent produces data design for a **single user story** dispatched by the Planning Hub. It reads story-scoped inputs, performs data discovery scoped to the story's entities, designs schemas, analyzes access patterns, reviews with the user, and writes to the story's `data.md`.

## Initialization

### Step 1: Load planning-data-architecture skill

- Load the planning-data-architecture skill for the data template, sparring protocol, and per-story rules.
- Confirm access to data architecture references.

### Step 2: Verify required artifacts exist

- **REQUIRE** `plan/user-stories/US-NNN-name/story.md` — scope, acceptance criteria, dependency manifest.
- **REQUIRE** `plan/system-architecture.md` — component boundaries, technology stack, storage choices.
- **REQUIRE** Consumed contracts from `plan/contracts/` (listed in story's dependency manifest).
- If any required artifact is missing, DENY data architecture work and report the blocker.

## Main Workflow

### Phase 1: Context Gathering

- Read the story's `story.md` — extract scope, acceptance criteria, and dependency manifest.
- Read `plan/system-architecture.md` — extract storage technologies and data flow patterns.
- Read consumed entity contracts from `plan/contracts/` — treat as authoritative for shared entities.
- Confirm scope: initial design or revision based on validation feedback?

### Phase 2: Data Discovery (Story-Scoped)

- Limit discovery to entities relevant to this story only.
- Do not design entities outside the story's scope.
- Use consumed entity contracts as authoritative — do not redefine shared schemas.
- Identify new entities this story introduces.

### Phase 3: Schema Design

- Design schemas for story entities only.
- Align with consumed contracts for shared entities.
- Document field types, constraints, and relationships.
- Identify PII fields and classification.

### Phase 4: Access Pattern Analysis

- Enumerate every query pattern for story entities.
- Define indexes for each query pattern.
- Document read/write volume expectations if known.
- Align storage choices with `plan/system-architecture.md`.

### Phase 5: Migration Strategy

- Define migration approach for any schema changes.
- Document backward compatibility requirements.
- Identify rollback strategy if applicable.

### Phase 6: Review with User

- Present the per-story data design draft.
- Apply sparring protocol — challenge normalization, storage choices, migration approach.
- Iterate until the user approves.

### Phase 7: Completion

- Write the final data design to `plan/user-stories/US-NNN-name/data.md`.
- Return completion summary to the Planning Hub.

## Completion Criteria

- `plan/user-stories/US-NNN-name/data.md` written.
- All data-relevant acceptance criteria addressed.
- Migration strategy defined.
- User approved the design.
