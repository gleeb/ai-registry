# Phase 2: Per-Task Dev Loop

`checkpoint.sh execution --phase 2`

For each implementation unit in the task checklist:

1. `checkpoint.sh execution --task "{id}:{name}" --step implement` (write-ahead)
2. **Infrastructure check**: Read the task's dependencies against the story's `## Integration Strategy` table. If any dependency for this task has `level: real` or `level: realize`:
   a. `checkpoint.sh dispatch-log --event dispatch ... --agent sdlc-devops --dispatch-id exec-{story}-t{id}-devops-i1`
   b. Dispatch `@sdlc-devops` using [`devops-dispatch-template.md`](devops-dispatch-template.md) with the required infrastructure.
   c. `checkpoint.sh dispatch-log --event response --dispatch-id exec-{story}-t{id}-devops-i1 --agent sdlc-devops --verdict "{SUCCESS|FAILURE}"`
   d. On success: read the infrastructure manifest and fold connection details into the implementer dispatch's `INTEGRATION CONTEXT` section.
   e. On failure: record the blocker in the staging doc. If the DevOps agent provides resolution guidance, re-dispatch once. If still failing, HALT and escalate to coordinator.
3. `checkpoint.sh dispatch-log --event dispatch --story {US-NNN} --hub execution --phase 2 --task "{id}:{name}" --agent sdlc-implementer --model-profile {profile} --dispatch-id exec-{story}-t{id}-impl-i{N} --iteration {N}`
4. **Implement** → dispatch `sdlc-implementer` using [`implementer-dispatch-template.md`](implementer-dispatch-template.md). If the DevOps agent was dispatched in step 2, include the infrastructure manifest details in the `INTEGRATION CONTEXT` section.
4. `checkpoint.sh dispatch-log --event response --dispatch-id exec-{story}-t{id}-impl-i{N} --agent sdlc-implementer --duration {seconds} --summary "{excerpt}"`
4b. **Implementation Completeness Gate**: Read the implementer's return message STATUS field:
   - `STATUS: BLOCKED` → Skip review. Record blocker in staging doc. Re-dispatch with resolution context or escalate.
   - `STATUS: PARTIAL` → Skip review. Re-dispatch implementer with focused instructions for missing ACs (counts as iteration).
   - `STATUS: COMPLETE` → Verify `git diff --stat` shows changes to expected files. If zero changes, skip review and re-dispatch with "no code changes detected."
   Only proceed to step 5 when STATUS is COMPLETE AND file changes exist.
4c. **Documentation Evidence Gate**: If the dispatch included `EXTERNAL LIBRARIES`, verify the implementer's completion summary includes a `## context7 Lookups` section. If missing, re-dispatch with documentation-search-only focus (counts as iteration).
5. `checkpoint.sh execution --step review --iteration 1`
6. `checkpoint.sh dispatch-log --event dispatch ... --agent sdlc-code-reviewer --dispatch-id exec-{story}-t{id}-review-i{N}`
7. **Review** → dispatch `sdlc-code-reviewer` using [`reviewer-dispatch-template.md`](reviewer-dispatch-template.md)
8. `checkpoint.sh dispatch-log --event response --dispatch-id exec-{story}-t{id}-review-i{N} --agent sdlc-code-reviewer --verdict "{Approved|Changes Required}"`
9. On review pass: `checkpoint.sh execution --step qa`
10. `checkpoint.sh dispatch-log --event dispatch ... --agent sdlc-qa --dispatch-id exec-{story}-t{id}-qa-i{N}`
11. **Verify** → dispatch `sdlc-qa` using [`qa-dispatch-template.md`](qa-dispatch-template.md)
12. `checkpoint.sh dispatch-log --event response --dispatch-id exec-{story}-t{id}-qa-i{N} --agent sdlc-qa --verdict "{PASS|FAIL}"`
13. On QA pass: `checkpoint.sh execution --task-done {id}`
14. **Git commit**: `checkpoint.sh git --commit --story {US-NNN-name} --task "{id}:{name}" --phase 2`
15. **Review Milestone check**: Read the staging doc's Review Milestones table. If any milestone's Trigger matches this task: execute its Action, update Status to `triggered`, return to coordinator with MILESTONE_PAUSE and the milestone output. On resume, mark `user-approved` and continue.

On review fail (re-dispatch implementer): `checkpoint.sh execution --step implement` then increment iteration on next review: `checkpoint.sh execution --step review --iteration {N}`

See [`review-cycle.md`](review-cycle.md) for iteration limits, security review integration, and escalation rules.
