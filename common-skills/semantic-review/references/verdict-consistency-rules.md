# Verdict Consistency Rules

Enumeration of contradiction patterns to detect in local model review and QA outputs.

---

## Code Reviewer Contradictions

| Pattern | Contradiction Type | Severity |
|---------|-------------------|----------|
| Spec Compliance = PASS, Overall Assessment = Changes Required | Direct contradiction | Critical |
| Spec Compliance = FAIL, Overall Assessment = Approved | Direct contradiction | Critical |
| Overall Assessment = Approved, but Critical issues listed | Verdict-findings mismatch | Critical |
| Overall Assessment = Approved, but Important issues listed (without explicit tolerance) | Verdict-findings mismatch | Important |
| Overall Assessment = Changes Required, but no issues listed | Empty rejection | Important |
| Same issue type categorized as Critical in one task, Suggestion in another | Inconsistent severity | Important |
| Review claims files were checked but file:line references point to non-existent files | Phantom references | Critical |

## QA Verifier Contradictions

| Pattern | Contradiction Type | Severity |
|---------|-------------------|----------|
| Verification Status = PASS, but one or more criteria marked FAIL | Status-criteria mismatch | Critical |
| Verification Status = FAIL, but all criteria marked PASS | Status-criteria mismatch | Critical |
| Criterion marked PASS, but evidence shows non-zero exit code | Evidence-verdict mismatch | Critical |
| Criterion marked PASS, but no command output provided | Missing evidence | Important |
| Command listed as "run" but output is generic help text (e.g., `--help` output) | Verification evasion | Important |
| Same verification command produces different results for same criterion across tasks | Inconsistent environment | Important |

## Cross-Agent Contradictions

| Pattern | Contradiction Type | Severity |
|---------|-------------------|----------|
| Reviewer approves, but QA finds failures in the same scope | Review missed defects | Important |
| QA passes, but reviewer flagged unresolved Critical issues | QA bypassed review findings | Critical |
| Implementer claims file created, but reviewer says file doesn't exist | Agent scope mismatch | Critical |
| Reviewer found issues in files not in implementer's summary | Scope expansion | Important |

## Interpretation Notes

- A single Critical contradiction triggers NEEDS WORK verdict.
- Multiple Important contradictions (3+) trigger NEEDS WORK verdict.
- Individual Important contradictions are flagged as observations unless they form a pattern.
- Verification evasion (running `--help` instead of actual tests) is a strong signal of capability limitations — guide toward correct commands rather than escalating.
