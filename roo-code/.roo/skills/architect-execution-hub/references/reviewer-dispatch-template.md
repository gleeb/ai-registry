# Code Reviewer Dispatch Template

Use this template when dispatching `code-reviewer` via `new_task`.

## Required Message Structure

```
REVIEW TASK: [Task ID] — [Task Name]

STAGING DOCUMENT: [exact path to docs/staging/T-{issue}-*.md]
Read the staging document first to understand the architecture plan and LLD for this task.

LLD SECTION:
[Paste or reference the specific LLD section/requirements for this task]

IMPLEMENTER SUMMARY:
[Paste the implementer's attempt_completion result — files changed, what was done]

REVIEW SCOPE:
1. Spec compliance: Does implementation match the LLD requirements?
2. Code quality: Patterns, error handling, naming, tests.
3. Architecture: Integration, separation of concerns.

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Spec Compliance: PASS / FAIL with specific gaps.
2. Issues: categorized as Critical / Important / Suggestion with file:line references.
3. Overall Assessment: Approved / Changes Required.

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Final Issue Review Variant

For the final full-issue review after all tasks complete, modify:

```
REVIEW SCOPE: Full issue — holistic review of all implemented tasks.
Focus on cross-task integration, overall architecture adherence, and consistency.

TASK SUMMARIES:
[Combined summaries from all implementation units]
```
