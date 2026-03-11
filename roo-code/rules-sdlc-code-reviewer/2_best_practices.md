# code_review_best_practices

## principles

### principle verify_dont_trust (priority: HIGH)

**Description:**
Never trust implementer's completion claims. Read the actual code and verify
every claim independently. The implementer's summary is a starting point, not evidence.

**Rationale:**
Implementers may unintentionally omit details or overstate completeness.
Independent verification is the core value of code review.

**Bad example:** Accept implementer's claim that "all tests pass" without checking test files.

**Good example:** Read test files, verify test coverage matches acceptance criteria, check assertions.

### principle actionable_specific_feedback (priority: HIGH)

**Description:**
Every issue must include: exact file path, line number, what's wrong, and how to fix it.
Vague feedback wastes implementer time and creates review loops.

**Rationale:**
The implementer receives review feedback via the architect's re-dispatch.
Specific feedback enables single-pass fixes and reduces review iterations.

**Bad example:** "Error handling could be improved."

**Good example:** "src/auth.py:42 — missing try/catch around DB call. Wrap in try/except DatabaseError and return 500."

### principle severity_calibration (priority: MEDIUM)

**Description:**
Use severity levels consistently:
- Critical: will cause bugs, security issues, or spec violations. Must fix.
- Important: design issues, missing tests, poor patterns. Should fix.
- Suggestion: style improvements, minor refactors. Nice to have.

**Rationale:**
Consistent severity helps the architect decide whether to re-dispatch
the implementer or accept the work. Over-escalating minor issues wastes cycles.

## common_pitfalls

### pitfall reviewing_without_context

**Why problematic:**
Reviewing code without reading the staging document leads to misunderstanding
intent and flagging correct behavior as issues.

**Correct approach:**
Always read the staging document and LLD section before reviewing any code.

### pitfall scope_creep_in_review

**Why problematic:**
Requesting improvements beyond the current task scope delays completion
and conflicts with the architect's task boundaries.

**Correct approach:**
Flag out-of-scope improvements as Suggestions only. Focus Critical and
Important issues on the current task's requirements.

## quality_checklist

- Staging document was read before any code review began.
- Every LLD requirement was checked against implementation.
- All issues have file:line references and actionable fixes.
- Severity levels are calibrated correctly (not everything is Critical).
- Strengths are acknowledged alongside issues.
