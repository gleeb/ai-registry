# Review Cycle Rules

## Per-Task Cycle

```
implement → code-review → security-review (conditional) → qa → (pass) → DONE
                ↓ (fail)                                       ↓ (fail)
          re-implement                                   re-implement
          (max 3 iterations)                             (max 2 retries)
```

### Security Review Integration

The security review is part of the code review step, not a separate dispatch. When `SECURITY_REVIEW: true` is set in the reviewer dispatch:

1. The code reviewer loads `common-skills/security-review/` during review.
2. The reviewer adds a `## Security Review` section to the review output.
3. Security findings are categorized alongside standard code review findings.
4. Critical security findings cause the same "Changes Required" verdict as critical code issues.

**When to enable**: Set `SECURITY_REVIEW: true` when:
- Story has `security` in `candidate_domains`
- Task touches authentication, authorization, or session management
- Task handles user input (forms, API parameters, file uploads)
- Task accesses or modifies data storage
- Task involves secrets, tokens, or credential handling

## Iteration Limits

| Gate | Max Iterations | On Limit Reached |
|------|---------------|------------------|
| Code Review (incl. security) | 3 rejections | Mark task BLOCKED. Return to coordinator with all 3 review verdicts. |
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
4. After fix, re-dispatch to sdlc-code-reviewer (not directly to QA).

### After QA Failure
1. Include QA failure evidence (commands, outputs, failing criteria).
2. Re-dispatch implementer to fix the specific failures.
3. After fix, restart from code-review step (not directly to QA).
4. Increment QA retry count.

## Final Story Review

After all individual tasks are `done` (Phase 3):
1. Dispatch sdlc-code-reviewer for full-story holistic review (with `SECURITY_REVIEW: true` if any task had security review).
2. If Approved → dispatch sdlc-qa for full-story verification.
3. If Changes Required → identify affected tasks, re-dispatch implementer for those only.
4. If final QA passes → proceed to Phase 4 (Acceptance Validation).

## Resume Support

On resume (Phase 0), the architect reads the staging document and:
- Finds the last task with status `done`
- Identifies the next task with status `pending` or `in-progress`
- Continues the cycle from that point
- All context comes from the staging doc, not session memory
