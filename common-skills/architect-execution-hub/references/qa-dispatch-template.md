# QA Verifier Dispatch Template

Use this template when dispatching `sdlc-qa` via `new_task`.

**Architect**: Before sending this dispatch, log it via `checkpoint.sh dispatch-log --event dispatch`. After the QA verifier returns, log the response via `checkpoint.sh dispatch-log --event response`.

## Required Message Structure

```
VERIFY TASK: [Task ID] — [Task Name]

STAGING DOCUMENT: [exact path to docs/staging/US-NNN-*.md]
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

DOCUMENTATION VERIFICATION:
- Verify that file references in the staging doc's "Implementation File References"
  section point to files that actually exist on disk.
- Verify that created/modified files listed by the implementer actually exist.
- Flag any file reference mismatches as verification failures.

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Verification Status: PASS / FAIL.
2. Per-criterion results: criterion → command → output → PASS/FAIL.
3. Evidence: full command outputs and exit codes.
4. Documentation verification: file references valid / mismatches found.
5. Any regressions or unexpected failures.

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Final Story Verification Variant

For the final full-story verification after all tasks complete (Phase 3):

```
VERIFY: Full story — all acceptance criteria across all tasks.
Run full test suite and verify all criteria end-to-end.
Verify all file references in the staging document are valid.
```
