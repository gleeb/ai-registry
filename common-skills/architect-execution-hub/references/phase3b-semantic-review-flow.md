# Phase 3b: Semantic Review (Commercial Mentor)

`checkpoint.sh execution --phase 3b`

Commercial-model senior-developer quality review with 3 checks (agent report integrity, code quality review, terminology alignment). Uses git diff for scoping, staging doc for context, then drills into the actual implementation.

1. `checkpoint.sh execution --phase 3b --step semantic-review`
2. Dispatch `sdlc-semantic-reviewer` using [`semantic-reviewer-dispatch-template.md`](semantic-reviewer-dispatch-template.md).
3. Include all local review verdicts, QA verdicts, and implementer summaries from the story.
4. Include git context (branch, base commit) for diff scoping. Populate the GIT CONTEXT section in the dispatch template using `branch_name` and `base_commit` from `execution.yaml`.
5. Include the tech stack for documentation fetching context via context7 MCP.
6. Read the semantic review result:
   - **PASS:** `checkpoint.sh execution --phase 3b --verdict pass`. Proceed to Phase 4. Optionally attach proactive observations to the acceptance validator dispatch.
   - **NEEDS WORK:** Extract the guidance package. Re-enter Phase 2 for affected tasks with guidance-aware re-dispatch — include the `SEMANTIC GUIDANCE` section in the implementer dispatch containing reasoned corrections, documentation (fetched excerpts and/or fetch instructions for the local model to retrieve via context7), and improvement instructions. After fixes, **commit the remediation**: `checkpoint.sh git --commit --story {US-NNN-name} --message "Address semantic review findings" --phase 3b`. Then restart from Phase 3 (full-story review + QA) then re-dispatch semantic reviewer (iteration 2).
   - **NEEDS WORK with escalation flag (work unreliable):** Halt execution. Escalate to coordinator and user — the local model may not be capable of this task and it may need reassignment.

**GATE**: Semantic review PASS. Max 2 iterations before escalating to coordinator.

**Guidance propagation:** When re-dispatching implementer after semantic review NEEDS WORK, include the guidance package in a `SEMANTIC GUIDANCE` section. This propagates commercial-model reasoning into the local model's next attempt. See [`re-dispatch-patterns.md`](re-dispatch-patterns.md) for the Guidance-Aware Re-dispatch pattern.
