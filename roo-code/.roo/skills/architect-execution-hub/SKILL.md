---
name: architect-execution-hub
description: Use when the sdlc-architect needs to orchestrate an implement-review-verify cycle for scoped implementation units, dispatching to implementer, code-reviewer, and qa sub-modes with structured contracts and iteration limits.
---

# Architect Execution Hub

## Overview

Orchestrates the Phase 2 execution cycle for the sdlc-architect mode. Provides dispatch templates, review cycle rules, and iteration limits for managing implementer, code-reviewer, and qa sub-modes.

**Core principle:** Precise dispatch specifications reduce review iterations. Invest in dispatch quality.

## When to Use

- sdlc-architect has completed Phase 1 (architecture planning) and is ready for Phase 2 (execution orchestration)
- A task checklist exists in the staging document with implementation units
- Each unit needs the implement-review-verify cycle

## Dispatch Cycle

For each implementation unit:

1. **Implement** → dispatch `sdlc-implementer` using `references/implementer-dispatch-template.md`
2. **Review** → dispatch `code-reviewer` using `references/reviewer-dispatch-template.md`
3. **Verify** → dispatch `qa` using `references/qa-dispatch-template.md`

See `references/review-cycle.md` for iteration limits and escalation rules.

## Key Rules

- Max 3 review iterations per task before escalating to coordinator
- Max 2 QA retries per task before escalating
- Update task status in staging doc after each cycle (pending | in-progress | done | blocked)
- Final full-issue review + QA after all tasks complete
- Staging document is the single source of truth for resume capability
