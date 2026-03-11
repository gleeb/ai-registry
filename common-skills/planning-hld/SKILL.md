---
name: planning-hld
description: HLD specialist agent skill. Produces High-Level Design documents and User Story decomposition from validated PRD and System Architecture inputs. Defines component-level design, acceptance criteria, and traceability chains. Writes to plan/hld.md and plan/user-stories/. Operates independently of any SaaS system.
---

# Planning HLD

## When to use
- Use when decomposing a validated PRD into high-level design and user stories.
- Use when updating or revising existing HLD and user stories in `plan/`.
- Use when the Planning Hub dispatches HLD work.

## When NOT to use
- DENY use before the PRD passes all 8 validation dimensions — the PRD must be validated first.
- DENY use for LLD generation — LLDs are created by the sdlc-architect during execution.
- DENY use for implementation work.
- DENY use for SaaS synchronization — use the appropriate sync skill.

## Inputs required
1. Validated `plan/prd.md`.
2. `plan/system-architecture.md` (system topology and component boundaries).
3. `plan/security.md` (if available, for security-informed design).

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

### Phase 1: Context Gathering
1. Read `plan/prd.md` — extract user story groups (section 7), constraints, and NFRs.
2. Read `plan/system-architecture.md` — extract component boundaries, integration patterns, technology stack.
3. Read `plan/security.md` if available — extract security requirements that affect design.
4. Identify the scope: full decomposition (greenfield) or targeted update (incremental).

### Phase 2: User Story Decomposition
1. ALWAYS create a "Project Scaffolding and Environment Setup" user story as the first story (`US-001-scaffolding.md`). This covers:
   - Repository initialization and project structure
   - Package manager and dependency setup
   - Linting, formatting, and CI configuration
   - Documentation tree (`docs/`) scaffolding
   - Development environment verification
2. Derive remaining user stories from the user story groups in PRD section 7.
3. Use the user story template from [`references/USER-STORY.md`](references/USER-STORY.md).
4. For each user story:
   - Define scope boundaries.
   - Write testable acceptance criteria (Given/When/Then or explicit bullet checks).
   - Include error cases and edge behaviors.
   - Map to parent PRD section.
5. Check for sibling overlap across user stories.
6. Write user stories to `plan/user-stories/US-NNN-[name].md`.

### Phase 3: High-Level Design
1. For each major component or feature area, produce an HLD section.
2. Use the HLD template from [`references/HLD.md`](references/HLD.md).
3. Each HLD section must include:
   - Outcome statement.
   - Parent linkage (to user story and PRD).
   - Scope (in and out).
   - High-level design (architecture approach, key interfaces, data contracts).
   - Acceptance criteria (testable, observable).
   - Dependencies and blockers.
4. Verify traceability: each HLD section traces to a user story which traces to the PRD.
5. Check for sibling overlap across HLD sections.
6. Write the HLD to `plan/hld.md`.

### Phase 4: Review with User
1. Present the decomposition summary to the user.
2. Spar on each user story and HLD section:
   - Challenge scope boundaries.
   - Probe acceptance criteria for testability.
   - Verify no gaps in PRD coverage.
3. Iterate until the user approves.

### Phase 5: Completion
1. Write final versions of `plan/hld.md` and `plan/user-stories/*.md`.
2. Return completion summary to the Planning Hub.

## Sparring Protocol
- Challenge every scope boundary: "Where exactly does this user story end and the next begin?"
- Probe acceptance criteria: "Can you write a test for this right now?"
- Check for hidden dependencies: "Does this user story assume something from another story is already done?"
- Verify traceability: "Which PRD requirement does this HLD section satisfy?"
- Look for gaps: "Is there a PRD requirement that no user story addresses?"
- Check sizing: "Is this HLD section small enough for one focused implementation cycle?"

## Anti-Pleasing Patterns
- **Scope creep acceptance**: Challenge any HLD section that tries to cover too much.
- **Vague acceptance criteria**: DENY "it should work correctly" — demand specific observable conditions.
- **Missing error cases**: Always ask about error handling and boundary conditions.
- **Assumed dependencies**: Make all dependencies explicit.
- **Gap glossing**: If a PRD requirement has no corresponding HLD section, flag it immediately.

## Output
- `plan/hld.md` — the High-Level Design document.
- `plan/user-stories/US-NNN-[name].md` — individual user story files.

## Files
- [`references/HLD.md`](references/HLD.md): HLD section template and quality checklist.
- [`references/USER-STORY.md`](references/USER-STORY.md): User Story template and decomposition rules.

## Troubleshooting
- If PRD is not validated, DENY HLD work and report the blocker to the Planning Hub.
- If architecture is missing, DENY HLD work and report the blocker.
- If an HLD section is too broad for one implementation cycle, split it.
- If user stories overlap, require explicit boundary rewrite before proceeding.
