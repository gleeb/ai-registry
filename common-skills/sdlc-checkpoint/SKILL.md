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
- **Coordinator**: Load when handling `/sdlc-continue`. Call `verify.sh` to determine routing.

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
| `execution.yaml` | Execution Hub | Phase, task, dev-loop step, iteration counts |
| `history.log` | All (append-only) | Timestamped action log for debugging |

## Script API

Scripts are bundled at `scripts/` relative to this skill. From a linked project, the path is:

```
.roo/skills/sdlc-checkpoint/scripts/checkpoint.sh
.roo/skills/sdlc-checkpoint/scripts/verify.sh
```

### checkpoint.sh — Write/Update State

```
checkpoint.sh <hub> [flags]
```

| Hub | Flags | Example |
|-----|-------|---------|
| `coordinator` | `--hub`, `--story`, `--story-done` | `checkpoint.sh coordinator --hub planning --story US-003` |
| `planning` | `--phase`, `--story`, `--agents-done`, `--agents-pending`, `--dispatch`, `--completed`, `--story-done` | `checkpoint.sh planning --dispatch sdlc-planner-hld` |
| `execution` | `--story`, `--phase`, `--tasks-total`, `--task`, `--step`, `--iteration`, `--task-done`, `--staging-doc` | `checkpoint.sh execution --step review --iteration 1` |
| `init` | (none) | `checkpoint.sh init` |

**Incremental updates**: Each call patches only the specified fields. Unspecified fields are preserved. The script regenerates `resume_hint` and appends to `history.log` on every call.

**Auto-create**: If `.sdlc/` does not exist, it is created on the first call to any subcommand.

**Init subcommand**: `checkpoint.sh init` scans `plan/` and `docs/staging/` to derive full state from existing artifacts. Use this when adopting checkpoints into an already-in-progress workflow.

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

## Integration Pattern

Each hub adds checkpoint calls at these points:

1. **Before every dispatch** (write-ahead — the critical one for crash safety)
2. **After every agent/task completion**
3. **At every phase transition**
4. **At every gate check result**
5. **At every loop iteration** (next story, next task)

Minimal token cost per call: ~20-30 tokens for the shell command.
