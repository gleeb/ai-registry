---
name: architect-execution-hub
description: >
  Use when the sdlc-architect needs to orchestrate the full implementation
  lifecycle for a user story: readiness check, task decomposition, per-task
  implement-review-verify cycles, story integration, acceptance validation,
  documentation integration, and user acceptance.
---

# Architect Execution Hub

## Overview

Orchestrates the full implementation lifecycle for the sdlc-architect mode. Manages seven phases from readiness check through user acceptance, dispatching to sdlc-implementer, sdlc-code-reviewer, sdlc-qa, sdlc-devops, and sdlc-acceptance-validator sub-modes with structured contracts and iteration limits.

**Core principle:** Precise dispatch specifications reduce review iterations. Invest in dispatch quality.

## When to Use

- sdlc-architect receives a user story for execution
- A plan exists at `plan/user-stories/US-NNN-name/` with story.md and supporting artifacts
- The story needs the full implementation lifecycle

## Checkpoint Integration

Load the `sdlc-checkpoint` skill at architect initialization. The checkpoint script is at `skills/sdlc-checkpoint/scripts/checkpoint.sh`.

**REQUIRE**: Before every sub-agent dispatch, call `checkpoint.sh execution` with the current state (write-ahead pattern).
**REQUIRE**: After every sub-agent completion, call `checkpoint.sh execution` to record progress.

## Dispatch Logging

**REQUIRE**: Before every sub-agent dispatch, call `checkpoint.sh dispatch-log --event dispatch` with story, hub, phase, task, agent, model profile, dispatch ID, and iteration.
**REQUIRE**: After every sub-agent completion, call `checkpoint.sh dispatch-log --event response` with dispatch ID, agent, verdict, duration, and summary excerpt.

Dispatch ID format: `exec-{story}-t{task-id}-{agent-short}-i{iteration}` (e.g., `exec-US001-t3-impl-i1`).

**REQUIRE**: Before logging a dispatch event, verify the dispatch_id does not already exist in `dispatch-log.jsonl`. If it does, append a disambiguating suffix (e.g., timestamp). For acceptance revalidation rounds, use `exec-{story}-phase4-acceptance-r{round}` with a monotonically increasing round number.

See the `sdlc-checkpoint` skill for the full `dispatch-log` API and flags.

## Lifecycle Phases

```
Phase 0: Implementation Readiness Check
    ↓
Phase 1: Task Decomposition + Staging Doc
    ↓
Phase 2: Per-Task Dev Loop (implement → review → QA)
    ↓
Phase 3: Story-Level Integration
    ↓
Phase 3b: Semantic Review (Commercial Mentor)
    ↓
Phase 4: Acceptance Validation
    ↓
Phase 5: Documentation Integration
    ↓
Phase 6: User Acceptance
```

## Phase Quick Index

Full phase procedures are in the agent. Load the reference for your current phase for operational detail (dispatch templates, checkpoint command patterns, gate conditions).

| Phase | Reference | Load when |
|-------|-----------|-----------|
| 0 | [`references/readiness-check.md`](references/readiness-check.md) | Entering Phase 0 |
| 0b | [`references/scaffolding-dispatch.md`](references/scaffolding-dispatch.md) | Greenfield project detected |
| 1 | [`references/phase1-task-decomposition.md`](references/phase1-task-decomposition.md) | Entering Phase 1 |
| 2 | [`references/phase2-dev-loop.md`](references/phase2-dev-loop.md) + [`references/review-cycle.md`](references/review-cycle.md) | Entering Phase 2 |
| 3 | [`references/phase3-story-integration.md`](references/phase3-story-integration.md) | Entering Phase 3 |
| 3b | [`references/phase3b-semantic-review-flow.md`](references/phase3b-semantic-review-flow.md) | Entering Phase 3b |
| 4 | [`references/phase4-acceptance-flow.md`](references/phase4-acceptance-flow.md) | Entering Phase 4 |
| 5-6 | [`references/phase56-doc-and-acceptance.md`](references/phase56-doc-and-acceptance.md) | Entering Phase 5 or 6 |
| — | [`references/self-repair-protocol.md`](references/self-repair-protocol.md) | Operational issue (branch, checkpoint) before escalating |

---

## Key Rules

- Max 5 review iterations per task before escalating to coordinator
- Max 2 QA retries per task before escalating
- Max 2 semantic review iterations per story before escalating
- Max 2 acceptance re-validations before escalating
- Update task status in staging doc after each cycle (pending | in-progress | done | blocked)
- Final full-story review + QA after all tasks complete (Phase 3)
- Staging document is the single source of truth for resume capability
- Documentation requirements are embedded in every dispatch template — the architect owns the staging doc lifecycle

## Dispatch Template Index

- [`references/implementer-dispatch-template.md`](references/implementer-dispatch-template.md) — Implementer dispatch
- [`references/devops-dispatch-template.md`](references/devops-dispatch-template.md) — DevOps infrastructure dispatch (Phase 2, before implementer)
- [`references/reviewer-dispatch-template.md`](references/reviewer-dispatch-template.md) — Reviewer dispatch
- [`references/qa-dispatch-template.md`](references/qa-dispatch-template.md) — QA dispatch
- [`references/semantic-reviewer-dispatch-template.md`](references/semantic-reviewer-dispatch-template.md) — Semantic reviewer dispatch (Phase 3b)
- [`references/acceptance-validation-dispatch-template.md`](references/acceptance-validation-dispatch-template.md) — Acceptance validator dispatch

## Other References

- [`references/skill-loading-protocol.md`](references/skill-loading-protocol.md) — Tech stack to skill mapping
- [`references/testing-skills-index.md`](references/testing-skills-index.md) — Testing skill loading guide (which skill, when, for which agent)
- [`references/review-cycle.md`](references/review-cycle.md) — Iteration limits and escalation
- [`references/doc-integration-protocol.md`](references/doc-integration-protocol.md) — Phase 5 documentation integration
- [`references/user-acceptance-protocol.md`](references/user-acceptance-protocol.md) — Phase 6 user acceptance format
