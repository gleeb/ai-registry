---
name: planning-hub
description: Orchestration hub for project planning. Use when starting a new project, adding features to an existing project, or re-planning after changes. Manages 7-phase per-story planning workflow, dispatches specialized sub-agents (PRD, Architecture, Story Decomposer, HLD, Security, API, Data, DevOps, Design, Testing), triggers validation after each phase, handles brownfield change propagation via impact analysis, and optionally syncs to external SaaS systems. Internal plan artifacts in plan/ are the source of truth.
---

# Planning Hub

## When to use
- Use as the entry point for all project planning work.
- Use when starting a new product/project from scratch (greenfield).
- Use when adding significant new capabilities to an existing project (incremental/brownfield).
- Use when re-planning or revising existing plan artifacts.
- Use when the user proposes a change to an existing plan (triggers brownfield change protocol).

## When NOT to use
- DENY use for implementation work — hand off to `sdlc-coordinator` for execution.
- DENY use for SaaS-specific operations — delegate to the appropriate sync skill (if configured).
- DENY direct plan content authoring — dispatch to the appropriate planning sub-agent.

## Core Principle

**Internal planning is king.** All plan artifacts live in the `plan/` folder. No external SaaS system is required. SaaS sync skills are optional translation layers.

**Per-story execution packages.** The planning unit matches the execution unit. Each user story gets its own folder with all artifacts an execution agent needs.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Planning Sub-Agents

| Agent | Task Dispatch Target | Skill (internal only) | Output |
|---|---|---|---|
| PRD | `sdlc-planner-prd` | `planning-prd` | `plan/prd.md` |
| System Architecture | `sdlc-planner-architecture` | `planning-system-architecture` | `plan/system-architecture.md` |
| Story Decomposer | `sdlc-planner-stories` | `planning-stories` | `plan/user-stories/US-NNN-name/story.md` + `plan/contracts/*.md` |
| HLD | `sdlc-planner-hld` | `planning-hld` | `plan/user-stories/US-NNN-name/hld.md` |
| Security | `sdlc-planner-security` | `planning-security` | `plan/user-stories/US-NNN-name/security.md` + `plan/cross-cutting/security-overview.md` |
| API Design | `sdlc-planner-api` | `planning-api-design` | `plan/user-stories/US-NNN-name/api.md` |
| Data Architecture | `sdlc-planner-data` | `planning-data-architecture` | `plan/user-stories/US-NNN-name/data.md` |
| DevOps | `sdlc-planner-devops` | `planning-devops` | `plan/cross-cutting/devops.md` |
| Design/UI-UX | `sdlc-planner-design` | `planning-design` | `plan/user-stories/US-NNN-name/design/` + `plan/design/` |
| Testing Strategy | `sdlc-planner-testing` | `planning-testing-strategy` | `plan/cross-cutting/testing-strategy.md` |
| Plan Validator | `sdlc-plan-validator` | `planning-validator` | `plan/validation/` |

**CRITICAL**: When dispatching via the Task tool, ALWAYS use the **Task Dispatch Target** column (e.g., `sdlc-planner-prd`). NEVER use the Skill column value — skills are loaded internally by the dispatched agent. Using a skill name as a dispatch target will fail with "unknown agent type."

## Checkpoint Integration

Load the `sdlc-checkpoint` skill at hub initialization. The checkpoint script is at `skills/sdlc-checkpoint/scripts/checkpoint.sh`.

**REQUIRE**: Before every dispatch, call `checkpoint.sh planning` with the current state (write-ahead pattern).
**REQUIRE**: After every agent completion, call `checkpoint.sh planning` to record progress.

## Dispatch Logging

**REQUIRE**: Before every sub-agent dispatch, call `checkpoint.sh dispatch-log --event dispatch` with story, hub (`planning`), phase, agent, model profile, and dispatch ID.
**REQUIRE**: After every sub-agent completion, call `checkpoint.sh dispatch-log --event response` with dispatch ID, agent, verdict, duration, and summary excerpt.

Dispatch ID format: `plan-{story}-{agent-short}-i{iteration}` (e.g., `plan-US003-hld-i1`). For non-story phases, use `plan-p{phase}-{agent-short}` (e.g., `plan-p1-prd`).

See the `sdlc-checkpoint` skill for the full `dispatch-log` API and flags.

### Phase 0: Resume Check

Before starting any planning work:

1. Check if `.sdlc/planning.yaml` exists.
2. If it exists, run `skills/sdlc-checkpoint/scripts/verify.sh planning`.
3. Read the `recommendation` field from the output and follow it (see `sdlc-checkpoint/references/resume-protocol.md`).
4. If no checkpoint exists, proceed to Phase 1.

## Workflow

### Phase 1: Requirements (PRD)

1. `checkpoint.sh planning --phase 1 --dispatch sdlc-planner-prd`
2. Dispatch the **PRD Agent** (`sdlc-planner-prd`) using [`dispatch-templates/prd-dispatch.md`](references/dispatch-templates/prd-dispatch.md).
3. The PRD agent conducts interactive sparring with the user, drafts and validates the PRD.
4. `checkpoint.sh planning --completed prd`
5. On completion, dispatch the **Plan Validator** to validate PRD completeness and internal consistency.
6. GATE: PRD must pass all validation dimensions before proceeding.

### Phase 2: Architecture and Story Decomposition

Sequential within this phase:

1. `checkpoint.sh planning --phase 2 --dispatch sdlc-planner-architecture`
2. Dispatch **System Architecture Agent** (`sdlc-planner-architecture`) using [`dispatch-templates/system-architecture-dispatch.md`](references/dispatch-templates/system-architecture-dispatch.md).
3. `checkpoint.sh planning --completed architecture`
4. On completion, dispatch **Plan Validator** to check architecture-PRD alignment.
5. GATE: Architecture must pass validation before story decomposition.
6. `checkpoint.sh planning --dispatch sdlc-planner-stories`
7. Dispatch **Story Decomposer Agent** (`sdlc-planner-stories`) using [`dispatch-templates/story-decomposition-dispatch.md`](references/dispatch-templates/story-decomposition-dispatch.md).
8. `checkpoint.sh planning --completed stories`
9. On completion, dispatch **Plan Validator** to check story coverage and dependency integrity.
10. GATE: All stories must have valid dependency manifests and full PRD coverage.

### Phase 3: Per-Story Planning (loop)

#### Phase 3 Initialization (one-time, after Phase 2 gate passes)

1. `checkpoint.sh planning --build-queue` — builds the ordered `story_queue` in `planning.yaml` from `execution_order` fields in each `story.md`.
2. Read `planning.yaml` and confirm `story_queue` is populated and `total_stories` is set.

#### Phase 3 Loop

**REQUIRE**: Before dispatching agents for the next story, ALWAYS read `planning.yaml` to determine `current_story`. NEVER derive the next story from memory or context — the checkpoint is the single source of truth.

For each iteration:
1. Read `planning.yaml`. The `current_story` field is the next story to plan.
2. If `current_story` is null/empty, Phase 3 is complete — proceed to Phase 4.
3. `checkpoint.sh planning --phase 3 --story {current_story} --agents-done "" --agents-pending "{domains from manifest}"`
4. `checkpoint.sh coordinator --hub planning --story {current_story}`
5. Read the story's `candidate_domains` from its dependency manifest.
6. For each agent to dispatch based on candidate_domains:
   - `checkpoint.sh planning --dispatch {agent-slug}` (write-ahead)
   - Dispatch the agent:
     - **HLD Agent** (always) using [`dispatch-templates/hld-dispatch.md`](references/dispatch-templates/hld-dispatch.md)
     - **API Design Agent** (if `api` in domains) using [`dispatch-templates/api-design-dispatch.md`](references/dispatch-templates/api-design-dispatch.md)
     - **Data Architecture Agent** (if `data` in domains) using [`dispatch-templates/data-architecture-dispatch.md`](references/dispatch-templates/data-architecture-dispatch.md)
     - **Security Agent** in per-story mode (if `security` in domains) using [`dispatch-templates/security-dispatch.md`](references/dispatch-templates/security-dispatch.md)
     - **Design Agent** (if `design` in domains) using [`dispatch-templates/design-dispatch.md`](references/dispatch-templates/design-dispatch.md)
   - `checkpoint.sh planning --completed {domain}` (after each agent returns)
7. On completion, dispatch **Plan Validator** in per-story mode (now includes Check 12: Story Testability Assessment — verifies HLD testability section with per-AC test types, negative testing, and E2E requirements for UI stories).
8. GATE: Per-story validation must pass (including testability) before moving to next story.
9. `checkpoint.sh planning --story-done {current_story}` — appends to `stories_completed` and auto-advances `current_story`.
10. Loop back to step 1.

Use [`dispatch-templates/per-story-planning-dispatch.md`](references/dispatch-templates/per-story-planning-dispatch.md) as the orchestration wrapper.

**Note — Continuous Execution**: After a validation gate passes, proceed immediately to the next story or phase. Do not stop to present a summary and wait for user input unless validation failed, a user decision is needed, or all phases are complete.

### Phase 4: Cross-Cutting Concerns

After all stories are planned:

1. `checkpoint.sh planning --phase 4`
2. `checkpoint.sh planning --dispatch sdlc-planner-security`
3. Dispatch **Security Agent** in rollup mode using [`dispatch-templates/security-rollup-dispatch.md`](references/dispatch-templates/security-rollup-dispatch.md) — produces `plan/cross-cutting/security-overview.md`.
4. `checkpoint.sh planning --completed security-rollup`
5. `checkpoint.sh planning --dispatch sdlc-planner-devops`
6. Dispatch **DevOps Agent** using [`dispatch-templates/devops-dispatch.md`](references/dispatch-templates/devops-dispatch.md) — produces `plan/cross-cutting/devops.md`.
7. `checkpoint.sh planning --completed devops`
8. `checkpoint.sh planning --dispatch sdlc-planner-testing`
9. Dispatch **Testing Strategy Agent** using [`dispatch-templates/testing-strategy-dispatch.md`](references/dispatch-templates/testing-strategy-dispatch.md) — produces `plan/cross-cutting/testing-strategy.md`.
10. `checkpoint.sh planning --completed testing`
11. On completion, dispatch **Plan Validator** in cross-story mode.
12. GATE: Cross-cutting validation must pass.

### Phase 5: Execution Readiness

1. `checkpoint.sh planning --phase 5`
2. Dispatch **Plan Validator** for final full-chain validation.
3. Verify: all stories planned, all contracts defined, all cross-cutting concerns addressed, no unresolved validation findings.
4. GATE: Full validation pass required before handoff.

### Phase 6: Optional SaaS Sync

If a SaaS sync skill was loaded:
1. Sync all plan artifacts to the external system using the loaded sync skill.
2. Report sync results.

### Phase 7: Handoff

1. `checkpoint.sh planning --phase 7`
2. `sync-coordinator.sh` — derives `stories_remaining` from `plan/user-stories/` artifacts sorted by `execution_order`, sets `current_story` to the first remaining story.
3. `checkpoint.sh coordinator --hub execution`
4. Present a planning completion summary to the user.
5. Hand off to `sdlc-coordinator` for execution orchestration.
6. The handoff includes: what was planned, which story to execute first, the full dependency graph, and the path to `plan/cross-cutting/testing-strategy.md` (coverage thresholds and AC traceability for execution agents).

## Brownfield Change Protocol

When the user proposes a change to an existing plan:

1. Classify the change level (PRD, Architecture, Story internal, Story contract, Cross-cutting).
2. Dispatch **Plan Validator** in impact analysis mode using [`dispatch-templates/impact-analysis-dispatch.md`](references/dispatch-templates/impact-analysis-dispatch.md).
3. Present the blast radius to the user.
4. User confirms or narrows scope.
5. Re-dispatch ONLY the minimum required agents.

See [`references/brownfield-change-protocol.md`](references/brownfield-change-protocol.md) for the full protocol specification.

## Shared Sparring Rules

ALL dispatch templates include a reference to [`references/shared-sparring-rules.md`](references/shared-sparring-rules.md). These apply to every planning sub-agent:

- Spec quoting (cite PRD section numbers and text)
- No gold-plating (flag additions beyond PRD)
- Revision cycle norm (expect 2-3 cycles)
- Evidence-based claims (justify every decision)
- Progressive specificity (right detail at right level)

## Dispatch Protocol

- Use the dispatch templates in [`references/dispatch-templates/`](references/dispatch-templates/) for each sub-agent.
- Each dispatch includes: context (which plan docs to read), scope (what to plan), existing artifacts, requirements from higher dimensions, shared sparring rules reference, and a completion contract.
- See [`references/planning-phases.md`](references/planning-phases.md) for the full phase dependency graph.

### MCP Server Context for All Dispatches

Include the following in the shared context for all planning agent dispatches:

```
MCP SERVERS AVAILABLE:
- context7: Library documentation search. Use to verify external library
  APIs and capabilities before making design decisions.
- tavily: Web search for current documentation, compatibility info, and
  known limitations of libraries in the tech stack.
```

This ensures all planning agents are aware of and can use documentation search tools to ground their plan artifacts in actual library capabilities.

## Plan Folder Structure

See [`references/plan-structure.md`](references/plan-structure.md) for the per-story folder layout.
See [`references/contracts-registry.md`](references/contracts-registry.md) for shared contracts specification.

## Files

- [`references/planning-phases.md`](references/planning-phases.md): Phase dependency graph and ordering rules.
- [`references/plan-structure.md`](references/plan-structure.md): Per-story folder structure.
- [`references/contracts-registry.md`](references/contracts-registry.md): Shared contracts registry specification.
- [`references/brownfield-change-protocol.md`](references/brownfield-change-protocol.md): Brownfield change propagation protocol.
- [`references/shared-sparring-rules.md`](references/shared-sparring-rules.md): Cross-cutting sparring rules for all agents.
- [`references/dispatch-templates/`](references/dispatch-templates/): Dispatch templates for all sub-agents and validator.

## Troubleshooting

- If a sub-agent cannot complete its plan, report the blocker and ask the user whether to skip, defer, or resolve.
- If the validator finds conflicts, dispatch the affected agents to resolve before proceeding.
- If the user wants to skip a phase, require explicit acknowledgment of what planning coverage is lost.
- If plan artifacts are stale relative to each other, trigger impact analysis before re-planning.
- If a brownfield change has unclear blast radius, default to broader impact analysis and let the user narrow scope.
