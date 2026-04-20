# checkpoint.sh coordinator

Manages top-level routing state: which hub is active, which story is current, story completion tracking, and user-requested review gates.

Only the coordinator agent should write to `coordinator.yaml`. The execution hub and planning hub write to their own state files.

## Flags

| Flag | Purpose |
|------|---------|
| `--hub` | Set the active hub (`planning` or `execution`) |
| `--story` | Set the current story identifier |
| `--story-done` | Mark a story as completed. **Auto-transitions**: adds story to `stories_done`, re-syncs `stories_remaining` from disk, removes the completed story, and advances `current_story` to the next entry. If the completed story matches `pause_after`, clears `active_hub` (PAUSED state). If the queue is empty, clears both `active_hub` and `current_story` (IDLE state). |
| `--sync` | Rebuild `stories_remaining` and `current_story` from `plan/user-stories/*/story.md` on disk, sorted by each story's `- execution_order:` field, filtering out anything already in `stories_done`. Idempotent. Safe to run repeatedly. Called automatically at `cmd_init` (bootstrap), during `--story-done` (to pick up newly-planned stories), and at planner Phase 7 handoff. |
| `--pause-after` | Set the `pause_after: US-NNN` field. The coordinator will clear `active_hub` after `--story-done` completes the matching story, but preserve `stories_remaining` and `pause_after`. Use this to set a user review gate without disabling auto-advance. |
| `--clear-pause-after` | Clear the `pause_after` field. Combined with `--hub execution`, the coordinator resumes from PAUSED by advancing `current_story` to the head of `stories_remaining`. |

## coordinator.yaml fields

| Field | Type | Purpose |
|-------|------|---------|
| `active_hub` | `planning` \| `execution` \| `null` | Which hub owns the current step. `null` means IDLE or PAUSED. |
| `current_story` | `US-NNN-name` \| `null` | Story the active hub is working on. |
| `stories_done` | list | Stories the engineering hub has completed. |
| `stories_remaining` | list | Stories still to run, in `execution_order`. Populated by `--sync`. |
| `pause_after` | `US-NNN-name` \| `null` | Optional user review gate. When `--story-done` completes this story, the coordinator enters PAUSED instead of auto-advancing. Default: `null` (auto-advance). |
| `resume_hint` | string | Human-readable status string for the next action. |

## Status values (reported by verify.sh)

| Status | Condition | Recommendation |
|--------|-----------|----------------|
| `ACTIVE` | `active_hub` non-null | Route to the active hub |
| `PAUSED` | `active_hub` null, `pause_after` set, `stories_remaining` non-empty | Resume via `--clear-pause-after --hub execution`, or update `pause_after` to set a new gate |
| `IDLE` | `active_hub` null, no pause gate, queue empty or absent | All work done, or queue needs repopulating — `verify.sh` flags ungated stories on disk if any exist |

## Examples

```bash
# Planner completed — populate coordinator queue from disk and hand off
checkpoint.sh coordinator --hub execution --sync

# Planning hub is active, working on story US-003
checkpoint.sh coordinator --hub planning --story US-003

# Story completed — auto-transitions to next story, pause gate, or idle
checkpoint.sh coordinator --story-done US-003-pwa-shell-baseline

# Set a review gate: pause after US-005 is done
checkpoint.sh coordinator --pause-after US-005-provider-settings

# Resume after the user reviews
checkpoint.sh coordinator --clear-pause-after --hub execution

# Mid-run re-sync after plan changes (rare — normally done at Phase 7)
checkpoint.sh coordinator --sync
```
