# Re-dispatch Patterns

All re-dispatch variants for review failures, QA failures, and semantic review guidance.

## After Review Rejection (iterations 1-3)

1. Include the reviewer's COMPLETE output verbatim in the re-dispatch — all Critical, Important, AND Suggestion items with their original file:line references and code snippets. Do NOT summarize or omit any findings.
2. Instruct implementer to fix ALL the listed issues.
3. Increment review iteration count.
4. After fix, re-dispatch to sdlc-code-reviewer (not directly to QA).

## After Diagnostic Analysis (Guided Re-dispatch)

When the architect has analyzed the actual code and determined the implementer needs concrete guidance (typically after iteration 3):

1. Include the reviewer's complete feedback as above.
2. Add a `DIAGNOSTIC GUIDANCE` section with:
   - Exact current code that is wrong, with file:line references.
   - What it should be changed to, with reasoning.
   - Any patterns from the existing codebase to follow.
3. This gives the implementer maximum chance of success before the architect self-implements.

## After QA Failure

1. Include QA failure evidence (commands, outputs, failing criteria).
2. Re-dispatch implementer to fix the specific failures.
3. After fix, restart from code-review step (not directly to QA).
4. Increment QA retry count.

## Final Story Review

After all individual tasks are `done` (Phase 3):
1. Dispatch `sdlc-engineering-story-reviewer` for full-story holistic review (uses larger model for cross-file reasoning). Include `SECURITY_REVIEW: true` if any task had security review.
2. If Approved → dispatch `sdlc-engineering-story-qa` for full-story verification (uses larger model for cross-task verification).
3. If Changes Required → identify affected tasks, re-dispatch implementer for those only.
4. If final QA passes → proceed to Phase 3b (Semantic Review).

Note: Per-task Phase 2 reviews/QA continue to use `sdlc-engineering-code-reviewer` and `sdlc-engineering-qa` (mini-model agents). Only Phase 3 story-level review/QA use the story-level agents.

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
