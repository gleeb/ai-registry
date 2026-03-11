---
name: planning-hub
description: Orchestration hub for project planning. Manages phase ordering, dispatches specialized planning sub-agents (PRD, System Architecture, HLD, Security, API Design, Data Architecture, DevOps, Design/UI-UX, Testing Strategy), triggers cross-plan validation after each phase, and optionally syncs to external SaaS systems. Internal plan artifacts in plan/ are the source of truth.
---

# Planning Hub

## When to use
- Use as the entry point for all project planning work.
- Use when starting a new product/project from scratch (greenfield).
- Use when adding significant new capabilities to an existing project (incremental).
- Use when re-planning or revising existing plan artifacts.

## When NOT to use
- DENY use for implementation work — hand off to sdlc-coordinator for execution.
- DENY use for SaaS-specific operations — delegate to the appropriate sync skill (e.g., linear-sync).
- DENY direct plan content authoring — dispatch to the appropriate planning sub-agent.

## Core Principle
**Internal planning is king.** All plan artifacts live in the `plan/` folder as markdown files (and HTML/CSS for design mockups). No external SaaS system is required. SaaS sync skills are optional translation layers.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Planning Sub-Agents

| Agent | Mode Slug | Skill | Output |
|---|---|---|---|
| PRD | `sdlc-planner-prd` | `planning-prd` | `plan/prd.md` |
| System Architecture | `sdlc-planner-architecture` | `planning-system-architecture` | `plan/system-architecture.md` |
| HLD | `sdlc-planner-hld` | `planning-hld` | `plan/hld.md` + `plan/user-stories/*.md` |
| Security | `sdlc-planner-security` | `planning-security` | `plan/security.md` |
| API Design | `sdlc-planner-api` | `planning-api-design` | `plan/api-design.md` |
| Data Architecture | `sdlc-planner-data` | `planning-data-architecture` | `plan/data-architecture.md` |
| DevOps | `sdlc-planner-devops` | `planning-devops` | `plan/devops.md` |
| Design/UI-UX | `sdlc-planner-design` | `planning-design` | `plan/design/` |
| Testing Strategy | `sdlc-planner-testing` | `planning-testing-strategy` | `plan/testing-strategy.md` |
| Plan Validator | `sdlc-plan-validator` | `planning-validator` | `plan/validation/cross-validation-report.md` |

## Workflow

### Phase 0: Initialization
1. Assess the current state of the `plan/` folder. Identify what exists, what is missing, what is stale.
2. Determine scope: greenfield (full planning cycle) or incremental (specific phases only).
3. If a SaaS sync is desired, identify the system and load the corresponding sync skill (e.g., `linear-sync`). This is optional.
4. Present the planning roadmap to the user: which phases are needed and in what order.

### Phase 1: Requirements (PRD)
1. Dispatch the **PRD Agent** (`sdlc-planner-prd`) using [`references/dispatch-templates/prd-dispatch.md`](references/dispatch-templates/prd-dispatch.md).
2. The PRD agent conducts interactive sparring with the user, drafts and validates the PRD.
3. On completion, dispatch the **Plan Validator** to validate PRD completeness and internal consistency.
4. GATE: PRD must pass all 8 validation dimensions at "high" before proceeding.

### Phase 2: Architecture
Dispatch in parallel (no dependency between them):
1. **System Architecture Agent** (`sdlc-planner-architecture`) using [`references/dispatch-templates/system-architecture-dispatch.md`](references/dispatch-templates/system-architecture-dispatch.md).
2. **Security Agent** (`sdlc-planner-security`) using [`references/dispatch-templates/security-dispatch.md`](references/dispatch-templates/security-dispatch.md).

On completion of both:
3. Dispatch **Plan Validator** to check:
   - Architecture satisfies all PRD requirements.
   - Security plan covers all sensitive data and threat surfaces identified in PRD.
   - No conflicts between architecture and security decisions.

### Phase 3: Detailed Design
Dispatch after Phase 2 validation passes. These can run in parallel where independent:
1. **HLD Agent** (`sdlc-planner-hld`) — depends on PRD + Architecture.
2. **API Design Agent** (`sdlc-planner-api`) — depends on PRD + Architecture.
3. **Data Architecture Agent** (`sdlc-planner-data`) — depends on PRD + Architecture.
4. **DevOps Agent** (`sdlc-planner-devops`) — depends on Architecture + Security.
5. **Design/UI-UX Agent** (`sdlc-planner-design`) — depends on PRD + HLD.

On completion:
6. Dispatch **Plan Validator** to check:
   - All PRD requirements are covered in HLD.
   - API design is consistent with architecture and HLD.
   - Data architecture supports all data entities from HLD and API design.
   - DevOps plan supports the architecture and security requirements.
   - Design mockups cover all user-facing flows from user stories.

### Phase 4: Stories and Test Plan
1. **User Story Decomposition** — part of the HLD agent's output, verified here.
2. **Testing Strategy Agent** (`sdlc-planner-testing`) using [`references/dispatch-templates/testing-strategy-dispatch.md`](references/dispatch-templates/testing-strategy-dispatch.md).

On completion:
3. Dispatch **Final Validator** to check:
   - All PRD requirements trace through HLD to user stories.
   - All user stories have testable acceptance criteria.
   - Testing strategy covers all acceptance criteria.
   - All cross-domain requirements (security, devops, data) are reflected in stories.

### Phase 5: Optional SaaS Sync
If a SaaS sync skill was loaded in Phase 0:
1. Sync all plan artifacts to the external system using the loaded sync skill.
2. Report sync results.

### Phase 6: Handoff
1. Present a planning completion summary to the user.
2. Hand off to `sdlc-coordinator` for execution orchestration.
3. The handoff includes: what was planned, which artifacts exist in `plan/`, and what should be executed first.

## Dispatch Protocol
- Use the dispatch templates in [`references/dispatch-templates/`](references/dispatch-templates/) for each sub-agent.
- Each dispatch includes: context (which plan docs to read), scope (what to plan), existing artifacts, requirements from higher dimensions, and a completion contract.
- See [`references/planning-phases.md`](references/planning-phases.md) for the full phase dependency graph.

## Plan Folder Structure
See [`references/plan-structure.md`](references/plan-structure.md) for the canonical `plan/` folder layout.

## Incremental Planning
When not greenfield:
- The hub identifies which plan artifacts are stale or missing.
- Only the affected phases and agents are dispatched.
- The validator still runs after each phase to ensure consistency with existing artifacts.
- Existing plan artifacts that are not being updated are treated as constraints for new planning work.

## Files
- [`references/planning-phases.md`](references/planning-phases.md): Phase dependency graph and ordering rules.
- [`references/plan-structure.md`](references/plan-structure.md): Canonical `plan/` folder structure.
- [`references/dispatch-templates/`](references/dispatch-templates/): Dispatch templates for all sub-agents and validator.

## Troubleshooting
- If a sub-agent cannot complete its plan, report the blocker and ask the user whether to skip, defer, or resolve.
- If the validator finds conflicts, dispatch the affected agents to resolve before proceeding.
- If the user wants to skip a phase, require explicit acknowledgment of what planning coverage is lost.
- If plan artifacts are stale relative to each other, trigger re-validation before handoff.
