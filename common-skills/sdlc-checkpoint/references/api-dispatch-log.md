# checkpoint.sh dispatch-log

Appends structured JSONL entries to `.sdlc/dispatch-log.jsonl`. Call once before each sub-agent dispatch (`--event dispatch`) and once after the sub-agent returns (`--event response`).

## Flags

### Dispatch Event

| Flag | Purpose |
|------|---------|
| `--event dispatch` | Record a dispatch event |
| `--story` | Story identifier |
| `--hub` | Hub name (`planning` or `execution`) |
| `--phase` | Current phase |
| `--task` | Task identifier (`"id:name"`) |
| `--agent` | Agent slug being dispatched |
| `--model-profile` | Model profile name |
| `--dispatch-id` | Unique dispatch identifier |
| `--iteration` | Iteration number |

### Response Event

| Flag | Purpose |
|------|---------|
| `--event response` | Record a response event |
| `--dispatch-id` | Dispatch ID to correlate with |
| `--agent` | Agent slug that responded |
| `--verdict` | Agent's verdict/result |
| `--duration` | Duration in seconds |
| `--summary` | Summary excerpt text |

## Dispatch ID Format

The `--dispatch-id` correlates dispatch/response pairs. Format: `{hub}-{story}-t{task-id}-{agent-short}-i{iteration}`.

**REQUIRE**: Dispatch IDs MUST be globally unique within a story's execution. For acceptance revalidation, use: `exec-{story}-phase4-acceptance-r{round}` where round is a monotonically increasing integer (r1, r2, r3).

Dispatch IDs are unique by construction — do NOT read `dispatch-log.jsonl` to verify during normal flow. On **resume only** (checkpoint shows a dispatch was already logged for the current task/step), run `grep -c '{dispatch-id}' .sdlc/dispatch-log.jsonl`; if count > 0, append a timestamp suffix (e.g., `exec-US001-phase4-acceptance-r2-1711100000`).

## Examples

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
