# User Acceptance Protocol

Phase 6 — present the completed story to the user for final approval.

## Presentation Format

Present to the user via `attempt_completion` with this structure:

```
## Story Complete: US-NNN — [Story Title]

### Implementation Summary
[2-3 sentence overview of what was built]

### Tasks Completed
| # | Task | Files | Status |
|---|------|-------|--------|
| 1 | [task name] | [key files] | Done |
| 2 | ... | ... | ... |

### Acceptance Criteria Verification
| # | Criterion | Status | Evidence |
|---|-----------|--------|----------|
| 1 | [criterion text] | PASS | [brief evidence summary] |
| 2 | ... | ... | ... |

### Deviations from Plan
[List any deviations with justification, or "None — implementation matches plan exactly"]

### Documentation
- Staging doc: [path]
- Updated docs: [list of permanent docs updated in Phase 5]

### Next Steps
[Any follow-up items, related stories, or known future work]
```

## User Response Handling

### User Approves
- Mark story as completed in the staging doc
- Return to coordinator with completion summary

### User Requests Changes
- Document the change requests in the staging doc
- Create targeted tasks from the change requests
- Re-enter Phase 2 with the new tasks
- After changes, skip directly to Phase 4 (acceptance validation) for the changed criteria
- Present again for user acceptance

### User Rejects
- Document rejection reason in staging doc
- Escalate to coordinator with rejection details
- Do not attempt to fix without coordinator guidance
