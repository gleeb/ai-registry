# Per-Story HLD Workflow

## Overview

The HLD agent produces High-Level Design for a **single user story** dispatched by the Planning Hub. It reads story-scoped inputs, designs components within story boundaries, documents using the HLD template, reviews with the user, and writes to the story's `hld.md`.

## Initialization

### Step 1: Load planning-hld skill

- Load the planning-hld skill for the HLD template, sparring protocol, and per-story rules.
- Confirm access to `references/HLD.md`.

### Step 2: Verify required artifacts exist

- **REQUIRE** `plan/user-stories/US-NNN-name/story.md` — scope, acceptance criteria, dependency manifest.
- **REQUIRE** `plan/system-architecture.md` — component boundaries, technology stack.
- **REQUIRE** Consumed contracts from `plan/contracts/` (listed in story's dependency manifest).
- If any required artifact is missing, DENY HLD work and report the blocker.

## Main Workflow

### Phase 1: Context Gathering

- Read the story's `story.md` — extract scope, acceptance criteria, and dependency manifest.
- Read `plan/system-architecture.md` — extract components referenced in the story's `architecture_components`.
- Read consumed contracts from `plan/contracts/` — understand shared interfaces this story depends on.
- Read `plan/prd.md` sections referenced in the story's `prd_sections` — for traceability.
- Confirm scope: initial design or revision based on validation feedback?

### Phase 2: Component Design

- For each architecture component this story touches, define:
  - Component responsibilities within this story's scope.
  - Internal module structure (if the component is complex enough).
  - Data flow within and between components.
  - Integration points with other stories (via contracts).
- Use consumed contract definitions as authoritative — do not redefine shared interfaces.
- Technology choices must align with `plan/system-architecture.md`.

### Phase 3: Design Documentation

- Use the template from `references/HLD.md`.
- For each major design unit:
  - Outcome statement (what is observable when done).
  - Parent linkage (story ID, PRD sections).
  - Scope (in and out).
  - High-level design (architecture approach, key interfaces, data contracts).
  - Acceptance criteria mapping (which story ACs this design unit addresses).
  - Dependencies (on contracts, other story artifacts, external systems).
- Verify every story acceptance criterion is addressed by at least one design unit.
- Check that no design unit is out-of-scope for this story.

### Phase 4: Review with User

- Present the per-story HLD draft.
- Apply sparring protocol — challenge component boundaries, probe integration points, verify traceability.
- Iterate until the user approves.

### Phase 5: Completion

- Write the final HLD to `plan/user-stories/US-NNN-name/hld.md`.
- Return completion summary to the Planning Hub.

## Completion Criteria

- `plan/user-stories/US-NNN-name/hld.md` written.
- All story acceptance criteria addressed by design units.
- Traceability verified (AC → design unit → component).
- User approved the design.
