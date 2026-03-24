# Review Cycle Rules

## Per-Task Cycle

```
implement → code-review → security-review (conditional) → qa → (pass) → DONE
                ↓ (fail)                                       ↓ (fail)
          re-implement                                   re-implement
          (max 5 iterations)                             (max 2 retries)
```

### Security Review Integration

The security review is part of the code review step, not a separate dispatch. When `SECURITY_REVIEW: true` is set in the reviewer dispatch:

1. The code reviewer loads `skills/security-review/` during review.
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
| Code Review (incl. security) | 5 rejections | Mark task BLOCKED. Return to coordinator with all 5 review verdicts. |
| QA Verification | 2 failures | Mark task BLOCKED. Return to coordinator with QA failure evidence. |
| Semantic Review (Phase 3b) | 2 NEEDS WORK | Escalate to coordinator. Include both review reports and all guidance packages. |

## Status Tracking

Update the staging document task checklist after each dispatch cycle:

| Status | Meaning |
|--------|---------|
| `pending` | Not yet started |
| `in-progress` | Implementer dispatched, cycle active |
| `done` | QA verification passed |
| `blocked` | Review or QA limit reached, escalated |

Track per task:
- Review iteration count (0-5)
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
4. If final QA passes → proceed to Phase 3b (Semantic Review).

## Semantic Review (Phase 3b)

After full-story review + QA passes:
1. Dispatch sdlc-semantic-reviewer using `semantic-reviewer-dispatch-template.md`.
2. Include all local review verdicts, QA verdicts, implementer summaries, and git context (branch, base commit).
3. The reviewer runs 3 checks (full sweep, no sampling): agent report integrity, code quality review via git diff drill-down, terminology and contract alignment.
4. If PASS → proceed to Phase 4 (Acceptance Validation).
5. If NEEDS WORK → extract the guidance package. Re-dispatch implementer for affected tasks with `SEMANTIC GUIDANCE` section (see Guidance-Aware Re-dispatch below). After fixes, restart from Final Story Review.
6. If NEEDS WORK with escalation flag → halt and escalate to coordinator + user.
7. Track semantic review iteration count (max 2).

## Guidance-Aware Re-dispatch

When re-dispatching implementer after semantic review NEEDS WORK, add a `SEMANTIC GUIDANCE` section:

```
SEMANTIC GUIDANCE (from commercial semantic review):
[Reasoned corrections — what should be different and why]
[Documentation — fetched excerpts and/or fetch instructions for the local model to retrieve via context7]
[Specific improvement instructions]
```

This propagates commercial-model reasoning and documentation guidance into the local model's context, improving the quality of its next attempt.

## Doc-Only Changes

Changes that ONLY modify documentation files (`docs/staging/*.md`, `docs/**/*.md`) and do not touch any source code:

- Do NOT require code review dispatch.
- Do NOT require QA verification dispatch.
- The architect applies them directly and logs the change in the staging document.
- This reduces a 3-dispatch cycle to a single edit.

## Resume Support

On resume (Phase 0), the architect reads the staging document and:
- Finds the last task with status `done`
- Identifies the next task with status `pending` or `in-progress`
- Continues the cycle from that point
- All context comes from the staging doc, not session memory
