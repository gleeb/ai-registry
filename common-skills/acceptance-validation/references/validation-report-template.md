# Acceptance Validation Report Template

Use this template when generating the acceptance validation report.

## Template

```markdown
# Acceptance Validation Report — US-NNN

**Story**: `plan/user-stories/US-NNN-name/story.md`
**Staging Doc**: `docs/staging/US-NNN-name.md`
**Git Diff Scope**: [N files changed — list key files or reference the full diff]
**Verdict**: COMPLETE / INCOMPLETE

## Criteria Verification

| # | Criterion | Code Reference | Verification | Evidence | Status |
|---|-----------|---------------|--------------|----------|--------|
| 1 | [criterion text from story.md] | `file:line` | [command or inspection] | [output summary] | PASS / FAIL / UNABLE TO VERIFY |
| 2 | ... | ... | ... | ... | ... |

## Documentation Completeness

| Check | Status | Notes |
|-------|--------|-------|
| Staging doc exists and populated | PASS / FAIL | |
| All created files listed in staging doc | PASS / FAIL | [missing files if any] |
| All modified files listed in staging doc | PASS / FAIL | [missing files if any] |
| Technical decisions have rationale | PASS / FAIL | |
| Issues & Resolutions populated | PASS / FAIL / N/A | |

## Detailed Evidence

### Criterion 1: [criterion text]
**Code**: `path/to/file.ext:42-58`
**Verification command**:
\```
[exact command run]
\```
**Output**:
\```
[full output]
\```
**Exit code**: [0 or error code]
**Verdict**: PASS / FAIL / UNABLE TO VERIFY
**Notes**: [any relevant observations]

[Repeat for each criterion]

## Summary

- **Total criteria**: [N]
- **PASS**: [N]
- **FAIL**: [N]
- **UNABLE TO VERIFY**: [N]
- **Functional verdict**: COMPLETE / INCOMPLETE
- **Documentation status**: COMPLETE / NEEDS_CLEANUP
- **Overall verdict**: COMPLETE / INCOMPLETE

## Documentation Notes

[If doc_status is NEEDS_CLEANUP, list specific gaps here. These are informational notes
for Phase 5 (Documentation Integration), not acceptance blockers.]

## Failure Guidance

[For each FAIL or UNABLE TO VERIFY criterion, provide actionable remediation guidance.]

### Criterion [N]: [criterion text]
- **Why it failed:** [root cause — missing implementation, incorrect logic, test gap, etc.]
- **Suggested remediation:** [specific steps the implementer should take]
- **Files to modify:** [file paths involved]

[Repeat for each failing criterion. Omit this section if all criteria PASS.]

## Deviations from Plan

[List any deviations from the original plan with justification, or "None detected"]
```

## Verdict Rules

- ALL functional criteria PASS → **COMPLETE** (regardless of documentation status)
- ANY functional criterion FAIL → INCOMPLETE
- ANY functional criterion UNABLE TO VERIFY → INCOMPLETE (escalate for manual check)
- Documentation issues → doc_status: COMPLETE / NEEDS_CLEANUP (non-blocking)
- Documentation NEEDS_CLEANUP is reported as advisory notes for Phase 5, not a gate failure
