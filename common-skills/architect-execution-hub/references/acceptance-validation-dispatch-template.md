# Acceptance Validation Dispatch Template

Use this template when dispatching `sdlc-acceptance-validator` via the Task tool in Phase 4.

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

GIT CONTEXT:
- Branch: [branch name, if applicable]
- Base commit: [commit hash before story execution started, if available]
- Diff command: git diff <base>..HEAD
[If git context is not available, the validator should use git log to identify
story-related commits and construct the diff independently. Use the diff to
scope the file search — check changed files first before searching the full codebase.]

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
1. Load the acceptance-validation skill (skills/acceptance-validation/).
2. Use git diff to identify changed files (scoping), staging doc for planned file
   references (context). Search these first when mapping criteria to code.
3. If PRIOR ACCEPTANCE CONTEXT is provided, review it first. Focus fresh verification
   on previously-failed criteria and any files changed since the prior run.
4. For EACH criterion above:
   a. Identify the implementing code (file:line) — search scoped files first.
   b. Determine a verification command or inspection.
   c. Run the verification fresh — do not trust prior results.
   d. Record evidence (command output, exit code).
5. Check documentation completeness (staging doc populated, file references valid).
   Documentation gaps are NEEDS_CLEANUP notes, not acceptance blockers.
6. For any FAIL or UNABLE TO VERIFY criterion, produce failure guidance:
   why it failed and specific suggested remediation steps.
7. Generate validation report using the skill's report template.

IRON LAW: Default verdict is INCOMPLETE for functional criteria. Every criterion must
be individually verified with fresh evidence. No assumptions, no rationalizations.
Documentation issues do not block a COMPLETE verdict.

DENY:
- Modifying any code — this is a read-only verification role.
- Marking any criterion as N/A without user approval.
- Accepting simplified versions of requirements.
- Deferring in-scope work to future iterations.

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Verdict: COMPLETE or INCOMPLETE.
2. Per-criterion evidence table.
3. Documentation completeness status.
4. Failure guidance (on INCOMPLETE): per-criterion root cause and suggested remediation.
5. Any deviations from plan detected.

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
