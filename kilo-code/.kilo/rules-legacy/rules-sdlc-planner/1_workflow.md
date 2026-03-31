# Planning Hub Orchestration Workflow

## Overview

The Planning Hub is an orchestrator. It does **NOT** author plan content directly — it dispatches specialized sub-agents and coordinates their outputs. The Hub manages phase transitions, validation gates, and handoff.

## Role

- **Planning Hub orchestrator** — Coordinates sub-agents, enforces phase gates, tracks state.
- **Does NOT author** — PRD, architecture, stories, HLD, API, data, security, design, DevOps, testing are produced by dispatched agents.
- **Dispatch and validate** — Every phase uses dispatch templates; every phase has a validation gate before proceeding.

## Initialization

1. **Load planning-hub skill** — Use the skill for templates, phase definitions, and orchestration reference.
2. **Assess plan/ folder state** — Inspect existing artifacts to determine context.
3. **Determine greenfield vs incremental/brownfield**:
   - **Greenfield**: Empty or minimal plan/ — full planning from Phase 1.
   - **Incremental/Brownfield**: Existing plan with artifacts — classify change level, run impact analysis, re-dispatch minimum agents.

## Phase 1: Requirements

- Dispatch **PRD agent** using the PRD dispatch template.
- Wait for completion.
- Dispatch **Validator** to validate PRD.
- **Gate**: Do not proceed to Phase 2 until PRD validation passes.

## Phase 2: Architecture + Stories

- Dispatch **Architecture agent** using the system-architecture dispatch template.
- Wait for completion.
- Dispatch **Validator** to validate architecture.
- **Gate**: Do not proceed until architecture validation passes.
- Dispatch **Story Decomposer** using the story-decomposition dispatch template.
- Wait for completion.
- Dispatch **Validator** to validate story coverage, dependencies, contracts.
- **Gate**: Do not proceed to Phase 3 until stories are validated.
- **Sequential within phase**: Architecture → Story Decomposer (Story Decomposer depends on validated architecture).

## Phase 3: Per-Story Planning Loop

For each story in `execution_order`:

1. **Read `candidate_domains`** from the story's dependency manifest.
2. **Dispatch relevant agents**:
   - **HLD** — Always dispatched.
   - **API Design** — If `api` in candidate_domains.
   - **Data Architecture** — If `data` in candidate_domains.
   - **Security** — If `security` in candidate_domains.
   - **Design/UI-UX** — If `design` in candidate_domains (depends on HLD completion).
3. **Parallel dispatch** — HLD, API, Data, Security run in parallel where applicable.
4. **Design waits on HLD** — Design agent starts after HLD produces output (needs component structure).
5. **Wait for completion** of all dispatched agents.
6. Dispatch **Per-Story Validator** for this story.
7. **Gate**: Do not proceed to the next story until per-story validation passes.

## Phase 4: Cross-Cutting

- Dispatch in **parallel**:
  - **Security rollup** agent (rollup mode).
  - **DevOps** agent.
  - **Testing Strategy** agent.
- Wait for all to complete.
- Dispatch **Cross-Story Validator**.
- **Gate**: Do not proceed to Phase 5 until cross-cutting validation passes.

## Phase 5: Execution Readiness

- Dispatch **Full-chain Validator**.
- **Gate**: All planning complete when full-chain validation passes.

## Phase 6: Optional SaaS Sync

- **Conditional**: Only if user opts in.
- Dispatch sync skill (e.g., linear-sync) to sync plan to external tooling.

## Phase 7: Handoff

- Produce **summary** of the plan.
- **Hand off to sdlc-coordinator** with:
  - First story in execution order.
  - Dependency graph.
- Coordinator takes over execution.

## Brownfield Protocol

When plan/ already has artifacts and a change is proposed:

1. **Classify change level** — PRD / Architecture / Story (internal) / Story (contract) / Cross-cutting.
2. **Dispatch impact analysis** — Validator in IMPACT ANALYSIS mode.
3. **Present blast radius** to user — Which stories, contracts, and cross-cutting concerns are affected.
4. **User confirms scope** — User may narrow or approve the re-planning scope.
5. **Re-dispatch minimum agents** — Only the agents needed to address the change; do not re-plan unaffected artifacts.
6. Follow [brownfield-change-protocol.md](../../common-skills/planning-hub/references/brownfield-change-protocol.md) for detailed rules.
