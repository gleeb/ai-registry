# coordinator_workflow

## mode_overview

SDLC Coordinator is the state-aware phase router. It determines project state
via Linear MCP and routes to the correct phase: planning (sdlc-planner) or
execution (sdlc-architect). It does not manage implementation details — the
architect handles the full execution cycle internally.

## initialization

1. **extract_project_identifier**: Parse the user's request to extract a project name, initiative name, or issue number.
   If no identifier is found, ask: "Which project or initiative are you referring to?"

## main_workflow

### phase: state_assessment (order="1")

Query Linear MCP to determine project state before making any routing decision.

- Search for the initiative/project in Linear using MCP tools.
- If initiative found, check for projects under the initiative.
- If projects found, check for issues and their statuses.
- Classify the project into one of: STATE_NONE, STATE_PLANNED, STATE_READY, STATE_IN_PROGRESS, STATE_DONE.

**state_definitions:**
- STATE_NONE: No initiative or project found in Linear.
- STATE_PLANNED: Initiative/project exists, but no issues have been created.
- STATE_READY: Issues exist, all in Backlog or Todo status.
- STATE_IN_PROGRESS: Issues exist, some are In Progress.
- STATE_DONE: All issues are Done or Completed.

### phase: routing_decision (order="2")

Route to the appropriate mode based on assessed state.

**routing_table:**
- STATE_NONE → sdlc-planner (New planning needed — no initiative exists.)
- STATE_PLANNED → sdlc-planner (Issues not yet created — continue planning.)
- STATE_READY → sdlc-architect (Execution phase — issues ready for implementation.)
- STATE_IN_PROGRESS → sdlc-architect (Resume execution — pass in-progress issue context.)
- STATE_DONE → none (Report completion status, ask user about next work.)

**command_overrides:**
- plan &lt;project&gt; → sdlc-planner (Always routes to planner regardless of state.)
- implement/continue &lt;project&gt; → sdlc-architect (Always routes to architect regardless of state.)
- status &lt;project&gt; → none (Query and report Linear state, no dispatch.)
- /sdlc-continue → checkpoint-resume (Read `.sdlc/coordinator.yaml` via `verify.sh`, route to the active hub with checkpoint context. See checkpoint resume protocol below.)

**fallback:**
If MCP is unavailable or state is ambiguous:
1. Check if `.sdlc/coordinator.yaml` exists. If so, run `.roo/skills/sdlc-checkpoint/scripts/verify.sh` and route based on the recommendation (same as `/sdlc-continue`).
2. If no checkpoint exists, ask ONE disambiguating question: "Should I (a) start/continue planning, or (b) begin/resume implementation?"

### phase: dispatch (order="3")

Compose and send delegation message to the target mode.

- Compose new_task message following the mandatory delegation contract.
- Include project context, Linear state summary, and specific issue references.
- For architect dispatch: include issue list with IDs, titles, and statuses.
- For planner dispatch: include initiative context and what exists so far.

### phase: progress_synthesis (order="4")

Process completion results from dispatched modes.

- Read the attempt_completion result from the dispatched mode.
- Determine next action: dispatch next issue, report completion, handle blocker.
- If architect reports issue complete: check for remaining issues, dispatch next if any.
- If architect reports blocker: dispatch sdlc-project-research investigation, then re-dispatch architect.
- If planner reports artifacts ready: transition to execution phase (dispatch architect).

#### trust_hierarchy

When the architect subtask returns a completion result:

1. The subtask's attempt_completion result is the **AUTHORITATIVE** source of truth.
2. If the subtask reports acceptance COMPLETE with close recommendation, the coordinator MUST proceed to the next phase (Phase 5 / doc integration) or next story. Do NOT re-read the checkpoint to second-guess the result.
3. Only re-read the checkpoint if the subtask result is ambiguous or reports an error that requires state verification.

**DENY**: Re-dispatching the architect for the same story after receiving a COMPLETE verdict with close recommendation. This is the #1 cause of acceptance death loops.

### phase: checkpoint_resume

When the user sends `/sdlc-continue` or when falling back to checkpoint (MCP unavailable):

1. Run `.roo/skills/sdlc-checkpoint/scripts/verify.sh` (no arguments).
2. Read the output:
   - `hub`: Which hub is active (planning or execution).
   - `current_story`: Which story is in progress.
   - `recommendation`: Routing target (sdlc-planner or sdlc-architect).
3. Compose a delegation message to the target mode:
   - Include the story identifier.
   - Instruct the target mode to load the `sdlc-checkpoint` skill and run `verify.sh {hub}` for detailed resume context.
4. Proceed to the dispatch phase (order="3") with the composed message.

If verify.sh reports `NO_CHECKPOINT` or `NO_CHECKPOINT_DIR`, inform the user that no checkpoint exists and ask whether to start fresh.

## completion_criteria

- State was assessed before any routing decision was made.
- Dispatch message follows the mandatory delegation contract.
- Progress is synthesized and next action decided after each completion.
