# Troubleshooting

## Checkpoint and Resume System

The SDLC uses a write-ahead checkpoint system that enables crash-safe resume across agents, models, and IDEs. State is stored in `.sdlc/` at the project root.

### State Files

```
<project>/.sdlc/
├── coordinator.yaml   # Active hub, current story, stories progress
├── planning.yaml      # Phase, story loop position, per-story agent progress
├── execution.yaml     # Phase, task, dev-loop step, iteration counts
└── history.log        # Append-only timestamped action log
```

### How Checkpoints Work

1. **Write-ahead pattern**: Before every sub-agent dispatch, the orchestrator calls `checkpoint.sh` to record "about to do X." If the agent dies mid-dispatch, the checkpoint reflects what was in progress.
2. **Post-completion update**: After every agent completes, the orchestrator updates the checkpoint with the result.
3. **Auto-bootstrap**: Scripts auto-create `.sdlc/` and YAML files on first invocation.

### Scripts

Both scripts are in the `sdlc-checkpoint` skill:
- Roo-Code path: `.roo/skills/sdlc-checkpoint/scripts/`
- Cursor path: `.cursor/skills/sdlc-checkpoint/scripts/`

**`checkpoint.sh <hub> [flags]`** — Writes or updates checkpoint state.

Examples:
```bash
checkpoint.sh coordinator --hub planning --story US-003
checkpoint.sh planning --phase 3 --story US-003 --dispatch sdlc-planner-hld
checkpoint.sh execution --task "4:Implement session store" --step review --iteration 1
```

**`verify.sh [hub]`** — Reads checkpoint state, cross-references against artifacts on disk, outputs a structured recommendation.

```
verify.sh              # Top-level routing recommendation
verify.sh planning     # Planning-specific resume recommendation
verify.sh execution    # Execution-specific resume recommendation
```

Output includes: current hub, phase, story, per-agent/task status, and a `recommendation` line with the exact next action.

### The `/sdlc-continue` Command

When a user sends `/sdlc-continue`:
1. The Coordinator runs `verify.sh` (no arguments).
2. Reads the `hub` field to determine routing (planning or execution).
3. Dispatches the appropriate orchestrator with checkpoint context.
4. The orchestrator runs `verify.sh {hub}` for detailed resume context.
5. Follows the `recommendation` field to resume at the exact point.

If `verify.sh` reports `NO_CHECKPOINT` or `NO_CHECKPOINT_DIR`, the user is informed that no checkpoint exists and asked whether to start fresh.

---

## Recovery Scenarios

### Agent Died Mid-Task (Token Exhaustion, IDE Crash)

**Symptoms**: Agent stopped responding mid-workflow. Incomplete output.

**Recovery**:
1. Send `/sdlc-continue` in a new session.
2. The Coordinator reads the checkpoint and routes to the correct hub.
3. The hub runs `verify.sh` to cross-reference checkpoint state against actual artifacts on disk.
4. Follows the recommendation — typically re-dispatches the agent that was in progress.

**Why it works**: Write-ahead checkpointing means the checkpoint recorded "about to dispatch agent X" before the crash. On resume, `verify.sh` checks if the artifact was actually produced:
- If the artifact exists → agent completed after checkpoint was written. Trust the artifact, advance.
- If the artifact is missing → agent did not complete. Re-dispatch it.

### Validation Gate Failed

**Symptoms**: Plan Validator returned NEEDS WORK on one or more checks.

**Recovery**:
1. **First failure**: The Planning Hub automatically re-dispatches the responsible agent with specific feedback from the validator.
2. **Second failure**: Same re-dispatch with more detailed guidance.
3. **Third failure**: Escalation to user with three options:
   - (a) Iterate manually — user provides guidance for the next attempt
   - (b) Accept partial — acknowledge documented gaps and proceed
   - (c) Skip — explicitly skip the gate with written acknowledgment

A gate is never silently bypassed. User acknowledgment is always required for non-passing results.

### Review Iteration Limit Hit (3 Rejections)

**Symptoms**: Code Reviewer rejected the implementation 3 times for the same task.

**Recovery**:
1. The task is marked **blocked** in the staging document.
2. The Execution Hub escalates to the user.
3. User options:
   - Provide specific guidance for the Implementer
   - Simplify the task scope
   - Split the task into smaller units
   - Manually resolve the issue

### QA Failure After Review Pass

**Symptoms**: Code passed review but QA verification failed.

**Recovery**:
1. The Execution Hub re-dispatches the Implementer with QA failure details (exact command, output, failing criterion).
2. After fix, the cycle restarts: implement → review → QA.
3. Max 2 QA retries per task before escalation.

### Missing Plan Artifacts

**Symptoms**: Execution Hub's Phase 0 readiness check fails — required artifacts are missing.

**Recovery**:
1. The Execution Hub halts and reports which artifacts are missing.
2. Return to planning: the Planning Hub is re-dispatched for the specific story and domains that need artifacts.
3. After artifacts are produced and validated, execution resumes.

### Circular Story Dependencies

**Symptoms**: Story Decomposer or Plan Validator detects a dependency cycle.

**Recovery**:
1. The dependency cycle is reported with the exact chain (e.g., US-003 → US-005 → US-003).
2. Options:
   - Merge the circular stories into one
   - Extract a shared contract to break the cycle
   - Restructure story boundaries

This is resolved during planning (Phase 2) before execution begins.

### IDE Switch Mid-Workflow

**Symptoms**: User started in one IDE, wants to continue in another.

**Recovery**: No special action needed. Checkpoint files are plain YAML in `.sdlc/` at the project root. Plan artifacts are plain Markdown in `plan/`. Both are IDE-independent. As long as the AI Registry is linked into the project for the target IDE (via `setup-links.sh`), `/sdlc-continue` will resume from the checkpoint in any IDE.

### Brownfield Plan Out of Sync

**Symptoms**: Code was implemented that doesn't match the current plan, or the plan was changed after implementation began.

**Recovery**:
1. Run the Plan Validator in **Impact Analysis** mode to assess the blast radius.
2. Review which stories and artifacts are affected.
3. Either:
   - Re-plan affected stories using the brownfield change protocol
   - Roll back the code change
   - Accept the deviation with documented justification

---

## Conflict Resolution

When checkpoint state and actual artifacts disagree:

| Situation | Resolution |
|---|---|
| Artifact exists but checkpoint says "pending" | Agent completed after checkpoint was written (token exhaustion scenario). **Trust the artifact.** |
| Checkpoint says "done" but artifact is missing | Something went wrong. **Re-dispatch the agent.** |
| Staging doc shows more progress than checkpoint | Staging doc is updated by sub-agents during work; checkpoints are updated by the hub. **Trust the staging doc.** |

**General rule**: Artifacts on disk are the ultimate source of truth. The checkpoint is a routing optimization, not the authority.

---

## Common Error Patterns

| Error | Likely Cause | Resolution |
|---|---|---|
| "Cannot review — staging document not found" | Code Reviewer dispatched without staging doc path | Re-dispatch with correct staging doc path in dispatch message |
| "Cannot verify — no acceptance criteria found" | QA dispatched without staging doc or empty criteria | Ensure staging doc has acceptance criteria populated |
| "Mode must be explicitly specified" (Plan Validator) | Validator dispatched without specifying which of its 4 modes to use | Re-dispatch with explicit mode: phase, per-story, cross-story, or impact-analysis |
| Readiness check fails at Phase 0 | Missing plan artifacts for story's candidate_domains | Return to planning for the specific missing domains |
| "DENY HLD work" (HLD Agent) | Missing story.md, architecture, or required contracts | Ensure upstream artifacts exist before dispatching |
| Research dispatch returns "inconclusive" | Insufficient evidence for technology decision | Narrow the research question or ask user for evidence |

---

## Debugging Checklist

When something seems wrong, check in this order:

1. **Check `.sdlc/` state**:
   - Does `.sdlc/coordinator.yaml` exist? What hub is active?
   - Does the relevant hub YAML (planning.yaml or execution.yaml) exist?
   - Run `verify.sh` to get a structured status and recommendation.

2. **Check `plan/` artifacts**:
   - Does `plan/prd.md` exist and have substantive content?
   - Does `plan/system-architecture.md` exist?
   - For the current story: are all expected artifacts present based on `candidate_domains`?
   - Check `plan/validation/` for the most recent validation report.

3. **Check staging documents** (during execution):
   - Does `docs/staging/US-NNN-*.md` exist for the current story?
   - Which tasks are checked off? Which are pending?
   - Are there any notes about blockers or issues?

4. **Check `history.log`**:
   - `.sdlc/history.log` is an append-only timestamped log of all checkpoint actions.
   - Look for the most recent entries to see what the last successful action was.

5. **Verify symlinks**:
   - Are `.cursor/skills/`, `.cursor/rules/`, `.cursor/agents/` (or `.roo/skills/`, `.roo/`) properly symlinked to the AI Registry?
   - Run `ls -la .cursor/skills/` or `ls -la .roo/skills/` to verify.
