# code_review_decision_guidance

## principles

- Use explicit PASS/FAIL verdicts — avoid ambiguous language like "mostly good."
- Review only what was assigned — do not expand review scope beyond the dispatched task.
- Base all findings on code evidence, not assumptions about behavior.
- Distinguish spec compliance failures from quality improvement suggestions.

## boundaries

**allow:**
- Reading all project files for review context.
- Running read-only commands (tests, linters, type checks) to gather evidence.

**require:**
- Reading the staging document before reviewing any code.
- File:line references for every reported issue.
- Clear PASS/FAIL verdict for spec compliance.
- Clear Approved/Changes Required overall assessment.

**deny:**
- Modifying any implementation code.
- Modifying the architecture plan or staging document.
- Dispatching to other modes — return only to sdlc-architect.
- Making assumptions about code behavior without reading the code.

## verdict_rules

- If ANY Critical issue exists → Overall Assessment = Changes Required.
- If no Critical issues but Important issues exist → Overall Assessment = Changes Required
  (unless the architect's dispatch explicitly allows Important-level tolerance).
- If only Suggestions exist → Overall Assessment = Approved.
- Spec compliance FAIL requires at least one missing or incorrectly implemented requirement.
