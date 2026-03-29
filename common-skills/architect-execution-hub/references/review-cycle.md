# Review Cycle Rules

## Per-Task Cycle

```
implement → test-gate → coverage-gate → code-review → security-review (conditional) → qa → (pass) → DONE
                                           ↓ (fail, iter 1-3)                              ↓ (fail)
                                     re-implement (verbatim feedback)                 re-implement
                                           ↓ (fail, iter 3+ same defect)             (max 2 retries)
                                     diagnostic analysis → self-implement or guided re-dispatch
                                           ↓ (iter 5 hard ceiling)
                                     architect self-implements → continues to review/QA
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
| Code Review (incl. security) | Adaptive (see below) | Adaptive Recovery Protocol — architect self-implements after diagnostic analysis. Never blocks. |
| QA Verification | 2 failures | Mark task BLOCKED. Return to coordinator with QA failure evidence. |
| Semantic Review (Phase 3b) | 2 NEEDS WORK | Escalate to coordinator. Include both review reports and all guidance packages. |

## Adaptive Recovery Protocol (Code Review)

Review iterations follow a tiered recovery strategy instead of a hard block:

### Tier 1: Standard re-dispatch (iterations 1-3)
- Re-dispatch to implementer with the reviewer's COMPLETE feedback verbatim (all Critical, Important, and Suggestion items with original file:line references and code snippets).
- Do NOT summarize or omit any reviewer findings.

### Tier 2: Diagnostic analysis (after 3 rejections for the SAME defect)
1. **Read actual code:** The architect reads the implementation files directly (not just the implementer's summary).
2. **Compare claims vs reality:** Check whether the implementer's completion claims match the actual file contents.
3. **Classify failure pattern:**
   - **Stuck pattern** (same core defect persisted across 3 iterations): Architect self-implements the fix directly. Edit source files, mark as `architect-implemented` in staging doc and dispatch log, continue to review/QA.
   - **Progress pattern** (different issues each time): One more guided dispatch with exact code snippets showing what to change (see After Diagnostic Analysis below). If that also fails, self-implement.

### Tier 3: Hard ceiling (iteration 5)
- Architect self-implements regardless. No more implementer dispatches for this task.
- Pipeline continues normally (review, QA). No escalation or blocking required.

### Audit trail for self-implementation
- Log the self-implementation in the dispatch log: `checkpoint.sh dispatch-log --event dispatch --agent architect-self-impl`.
- Update the staging doc's task status board with `architect-implemented` in the notes column.
- The self-implemented code still goes through review and QA like any other implementation.

## Test Existence Gate

Before dispatching to code reviewer, the architect verifies that the implementer created test files for new/modified source modules:

**Detection patterns** (check via bash — adapt globs to project conventions):
- `**/__tests__/**/*.{test,spec}.{ts,tsx,js,jsx}`
- `**/*.{test,spec}.{ts,tsx,js,jsx}`
- `**/test_*.py`, `**/*_test.py`, `**/tests/**/*.py`

**Module-to-test mapping**: Every new or significantly modified source file under `src/` (or project source root) must have a corresponding test file. The mapping uses naming conventions: `Foo.ts` → `Foo.test.ts` or `__tests__/Foo.test.ts`.

**Exemptions** (no test file required):
- Documentation-only changes (`*.md`, `docs/**`)
- Configuration files (`*.config.*`, `*.json`, `*.yaml`, `*.yml` at project root)
- Type declaration files (`*.d.ts`)
- Test utility files (`test-utils.*`, `__mocks__/**`, `*.fixture.*`)
- Generated code (if project has a generation convention)

**On failure**: Re-dispatch implementer with test-only focus (counts as an iteration). Do NOT send to reviewer without tests.

## Coverage Gate

After the Test Existence Gate passes and before dispatching to the code reviewer, run a coverage check on the implementer's work:

1. **Run coverage**: Execute the project's test suite with coverage reporting:
   - Default: `npx jest --coverage --coverageReporters=json-summary`
   - Stack-specific alternatives: `pytest --cov --cov-report=json`, `go test -cover`, etc.
2. **Parse results**: Read the coverage summary (e.g., `coverage/coverage-summary.json`) for line, branch, and function percentages.
3. **Apply thresholds**: Compare new/modified file coverage against thresholds from `plan/cross-cutting/testing-strategy.md`. If no testing strategy exists, use defaults: 80% lines, 70% branches for new/modified files.
4. **On failure**: Re-dispatch to implementer with coverage report and specific uncovered lines/branches. Include the coverage summary in the re-dispatch message. This counts as an iteration.
5. **On success**: Include the coverage summary in the reviewer dispatch for reference.

**Note**: The Coverage Gate runs the test suite to collect metrics — this is separate from the QA agent's independent execution later in the pipeline.

## Status Tracking

Update the staging document task checklist after each dispatch cycle:

| Status | Meaning |
|--------|---------|
| `pending` | Not yet started |
| `in-progress` | Implementer dispatched, cycle active |
| `done` | QA verification passed |
| `blocked` | QA limit reached, escalated (never for review iterations) |

Track per task:
- Review iteration count (0+, no hard max — adaptive recovery applies)
- QA retry count (0-2)
- Last review verdict summary
- Last QA verdict summary
- Recovery method: `implementer` | `architect-implemented` (when self-implementation was used)

## Re-dispatch Rules

### After Review Rejection (iterations 1-3)
1. Include the reviewer's COMPLETE output verbatim in the re-dispatch — all Critical, Important, AND Suggestion items with their original file:line references and code snippets. Do NOT summarize or omit any findings.
2. Instruct implementer to fix ALL the listed issues.
3. Increment review iteration count.
4. After fix, re-dispatch to sdlc-code-reviewer (not directly to QA).

### After Diagnostic Analysis (Guided Re-dispatch)
When the architect has analyzed the actual code and determined the implementer needs concrete guidance (typically after iteration 3):

1. Include the reviewer's complete feedback as above.
2. Add a `DIAGNOSTIC GUIDANCE` section with:
   - Exact current code that is wrong, with file:line references.
   - What it should be changed to, with reasoning.
   - Any patterns from the existing codebase to follow.
3. This gives the implementer maximum chance of success before the architect self-implements.

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
