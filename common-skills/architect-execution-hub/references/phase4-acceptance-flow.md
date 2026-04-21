# Phase 4: Acceptance Validation

`checkpoint.sh execution --phase 4`

Independent verification that every acceptance criterion was implemented. Uses git diff for scoping, staging doc for context, then drills into code and runs fresh commands for evidence. Produces failure guidance on INCOMPLETE.

The validator has a narrow, positively-defined write scope enforced by its own permission schema and spec: `docs/staging/**/evidence/**`, `docs/staging/**/*.evidence.md`, and `docs/staging/**/*.skill-gotchas.md`. Everything else — implementation code, tests, context caches, staging-doc narrative, per-task context docs — is out of mandate and blocked by the agent's edit allowlist. The hub does not police the validator further; dispatch-level scope enforcement is the validator's own responsibility.

1. Dispatch `sdlc-acceptance-validator` using [`acceptance-validation-dispatch-template.md`](acceptance-validation-dispatch-template.md).
2. Include git context (branch, base commit) for diff scoping. Populate the GIT CONTEXT section in the dispatch template using `branch_name` and `base_commit` from `execution.yaml`.
3. Validator maps every criterion to code + evidence, persists evidence under `docs/staging/<story>/evidence/AC-N/`, writes the validation report to `docs/staging/<story>/validation-report.evidence.md`, and produces failure guidance for any FAIL criteria.
4. Read the validation report.

**GATE**: Verdict is COMPLETE. If INCOMPLETE:

1. Read `acceptance_iteration` from `execution.yaml` (tracked via `checkpoint.sh execution --acceptance-iteration N`).
2. If `acceptance_iteration >= 2`: **STOP.** Do NOT dispatch another remediation or acceptance run. Return to coordinator with ESCALATE verdict, all acceptance reports attached, and recommendation for user review.
3. If `acceptance_iteration < 2`: Create targeted remediation tasks for **FUNCTIONAL failures only** (ignore NEEDS_CLEANUP doc notes). Increment `acceptance_iteration` via `checkpoint.sh execution --acceptance-iteration {N+1}`. After remediation fixes are applied, **commit the fixes**: `checkpoint.sh git --commit --story {US-NNN-name} --message "Fix failing acceptance criteria" --phase 4`. Re-run acceptance with PRIOR ACCEPTANCE CONTEXT from the dispatch template.

**HARD LIMIT**: The architect MUST NOT run more than 2 acceptance re-validations (3 total runs). This limit is non-negotiable. Violating it is a protocol error.

## Doc-Only Remediation (fast path)

If the acceptance verdict is COMPLETE but `doc_status` is NEEDS_CLEANUP:

1. The architect applies documentation fixes directly (staging doc edits only).
2. No implementer dispatch, no code review, no QA required for doc-only changes.
3. Log the fix in the staging document's Issues & Resolutions table.
4. Proceed directly to Phase 5.

This avoids full remediation cycles for markdown formatting issues.
