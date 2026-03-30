# checkpoint.sh coordinator

Manages top-level routing state: which hub is active, which story is current, and story completion tracking.

Only the coordinator agent should write to `coordinator.yaml`. The execution hub and planning hub write to their own state files.

## Flags

| Flag | Purpose |
|------|---------|
| `--hub` | Set the active hub (`planning` or `execution`) |
| `--story` | Set the current story identifier |
| `--story-done` | Mark a story as completed. **Auto-transitions**: adds story to `stories_done`, removes from `stories_remaining`. If stories remain, advances `current_story` to the next one. If none remain, clears both `active_hub` and `current_story` (idle state) |

## Examples

```bash
# Planning hub is active, working on story US-003
checkpoint.sh coordinator --hub planning --story US-003

# Story completed — auto-transitions to next story or idle
checkpoint.sh coordinator --story-done US-003

# Switching to execution hub
checkpoint.sh coordinator --hub execution --story US-001
```
