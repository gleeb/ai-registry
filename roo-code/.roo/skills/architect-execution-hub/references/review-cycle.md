# Review Cycle Rules

## Per-Task Cycle

```
implement → code-review → (pass) → qa → (pass) → DONE
                ↓ (fail)              ↓ (fail)
          re-implement          re-implement
          (max 3 iterations)    (max 2 retries)
```

## Iteration Limits

| Gate | Max Iterations | On Limit Reached |
|------|---------------|------------------|
| Code Review | 3 rejections | Mark task BLOCKED. Return to coordinator with all 3 review verdicts. |
| QA Verification | 2 failures | Mark task BLOCKED. Return to coordinator with QA failure evidence. |

## Status Tracking

Update the staging document task checklist after each dispatch cycle:

| Status | Meaning |
|--------|---------|
| `pending` | Not yet started |
| `in-progress` | Implementer dispatched, cycle active |
| `done` | QA verification passed |
| `blocked` | Review or QA limit reached, escalated |

Track per task:
- Review iteration count (0-3)
- QA retry count (0-2)
- Last review verdict summary
- Last QA verdict summary

## Re-dispatch Rules

### After Review Rejection
1. Include the reviewer's exact issue list in the re-dispatch message.
2. Instruct implementer to fix ONLY the listed issues.
3. Increment review iteration count.
4. After fix, re-dispatch to code-reviewer (not directly to QA).

### After QA Failure
1. Include QA failure evidence (commands, outputs, failing criteria).
2. Re-dispatch implementer to fix the specific failures.
3. After fix, restart from code-review step (not directly to QA).
4. Increment QA retry count.

## Final Issue Review

After all individual tasks are `done`:
1. Dispatch code-reviewer for full-issue holistic review.
2. If Approved → dispatch QA for full-issue verification.
3. If Changes Required → identify affected tasks, re-dispatch implementer for those only.
4. If final QA passes → return to coordinator with full completion summary.

## Resume Support

On resume (Phase 0), the architect reads the staging document and:
- Finds the last task with status `done`
- Identifies the next task with status `pending` or `in-progress`
- Continues the cycle from that point
- All context comes from the staging doc, not session memory
