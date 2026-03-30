# checkpoint.sh continue

Reads the current checkpoint state and provides clear, actionable instructions for resuming work. Use this when handling `/sdlc-continue-checkpoint` commands.

## Usage

When an agent receives a `/sdlc-continue-checkpoint` user command:

1. **Load this skill** if not already loaded
2. **Run**: `checkpoint.sh continue`
3. **Follow the output instructions** exactly as provided

## Output

The `continue` subcommand outputs structured, actionable instructions including:
- Current workflow state (hub, phase, story)
- Specific next action to take
- Context needed for the action
- Routing instructions if delegation is required

## Example Output

```
SDLC Checkpoint Resume Instructions
==================================

Status: Planning Hub Active
Phase: 3 (Per-story planning)
Story: US-003-settings
Progress: HLD done, API done, Data pending

INSTRUCTION: Dispatch sdlc-planner-data agent for story US-003-settings
Context: Load sdlc-checkpoint skill and run verify.sh planning for detailed state
After completion: Update checkpoint with --completed data flag

READY TO EXECUTE: Use Task tool with subagent_type="generalPurpose" and prompt:
"You are the Data Planning agent for story US-003-settings. Load the sdlc-checkpoint skill and run verify.sh planning to get current context. Then proceed with data architecture planning."
```

This command bridges the gap between checkpoint state and actionable agent instructions, making resume operations seamless across different conversation contexts.
