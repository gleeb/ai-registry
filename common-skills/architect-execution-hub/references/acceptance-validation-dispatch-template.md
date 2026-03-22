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

INSTRUCTIONS:
1. Load the acceptance-validation skill (common-skills/acceptance-validation/).
2. For EACH criterion above:
   a. Identify the implementing code (file:line).
   b. Determine a verification command or inspection.
   c. Run the verification fresh — do not trust prior results.
   d. Record evidence (command output, exit code).
3. Check documentation completeness (staging doc populated, file references valid).
4. Generate validation report using the skill's report template.

IRON LAW: Default verdict is INCOMPLETE. Every criterion must be individually verified
with fresh evidence. No assumptions, no trust in prior results, no rationalizations.

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
