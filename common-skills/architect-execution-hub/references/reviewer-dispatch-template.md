# Code Reviewer Dispatch Template

Use this template when dispatching `sdlc-code-reviewer` via the Task tool.

**Architect**: Before sending this dispatch, log it via `checkpoint.sh dispatch-log --event dispatch`. After the reviewer returns, log the response via `checkpoint.sh dispatch-log --event response`.

## Required Message Structure

```
REVIEW TASK: [Task ID] — [Task Name]

STAGING DOCUMENT: [exact path to docs/staging/US-NNN-*.md]
Read the staging document first to understand the architecture plan and LLD for this task.

LLD SECTION:
[Paste or reference the specific LLD section/requirements for this task]

IMPLEMENTER SUMMARY:
[Paste the implementer's final summary returned to the parent agent — files changed, what was done]

TECH SKILLS:
- [skill-name] (path: skills/[skill-name]/)
  Verify implementation follows this skill's patterns and performance budgets.
[Include all tech skills from the implementer dispatch. Omit section if none.]

SECURITY REVIEW: [true/false]
If true, load skills/security-review/ and include a "## Security Review"
section in the review output with findings categorized by severity.

REVIEW SCOPE:
1. Spec compliance: Does implementation match the LLD requirements?
2. Code quality: Patterns, error handling, naming, tests.
3. Architecture: Integration, separation of concerns.
4. Security (if SECURITY REVIEW is true): OWASP, secrets, input validation, auth.

DOCUMENTATION CHECK (scoped to this task only):
- Verify the staging document exists and is current.
- Check that new/modified files from the IMPLEMENTER SUMMARY above are listed in the
  staging doc's "Implementation File References" section.
- Check that technical decisions for THIS task have rationale documented.
- Flag stale or missing documentation references as Important issues.
- Do NOT flag files listed under other tasks or planned for future implementation.
  Only verify files the implementer claims to have created or modified in this task.

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Spec Compliance: PASS or FAIL (does implementation match LLD requirements?).
2. Issues: categorized as Critical / Important / Suggestion with file:line references.
3. Security Review (if applicable): findings by severity.
4. Documentation Status: current / stale / missing references.
5. Overall Assessment: Approved or Changes Required (final verdict — this is what the
   architect acts on. NEVER use PASS/FAIL here. Must be consistent with issues found:
   any Critical or Important issues → Changes Required; only Suggestions → Approved).

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Final Story Review Variant

For the final full-story review after all tasks complete (Phase 3), modify:

```
REVIEW SCOPE: Full story — holistic review of all implemented tasks.
Focus on cross-task integration, overall architecture adherence, and consistency.

SECURITY REVIEW: [true — if any individual task had security review enabled]

TASK SUMMARIES:
[Combined summaries from all implementation units]
```
