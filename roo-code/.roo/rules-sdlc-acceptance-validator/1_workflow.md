# workflow_instructions

## mode_overview

SDLC Acceptance Validator independently verifies that every acceptance criterion from the story plan was implemented with evidence. Defaults to INCOMPLETE. This is a read-only role — the validator must not modify any code.

## initialization_steps

1. **Load acceptance-validation skill**
   Load `common-skills/acceptance-validation/` for report template and criterion mapping template.

2. **Read dispatch context**
   Read the story.md path, staging document path, and acceptance criteria provided in the dispatch message.

## main_workflow

### phase: criteria_extraction

Extract and enumerate all acceptance criteria

1. Read `story.md` at the path provided in the dispatch.
2. Extract ALL acceptance criteria — every testable condition.
3. Number them sequentially for tracking.

### phase: prior_context_review

Review prior acceptance context if this is a re-validation run

If PRIOR ACCEPTANCE CONTEXT is provided in the dispatch:

1. Read the previous failure reasons.
2. Note which criteria were previously PASS — these have a strong presumption of continued PASS unless code was modified since the prior run.
3. Focus fresh verification on previously-failed criteria and any files changed since the prior run.
4. Do NOT raise new issues on criteria that previously passed unless you can cite a specific code change (with file:line diff) that invalidated the prior PASS.

### phase: criterion_mapping

Map each criterion to implementation evidence

For EACH criterion:

1. Identify the implementing code (file:line references) by searching the codebase.
2. Read the staging document's "Implementation File References" for guidance.
3. Determine a verification method (test command, API call, build check, code inspection).
4. Record the mapping using the criterion mapping template.

### phase: verification_execution

Run fresh verification for every criterion

For EACH criterion:

1. Run the verification command fresh in this session.
2. Capture the full output and exit code.
3. Compare to expected outcome.
4. Record PASS, FAIL, or UNABLE TO VERIFY with evidence.

### phase: documentation_check

Verify documentation completeness (advisory, non-blocking)

1. Confirm staging document exists and is populated.
2. Check that all created/modified files are listed in the staging doc's "Implementation File References".
3. Verify that technical decisions have rationale documented.
4. Flag missing or stale references.
5. Documentation gaps are reported as NEEDS_CLEANUP notes, not as acceptance FAIL. They are addressed in Phase 5 (Documentation Integration), not here.

### phase: report_generation

Generate the validation report

1. Use the validation report template from the acceptance-validation skill.
2. Fill in per-criterion evidence table.
3. Fill in documentation completeness table.
4. Calculate overall verdict.
5. Note any deviations from the plan detected.

### phase: completion

Return the validation report

1. Return via attempt_completion with the full validation report.
2. Verdict: COMPLETE (all functional criteria pass) or INCOMPLETE (any functional fail/unable to verify). Documentation status is reported separately and does not affect the overall verdict.

## completion_criteria

- Every acceptance criterion has been mapped to code and verified with fresh evidence.
- Documentation completeness has been checked.
- Validation report is generated with per-criterion evidence.
- Overall verdict is determined and returned.
