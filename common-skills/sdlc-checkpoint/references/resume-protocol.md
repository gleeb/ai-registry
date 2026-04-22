# Resume Protocol — How Each Hub Acts on verify.sh Output

## Overview

When an agent receives a `/sdlc-continue` command (or loads the checkpoint skill during initialization and finds existing checkpoint state), it runs `verify.sh` and follows the structured recommendation. This document specifies how each hub interprets the output.

## Coordinator Resume

1. Run `verify.sh` (no arguments).
2. Read the `status` field: `ACTIVE`, `PAUSED`, or `IDLE`.
3. Act on the status:

| Status | Action |
|--------|--------|
| `ACTIVE` | Read `hub` and `current_story`; compose a delegation message to the target mode (sdlc-planner or sdlc-architect). Include the story and instruction to load the `sdlc-checkpoint` skill and run `verify.sh {hub}` for detailed resume context. |
| `PAUSED` | The user set a review gate via `pause_after` and the gate was hit. Report the completed story and the remaining queue to the user. Wait for user acknowledgment before resuming. On "continue" or equivalent, run `checkpoint.sh coordinator --clear-pause-after --hub execution` and route to sdlc-architect. On "set a new gate," run `--pause-after US-NNN` for the new gate and optionally clear with `--clear-pause-after`. |
| `IDLE` with `ungated_on_disk` in output | Stories exist on disk that are neither in `stories_done` nor `stories_remaining`. Run `checkpoint.sh coordinator --sync` to repopulate, then re-run `verify.sh` and follow the refreshed status. |
| `IDLE` with `remaining` but no `ungated_on_disk` | The queue is populated (e.g., immediately after a planner `--sync`) but no hub is active. Run `checkpoint.sh coordinator --hub execution` to activate, then route to sdlc-architect. |
| `IDLE` with neither `remaining` nor `ungated_on_disk` | All work is complete. Report to the user and ask what to work on next. |

## Planner Handoff to Coordinator

When the planner completes Phase 7, it runs:

```bash
checkpoint.sh coordinator --sync      # Populate stories_remaining from plan/user-stories/
checkpoint.sh coordinator --hub execution
```

`--sync` reads every `plan/user-stories/*/story.md`, sorts by `- execution_order:`, filters out any already in `stories_done`, and writes the result to `stories_remaining` + `current_story`. The coordinator then has a populated queue and can auto-advance between stories on each `--story-done`.

If stories are re-planned mid-run (rare), the planner re-enters Phase 7 so `--sync` refreshes the queue.

## Planning Hub Resume

1. Run `verify.sh planning`.
2. Read the output fields:
   - `phase`: Current planning phase.
   - `story`: Current story being planned.
   - `verification`: Per-agent artifact status.
   - `recommendation`: Specific next action.
3. Act on the recommendation:

| Recommendation Pattern | Action |
|------------------------|--------|
| `dispatch sdlc-planner-{agent} for {story}` | Dispatch the named agent using the appropriate dispatch template for the story |
| `re-dispatch sdlc-planner-{agent} for {story}` | Same as dispatch — the agent's previous attempt did not complete |
| `all agents complete for {story} -- dispatch per-story validator` | Dispatch Plan Validator in per-story mode for the named story |
| `phase {N} artifacts complete -- run validator then advance` | Dispatch Plan Validator for the completed phase, then proceed to next phase |
| `dispatch agents for missing cross-cutting: {list}` | Dispatch the named cross-cutting agents (Phase 4) |
| `all cross-cutting artifacts complete -- dispatch cross-story validator` | Dispatch Plan Validator in cross-story mode |

4. After acting on the recommendation, resume normal workflow from that point forward (all subsequent dispatches will be checkpointed via write-ahead as usual).

## Execution Hub (Architect) Resume

1. Run `verify.sh execution`.
2. Read the output fields:
   - `phase`: Current execution phase.
   - `story`: Story being implemented.
   - `tasks`: Completed/total task counts.
   - `current_task`, `current_step`, `current_iteration`: Where in the dev loop.
   - `staging_doc`: Path to the staging document.
   - `recommendation`: Specific next action.
3. Act on the recommendation:

| Recommendation Pattern | Action |
|------------------------|--------|
| `dispatch sdlc-implementer for task {id} "{name}"` | Dispatch implementer using the implementer dispatch template |
| `dispatch sdlc-code-reviewer for task {id} "{name}" (iteration {N})` | Dispatch reviewer using the reviewer dispatch template |
| `dispatch sdlc-qa for task {id} "{name}"` | Dispatch QA using the QA dispatch template |
| `all tasks complete -- advance to Phase 3 story integration` | Begin Phase 3: dispatch full-story code reviewer |
| `Phase 3 story integration -- dispatch sdlc-code-reviewer for full-story review` | Dispatch reviewer for full-story review |
| `Phase 4 acceptance -- dispatch sdlc-acceptance-validator` | Dispatch acceptance validator |
| `Phase 5 documentation integration` | Follow doc-integration-protocol |
| `Phase 6 user acceptance` | Present evidence report to user |
| `read staging doc to identify next pending task` | Open the staging doc and find the first `### Task` section whose `**Status:**` line is `pending` |

4. After acting on the recommendation, resume normal workflow. The staging doc remains the detailed source of truth; the checkpoint provides the routing shortcut.

## Conflict Resolution

If the checkpoint and the artifact state disagree:

- **Artifact exists but checkpoint says pending**: The agent completed after the checkpoint was written (token exhaustion scenario). Trust the artifact.
- **Checkpoint says done but artifact missing**: Something went wrong. Re-dispatch the agent.
- **Staging doc has more progress than checkpoint**: Trust the staging doc (it's updated by sub-agents during their work, while checkpoints are only updated by the hub).

The general rule: **artifacts on disk are the ultimate source of truth**. The checkpoint is a routing optimization, not the authority.
