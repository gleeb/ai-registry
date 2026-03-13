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

Orchestrates the full implementation lifecycle for the sdlc-architect mode. Manages seven phases from readiness check through user acceptance, dispatching to sdlc-implementer, sdlc-code-reviewer, sdlc-qa, and sdlc-acceptance-validator sub-modes with structured contracts and iteration limits.

**Core principle:** Precise dispatch specifications reduce review iterations. Invest in dispatch quality.

## When to Use

- sdlc-architect receives a user story for execution
- A plan exists at `plan/user-stories/US-NNN-name/` with story.md and supporting artifacts
- The story needs the full implementation lifecycle

## Checkpoint Integration

Load the `sdlc-checkpoint` skill at architect initialization. The checkpoint script is at `.roo/skills/sdlc-checkpoint/scripts/checkpoint.sh`.

**REQUIRE**: Before every sub-agent dispatch, call `checkpoint.sh execution` with the current state (write-ahead pattern).
**REQUIRE**: After every sub-agent completion, call `checkpoint.sh execution` to record progress.

## Lifecycle Phases

```
Phase 0: Implementation Readiness Check
    ↓
Phase 1: Task Decomposition + Staging Doc (existing Phase 0/1)
    ↓
Phase 2: Per-Task Dev Loop (implement → review → QA)
    ↓
Phase 3: Story-Level Integration
    ↓
Phase 4: Acceptance Validation
    ↓
Phase 5: Documentation Integration
    ↓
Phase 6: User Acceptance
```

---

## Phase 0: Implementation Readiness Check

Before any implementation work, verify all prerequisites are in place.

See [`references/readiness-check.md`](references/readiness-check.md) for the full protocol.

1. `checkpoint.sh execution --story {US-NNN-name} --phase 0`
2. `checkpoint.sh coordinator --hub execution --story {US-NNN-name}`
3. **Verify plan artifacts** — read `plan/user-stories/US-NNN-name/story.md` and confirm all expected artifacts exist based on `candidate_domains` (hld.md, api.md, data.md, security.md, design/).
4. **Check dependencies** — verify all stories in `depends_on_stories` are completed.
5. **Determine tech skills** — read `tech_stack` from the story manifest and map to available skills using [`references/skill-loading-protocol.md`](references/skill-loading-protocol.md).
6. **Load documentation skill** — load `common-skills/project-documentation/` for staging doc templates.

**GATE**: All plan artifacts exist, all dependency stories are complete. If not, HALT and escalate to coordinator.

---

## Phase 1: Task Decomposition + Staging Doc

This is the existing Phase 0 (resume check) and Phase 1 (context gathering, architecture, LLD, staging doc creation). No changes to the core flow, with one addition:

1. `checkpoint.sh execution --phase 1`
2. **Staging doc scaffolding**: Use the staging doc template from `common-skills/project-documentation/references/staging-doc-template.md` to create the staging document. Pre-populate Plan References, Acceptance Criteria (from story.md), and Tech Stack sections.
3. After staging doc is created: `checkpoint.sh execution --staging-doc "docs/staging/{filename}.md" --tasks-total {N}`

---

## Phase 2: Per-Task Dev Loop

`checkpoint.sh execution --phase 2`

For each implementation unit in the task checklist:

1. `checkpoint.sh execution --task "{id}:{name}" --step implement` (write-ahead)
2. **Implement** → dispatch `sdlc-implementer` using [`references/implementer-dispatch-template.md`](references/implementer-dispatch-template.md)
3. `checkpoint.sh execution --step review --iteration 1`
4. **Review** → dispatch `sdlc-code-reviewer` using [`references/reviewer-dispatch-template.md`](references/reviewer-dispatch-template.md)
5. On review pass: `checkpoint.sh execution --step qa`
6. **Verify** → dispatch `sdlc-qa` using [`references/qa-dispatch-template.md`](references/qa-dispatch-template.md)
7. On QA pass: `checkpoint.sh execution --task-done {id}`

On review fail (re-dispatch implementer): `checkpoint.sh execution --step implement` then increment iteration on next review: `checkpoint.sh execution --step review --iteration {N}`

See [`references/review-cycle.md`](references/review-cycle.md) for iteration limits, security review integration, and escalation rules.

---

## Phase 3: Story-Level Integration

`checkpoint.sh execution --phase 3`

After all per-task dev loops pass:

1. **Final holistic code review** — dispatch sdlc-code-reviewer for full-story review (existing behavior from review-cycle.md).
2. **Final holistic QA** — dispatch sdlc-qa for full-story verification (existing behavior).
3. **Performance validation** — if tech skills include performance budgets (e.g., react-native), verify metrics meet targets.
4. **Accessibility check** — if story has `design` in `candidate_domains`, verify accessibility requirements.

**GATE**: Full-story review passes + full-story QA passes. If not, re-enter Phase 2 for affected tasks.

---

## Phase 4: Acceptance Validation

`checkpoint.sh execution --phase 4`

Independent verification that every acceptance criterion was implemented.

1. Dispatch `sdlc-acceptance-validator` using [`references/acceptance-validation-dispatch-template.md`](references/acceptance-validation-dispatch-template.md).
2. Validator maps every criterion to code + evidence.
3. Read the validation report.

**GATE**: Verdict is COMPLETE. If INCOMPLETE, identify failing criteria and re-enter Phase 2 with targeted fix dispatches. Max 2 acceptance re-validations before escalating.

---

## Phase 5: Documentation Integration

`checkpoint.sh execution --phase 5`

Merge implementation knowledge into permanent documentation.

See [`references/doc-integration-protocol.md`](references/doc-integration-protocol.md) for the full protocol.

1. Load `common-skills/project-documentation/references/integration-checklist.md`.
2. Distribute staging doc insights into permanent docs (`docs/frontend/`, `docs/backend/`, etc.).
3. Update `docs/index.md` if new domains were added.
4. Verify all file references in staging doc are still valid.
5. Mark staging doc as completed or move to `docs/archive/`.

---

## Phase 6: User Acceptance

`checkpoint.sh execution --phase 6`

Present the completed story to the user for final approval.

See [`references/user-acceptance-protocol.md`](references/user-acceptance-protocol.md) for the presentation format.

1. Summarize what was implemented (per-task summary from staging doc).
2. Present the acceptance validation report (per-criterion evidence).
3. Note any deviations from the original plan with justification.
4. Request user confirmation.

If the user requests changes, create targeted tasks and re-enter Phase 2. Mark the staging doc with the change request context.

On user approval: `checkpoint.sh coordinator --story-done {US-NNN-name}`

---

## Scaffolding Dispatch (Task 0)

When the architect detects a greenfield project (no package manager config, no source directories, no docs/ tree):

1. Create **Task 0: Scaffold Project** in the staging document before any implementation units.
2. Dispatch `sdlc-implementer` with:
   - Reference to the `scaffold-project` skill (located in the skills directory).
   - Initiative and user story context so the implementer can determine project type and make technology decisions.
   - Acceptance criteria: project builds, lints, and `docs/` structure exists.
3. Run the standard review + QA cycle on the scaffold output.
4. After scaffold is complete, proceed with normal architecture planning (Phase 1) against the scaffolded codebase.

## Key Rules

- Max 3 review iterations per task before escalating to coordinator
- Max 2 QA retries per task before escalating
- Max 2 acceptance re-validations before escalating
- Update task status in staging doc after each cycle (pending | in-progress | done | blocked)
- Final full-story review + QA after all tasks complete (Phase 3)
- Staging document is the single source of truth for resume capability
- Documentation requirements are embedded in every dispatch template — the architect owns the staging doc lifecycle

## References

- [`references/readiness-check.md`](references/readiness-check.md) — Phase 0 readiness protocol
- [`references/skill-loading-protocol.md`](references/skill-loading-protocol.md) — Tech stack to skill mapping
- [`references/implementer-dispatch-template.md`](references/implementer-dispatch-template.md) — Implementer dispatch
- [`references/reviewer-dispatch-template.md`](references/reviewer-dispatch-template.md) — Reviewer dispatch
- [`references/qa-dispatch-template.md`](references/qa-dispatch-template.md) — QA dispatch
- [`references/acceptance-validation-dispatch-template.md`](references/acceptance-validation-dispatch-template.md) — Acceptance validator dispatch
- [`references/review-cycle.md`](references/review-cycle.md) — Iteration limits and escalation
- [`references/doc-integration-protocol.md`](references/doc-integration-protocol.md) — Phase 5 documentation integration
- [`references/user-acceptance-protocol.md`](references/user-acceptance-protocol.md) — Phase 6 user acceptance format
