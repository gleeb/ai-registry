# Acceptance Validation Report Template

Use this template when generating the acceptance validation report.

## Template

```markdown
# Acceptance Validation Report — US-NNN

**Story**: `plan/user-stories/US-NNN-name/story.md`
**Staging Doc**: `docs/staging/US-NNN-name.md`
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
- **Documentation**: [COMPLETE / INCOMPLETE]
- **Overall verdict**: COMPLETE / INCOMPLETE

## Deviations from Plan

[List any deviations from the original plan with justification, or "None detected"]
```

## Verdict Rules

- ALL criteria PASS + documentation COMPLETE → COMPLETE
- ANY criterion FAIL → INCOMPLETE
- ANY criterion UNABLE TO VERIFY → INCOMPLETE (escalate for manual check)
- Documentation INCOMPLETE → INCOMPLETE
