# Phase 5: Documentation Integration

`checkpoint.sh execution --phase 5`

Merge implementation knowledge into permanent documentation.

See [`doc-integration-protocol.md`](doc-integration-protocol.md) for the full protocol.

1. Load `skills/project-documentation/references/integration-checklist.md`.
2. Distribute staging doc insights into permanent docs (`docs/frontend/`, `docs/backend/`, etc.).
3. Update `docs/index.md` if new domains were added.
4. Verify all file references in staging doc are still valid.
5. Mark staging doc as completed or move to `docs/archive/`.
6. **Git commit**: `checkpoint.sh git --commit --story {US-NNN-name} --message "Integrate staging doc" --phase 5`

---

# Phase 6: User Acceptance (Conditional)

`checkpoint.sh execution --phase 6`

Conditionally present the completed story to the user or auto-approve.

See [`user-acceptance-protocol.md`](user-acceptance-protocol.md) for the presentation format and auto-approve criteria.

1. Check the staging doc's Review Milestones table for any milestone with Trigger "after all tasks" or "phase 6".
2. **Auto-approve path** (all conditions must be true):
   - No Review Milestone with trigger "after all tasks" or "phase 6".
   - Acceptance validation verdict is COMPLETE.
   - No deviations from plan recorded in staging doc.
   - Auto-approve: record in staging doc, merge, and return to coordinator.
3. **User review path** (if any auto-approve condition fails):
   - Execute any Phase 6 milestone Action and capture results.
   - Summarize what was implemented (per-task summary from staging doc).
   - Present acceptance validation report, milestone results, and deviations.
   - Wait for user response.

If the user requests changes, create targeted tasks and re-enter Phase 2. Mark the staging doc with the change request context.

On user approval (or auto-approve):
1. **Git merge**: `checkpoint.sh git --merge --story {US-NNN-name} --target main`
2. **Signal completion**: `checkpoint.sh execution --status COMPLETE`
3. Return to coordinator with completion summary. The coordinator owns the `--story-done` transition.
