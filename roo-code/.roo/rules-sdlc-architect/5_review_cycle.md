# review_cycle

## overview

Specification for the implement-review-verify cycle that the architect
manages for each implementation unit during Phase 2.

## per_task_cycle

### step: implement (order: 1)

**Action:** Dispatch sdlc-implementer with task specification.

**Success:** Implementer returns attempt_completion with code-change summary.

**Failure:** Implementer returns blocker — mark task blocked, escalate to coordinator.

### step: code_review (order: 2)

**Action:** Dispatch sdlc-code-reviewer with staging path and implementer's summary.

**Success (verdict: Approved):** Proceed to QA verification.

**Failure (verdict: Changes Required):**
Re-dispatch implementer with review feedback.
Track iteration count in staging document.

### step: qa_verification (order: 3)

**Action:** Dispatch sdlc-qa with acceptance criteria and verification commands.

**Success (verdict: PASS):** Mark task done in staging. Proceed to next task.

**Failure (verdict: FAIL):**
Re-dispatch implementer with QA failure evidence.
After implementer fix, restart from code_review step.

## iteration_limits

### limit: review_iterations (max: 3)

After 3 review rejections for the same task:
- Mark task as blocked in staging with review history.
- Return to coordinator with blocker details and all 3 review verdicts.
- Do NOT continue dispatching.

### limit: qa_retries (max: 2)

After 2 QA failures for the same task:
- Mark task as blocked in staging with QA failure evidence.
- Return to coordinator with blocker details.

### limit: semantic_review_iterations (max: 2)

After 2 semantic review NEEDS WORK verdicts for the same story:
- The local model may not be capable of resolving the issues.
- Return to coordinator with both semantic review reports and all guidance packages.
- Recommend escalating affected tasks to Commercial model.

## status_tracking

**Description:**
After each dispatch cycle, update the task status in the staging document.
Status values: pending | in-progress | done | blocked.

**transitions:**
- **transition (from: pending, to: in-progress):** trigger: Implementer dispatched.
- **transition (from: in-progress, to: done):** trigger: QA verification passed.
- **transition (from: in-progress, to: blocked):** trigger: Review limit or QA limit reached.

**tracking_fields:**
- Review iteration count (0-3).
- QA retry count (0-2).
- Last review verdict summary.
- Last QA verdict summary.

## final_issue_review

**Description:**
After all individual tasks are done, run a final full-issue review cycle followed by semantic review.

**Steps:**
- Dispatch sdlc-code-reviewer with full issue scope and combined task summaries.
- If Approved: dispatch sdlc-qa for full-issue verification.
- If Changes Required: identify which task(s) need fixes, re-dispatch implementer for those specific tasks only.
- If final QA passes: proceed to semantic review (Phase 3b).

## semantic_review

**Description:**
After full-issue review + QA passes, run the commercial-model semantic review (Phase 3b).

**Steps:**
- Dispatch sdlc-semantic-reviewer using semantic-reviewer-dispatch-template.md.
- Include all local review verdicts, QA verdicts, and implementer summaries.
- Handle result:
  - PASS: proceed to acceptance validation (Phase 4).
  - NEEDS WORK: extract guidance package. Re-dispatch implementer for affected tasks with `SEMANTIC GUIDANCE` section containing the guidance package's reasoned corrections, documentation (fetched excerpts and/or fetch instructions), and improvement instructions.
  - NEEDS WORK with escalation flag: halt and escalate to coordinator + user.
- After implementer fixes from semantic guidance, restart from full-issue review (not just semantic review) to ensure fixes don't introduce new issues.
- Track semantic review iteration count (max 2).

## guidance_propagation

**Description:**
How the semantic reviewer's guidance package flows into local model re-dispatches.

**Pattern:**
When re-dispatching implementer after semantic review NEEDS WORK, add a `SEMANTIC GUIDANCE` section to the implementer dispatch:

```
SEMANTIC GUIDANCE (from commercial semantic review):
[Reasoned corrections — what should be different and why, from the guidance package]
[Documentation — fetched excerpts and/or fetch instructions for the local model to retrieve via context7]
[Specific improvement instructions — actionable steps from the guidance package]
```

This section provides the local model with commercial-grade reasoning and targeted documentation, improving the quality of its next attempt.
