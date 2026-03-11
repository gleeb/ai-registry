# Meta-Validation

## Overview

The validator validates its own report before completion. Before writing the final report and returning, run these meta-validation checks on the report itself.

## Meta-Validation Checks

### Every Finding Has Evidence

- For each finding (PASS or FAIL), verify the report includes:
  - What was checked.
  - What evidence was examined (specific documents, sections).
  - What was found.
- **Failure action:** Add evidence or downgrade the finding. Do not leave findings without evidence.

### No Check Marked PASS Without Evidence

- A PASS must cite specific content that proves the check.
- "References exist" or "looks aligned" is insufficient.
- **Failure action:** Either add specific evidence or change to NEEDS WORK.

### Report Has Observations Section

- Every report must include an Observations section.
- It must contain at least one item (non-blocking observation, question, or area for deeper review).
- **Failure action:** Add observations. Ask "What did I NOT check?" and document it.

### Traceability Coverage Is Calculated

- For Phase and Cross-Story modes, the report must include a traceability coverage percentage.
- Formula: `Coverage = TRACED / (TRACED + UNTRACED + PARTIALLY_TRACED) * 100%`
- **Failure action:** Calculate and add coverage. If not applicable (e.g., Per-Story), note why.

### Recommendation Is Actionable

- The recommendation must be specific: "Proceed to Phase 4" or "Re-dispatch API agent for US-003" or "Escalate to Hub: contract ownership dispute."
- Vague recommendations ("review and fix") are insufficient.
- **Failure action:** Replace with specific, actionable recommendation.

---

## Meta-Validation Process

1. Draft the validation report.
2. Run all meta-validation checks on the draft.
3. For each failure: fix the report.
4. Re-run meta-validation until all checks pass.
5. Write final report and return.

---

## Self-Validation Schedule

- Run meta-validation immediately before writing the final report.
- Do not skip — a report that fails meta-validation must not be delivered.
- If time-constrained, reduce validation scope (and note in report) rather than deliver an invalid report.
