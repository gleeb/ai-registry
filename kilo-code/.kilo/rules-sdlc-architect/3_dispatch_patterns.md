# Dispatch Patterns

## Overview

Templates and contracts for dispatching sub-modes during Phase 2 execution orchestration. Every dispatch must follow the mandatory dispatch contract defined in the architect's customInstructions. These templates provide the specific structure for each sub-mode.

## Dispatch Template: sdlc-implementer

Dispatch for a single scoped implementation unit.

**Required fields:**

- **task_id:** Task number from the staging document checklist.
- **task_name:** Descriptive name matching the checklist item.
- **specification:** Full task specification from LLD including:
  - Function signatures and parameters
  - Interface definitions
  - File paths for each change
  - Dependencies on prior tasks
- **acceptance_criteria:** Testable conditions that define task completion.
- **staging_path:** Exact path to the staging document for shared context.
- **boundaries:** Explicit scope limits: what to implement and what NOT to implement.
- **completion_contract:** Return via attempt_completion with:
  1. Code-change summary (files created/modified with brief description).
  2. Test results if applicable.
  3. Any blockers encountered.

**Example:**

```
Task 3: Create IngredientModel
Specification: Create src/models/ingredient.py with dataclass IngredientModel.
  Fields: name(str), quantity(float), unit(str), expiry_date(Optional[date]).
  Methods: __eq__ comparing name+unit, __hash__ on name+unit, is_expired() -> bool.
Acceptance: Unit test test_ingredient_equality passes. test_is_expired passes.
Staging: docs/staging/T-WOL-8-data-model-migration-baseline.md
Boundaries: Only create the model file and its test. Do not implement storage or migrations.
Completion: attempt_completion with file list and test results.
```

## Dispatch Template: sdlc-code-reviewer

Dispatch for reviewing a completed implementation unit.

**Required fields:**

- **task_id:** Task number being reviewed.
- **staging_path:** Exact path to the staging document.
- **lld_section:** Specific LLD section or requirements for this task.
- **implementer_summary:** The implementer's completion summary (files changed, what was done).
- **completion_contract:** Return via attempt_completion with:
  1. Spec Compliance: PASS/FAIL.
  2. Issues categorized by severity with file:line references.
  3. Overall Assessment: Approved / Changes Required.

## Dispatch Template: sdlc-qa

Dispatch for independently verifying a completed and reviewed implementation unit.

**Required fields:**

- **task_id:** Task number being verified.
- **staging_path:** Exact path to the staging document.
- **acceptance_criteria:** Testable conditions from the task specification.
- **verification_commands:** Suggested commands to verify each criterion (tests, build, etc.).
- **completion_contract:** Return via attempt_completion with:
  1. Verification Status: PASS/FAIL.
  2. Per-criterion results with evidence (command output, exit codes).
  3. Any regressions detected.

## Dispatch Template: sdlc-code-reviewer (Final Issue Review)

Dispatch for final full-issue review after all tasks complete.

**Required fields:**

- **scope:** Full issue scope — all tasks in the staging document.
- **staging_path:** Exact path to the staging document.
- **task_summaries:** Combined summaries from all implementation units.
- **focus:** Holistic review: cross-task integration, overall architecture adherence, consistency.
- **completion_contract:** Same format as per-task review.

## Re-Dispatch Pattern

When re-dispatching implementer after review feedback.

**Required fields:**

- **original_task:** Reference to the original task specification.
- **review_feedback:** The reviewer's exact issue list with file:line references and recommended fixes.
- **iteration_count:** Current iteration number (1-3). After 3, escalate instead.
- **focus:** Fix ONLY the issues identified in the review. Do not expand scope.
