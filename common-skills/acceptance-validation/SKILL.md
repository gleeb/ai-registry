---
name: acceptance-validation
description: >
  Framework for verifying that every acceptance criterion from a user story was
  actually implemented with evidence. Use when the sdlc-acceptance-validator mode
  is dispatched after story integration passes, or when the architect needs to
  verify story completeness before user acceptance. Defaults to INCOMPLETE until
  all criteria are verified with fresh evidence.
---

# Acceptance Validation

## Overview

Independently verify that every acceptance criterion from the story plan was implemented. This is the final quality gate before documentation integration and user acceptance.

**Default verdict: INCOMPLETE.** Every criterion must be individually verified with fresh evidence to pass. No assumptions, no trust in prior results.

## Workflow

### 1. Extract Acceptance Criteria

- Read the story's `story.md` file (path provided in dispatch)
- Extract ALL acceptance criteria
- Read the staging document for implementation context and file references

### 2. Map Criteria to Evidence

For EACH acceptance criterion:

1. **Identify implementing code** — find the specific file:line that implements this criterion
2. **Identify verification method** — what command, test, or inspection proves it works
3. **Run verification** — execute the command fresh in this session
4. **Capture evidence** — record the command output, exit code, or observation

Use [`references/criterion-mapping-template.md`](references/criterion-mapping-template.md) for the mapping structure.

### 3. Check Documentation Completeness

- Staging document exists and is populated
- All created/modified files are listed in staging doc
- Technical decisions have rationale documented
- Issues & Resolutions table has entries (flag as suspicious if empty after non-trivial implementation)

### 4. Generate Report

Use [`references/validation-report-template.md`](references/validation-report-template.md) for the output format.

## Rules

### REQUIRE
- Map every acceptance criterion to specific code (file:line reference)
- Run every verification command fresh in this session
- Include full evidence (command output, exit codes) in the report
- Default to INCOMPLETE until proven otherwise

### DENY
- Marking any criterion as N/A without explicit user approval
- Accepting "simplified versions" of requirements
- Trusting prior verification results — run everything fresh
- Using "should", "probably", or "seems to" in the report
- Modifying any code — this is a read-only verification role
- Deferring in-scope work to future iterations

### ESCALATION
- If a criterion cannot be verified (no test exists, no clear implementation), report it as UNABLE TO VERIFY with explanation — do not mark it as PASS or FAIL
- If a criterion is clearly not implemented, report FAIL with evidence of absence

## References

- [`references/validation-report-template.md`](references/validation-report-template.md) — Report output format
- [`references/criterion-mapping-template.md`](references/criterion-mapping-template.md) — Per-criterion mapping structure
