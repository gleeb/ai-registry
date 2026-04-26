# Oracle Dispatch Template

Use this template when dispatching `@sdlc-engineering-oracle` via the Task tool. This implements the dispatch contract from **P14 §3.2**.

**Architect:** Before sending this dispatch, log it via `checkpoint.sh dispatch-log --event dispatch --agent sdlc-engineering-oracle --counters '...' --scope '[...]'`. After Oracle returns, log the response with verdict (`FIX` or `ESCALATION`).

## Cross-cutting governors (verify BEFORE composing the dispatch)

The hub MUST verify all of the following before dispatching Oracle. If any fails, do NOT dispatch — log a decline reason and continue with the standard pipeline (or, on cap exhaustion, escalate to coordinator).

- **Default-cycle precondition** — At least one complete `implementer → code-reviewer → QA` cycle has run on this task in the current story. (Exempt: trigger 5 defect-incident — original story execution satisfies it.) If not satisfied, do NOT dispatch.
- **Per-task dispatch cap** — Count prior Oracle dispatches on this task:
  - **0 prior:** allowed.
  - **1 prior (i.e., this is the 2nd):** allowed only if a justification is logged stating (a) what materially changed since the prior dispatch (new failing test, new error symptom, newly available context, scope expansion), and (b) why a different output is expected. Include the prior Oracle's diff and notes in the dispatch as the `PRIOR ORACLE DISPATCH` field.
  - **2 prior (i.e., this is the 3rd):** forbidden without coordinator approval. HALT and escalate to coordinator.
- **Per-story soft cap** — Count Oracle dispatches across all tasks in the current story. If this would be the 4th, pause for coordinator review before dispatching.

## Required Message Structure

```
TASK: [Task ID] — [Task Name]

DISPATCH CONTEXT:
- Story: [US-NNN-name]
- Trigger: [1=query-budget | 2=retry-budget | 3=task-shape preauthorize | 4=hub-internal evaluation | 5=defect-incident]
- Per-task dispatch index: [1 for first dispatch on this task, 2 for second]
- Per-story dispatch index: [1, 2, 3 across all tasks in the story so far]
- Justification (only if per-task index ≥ 2): [what changed; expected differentiator]

SCOPE (you may edit ONLY these files; any other file is out-of-scope):
- [file path 1]
- [file path 2]
- [file path 3]
[Authoritative list. Files outside this list MAY be read for context but MUST NOT be edited. If the fix appears to require an out-of-scope edit, return ESCALATION REPORT — do not silently expand.]

FAILING AC / FAILING TEST:
- AC: [exact AC text from story.md or task context, with section/line ref]
- Test(s): [test file path::test name(s) that fail, or "no test exists — failure observed via <evidence>"]

ERROR SYMPTOMS:
[Verbatim error output, stack traces, console errors, or behavioral observations
that demonstrate the failure. Include the most recent run's evidence; do not summarize.]

PRIOR IMPLEMENTER ATTEMPTS (verbatim, all of them):
- Attempt 1 (dispatch_id: ...): [implementer's completion summary, including diff if available]
- Attempt 2 (dispatch_id: ...): [...]
- Attempt N (dispatch_id: ...): [...]

PRIOR REVIEWER FEEDBACK (verbatim, all iterations):
- Iteration 1 (dispatch_id: ...): [reviewer's full Changes Required findings]
- Iteration 2 (dispatch_id: ...): [...]
- Iteration N (dispatch_id: ...): [...]

[If story-review feedback also exists for this task's findings, include it here under
"PRIOR STORY-REVIEWER FEEDBACK" with the same verbatim treatment.]

ARCHITECT SELF-IMPLEMENTATION (only if Adaptive Recovery already self-implemented):
- Diff: [the architect's edits, verbatim]
- Rejection reason: [verbatim review/QA verdict that rejected it]

PRIOR ORACLE DISPATCH (only if per-task dispatch index ≥ 2):
- Prior diff: [the prior Oracle's CHANGES MADE section, verbatim]
- Prior NOTES: [the prior Oracle's NOTES section, verbatim]
- Prior verdict: [FIX or ESCALATION]
- Why this re-dispatch will be different: [from the hub's justification]

CACHE ENTRIES (relevant libraries):
- Library cache file: docs/staging/[story-id].lib-cache.md
- Relevant entries: [list of library names whose entries are pertinent to the failing AC]

PLAN ARTIFACTS:
- story.md: [path] — sections [line ranges that bear on the failing AC]
- hld.md: [path] — sections [line ranges]
- api.md: [path] — sections [line ranges] (if external integration)
- security.md: [path] — sections [line ranges] (if security-relevant)
- testing-strategy.md: [path] — sections [line ranges] (if relevant)

STAGING DOC: docs/staging/[story-id].md

TASK CONTEXT DOCUMENT: docs/staging/[story-id].task-[N].context.md

INSTRUCTIONS:
- Solve the failing AC by editing files within SCOPE only.
- Run lint, typecheck, the failing test(s) named above, and build for verification.
- If the fix requires editing files outside SCOPE, return ESCALATION REPORT listing the files — do not edit them.
- Tangential issues you observe (in or out of scope) go in NOTES, not in the diff.
- Return your verdict using the FIX or ESCALATION REPORT structure from your agent spec.
```

## Dispatch Logging

Log the Oracle dispatch event with the new P14 fields:

```bash
checkpoint.sh dispatch-log \
  --event dispatch \
  --agent sdlc-engineering-oracle \
  --dispatch-id "exec-{story}-t{id}-oracle-i{N}" \
  --story "{story}" \
  --phase "{phase}" \
  --task "{id}:{name}" \
  --iteration {N} \
  --counters '{"doc_queries":M,"implementer_attempts":K,"reviewer_iterations":L}' \
  --scope '["path/to/file1","path/to/file2"]'
```

When a trigger fires but the hub elects NOT to dispatch (e.g., trigger 1 fired but the doc-query reason is benign exploration of well-cached territory), log a decline event:

```bash
checkpoint.sh dispatch-log \
  --event dispatch \
  --agent sdlc-engineering-oracle \
  --dispatch-id "exec-{story}-t{id}-oracle-decline-{trigger}" \
  --story "{story}" \
  --phase "{phase}" \
  --task "{id}:{name}" \
  --counters '{"doc_queries":M,"implementer_attempts":K,"reviewer_iterations":L}' \
  --decline-reason "Trigger {1|2|3}: {one-line reason the hub declined to dispatch}"
```

The decline event makes M1 (P14 §5) auditable.

## Response Logging

Log the Oracle response with verdict:

```bash
checkpoint.sh dispatch-log \
  --event response \
  --agent sdlc-engineering-oracle \
  --dispatch-id "exec-{story}-t{id}-oracle-i{N}" \
  --verdict "FIX|ESCALATION|BLOCKED" \
  --summary "{one-line summary of root cause and fix or escalation reason}"
```

## Post-Response Handling

- **FIX:** Verify Oracle's `SCOPE COMPLIANCE` field lists only files from the dispatched scope. Run the next default-cycle pass: dispatch `@sdlc-engineering-code-reviewer` and then `@sdlc-engineering-qa` on Oracle's edits. If review/QA fails, the hub considers re-dispatch under §3.0 per-task cap rules — it does NOT auto-retry Oracle.
- **ESCALATION:** Return the report to the coordinator (Tier 4 protocol). If the report's blocker is "fix requires out-of-scope edits," the coordinator and user decide whether to authorize a scope expansion.
- **BLOCKED:** Read the missing-field message; supply the missing fields and re-dispatch as a fresh dispatch (this does not consume the per-task cap).

## NOTES Triage

Oracle's NOTES section (out-of-scope observations) is the hub's responsibility to triage. For each NOTE:

- If the observation is a defect against a separate AC: open a `defect-incident` per P21.
- If the observation is a refactor or improvement opportunity: defer to a follow-up story; do NOT add it to the current story scope unless the user approves.
- If the observation is a planning gap: append to the story's `planning-gotchas.md` if relevant.

NOTES are never silently absorbed into the current task without an explicit hub decision.
