# Adaptive Recovery Protocol (Code Review)

This protocol governs the Phase 2 implement-review-QA loop on a single task. It implements the **Oracle Escalation Policy**: count-based triggers, default-cycle precondition, per-task and per-story dispatch caps, and a strict "workers do not route" separation of concerns.

> **Where Oracle fits.** Oracle is **not** the last-resort agent it once was. It is a high-leverage escalation route the hub may dispatch as early as the second attempt on a task, governed by triggers and caps. The standard implement-review-QA cycle is still the default; Oracle replaces some retries, not all of them.

## Cross-Cutting Governors (always apply)

The hub MUST verify all of these before dispatching `@sdlc-engineering-oracle`:

1. **Default-cycle precondition.** At least one complete `implementer → code-reviewer → QA` cycle has run on this task in the current story. This holds **regardless of any preauthorize flag, retry count, or query count.** (Exempt: trigger 5 defect-incident — original story execution satisfies it.)
2. **Per-task dispatch cap.** Oracle is dispatched at most **once per task** by default.
   - 2nd dispatch on the same task: requires hub-logged justification stating (a) what materially changed since the prior Oracle dispatch and (b) why a different output is expected. Include `PRIOR ORACLE DISPATCH` field in the new dispatch envelope.
   - 3rd dispatch on the same task: forbidden without coordinator approval.
3. **Per-story soft cap.** Beyond **3 Oracle dispatches across all tasks in a story**, the SDLC coordinator is paused for review before the next dispatch.
4. **Worker prompts unchanged.** Implementer and reviewer prompts contain no awareness of Oracle, no counters, no "should this go to Oracle?" question. All routing happens hub-internally based on dispatch metadata. Reviewer findings (e.g., "implementer repeatedly misuses API X") are routing inputs the hub interprets — the reviewer never names Oracle.

## Per-Task Counters (hub maintains)

For every task in the current story, the hub maintains:

- `doc_queries` — cumulative context7 + Tavily queries on this task across all attempts in the current story (resets at story boundary).
- `implementer_attempts` — count of implementer dispatches on this task.
- `reviewer_iterations` — count of code-reviewer dispatches on this task.
- `oracle_dispatches_task` — count of Oracle dispatches on this task.
- `oracle_dispatches_story` — story-aggregate count of Oracle dispatches across all tasks (story-scoped counter).

These counters are read from the dispatch log; they are NOT surfaced into worker prompts.

## Triggers (hub-internal evaluation before every re-dispatch on a task post-default-cycle)

Before authorizing **any** implementer or code-reviewer re-dispatch on a task that has completed at least one default cycle, the hub evaluates triggers 1–3 against the per-task counters and the most recent reviewer findings:

### Trigger 1 — Query-budget
**Condition:** `doc_queries > 8` AND default cycle complete.
**Action:** Hub MUST consider Oracle before authorizing another implementer dispatch. If the hub declines (e.g., the queries reflect benign exploration of well-cached territory), it MUST log an explicit decline reason via `checkpoint.sh dispatch-log --event dispatch --decline-reason "..."`.

### Trigger 2 — Retry-budget
**Condition:** Implementer would be dispatched for the 3rd+ attempt on the same task (`implementer_attempts >= 2` and another dispatch is contemplated) AND default cycle complete.
**Action:** Oracle MUST be offered as an alternative. The hub's delegation contract treats Oracle selection as a first-class option at attempt 3.

### Trigger 3 — Task-shape preauthorize (accelerator, not bypass)
**Condition:** The planner-produced task entry sets `oracle_preauthorize: true` AND the default cycle has just completed without satisfying the AC. (This flag is currently dormant — the current planner contract does not produce it; treat every task as `oracle_preauthorize: false` until that changes.)
**Action:** Oracle is dispatched on attempt 2 (immediately after the first cycle), instead of waiting for trigger 1 or 2 thresholds. The flag accelerates Oracle entry; it does NOT bypass the default cycle.

### Trigger 4 — Hub-internal escalation evaluation (governing rule)
This is the **rule that makes triggers 1–3 actionable**. Before every re-dispatch on a task post-default-cycle, the hub:

1. Reads per-task counters from the dispatch log.
2. Reads the most recent reviewer findings (looking for repeated API misuse, AC contradictions, cross-cutting mismatches).
3. Evaluates triggers 1–3.
4. Either dispatches Oracle (if a trigger fires and the cross-cutting governors permit) or logs an explicit decline reason and re-dispatches the worker normally.

The evaluation is hub-internal: it does NOT prompt the implementer or reviewer with counters or with an "Oracle?" question. Worker prompts are unchanged.

### Trigger 5 — Defect-incident
When the hub opens a `defect-incident` against a completed story, Oracle is dispatched as the **first-line investigator** when:
- The contradicted AC involves an external integration (story's `api.md` declares a `wire_format` block), OR
- The reproduced behavior indicates a cross-cutting contract mismatch (wrong auth, envelope, serialization), OR
- The story's original execution consumed ≥ 8 doc queries or ≥ 3 implementer retries on the now-contradicted AC.

The default-cycle precondition is considered satisfied for defect incidents because the original story execution already ran a complete cycle.

## Tiered Recovery (governed by escalation triggers)

The Tier 1 → Tier 4 progression is preserved as the **default sequence when no escalation trigger fires earlier**. Triggers insert Oracle dispatch points earlier in the progression when they warrant it.

### Tier 1: Standard re-dispatch (iterations 1–2 of the default cycle)
- Re-dispatch to implementer with the reviewer's COMPLETE feedback verbatim (all Critical, Important, and Suggestion items with original file:line references and code snippets).
- Do NOT summarize or omit any reviewer findings.
- **Hub trigger evaluation runs here** — if trigger 1 (queries > 8) or trigger 2 (3rd attempt) fires after the default cycle completes, the hub may dispatch Oracle instead of another implementer pass. If trigger 3 (preauthorize) is set, Oracle is dispatched on attempt 2.

### Tier 2: Diagnostic analysis (after 3 rejections for the SAME defect, if Oracle did not already dispatch)
1. **Read actual code:** The architect reads the implementation files directly (not just the implementer's summary).
2. **Compare claims vs reality:** Check whether the implementer's completion claims match the actual file contents.
3. **Classify failure pattern:**
   - **Stuck pattern** (same core defect persisted across 3 iterations): Architect self-implements the fix directly. Edit source files, mark as `architect-implemented` in staging doc and dispatch log, continue to review/QA.
   - **Progress pattern** (different issues each time): One more guided dispatch with exact code snippets showing what to change (see re-dispatch-patterns.md After Diagnostic Analysis section). If that also fails, self-implement.

### Tier 3: Hard ceiling (iteration 5)
- Architect self-implements regardless. No more implementer dispatches for this task.
- Pipeline continues normally (review, QA). No escalation or blocking required.

### Tier 4: Oracle escalation (last-resort path)

When the architect's self-implemented code is also rejected by review or QA (total pipeline exhaustion for this task), and Oracle has not yet been dispatched on this task earlier via triggers 1–3:

1. Verify cross-cutting governors permit dispatch (default-cycle precondition is trivially met by Tier 4; check per-task and per-story caps).
2. Compose the dispatch envelope per `oracle-dispatch-template.md` — include all implementer attempts, all reviewer feedback, the architect's self-implementation diff and rejection reasons, plan artifacts, staging doc, the `scope` block, the failing AC/test, and error symptoms.
3. Dispatch `@sdlc-engineering-oracle`.
4. If Oracle returns **FIX**: verify SCOPE COMPLIANCE (no edits outside the dispatched `scope`); mark as `oracle-implemented` in staging doc and dispatch log. Continue pipeline normally (review + QA on Oracle's code). The next default-cycle pass is the verification mechanism — do NOT auto-retry Oracle if the code fails review/QA; consider re-dispatch only under §3.0 per-task cap rules.
5. If Oracle returns **ESCALATION REPORT**: return to coordinator for user decision.

> **Note on early Oracle dispatch.** If an escalation trigger (1, 2, or 3) dispatched Oracle earlier than Tier 4, then Tier 4 may not be reachable on this task — Oracle has already had its single default dispatch. A second Oracle dispatch under Tier 4 would consume the per-task cap's "2nd dispatch with justification" allowance and requires the hub to log what changed and why a different output is expected.

## Audit Trail

### Self-implementation
- Log via dispatch log: `checkpoint.sh dispatch-log --event dispatch --agent architect-self-impl`.
- Update the staging doc's task status board with `architect-implemented` in the notes column.
- The self-implemented code still goes through review and QA like any other implementation.

### Oracle dispatch
- Log dispatch with full escalation metadata:
  ```bash
  checkpoint.sh dispatch-log --event dispatch \
    --agent sdlc-engineering-oracle \
    --dispatch-id "exec-{story}-t{id}-oracle-i{N}" \
    --counters '{"doc_queries":M,"implementer_attempts":K,"reviewer_iterations":L}' \
    --scope '["path/to/file1","path/to/file2"]'
  ```
- Log response: `checkpoint.sh dispatch-log --event response --verdict "FIX|ESCALATION|BLOCKED" --summary "..."`.
- If Oracle fixes: mark as `oracle-implemented` in staging doc notes column.
- If Oracle escalates: log with verdict `ESCALATION` and return the report to the coordinator.

### Oracle decline (trigger fired, hub did not dispatch)
- Log via dispatch log with a decline reason (no Oracle subagent dispatch occurs):
  ```bash
  checkpoint.sh dispatch-log --event dispatch \
    --agent sdlc-engineering-oracle \
    --dispatch-id "exec-{story}-t{id}-oracle-decline-{trigger}" \
    --counters '{"doc_queries":M,"implementer_attempts":K,"reviewer_iterations":L}' \
    --decline-reason "Trigger {1|2|3}: {one-line reason}"
  ```
- This keeps the Oracle-decline metric auditable from `.sdlc/dispatch-log.jsonl`.
