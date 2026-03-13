# Resume Protocol — How Each Hub Acts on verify.sh Output

## Overview

When an agent receives a `/sdlc-continue` command (or loads the checkpoint skill during initialization and finds existing checkpoint state), it runs `verify.sh` and follows the structured recommendation. This document specifies how each hub interprets the output.

## Coordinator Resume

1. Run `verify.sh` (no arguments).
2. Read the `hub` field to determine routing target.
3. Read the `recommendation` field for the dispatch target.
4. Compose a delegation message to the target mode (sdlc-planner or sdlc-architect) including:
   - The story from the `current_story` field.
   - Instruction to load the `sdlc-checkpoint` skill and run `verify.sh {hub}` for detailed resume context.

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
| `read staging doc to identify next pending task` | Open the staging doc and find the first `- [ ]` task |

4. After acting on the recommendation, resume normal workflow. The staging doc remains the detailed source of truth; the checkpoint provides the routing shortcut.

## Conflict Resolution

If the checkpoint and the artifact state disagree:

- **Artifact exists but checkpoint says pending**: The agent completed after the checkpoint was written (token exhaustion scenario). Trust the artifact.
- **Checkpoint says done but artifact missing**: Something went wrong. Re-dispatch the agent.
- **Staging doc has more progress than checkpoint**: Trust the staging doc (it's updated by sub-agents during their work, while checkpoints are only updated by the hub).

The general rule: **artifacts on disk are the ultimate source of truth**. The checkpoint is a routing optimization, not the authority.
