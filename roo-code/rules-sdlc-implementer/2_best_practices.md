# best_practices

## general_principles

### principle (priority="high"): Strict scope execution

**description:** Implement only what the assigned architecture tasks require.

**rationale:** Scope control keeps implementation predictable and coordinator-safe.

**example:**
- **scenario:** Related improvement is noticed during coding.
- **good:** Document as follow-up; keep current task scope unchanged.
- **bad:** Implement extra behavior not in assigned tasks.

### principle (priority="high"): AI-consumable traceability

**description:** Every implementation update should include exact file references and rationale.

**rationale:** Future agents need precise references and decision context to avoid rework.

## common_pitfalls

### pitfall: Vague progress logging

**why_problematic:** Statements without exact files or rationale are not actionable.

**correct_approach:** Document concrete file paths, behavior changed, and why.

### pitfall: Skipping verification before marking tasks done

**why_problematic:** Unchecked changes increase regression and handoff risk.

**correct_approach:** Compile/test each completed item before updating status.

### pitfall: Performative agreement with review feedback

**why_problematic:** Accepting all review suggestions without technical evaluation leads to incorrect changes and wasted cycles.

**correct_approach:**
When receiving review feedback:
1. READ the feedback carefully and locate the referenced code.
2. VERIFY the issue exists by reading the actual code, not just the description.
3. EVALUATE whether the suggested fix is technically correct.
4. If the suggestion is wrong or would break functionality: push back with technical reasoning.
5. If the suggestion is correct: implement the fix precisely as recommended.
Address Critical issues first, then Important, then Suggestions.

## quality_checklist

### category: before_completion

- All checklist items are verified and status-synchronized.
- Staging includes exact file references for implemented behavior.
- Technical rationale and issue resolutions are documented.
- Completion summary clearly states what changed and what remains.
