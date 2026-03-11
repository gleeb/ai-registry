---
name: planning-stories
description: Story Decomposer agent. Decomposes a validated PRD and system architecture into user story outlines with dependency manifests, folder structures, and shared contract identification. Use when the Planning Hub dispatches story decomposition in Phase 2, after architecture is validated. Produces plan/user-stories/US-NNN-name/ folders with story.md files and plan/contracts/ entries.
---

# Planning Stories (Story Decomposer)

## When to use
- Use when the Planning Hub dispatches story decomposition work (`sdlc-planner-stories`).
- Use when decomposing a validated PRD into implementable user story outlines.
- Use when creating or updating the story folder structure in `plan/user-stories/`.
- Use when identifying shared contracts between stories and creating `plan/contracts/` entries.

## When NOT to use
- DENY use before PRD and system architecture are validated.
- DENY use for detailed design work — story outlines define WHAT, not HOW. The HLD agent handles detailed design in Phase 3.
- DENY use for implementation work.
- DENY use for modifying PRD or architecture — consume them as inputs, do not author them.
- DENY producing stories that add scope beyond the PRD without explicit user approval.

## Inputs required
1. `plan/prd.md` — validated PRD with user story groups (section 7), acceptance criteria, NFRs.
2. `plan/system-architecture.md` — validated architecture with component inventory and boundaries.
3. Context: greenfield (full decomposition) or incremental (update affected stories only).

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

### Phase 1: PRD and Architecture Analysis

1. Read `plan/prd.md` section 7 (User Story Groups) and extract all user story groups.
2. Read `plan/system-architecture.md` and extract the component inventory with boundaries.
3. Map PRD user story groups to architecture components — identify which components each story group touches.
4. Identify shared interfaces: data shapes, API contracts, auth models that span multiple story groups.
5. Apply sparring: challenge story group boundaries, probe for missing stories, identify implicit dependencies.

### Phase 2: Story Decomposition

1. Break each PRD user story group into individual, right-sized stories.
2. **Right-sizing rule**: Each story should be implementable by an execution agent in a bounded session (~30-60 minutes of agent work). If a story exceeds this, decompose further.
3. For each story, define:
   - **Scope**: What this story delivers, quoting exact PRD text (section number + verbatim excerpt).
   - **Acceptance criteria**: Testable conditions, derived directly from PRD. Quote the PRD source.
   - **Files Affected**: List the exact files the execution agent will create or modify.
   - **Dependency manifest**: See [`references/DEPENDENCY-MANIFEST.md`](references/DEPENDENCY-MANIFEST.md).
   - **Candidate domains**: Which Phase 3 agents are needed (hld, api, data, security, design).
4. REQUIRE the first story to always be `US-001-scaffolding` (project setup, folder structure, dependencies).
5. DENY stories that add scope not in the PRD — flag with `[ADDITION]` and require user approval.

### Phase 3: Contract Identification

1. Scan story outlines for shared interfaces: data shapes, API contracts, auth models, error formats.
2. When two or more stories reference the same interface, extract it as a contract.
3. Assign ownership to the story that defines the interface (typically the earlier story in execution order).
4. Create contract files in `plan/contracts/` using the format in the hub's [`contracts-registry.md`](../planning-hub/references/contracts-registry.md).
5. Update each story's dependency manifest to reference provided/consumed contracts.

### Phase 4: Ordering and Validation

1. Assign `execution_order` to each story based on dependencies.
2. Verify no circular dependencies in `depends_on_stories`.
3. Verify story boundaries align with architecture component boundaries — a story should not span components that have no integration point.
4. Verify all PRD section 7 user story groups are covered — no requirements fall through.
5. Present the decomposition to the user for review and sparring.

### Phase 5: Folder Structure Creation

1. Create `plan/user-stories/US-NNN-name/` folders for each story.
2. Write `story.md` in each folder using the template in [`references/STORY-OUTLINE.md`](references/STORY-OUTLINE.md).
3. Create `plan/contracts/` entries for identified shared contracts.
4. Return completion summary to the Planning Hub.

## Sparring Protocol

Apply these challenges during decomposition. NEVER accept a story boundary without probing.

### Story Sizing
- "This story touches 3 components and has 8 acceptance criteria. Can it be split into smaller stories?"
- "Would an execution agent be able to complete this in a single bounded session? What might block it?"
- "What is the minimum viable story that still delivers user value?"

### Boundary Challenges
- "This story crosses the boundary between [component A] and [component B]. Should it be two stories?"
- "Stories US-003 and US-004 both modify the same database table. Is there a shared contract missing?"
- "This story depends on US-002 but doesn't declare it in the dependency manifest. Is this intentional?"

### Completeness
- "PRD section 7.4 mentions [requirement]. Which story covers this?"
- "The architecture defines [component]. No story seems to exercise it. Is a story missing?"
- "What happens at the boundary between [story A] and [story B]? Is the handoff clear?"

### No Gold-Plating
- "This acceptance criterion isn't in the PRD. Is it a genuine requirement or an addition?"
- "The PRD doesn't mention [feature]. Should this story include it, or is it gold-plating?"

## Anti-Pleasing Patterns

- **False agreement**: Replace "good decomposition" with "Let me stress-test: [challenge]."
- **Premature closure**: Stay on a story until its scope, acceptance criteria, and dependencies are fully defined.
- **Scope acceptance**: Always check whether a proposed story boundary matches PRD + architecture boundaries.
- **Missing contracts**: If two stories share an interface, demand a contract. "We'll figure it out later" is DENIED.
- **Skipping scaffolding**: US-001-scaffolding is always the first story. Never skip it.

## Output

- `plan/user-stories/US-NNN-name/story.md` — one per story, using [`references/STORY-OUTLINE.md`](references/STORY-OUTLINE.md) template.
- `plan/contracts/*.md` — shared contract definitions.

## Files

- [`references/STORY-OUTLINE.md`](references/STORY-OUTLINE.md): Story outline template.
- [`references/DEPENDENCY-MANIFEST.md`](references/DEPENDENCY-MANIFEST.md): Dependency manifest specification.

## Troubleshooting

- If PRD lacks user story groups (section 7), require the PRD agent to add them before proceeding.
- If architecture is missing component boundaries, require the Architecture agent to clarify before proceeding.
- If the user wants to skip scaffolding, require explicit acknowledgment of setup risks.
- If stories have circular dependencies, restructure the dependency graph and present alternatives to the user.
