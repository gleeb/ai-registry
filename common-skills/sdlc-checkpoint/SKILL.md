---
name: sdlc-checkpoint
description: >
  Crash-safe checkpoint and resume system for the SDLC workflow. Load this skill
  when orchestrating planning or execution phases. Provides shell scripts to
  write checkpoint state before each dispatch and verify state on resume.
  Enables seamless continuation across agents, models, and IDEs.
---

# SDLC Checkpoint

## When to Use

- **Planning Hub**: Load at hub initialization. Call `checkpoint.sh` before and after every sub-agent dispatch.
- **Execution Hub**: Load at architect initialization. Call `checkpoint.sh` before and after every task dispatch.
- **Coordinator**: Load when handling `/sdlc-continue` or `/sdlc-continue-checkpoint`. Call `verify.sh` to determine routing.
- **Any Agent**: Load when receiving `/sdlc-continue-checkpoint` command. Call `checkpoint.sh continue` for actionable instructions.

## When NOT to Use

- Do not load for individual sub-agents (PRD agent, HLD agent, implementer, etc.). Only the orchestrating hub writes checkpoints.

## Core Principles

- **Write-ahead**: Always update the checkpoint BEFORE dispatching a sub-agent. If the agent dies mid-dispatch, the checkpoint reflects "about to do X."
- **Verify on resume**: On resume, run `verify.sh` to cross-reference checkpoint state against actual artifacts on disk. Never blindly trust the checkpoint.
- **Auto-bootstrap**: Scripts auto-create `.sdlc/` and YAML files on first invocation. No separate setup step needed.

## State Files

All state lives in `.sdlc/` at the target project root:

| File | Owner | Contents |
|------|-------|----------|
| `coordinator.yaml` | Coordinator / Hubs | Active hub, current story, stories progress |
| `planning.yaml` | Planning Hub | Phase, story loop position, per-story agent progress |
| `execution.yaml` | Execution Hub | Phase, task, dev-loop step, iteration counts, acceptance_iteration (0-2), acceptance_verdict (COMPLETE/INCOMPLETE/null) |
| `dispatch-log.jsonl` | Planning & Execution Hubs | Structured dispatch/response audit trail (append-only JSONL) |
| `history.log` | All (append-only) | Timestamped action log for debugging |

## Script API

Scripts are bundled at `scripts/` relative to this skill. From a linked project, the path is:

```
.roo/skills/sdlc-checkpoint/scripts/checkpoint.sh
.roo/skills/sdlc-checkpoint/scripts/verify.sh
.roo/skills/sdlc-checkpoint/scripts/dispatch-summary.sh
```

### checkpoint.sh — Write/Update State

```
checkpoint.sh <hub> [flags]
checkpoint.sh continue
```

| Hub | Flags | Example |
|-----|-------|---------|
| `coordinator` | `--hub`, `--story`, `--story-done` | `checkpoint.sh coordinator --hub planning --story US-003` |
| `planning` | `--phase`, `--story`, `--agents-done`, `--agents-pending`, `--dispatch`, `--completed`, `--story-done` | `checkpoint.sh planning --dispatch sdlc-planner-hld` |
| `execution` | `--story`, `--phase`, `--tasks-total`, `--task`, `--step`, `--iteration`, `--task-done`, `--staging-doc`, `--acceptance-iteration`, `--acceptance-verdict` | `checkpoint.sh execution --step review --iteration 1` |
| `dispatch-log` | `--event`, `--story`, `--hub`, `--phase`, `--task`, `--agent`, `--model-profile`, `--dispatch-id`, `--iteration`, `--verdict`, `--duration`, `--summary` | `checkpoint.sh dispatch-log --event dispatch --agent sdlc-implementer --dispatch-id exec-US001-t3-impl-i1` |
| `init` | (none) | `checkpoint.sh init` |
| `continue` | (none) | `checkpoint.sh continue` |

**Incremental updates**: Each call patches only the specified fields. Unspecified fields are preserved. The script regenerates `resume_hint` and appends to `history.log` on every call.

**Auto-create**: If `.sdlc/` does not exist, it is created on the first call to any subcommand.

**Init subcommand**: `checkpoint.sh init` scans `plan/` and `docs/staging/` to derive full state from existing artifacts. Use this when adopting checkpoints into an already-in-progress workflow.

**Continue subcommand**: `checkpoint.sh continue` reads the current checkpoint state and provides clear, actionable instructions for resuming work. Use this when handling `/sdlc-continue-checkpoint` commands.

#### Coordinator Examples

```bash
# Planning hub is active, working on story US-003
checkpoint.sh coordinator --hub planning --story US-003

# Story completed, update coordinator
checkpoint.sh coordinator --story-done US-003

# Switching to execution hub
checkpoint.sh coordinator --hub execution --story US-001
```

#### Planning Examples

```bash
# Starting phase 3 for a story
checkpoint.sh planning --phase 3 --story US-003 --agents-done "hld,api" --agents-pending "data,security"

# Before dispatching a sub-agent (write-ahead)
checkpoint.sh planning --dispatch sdlc-planner-data

# After sub-agent completes
checkpoint.sh planning --completed data

# Story fully planned
checkpoint.sh planning --story-done US-003
```

#### Execution Examples

```bash
# Starting execution for a story
checkpoint.sh execution --story US-001 --phase 2 --tasks-total 8 --staging-doc "docs/staging/US-001-auth.md"

# Before dispatching implementer (write-ahead)
checkpoint.sh execution --task "4:Implement session store" --step implement

# Transitioning to review
checkpoint.sh execution --step review --iteration 1

# Task done
checkpoint.sh execution --task-done 4

# Phase transition
checkpoint.sh execution --phase 3

# Tracking acceptance revalidation (Phase 4)
checkpoint.sh execution --phase 4 --acceptance-iteration 0
checkpoint.sh execution --acceptance-iteration 1 --acceptance-verdict INCOMPLETE
checkpoint.sh execution --acceptance-verdict COMPLETE
```

### verify.sh — Read State and Recommend Next Action

```
verify.sh [hub]
```

If `hub` is omitted, reads `coordinator.yaml` and outputs the top-level routing recommendation. If `hub` is `planning` or `execution`, reads the corresponding YAML and verifies against artifacts on disk.

**Output format** (structured, machine-readable):

```
hub: planning
phase: 3
story: US-003-settings
status: IN_PROGRESS
verification:
  hld: DONE (plan/user-stories/US-003-settings/hld.md exists)
  api: DONE (plan/user-stories/US-003-settings/api.md exists)
  data: DONE (plan/user-stories/US-003-settings/data.md exists)
  security: PENDING
recommendation: dispatch sdlc-planner-security for US-003-settings
next_after: per-story-validation for US-003-settings
```

The agent reads the `recommendation` line and follows it directly. See [`references/resume-protocol.md`](references/resume-protocol.md) for how each hub should act on the output.

The artifact-to-path mapping used by verify.sh is documented in [`references/artifact-map.md`](references/artifact-map.md).

### checkpoint.sh dispatch-log — Dispatch Audit Trail

Appends structured JSONL entries to `.sdlc/dispatch-log.jsonl`. Call once before each sub-agent dispatch (`--event dispatch`) and once after the sub-agent returns (`--event response`).

**Dispatch event flags**: `--event dispatch --story X --hub H --phase N --task "id:name" --agent slug --model-profile profile --dispatch-id ID --iteration N`

**Response event flags**: `--event response --dispatch-id ID --agent slug --verdict V --duration S --summary "text"`

The `--dispatch-id` correlates dispatch/response pairs. Format: `{hub}-{story}-t{task-id}-{agent-short}-i{iteration}`.

**REQUIRE**: Dispatch IDs MUST be globally unique within a story's execution. For acceptance revalidation, use: `exec-{story}-phase4-acceptance-r{round}` where round is a monotonically increasing integer (r1, r2, r3).

**DENY**: Reusing a dispatch-id that already appears in `dispatch-log.jsonl`. If in doubt, include a timestamp suffix: `exec-US001-phase4-acceptance-r2-1711100000`.

#### Dispatch Log Examples

```bash
# Before dispatching implementer (write-ahead)
checkpoint.sh dispatch-log \
  --event dispatch \
  --story US-001-scaffolding \
  --hub execution \
  --phase 2 \
  --task "3:Startup budget baseline" \
  --agent sdlc-implementer \
  --model-profile local-coder \
  --dispatch-id exec-US001-t3-impl-i1 \
  --iteration 1

# After implementer returns
checkpoint.sh dispatch-log \
  --event response \
  --dispatch-id exec-US001-t3-impl-i1 \
  --agent sdlc-implementer \
  --duration 342 \
  --summary "Implemented startup budget baseline with performance monitoring hooks"

# Before dispatching reviewer
checkpoint.sh dispatch-log \
  --event dispatch \
  --story US-001-scaffolding \
  --hub execution \
  --phase 2 \
  --task "3:Startup budget baseline" \
  --agent sdlc-code-reviewer \
  --model-profile local-coder \
  --dispatch-id exec-US001-t3-review-i1 \
  --iteration 1

# After reviewer returns
checkpoint.sh dispatch-log \
  --event response \
  --dispatch-id exec-US001-t3-review-i1 \
  --agent sdlc-code-reviewer \
  --verdict "Approved" \
  --duration 120
```

### dispatch-summary.sh — Dispatch Analytics

Reads `.sdlc/dispatch-log.jsonl` and produces a human-readable summary.

```
dispatch-summary.sh                  # Full summary
dispatch-summary.sh --story US-001   # Filter to one story
dispatch-summary.sh --timeline       # Timeline only
```

Output includes: dispatch counts by agent and model profile, duration statistics, review iteration counts, verdict pass/fail ratios, and a chronological timeline.

## Integration Pattern

Each hub adds checkpoint calls at these points:

1. **Before every dispatch** (write-ahead — the critical one for crash safety)
2. **After every agent/task completion**
3. **At every phase transition**
4. **At every gate check result**
5. **At every loop iteration** (next story, next task)

Minimal token cost per call: ~20-30 tokens for the shell command.

## `/sdlc-continue-checkpoint` Command

When an agent receives a `/sdlc-continue-checkpoint` user command:

1. **Load this skill** if not already loaded
2. **Run**: `checkpoint.sh continue` 
3. **Follow the output instructions** exactly as provided

The `continue` subcommand outputs structured, actionable instructions including:
- Current workflow state (hub, phase, story)
- Specific next action to take 
- Context needed for the action
- Routing instructions if delegation is required

**Example output**:
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
