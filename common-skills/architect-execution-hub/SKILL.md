---
name: architect-execution-hub
description: Use when the sdlc-architect needs to orchestrate an implement-review-verify cycle for scoped implementation units, dispatching to sdlc-implementer, sdlc-code-reviewer, and sdlc-qa sub-modes with structured contracts and iteration limits.
---

# Architect Execution Hub

## Overview

Orchestrates the Phase 2 execution cycle for the sdlc-architect mode. Provides dispatch templates, review cycle rules, and iteration limits for managing sdlc-implementer, sdlc-code-reviewer, and sdlc-qa sub-modes.

**Core principle:** Precise dispatch specifications reduce review iterations. Invest in dispatch quality.

## When to Use

- sdlc-architect has completed Phase 1 (architecture planning) and is ready for Phase 2 (execution orchestration)
- A task checklist exists in the staging document with implementation units
- Each unit needs the implement-review-verify cycle

## Dispatch Cycle

For each implementation unit:

1. **Implement** → dispatch `sdlc-implementer` using `references/implementer-dispatch-template.md`
2. **Review** → dispatch `sdlc-code-reviewer` using `references/reviewer-dispatch-template.md`
3. **Verify** → dispatch `sdlc-qa` using `references/qa-dispatch-template.md`

See `references/review-cycle.md` for iteration limits and escalation rules.

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
- Update task status in staging doc after each cycle (pending | in-progress | done | blocked)
- Final full-issue review + QA after all tasks complete
- Staging document is the single source of truth for resume capability
