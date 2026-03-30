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

## Git Branch Lifecycle

Each user story executes on its own git branch (created Phase 0, merged Phase 6). See [`references/git-branch-lifecycle.md`](references/git-branch-lifecycle.md) for the full protocol, naming conventions, commit points, merge strategy, and edge cases.

## State Files

All state lives in `.sdlc/` at the target project root:

| File | Owner | Contents |
|------|-------|----------|
| `coordinator.yaml` | Coordinator / Hubs | Active hub, current story, stories progress |
| `planning.yaml` | Planning Hub | Phase, story loop position, per-story agent progress |
| `execution.yaml` | Execution Hub | Phase, task, dev-loop step, iteration counts, acceptance_iteration (0-2), acceptance_verdict (COMPLETE/INCOMPLETE/null), branch_name, base_branch, base_commit |
| `dispatch-log.jsonl` | Planning & Execution Hubs | Structured dispatch/response audit trail (append-only JSONL) |
| `history.log` | All (append-only) | Timestamped action log for debugging |

## Script API

Scripts are bundled at `scripts/` relative to this skill. From a linked project, the path is:

```
skills/sdlc-checkpoint/scripts/checkpoint.sh
skills/sdlc-checkpoint/scripts/verify.sh
skills/sdlc-checkpoint/scripts/dispatch-summary.sh
```

### checkpoint.sh — Quick Reference

```
checkpoint.sh <hub> [flags]
checkpoint.sh continue
```

| Hub | Reference | Purpose |
|-----|-----------|---------|
| `coordinator` | [`references/api-coordinator.md`](references/api-coordinator.md) | Top-level routing state |
| `planning` | [`references/api-planning.md`](references/api-planning.md) | Planning hub phase/agent state |
| `execution` | [`references/api-execution.md`](references/api-execution.md) | Execution hub phase/task/iteration state |
| `git` | [`references/api-git.md`](references/api-git.md) | Branch create, commit, merge |
| `dispatch-log` | [`references/api-dispatch-log.md`](references/api-dispatch-log.md) | Dispatch/response audit trail |
| `init` | (no reference needed) | Re-derive state from artifacts on disk |
| `continue` | [`references/continue-command.md`](references/continue-command.md) | Resume instructions for `/sdlc-continue-checkpoint` |

Load the reference for your current hub's subcommand. Do NOT load all API references at once.

**Incremental updates**: Each call patches only the specified fields. Unspecified fields are preserved. The script regenerates `resume_hint` and appends to `history.log` on every call.

**Auto-create**: If `.sdlc/` does not exist, it is created on the first call to any subcommand.

**Init subcommand**: `checkpoint.sh init` scans `plan/` and `docs/staging/` to derive full state from existing artifacts. Use this when adopting checkpoints into an already-in-progress workflow.

### verify.sh — Read State and Recommend Next Action

```
verify.sh [hub]
```

If `hub` is omitted, reads `coordinator.yaml` and outputs the top-level routing recommendation. If `hub` is `planning` or `execution`, reads the corresponding YAML and verifies against artifacts on disk.

The agent reads the `recommendation` line from the output and follows it directly. See [`references/resume-protocol.md`](references/resume-protocol.md) for how each hub should act on the output. The artifact-to-path mapping is documented in [`references/artifact-map.md`](references/artifact-map.md).

### dispatch-summary.sh — Dispatch Analytics

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
6. **Git lifecycle events**: branch create (Phase 0 gate pass), commit (Phase 2 task-done, Phase 3b/4 remediation, Phase 5 docs), merge (Phase 6 approval)

Minimal token cost per call: ~20-30 tokens for the shell command.
