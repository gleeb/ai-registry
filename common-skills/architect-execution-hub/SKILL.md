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
Phase 1: Task Decomposition + Staging Doc (existing Phase 0/1)
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

---

## Phase 0: Implementation Readiness Check

Before any implementation work, verify all prerequisites are in place.

See [`references/readiness-check.md`](references/readiness-check.md) for the full protocol.

1. `checkpoint.sh execution --story {US-NNN-name} --phase 0`
2. `checkpoint.sh coordinator --hub execution --story {US-NNN-name}`
3. **Verify plan artifacts** — read `plan/user-stories/US-NNN-name/story.md` and confirm all expected artifacts exist based on `candidate_domains` (hld.md, api.md, data.md, security.md, design/).
4. **Check dependencies** — verify all stories in `depends_on_stories` are completed.
5. **Determine tech skills** — read `tech_stack` from the story manifest and map to available skills using [`references/skill-loading-protocol.md`](references/skill-loading-protocol.md).
6. **Load documentation skill** — load `skills/project-documentation/` for staging doc templates.

**GATE**: All plan artifacts exist, all dependency stories are complete. If not, HALT and escalate to coordinator.

7. **Create story branch**: After GATE passes, create an isolated branch for this story's work:
   `checkpoint.sh git --branch-create --story {US-NNN-name} --base main`
   This records `branch_name`, `base_branch`, and `base_commit` in `execution.yaml` for use by reviewers and validators.

---

## Phase 1: Task Decomposition + Staging Doc

This is the existing Phase 0 (resume check) and Phase 1 (context gathering, architecture, LLD, staging doc creation). No changes to the core flow, with additions:

1. `checkpoint.sh execution --phase 1`
2. **Testing strategy consumption**: If `plan/cross-cutting/testing-strategy.md` exists, read it and use the AC traceability table to inform per-task testing requirements. When decomposing tasks, include expected test types and locations for each task based on the testing strategy (e.g., "unit tests for data layer", "integration tests for API endpoint").
3. **Staging doc scaffolding**: Use the staging doc template from `skills/project-documentation/references/staging-doc-template.md` to create the staging document. Pre-populate Plan References, Acceptance Criteria (from story.md), and Tech Stack sections.
4. **Copy Review Milestones** from `story.md` into the staging doc's `## Review Milestones` section. Add a Status column (pending / triggered / user-approved). If `story.md` has "None — fully autonomous execution," copy that. These milestones are the ONLY points where execution pauses for user input.
5. After staging doc is created: `checkpoint.sh execution --staging-doc "docs/staging/{filename}.md" --tasks-total {N}`

---

## Phase 2: Per-Task Dev Loop

`checkpoint.sh execution --phase 2`

For each implementation unit in the task checklist:

1. `checkpoint.sh execution --task "{id}:{name}" --step implement` (write-ahead)
2. **Infrastructure check**: Read the task's dependencies against the story's `## Integration Strategy` table. If any dependency for this task has `level: real` or `level: realize`:
   a. `checkpoint.sh dispatch-log --event dispatch ... --agent sdlc-devops --dispatch-id exec-{story}-t{id}-devops-i1`
   b. Dispatch `@sdlc-devops` using [`references/devops-dispatch-template.md`](references/devops-dispatch-template.md) with the required infrastructure.
   c. `checkpoint.sh dispatch-log --event response --dispatch-id exec-{story}-t{id}-devops-i1 --agent sdlc-devops --verdict "{SUCCESS|FAILURE}"`
   d. On success: read the infrastructure manifest and fold connection details into the implementer dispatch's `INTEGRATION CONTEXT` section.
   e. On failure: record the blocker in the staging doc. If the DevOps agent provides resolution guidance, re-dispatch once. If still failing, HALT and escalate to coordinator.
3. `checkpoint.sh dispatch-log --event dispatch --story {US-NNN} --hub execution --phase 2 --task "{id}:{name}" --agent sdlc-implementer --model-profile {profile} --dispatch-id exec-{story}-t{id}-impl-i{N} --iteration {N}`
4. **Implement** → dispatch `sdlc-implementer` using [`references/implementer-dispatch-template.md`](references/implementer-dispatch-template.md). If the DevOps agent was dispatched in step 2, include the infrastructure manifest details in the `INTEGRATION CONTEXT` section.
4. `checkpoint.sh dispatch-log --event response --dispatch-id exec-{story}-t{id}-impl-i{N} --agent sdlc-implementer --duration {seconds} --summary "{excerpt}"`
5. `checkpoint.sh execution --step review --iteration 1`
6. `checkpoint.sh dispatch-log --event dispatch ... --agent sdlc-code-reviewer --dispatch-id exec-{story}-t{id}-review-i{N}`
7. **Review** → dispatch `sdlc-code-reviewer` using [`references/reviewer-dispatch-template.md`](references/reviewer-dispatch-template.md)
8. `checkpoint.sh dispatch-log --event response --dispatch-id exec-{story}-t{id}-review-i{N} --agent sdlc-code-reviewer --verdict "{Approved|Changes Required}"`
9. On review pass: `checkpoint.sh execution --step qa`
10. `checkpoint.sh dispatch-log --event dispatch ... --agent sdlc-qa --dispatch-id exec-{story}-t{id}-qa-i{N}`
11. **Verify** → dispatch `sdlc-qa` using [`references/qa-dispatch-template.md`](references/qa-dispatch-template.md)
12. `checkpoint.sh dispatch-log --event response --dispatch-id exec-{story}-t{id}-qa-i{N} --agent sdlc-qa --verdict "{PASS|FAIL}"`
13. On QA pass: `checkpoint.sh execution --task-done {id}`
14. **Git commit**: `checkpoint.sh git --commit --story {US-NNN-name} --task "{id}:{name}" --phase 2`
15. **Review Milestone check**: Read the staging doc's Review Milestones table. If any milestone's Trigger matches this task: execute its Action, update Status to `triggered`, return to coordinator with MILESTONE_PAUSE and the milestone output. On resume, mark `user-approved` and continue.

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

### Pre-Flight Evidence Gate (before Phase 3b)

Before dispatching the commercial semantic reviewer, read the QA agent's structured evidence from the Phase 3 story-level QA completion. Confirm all automated quality gates are clean:

- Lint: 0 errors (from QA evidence)
- Type check: 0 errors (from QA evidence)
- Test suite: all passing (from QA evidence)
- Build: exit 0 (from QA evidence)
- Browser smoke test: key routes load without console errors (from QA evidence, web app stories only)

If any quality gate shows failures, return to Phase 2 for targeted fixes. Do NOT dispatch the semantic reviewer until all automated gates are clean. The hub reads evidence — it does not re-run commands.

---

## Phase 3b: Semantic Review (Commercial Mentor)

`checkpoint.sh execution --phase 3b`

Commercial-model senior-developer quality review with 3 checks (agent report integrity, code quality review, terminology alignment). Uses git diff for scoping, staging doc for context, then drills into the actual implementation.

1. `checkpoint.sh execution --phase 3b --step semantic-review`
2. Dispatch `sdlc-semantic-reviewer` using [`references/semantic-reviewer-dispatch-template.md`](references/semantic-reviewer-dispatch-template.md).
3. Include all local review verdicts, QA verdicts, and implementer summaries from the story.
4. Include git context (branch, base commit) for diff scoping. Populate the GIT CONTEXT section in the dispatch template using `branch_name` and `base_commit` from `execution.yaml`.
5. Include the tech stack for documentation fetching context via context7 MCP.
6. Read the semantic review result:
   - **PASS:** `checkpoint.sh execution --phase 3b --verdict pass`. Proceed to Phase 4. Optionally attach proactive observations to the acceptance validator dispatch.
   - **NEEDS WORK:** Extract the guidance package. Re-enter Phase 2 for affected tasks with guidance-aware re-dispatch — include the `SEMANTIC GUIDANCE` section in the implementer dispatch containing reasoned corrections, documentation (fetched excerpts and/or fetch instructions for the local model to retrieve via context7), and improvement instructions. After fixes, **commit the remediation**: `checkpoint.sh git --commit --story {US-NNN-name} --message "Address semantic review findings" --phase 3b`. Then restart from Phase 3 (full-story review + QA) then re-dispatch semantic reviewer (iteration 2).
   - **NEEDS WORK with escalation flag (work unreliable):** Halt execution. Escalate to coordinator and user — the local model may not be capable of this task and it may need reassignment.

**GATE**: Semantic review PASS. Max 2 iterations before escalating to coordinator.

**Guidance propagation:** When re-dispatching implementer after semantic review NEEDS WORK, include the guidance package in a `SEMANTIC GUIDANCE` section. This propagates commercial-model reasoning into the local model's next attempt. See [`references/review-cycle.md`](references/review-cycle.md) for the re-dispatch pattern.

---

## Phase 4: Acceptance Validation

`checkpoint.sh execution --phase 4`

Independent verification that every acceptance criterion was implemented. Uses git diff for scoping, staging doc for context, then drills into code and runs fresh commands for evidence. Produces failure guidance on INCOMPLETE.

1. Dispatch `sdlc-acceptance-validator` using [`references/acceptance-validation-dispatch-template.md`](references/acceptance-validation-dispatch-template.md).
2. Include git context (branch, base commit) for diff scoping. Populate the GIT CONTEXT section in the dispatch template using `branch_name` and `base_commit` from `execution.yaml`.
3. Validator maps every criterion to code + evidence, produces failure guidance for any FAIL criteria.
4. Read the validation report.

**GATE**: Verdict is COMPLETE. If INCOMPLETE:

1. Read `acceptance_iteration` from `execution.yaml` (tracked via `checkpoint.sh execution --acceptance-iteration N`).
2. If `acceptance_iteration >= 2`: **STOP.** Do NOT dispatch another remediation or acceptance run. Return to coordinator with ESCALATE verdict, all acceptance reports attached, and recommendation for user review.
3. If `acceptance_iteration < 2`: Create targeted remediation tasks for **FUNCTIONAL failures only** (ignore NEEDS_CLEANUP doc notes). Increment `acceptance_iteration` via `checkpoint.sh execution --acceptance-iteration {N+1}`. After remediation fixes are applied, **commit the fixes**: `checkpoint.sh git --commit --story {US-NNN-name} --message "Fix failing acceptance criteria" --phase 4`. Re-run acceptance with PRIOR ACCEPTANCE CONTEXT from the dispatch template.

**HARD LIMIT**: The architect MUST NOT run more than 2 acceptance re-validations (3 total runs). This limit is non-negotiable. Violating it is a protocol error.

### Doc-Only Remediation (fast path)

If the acceptance verdict is COMPLETE but `doc_status` is NEEDS_CLEANUP:

1. The architect applies documentation fixes directly (staging doc edits only).
2. No implementer dispatch, no code review, no QA required for doc-only changes.
3. Log the fix in the staging document's Issues & Resolutions table.
4. Proceed directly to Phase 5.

This avoids full remediation cycles for markdown formatting issues.

---

## Phase 5: Documentation Integration

`checkpoint.sh execution --phase 5`

Merge implementation knowledge into permanent documentation.

See [`references/doc-integration-protocol.md`](references/doc-integration-protocol.md) for the full protocol.

1. Load `skills/project-documentation/references/integration-checklist.md`.
2. Distribute staging doc insights into permanent docs (`docs/frontend/`, `docs/backend/`, etc.).
3. Update `docs/index.md` if new domains were added.
4. Verify all file references in staging doc are still valid.
5. Mark staging doc as completed or move to `docs/archive/`.
6. **Git commit**: `checkpoint.sh git --commit --story {US-NNN-name} --message "Integrate staging doc" --phase 5`

---

## Phase 6: User Acceptance (Conditional)

`checkpoint.sh execution --phase 6`

Conditionally present the completed story to the user or auto-approve.

See [`references/user-acceptance-protocol.md`](references/user-acceptance-protocol.md) for the presentation format and auto-approve criteria.

1. Check the staging doc's Review Milestones table for any milestone with Trigger "after all tasks" or "phase 6".
2. **Auto-approve path** (all conditions must be true):
   - No Review Milestone with trigger "after all tasks" or "phase 6".
   - Acceptance validation verdict is COMPLETE.
   - No deviations from plan recorded in staging doc.
   - Auto-approve: record in staging doc, merge, and return to coordinator.
3. **User review path** (if any auto-approve condition fails):
   - Execute any Phase 6 milestone Action and capture results.
   - Summarize what was implemented (per-task summary from staging doc).
   - Present acceptance validation report, milestone results, and deviations.
   - Wait for user response.

If the user requests changes, create targeted tasks and re-enter Phase 2. Mark the staging doc with the change request context.

On user approval (or auto-approve):
1. **Git merge**: `checkpoint.sh git --merge --story {US-NNN-name} --target main`
2. `checkpoint.sh coordinator --story-done {US-NNN-name}`

---

## Scaffolding Dispatch (Task 0)

When the architect detects a greenfield project (no package manager config, no source directories, no docs/ tree):

1. Create **Task 0: Scaffold Project** in the staging document before any implementation units.
2. Dispatch `sdlc-implementer` with:
   - Reference to the `scaffold-project` skill (located in the skills directory).
   - Initiative and user story context so the implementer can determine project type and make technology decisions.
   - Acceptance criteria:
     - Project builds and lints successfully.
     - `docs/` structure exists per the scaffold-project skill's Step 4 ("Scaffold Project Documentation"): `docs/index.md`, domain folders matching project type (e.g., `docs/mobile/` for React Native, `docs/frontend/` for web), `docs/staging/README.md`, `docs/specs/.gitkeep`, `docs/archive/.gitkeep`.
3. Run the standard review + QA cycle on the scaffold output.
4. **GATE**: Verify `docs/index.md` exists before proceeding to Phase 1. If missing, re-dispatch implementer to complete documentation scaffolding.
5. After scaffold is complete and gate passes, proceed with normal architecture planning (Phase 1) against the scaffolded codebase.

## Self-Repair Protocol

Before escalating ANY operational issue to coordinator, attempt self-repair:

1. **Branch missing or wrong**: Run `checkpoint.sh git --branch-create --story {US-NNN-name} --base main` or create the branch manually. If work was done on the wrong branch, create the story branch from the current state and update `execution.yaml` accordingly.
2. **Checkpoint drift**: Run `checkpoint.sh init` to re-derive state from existing artifacts on disk (`plan/`, `docs/staging/`). Then run `verify.sh execution` to confirm consistency. If fields are still inconsistent, overwrite them using `checkpoint.sh execution` with values derived from the staging doc task checklist + git log.
3. **Checkpoint field inconsistency**: Overwrite inconsistent fields using `checkpoint.sh execution` with correct values derived from staging doc + git log.
4. **Resume state unclear**: Read staging doc task checklist, cross-reference with git log, determine actual progress, update checkpoint accordingly.

**DENY**: Escalating branch lifecycle issues, checkpoint drift, or checkpoint field inconsistencies to the coordinator. These are operational issues the execution hub must resolve with the tools at hand.

**Only escalate to coordinator when**: the issue is at the product/planning level (missing plan artifacts, wrong architecture, model capability issues, cross-story dependency conflicts, user-facing product decisions).

## Key Rules

- Max 5 review iterations per task before escalating to coordinator
- Max 2 QA retries per task before escalating
- Max 2 semantic review iterations per story before escalating
- Max 2 acceptance re-validations before escalating
- Update task status in staging doc after each cycle (pending | in-progress | done | blocked)
- Final full-story review + QA after all tasks complete (Phase 3)
- Staging document is the single source of truth for resume capability
- Documentation requirements are embedded in every dispatch template — the architect owns the staging doc lifecycle

## References

- [`references/readiness-check.md`](references/readiness-check.md) — Phase 0 readiness protocol
- [`references/skill-loading-protocol.md`](references/skill-loading-protocol.md) — Tech stack to skill mapping
- [`references/implementer-dispatch-template.md`](references/implementer-dispatch-template.md) — Implementer dispatch
- [`references/devops-dispatch-template.md`](references/devops-dispatch-template.md) — DevOps infrastructure dispatch (Phase 2, before implementer)
- [`references/reviewer-dispatch-template.md`](references/reviewer-dispatch-template.md) — Reviewer dispatch
- [`references/qa-dispatch-template.md`](references/qa-dispatch-template.md) — QA dispatch
- [`references/semantic-reviewer-dispatch-template.md`](references/semantic-reviewer-dispatch-template.md) — Semantic reviewer dispatch (Phase 3b)
- [`references/acceptance-validation-dispatch-template.md`](references/acceptance-validation-dispatch-template.md) — Acceptance validator dispatch
- [`references/review-cycle.md`](references/review-cycle.md) — Iteration limits and escalation
- [`references/doc-integration-protocol.md`](references/doc-integration-protocol.md) — Phase 5 documentation integration
- [`references/user-acceptance-protocol.md`](references/user-acceptance-protocol.md) — Phase 6 user acceptance format
