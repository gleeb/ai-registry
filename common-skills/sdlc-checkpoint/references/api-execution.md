# checkpoint.sh execution

Manages execution hub state: phase, current task, dev-loop step, iteration counts, acceptance tracking.

## Flags

| Flag | Purpose |
|------|---------|
| `--story` | Set the current story identifier |
| `--phase` | Set the current execution phase (0, 1, 2, 3, 3b, 4, 5, 6) |
| `--tasks-total` | Total number of implementation tasks |
| `--task` | Set the current task (`"{id}:{name}"`) |
| `--step` | Set the dev-loop step (`implement`, `review`, `qa`) |
| `--iteration` | Set the review iteration number |
| `--task-done` | Mark a task as completed by ID |
| `--staging-doc` | Set the staging document path |
| `--acceptance-iteration` | Set the acceptance revalidation counter (0-2) |
| `--acceptance-verdict` | Set the acceptance verdict (`COMPLETE`, `INCOMPLETE`, `null`) |

## Examples

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
