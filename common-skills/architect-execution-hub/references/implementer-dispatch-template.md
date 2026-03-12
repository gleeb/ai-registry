# Implementer Dispatch Template

Use this template when dispatching `sdlc-implementer` via `new_task`.

## Required Message Structure

```
TASK: [Task ID] — [Task Name]

SPECIFICATION:
- [Function signatures and parameters]
- [Interface definitions]
- [File paths for each change]
- [Dependencies on prior tasks]

ACCEPTANCE CRITERIA:
- [Testable condition 1]
- [Testable condition 2]

TECH SKILLS:
- [skill-name] (path: common-skills/[skill-name]/)
  Load and apply patterns from this skill during implementation.
[Include all tech skills identified in Phase 0. Omit section if no tech skills apply.]

STAGING DOCUMENT: [exact path to docs/staging/US-NNN-*.md]

DOCUMENTATION:
- Update the staging document with progress after each significant change.
- Document all technical decisions with rationale in the staging doc's
  "Technical Decisions & Rationale" section.
- Record all created/modified files in the staging doc's
  "Implementation File References" section.
- Document any issues encountered and their resolutions in the
  "Issues & Resolutions" table.

BOUNDARIES:
- IN SCOPE: [what to implement]
- OUT OF SCOPE: [what NOT to implement]
- Do not expand scope beyond this task specification.

CONTEXT:
- Read the staging document for architecture rationale and decisions.
- [Any additional context from prior tasks]

SELF-VERIFICATION:
Before attempt_completion:
1. Load the verification-before-completion skill (common-skills/verification-before-completion/).
2. For each acceptance criterion above, identify a verification command and run it fresh.
3. If any criterion fails verification, fix it before claiming completion.
4. Include verification evidence (commands + outputs) in the completion summary.

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Code-change summary: files created/modified with brief description.
2. Verification evidence: per-criterion command + output + PASS/FAIL.
3. Staging doc updates: confirm documentation was updated.
4. Any blockers encountered.

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Re-dispatch (after review feedback)

When re-dispatching after code review rejection, add:

```
REVIEW FEEDBACK (iteration [N]/3):
The following issues were identified by code review. Fix ONLY these issues:

[Paste reviewer's exact issue list with file:line references and recommended fixes]

Do not make changes beyond the listed issues.
Update the staging document with the review feedback and fixes applied.
```
