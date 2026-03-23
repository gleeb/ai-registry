---
name: acceptance-validation
description: >
  Framework for verifying that every acceptance criterion from a user story was
  actually implemented with evidence. Use when the sdlc-acceptance-validator mode
  is dispatched after story integration passes, or when the architect needs to
  verify story completeness before user acceptance. Defaults to INCOMPLETE until
  all criteria are verified with fresh evidence. Uses a commercial model for
  thorough verification and actionable failure guidance.
---

# Acceptance Validation

## Overview

Independently verify that every acceptance criterion from the story plan was implemented. This is the final quality gate before documentation integration and user acceptance.

**Default verdict: INCOMPLETE.** Every criterion must be individually verified with fresh evidence to pass. No assumptions, no trust in prior results.

## Layered Scoping

The acceptance validator uses multiple inputs to locate implementing code efficiently:

- **Git diff** — scoping: identifies which files were changed during the execution cycle. Check these first.
- **Staging document** — context: provides planned file references, task decomposition, and AC-to-task mapping. Use this to narrow the search.
- **Full codebase search** — fallback: if git diff and staging doc don't surface the implementing code, search the full codebase.

Git diff and staging doc tell the validator WHERE to look. The actual verification is done by reading the code, running commands, and capturing evidence.

## Workflow

### 1. Extract Acceptance Criteria

- Read the story's `story.md` file (path provided in dispatch)
- Extract ALL acceptance criteria
- Read the staging document for implementation context and file references

### 2. Scope via Git Diff + Staging Doc

- Run `git diff` (or use GIT CONTEXT from dispatch) to identify all files changed during this story's execution cycle
- Read the staging document's file references for planned context
- Cross-reference: the changed file list + staging doc references form the primary search scope for criterion mapping
- If implementing code cannot be found in the scoped files, fall back to full codebase search

### 3. Map Criteria to Evidence

For EACH acceptance criterion:

1. **Identify implementing code** — search the scoped files (git diff + staging doc references) first, then fall back to full codebase. Find the specific file:line that implements this criterion.
2. **Identify verification method** — what command, test, or inspection proves it works
3. **Run verification** — execute the command fresh in this session
4. **Capture evidence** — record the command output, exit code, or observation

Use [`references/criterion-mapping-template.md`](references/criterion-mapping-template.md) for the mapping structure.

### 4. Check Documentation Completeness

- Staging document exists and is populated
- All created/modified files are listed in staging doc
- Technical decisions have rationale documented
- Issues & Resolutions table has entries (flag as suspicious if empty after non-trivial implementation)

### 5. Generate Report

Use [`references/validation-report-template.md`](references/validation-report-template.md) for the output format.

## Rules

### REQUIRE
- Map every acceptance criterion to specific code (file:line reference)
- Run every verification command fresh in this session
- Include full evidence (command output, exit codes) in the report
- Default to INCOMPLETE for functional criteria until proven otherwise
- Documentation completeness is reported but does not block a COMPLETE functional verdict
- On FAIL or UNABLE TO VERIFY: produce failure guidance explaining why the criterion failed and suggesting specific remediation steps

### DOC_CLEANUP
- Documentation gaps (missing file references, stale sections, formatting drift) are surfaced as NEEDS_CLEANUP notes in the report
- These notes are addressed in Phase 5 (Documentation Integration), not during acceptance validation
- Documentation status does not affect the overall COMPLETE/INCOMPLETE verdict

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

### GUIDANCE ON FAILURE
- For each criterion that is FAIL or UNABLE TO VERIFY, produce a brief guidance note:
  - **Why it failed** — root cause analysis (missing implementation, incorrect logic, test gap, etc.)
  - **Suggested remediation** — specific actionable steps the implementer should take to fix it
- This is lighter than the semantic reviewer's full guidance package but gives the architect actionable direction for targeted remediation tasks.

## References

- [`references/validation-report-template.md`](references/validation-report-template.md) — Report output format
- [`references/criterion-mapping-template.md`](references/criterion-mapping-template.md) — Per-criterion mapping structure
