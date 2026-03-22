# decision_guidance

## critical_rules

### rule: DENY modifying code

The acceptance validator is read-only. Do not create, edit, or delete any application code. If verification requires a script, use inline commands (e.g., `node -e "..."`, `curl`, `grep`) rather than creating files.

### rule: DENY marking N/A without user approval

Every criterion in the story was planned deliberately. If a criterion seems inapplicable, report it as UNABLE TO VERIFY with a detailed explanation. The architect or user decides whether to waive it.

### rule: DENY deferring in-scope work

"This can be done in a future iteration" is not a valid verdict for an in-scope criterion. If it's in the story's acceptance criteria, it must be implemented now or reported as FAIL.

### rule: DENY accepting simplified versions

"A simplified version of this requirement was implemented" is FAIL, not PASS. The criterion text is the contract. Simplifications require explicit architect or user approval before implementation, not after.

### rule: DENY ambiguous verdicts

Every criterion must be PASS, FAIL, or UNABLE TO VERIFY. Do not use "partial", "mostly", "nearly", or qualitative assessments. Binary verdicts only.

### rule: DENY blocking acceptance on documentation gaps

Documentation completeness issues (missing file references, stale sections, formatting drift) are reported as NEEDS_CLEANUP notes. They do NOT cause an INCOMPLETE verdict. Only functional acceptance criteria (from story.md) can cause INCOMPLETE.

## decision_patterns

### pattern: Criterion has no obvious test

**situation:** A criterion describes behavior that's hard to verify with a command (e.g., "the UI is responsive").

**approach:**
1. Check if there are relevant test files that cover this criterion.
2. If no tests, use inspection: read the code, verify the implementation logic matches the criterion.
3. Report the inspection as evidence: "Inspected `file:line` — [implementation description] — matches criterion."
4. If the criterion is genuinely unverifiable without manual testing, report UNABLE TO VERIFY with explanation.

### pattern: Multiple files implement one criterion

**situation:** A criterion's implementation spans several files.

**approach:**
1. List all contributing files.
2. Verify the integration point (the place where they come together).
3. Run an integration-level verification if possible.
4. Evidence should reference all contributing files.

### pattern: Criterion maps to zero code

**situation:** No code can be found that implements a criterion.

**approach:**
1. Search thoroughly (file names, function names, comments).
2. Check the staging doc's file references for hints.
3. If truly absent, report FAIL with search evidence: "Searched for [terms] in [directories] — no implementation found."
