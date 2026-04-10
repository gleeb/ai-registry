# checkpoint.sh planning

Manages planning hub state: phase progression, story loop position, per-story agent dispatch tracking.

## Flags

| Flag | Purpose |
|------|---------|
| `--phase` | Set the current planning phase |
| `--story` | Set the current story being planned |
| `--agents-done` | Comma-separated list of completed agent domains |
| `--agents-pending` | Comma-separated list of remaining agent domains |
| `--dispatch` | Record which agent is about to be dispatched (write-ahead) |
| `--completed` | Mark a domain agent as completed |
| `--story-done` | Mark the current story as fully planned; appends to `stories_completed` and auto-advances `current_story` to the next unplanned story in `story_queue` |
| `--build-queue` | Scan `plan/user-stories/` and build ordered `story_queue` from `execution_order` fields |

## YAML Schema (planning.yaml)

```yaml
last_updated: "2025-04-05T12:00:00Z"
phase: 3
completed_phases: [1,2]
total_stories: 12
current_story: US-003-pwa-shell-baseline
story_queue: ["US-001-scaffolding", "US-002-local-persistence", "US-003-pwa-shell-baseline", ...]
stories_completed: ["US-001-scaffolding", "US-002-local-persistence"]
agents_done: ["hld", "api"]
agent_in_progress: data
agents_pending: ["security"]
last_dispatch: sdlc-planner-data
last_completed: api
resume_hint: "Phase 3, story US-003-pwa-shell-baseline (2/12 done). Done: [hld api]. data in progress."
```

## Examples

```bash
# Starting phase 3 for a story
checkpoint.sh planning --phase 3 --story US-003 --agents-done "hld,api" --agents-pending "data,security"

# Before dispatching a sub-agent (write-ahead)
checkpoint.sh planning --dispatch sdlc-planner-data

# After sub-agent completes
checkpoint.sh planning --completed data

# Story fully planned — auto-advances current_story from queue
checkpoint.sh planning --story-done US-003

# Build ordered story queue from disk (Phase 3 initialization)
checkpoint.sh planning --build-queue
```

---

# checkpoint.sh sync-planning

Standalone bootstrap command. Scans `plan/user-stories/` to build `story_queue` and `stories_completed` from disk artifacts. Safe to run at any time — idempotent.

No flags required. Reads the `plan/` directory and writes `planning.yaml`.

- Builds `story_queue` from `execution_order` in each `story.md`
- Marks stories with `hld.md` as completed
- Derives `current_story` as the first incomplete story
- Prints a human-readable status summary

```bash
# Bootstrap an existing project onto the new story queue mechanics
checkpoint.sh sync-planning

# Example output:
# Story queue built from disk (12 stories):
#   1. US-001-scaffolding              [DONE]
#   2. US-002-local-persistence        [DONE]
#   3. US-003-pwa-shell-baseline       [PENDING] <-- current
#   ...
# Phase: 3 | Completed: 2/12 | Next: US-003-pwa-shell-baseline
```
