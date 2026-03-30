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
| `--story-done` | Mark the current story as fully planned |

## Examples

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
