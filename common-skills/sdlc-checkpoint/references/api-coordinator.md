# checkpoint.sh coordinator

Manages top-level routing state: which hub is active, which story is current, and story completion tracking.

## Flags

| Flag | Purpose |
|------|---------|
| `--hub` | Set the active hub (`planning` or `execution`) |
| `--story` | Set the current story identifier |
| `--story-done` | Mark a story as completed |

## Examples

```bash
# Planning hub is active, working on story US-003
checkpoint.sh coordinator --hub planning --story US-003

# Story completed, update coordinator
checkpoint.sh coordinator --story-done US-003

# Switching to execution hub
checkpoint.sh coordinator --hub execution --story US-001
```
