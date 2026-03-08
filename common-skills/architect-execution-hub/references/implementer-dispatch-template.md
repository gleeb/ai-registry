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

STAGING DOCUMENT: [exact path to docs/staging/T-{issue}-*.md]

BOUNDARIES:
- IN SCOPE: [what to implement]
- OUT OF SCOPE: [what NOT to implement]
- Do not expand scope beyond this task specification.

CONTEXT:
- Read the staging document for architecture rationale and decisions.
- [Any additional context from prior tasks]

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Code-change summary: files created/modified with brief description.
2. Test results if applicable.
3. Any blockers encountered.

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Re-dispatch (after review feedback)

When re-dispatching after code review rejection, add:

```
REVIEW FEEDBACK (iteration [N]/3):
The following issues were identified by code review. Fix ONLY these issues:

[Paste reviewer's exact issue list with file:line references and recommended fixes]

Do not make changes beyond the listed issues.
```
