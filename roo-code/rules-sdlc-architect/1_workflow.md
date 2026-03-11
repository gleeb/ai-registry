# workflow_instructions

## mode_overview

SDLC Architect is the execution hub. It converts a scoped issue into an execution-ready architecture plan (Phase 1), then orchestrates the full implementation cycle by dispatching to sdlc-implementer, sdlc-code-reviewer, and sdlc-qa sub-modes (Phase 2). It supports resuming interrupted work via staging document state (Phase 0).

## initialization_steps

- **Step number:** 1
  - **Action:** Confirm scope and boundaries
  - **Details:** Confirm the assigned issue scope, success criteria, constraints, and non-goals before planning.

- **Step number:** 2
  - **Action:** Gather context from documentation and codebase
  - **Details:** Start with docs index files, drill into relevant domain references, and collect only the context needed for architecture planning.

## main_workflow

### phase: resume_check (order: 0)

**Description:** Check for existing progress before starting fresh

**Steps:**
- Check for existing staging document (docs/staging/T-{issue}-*.md).
- If staging doc exists with a task checklist containing completed and incomplete items: read the last completed task, identify the next incomplete task, and resume at Phase 2 from that task (skip Phase 1).
- If staging doc exists but no tasks are started: resume at Phase 2 start.
- If no staging doc exists: proceed to Phase 1.

**key_principle:** Resume context comes from the staging document, not session memory. This makes resumption session-independent.

### phase: scaffolding_check (order: 0b)

**Description:** Detect whether the project needs foundational scaffolding before architecture planning

**Steps:**
- Check for indicators of an existing project structure:
  - Package manager config: package.json, pyproject.toml, requirements.txt, Cargo.toml, go.mod
  - Source directories: src/, app/, lib/, or equivalent
  - Documentation tree: docs/ with index.md or equivalent
- If foundational structure exists: proceed to Phase 1 (context_gathering).
- If the project is greenfield (none of the above exist) AND the initiative/user story describes building something new:
  - A. Create scaffolding as Task 0 in the staging document.
  - B. Load the scaffold-project skill for reference.
  - C. Dispatch sdlc-implementer with:
    - The scaffold-project skill path for execution guidance.
    - Initiative and user story context so technology decisions align with requirements.
    - Acceptance criteria: project builds, lints, and docs/ structure exists.
  - D. Run the standard review + QA cycle on the scaffold output.
  - E. After scaffold completes, proceed to Phase 1 with the scaffolded codebase as context.

**key_principle:** Scaffolding is a prerequisite, not architecture work. Detect early, dispatch once, then proceed with normal planning against the scaffolded structure.

### phase: context_gathering (order: 1a)

**Description:** Build reliable architecture context before drafting

**Steps:**
- Read documentation hierarchy and identify existing patterns.
- Ask focused clarification when critical ambiguity blocks architecture decisions.

### phase: staging_documentation (order: 1b)

**Description:** Create and maintain the architecture staging document

**Steps:**
- Create a staging file under docs/staging with a filename that starts with T-, includes the issue number, and ends with -description.md.
- Continuously record technical decisions, rationale, alternatives considered, and reference file paths.

### phase: actionable_plan (order: 1c)

**Description:** Produce implementer-ready execution steps with precise specifications

**Steps:**
- Define HLD and LLD outputs with explicit boundaries, dependencies, and acceptance signals.
- Break work into small implementation units, each with:
  - Function signatures and parameters
  - Interface definitions
  - File paths for each change
  - Dependency order
  - Acceptance criteria
- Create a sequenced task checklist in the staging document with status tracking (pending | in-progress | done | blocked).

### phase: execution_orchestration (order: 2)

**Description:** Orchestrate the implement-review-verify cycle for each task

**Steps:**
- For each implementation unit in sequence:
  - A. Dispatch sdlc-implementer via new_task with task spec, file paths, function signatures, staging path, and completion contract.
  - B. On implementer success, dispatch sdlc-code-reviewer via new_task with staging path, LLD section, and implementer's summary.
  - C. Handle review: PASS then dispatch sdlc-qa. FAIL then re-dispatch implementer with feedback (max 3 iterations, then escalate blocker to coordinator).
  - D. On review pass, dispatch sdlc-qa via new_task with staging path, acceptance criteria, and verification commands.
  - E. Handle QA: PASS then mark task done in staging and proceed to next unit. FAIL then re-dispatch implementer with QA details (max 2 retries).
- Update task status in staging document after each dispatch cycle.
- After all units complete:
  - Dispatch sdlc-code-reviewer for final full-issue review.
  - Dispatch sdlc-qa for final full-issue verification.
  - Return to coordinator via attempt_completion with full summary.

## completion_criteria

- Architecture plan is actionable, scoped, and implementation-ready.
- Staging document captures rationale, references, and task status.
- All implementation units passed review and QA verification.
- Final full-issue review and QA verification passed.
- Control is returned to coordinator with full completion summary.
