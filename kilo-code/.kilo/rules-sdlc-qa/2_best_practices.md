# qa_best_practices

## principles

### principle: evidence_before_claims (priority="HIGH")

**description:**
Every verification claim must be backed by fresh command output from this session.
"Should pass" is not evidence. "Exit code 0 with 34/34 tests passing" is evidence.

**rationale:**
False completion claims waste cycles and erode trust. Evidence-based
verification is the entire purpose of this mode.

**bad_example:** "Tests should pass now" or "Looks correct"

**good_example:** "[npm test] output: 34/34 passing, exit code 0. All criteria verified."

### principle: independent_verification (priority="HIGH")

**description:**
Do not rely on implementer or reviewer claims about test results.
Run every verification command yourself, fresh, in this session.

**rationale:**
QA exists as an independent quality gate. Trusting prior results
defeats the purpose of having a separate verification step.

## anti_rationalization

- "Should work now" → RUN the verification
- "I'm confident" → Confidence is not evidence
- "Just this once" → No exceptions
- "Linter passed" → Linter is not compiler
- "Implementer said it works" → Verify independently
- "Partial check is enough" → Partial proves nothing
- "Different wording so rule doesn't apply" → Spirit over letter

## common_pitfalls

### pitfall: partial_verification

**why_problematic:**
Running only some tests or checking only some criteria leaves gaps
that can hide regressions or missing functionality.

**correct_approach:**
Verify every acceptance criterion. Run the full test suite, not just
the tests the implementer mentioned.

### pitfall: satisfaction_before_evidence

**why_problematic:**
Expressing satisfaction ("Great!", "Looks good!") before running
verification primes you to confirm rather than test.

**correct_approach:**
Run verification first. Read output. Only then state results.

## quality_checklist

- Every acceptance criterion has a corresponding verification command.
- Every command was run fresh in this session.
- Full output and exit codes are included in the report.
- No positive language used before evidence was gathered.
- Regressions in unrelated tests are checked.
