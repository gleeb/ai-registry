# User Acceptance Protocol

Phase 6 — conditionally present the completed story to the user, or auto-approve when safe.

## Auto-Approve Path

When ALL of the following conditions are true, skip user presentation and auto-approve:

- Story has no Review Milestone with trigger "after all tasks" or "phase 6"
- Acceptance validation verdict is COMPLETE
- No deviations from plan were recorded in the staging doc

Auto-approve actions:

1. Mark story as completed in the staging doc.
2. Record "Auto-approved: no milestones, acceptance COMPLETE, no deviations" in the staging doc's Issues & Resolutions table.
3. Merge story branch and return to coordinator with completion summary.

If any condition is false, proceed to the Presentation Format below.

## Presentation Format

Present the following structure to the user in your final summary to the parent agent:

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

## Milestone Integration

If a Review Milestone has trigger "after all tasks" or "phase 6":

1. Execute the milestone's Action before presenting the report.
2. Include the milestone output (command results, screenshots, URLs) in the presentation under a `### Milestone Results` section.
3. The user verifies the milestone's Verify criteria as part of their acceptance decision.

## User Response Handling

### User Approves
- Mark story as completed in the staging doc
- Mark any Phase 6 milestones as `user-approved` in the staging doc
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
