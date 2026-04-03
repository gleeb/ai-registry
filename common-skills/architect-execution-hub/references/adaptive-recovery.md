# Adaptive Recovery Protocol (Code Review)

Review iterations follow a tiered recovery strategy instead of a hard block:

## Tier 1: Standard re-dispatch (iterations 1-3)
- Re-dispatch to implementer with the reviewer's COMPLETE feedback verbatim (all Critical, Important, and Suggestion items with original file:line references and code snippets).
- Do NOT summarize or omit any reviewer findings.

## Tier 2: Diagnostic analysis (after 3 rejections for the SAME defect)
1. **Read actual code:** The architect reads the implementation files directly (not just the implementer's summary).
2. **Compare claims vs reality:** Check whether the implementer's completion claims match the actual file contents.
3. **Classify failure pattern:**
   - **Stuck pattern** (same core defect persisted across 3 iterations): Architect self-implements the fix directly. Edit source files, mark as `architect-implemented` in staging doc and dispatch log, continue to review/QA.
   - **Progress pattern** (different issues each time): One more guided dispatch with exact code snippets showing what to change (see re-dispatch-patterns.md After Diagnostic Analysis section). If that also fails, self-implement.

## Tier 3: Hard ceiling (iteration 5)
- Architect self-implements regardless. No more implementer dispatches for this task.
- Pipeline continues normally (review, QA). No escalation or blocking required.

## Tier 4: Oracle escalation (after architect self-implementation also fails)

When the architect's self-implemented code is also rejected by review or QA (total pipeline exhaustion for this task):

1. Dispatch `@sdlc-engineering-oracle` with the complete failure chain:
   - All implementer attempts and their summaries
   - All reviewer feedback (every iteration)
   - Architect self-implementation code and its rejection reasons
   - Plan artifacts (story.md, hld.md, relevant domain artifacts)
   - Staging doc with full history
2. Oracle diagnoses root cause using context7, Tavily web search, and deep analysis.
3. If Oracle produces a **FIX**: mark as `oracle-implemented` in staging doc and dispatch log. Continue pipeline normally (review + QA on Oracle's code).
4. If Oracle produces an **ESCALATION REPORT**: return to coordinator for user decision. The report includes: root cause analysis, what was tried, why it failed, and structured user options (drop feature, simplify scope, defer, provide manual guidance, alternative approach).

## Audit trail for self-implementation
- Log the self-implementation in the dispatch log: `checkpoint.sh dispatch-log --event dispatch --agent architect-self-impl`.
- Update the staging doc's task status board with `architect-implemented` in the notes column.
- The self-implemented code still goes through review and QA like any other implementation.

## Audit trail for Oracle escalation
- Log the Oracle dispatch: `checkpoint.sh dispatch-log --event dispatch --agent sdlc-engineering-oracle --dispatch-id exec-{story}-t{id}-oracle-i1`.
- If Oracle fixes: mark as `oracle-implemented` in staging doc notes column and dispatch log.
- If Oracle escalates: log with verdict `ESCALATION` and return the report to the coordinator.
