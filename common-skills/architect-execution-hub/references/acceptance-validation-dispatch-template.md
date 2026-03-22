# Acceptance Validation Dispatch Template

Use this template when dispatching `sdlc-acceptance-validator` via `new_task` in Phase 4.

**Architect**: Before sending this dispatch, log it via `checkpoint.sh dispatch-log --event dispatch`. After the acceptance validator returns, log the response via `checkpoint.sh dispatch-log --event response`.

## Required Message Structure

```
VALIDATE: US-NNN — [Story Title]

STORY: [exact path to plan/user-stories/US-NNN-name/story.md]

STAGING DOCUMENT: [exact path to docs/staging/US-NNN-name.md]
Read the staging document for implementation context, file references, and decisions.

ACCEPTANCE CRITERIA:
1. [Criterion 1 — copied exactly from story.md]
2. [Criterion 2]
3. [Criterion N]

PRIOR ACCEPTANCE CONTEXT (include only on re-validation, omit on first run):
- Iteration: [N] of max 2 re-validations
- Previous verdict: [INCOMPLETE]
- Previous failure reasons:
  [Paste the exact criterion-level failures from the prior acceptance report]
- Remediation applied:
  [Summarize what was fixed since the last acceptance run]

CONVERGENCE RULE: If a criterion that previously FAILED now has evidence of
remediation AND fresh verification passes, it MUST be marked PASS. Do not
re-interpret the criterion more strictly than the prior run. Do NOT raise new
failures on criteria that previously passed unless you can cite a specific code
change (with file:line diff) that invalidated the prior PASS.

INSTRUCTIONS:
1. Load the acceptance-validation skill (common-skills/acceptance-validation/).
2. If PRIOR ACCEPTANCE CONTEXT is provided, review it first. Focus fresh verification
   on previously-failed criteria and any files changed since the prior run.
3. For EACH criterion above:
   a. Identify the implementing code (file:line).
   b. Determine a verification command or inspection.
   c. Run the verification fresh — do not trust prior results.
   d. Record evidence (command output, exit code).
4. Check documentation completeness (staging doc populated, file references valid).
   Documentation gaps are NEEDS_CLEANUP notes, not acceptance blockers.
5. Generate validation report using the skill's report template.

IRON LAW: Default verdict is INCOMPLETE for functional criteria. Every criterion must
be individually verified with fresh evidence. No assumptions, no rationalizations.
Documentation issues do not block a COMPLETE verdict.

DENY:
- Modifying any code — this is a read-only verification role.
- Marking any criterion as N/A without user approval.
- Accepting simplified versions of requirements.
- Deferring in-scope work to future iterations.

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Verdict: COMPLETE or INCOMPLETE.
2. Per-criterion evidence table.
3. Documentation completeness status.
4. Any deviations from plan detected.

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
