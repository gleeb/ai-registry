# QA Verifier Dispatch Template

Use this template when dispatching `sdlc-qa` via `new_task`.

## Required Message Structure

```
VERIFY TASK: [Task ID] — [Task Name]

STAGING DOCUMENT: [exact path to docs/staging/T-{issue}-*.md]
Read the staging document for acceptance criteria and expected behavior.

ACCEPTANCE CRITERIA:
1. [Testable condition 1]
2. [Testable condition 2]
3. [Testable condition 3]

SUGGESTED VERIFICATION COMMANDS:
- [test command for criterion 1]
- [build command if applicable]
- [any other verification commands]

IRON LAW: No completion claims without fresh verification evidence.
Run every command fresh. Do not trust prior results or implementer claims.

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Verification Status: PASS / FAIL.
2. Per-criterion results: criterion → command → output → PASS/FAIL.
3. Evidence: full command outputs and exit codes.
4. Any regressions or unexpected failures.

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Final Issue Verification Variant

For the final full-issue verification after all tasks complete:

```
VERIFY: Full issue — all acceptance criteria across all tasks.
Run full test suite and verify all criteria end-to-end.
```
