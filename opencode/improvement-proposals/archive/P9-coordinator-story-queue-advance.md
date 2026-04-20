# P9: Coordinator Story-Queue Population and Auto-Advance

**Status:** Resolved — drafted 2026-04-18, revised 2026-04-19, implemented 2026-04-19
**Relates to:** (foundational — no prior P directly addresses coordinator queue wiring)
**Scope:** `common-skills/sdlc-checkpoint/scripts/checkpoint.sh` (new `coordinator --sync`, `--pause-after`, `--clear-pause-after` flags; removed dead `sync-coordinator.sh` lookup in `cmd_init`), `common-skills/sdlc-checkpoint/scripts/verify.sh` (new `ACTIVE` / `PAUSED` / `IDLE` statuses with `ungated_on_disk` self-heal hint), `common-skills/sdlc-checkpoint/references/api-coordinator.md`, `common-skills/sdlc-checkpoint/references/resume-protocol.md`, `opencode/.opencode/agents/sdlc-coordinator.md`, `opencode/.opencode/agents/sdlc-planner.md`, `.sdlc/coordinator.yaml` schema (new optional `pause_after` field)
**Transcript evidence:** `ses_26105317cffeCAev1W8UP3BtK1` — lines 51516–51564: after `checkpoint.sh coordinator --story-done US-002-local-persistence-foundation`, `verify.sh` returned `hub: null / current_story: null / status: IDLE / recommendation: no active hub -- ask user what to do`, despite 10 remaining user stories sitting at `plan/user-stories/US-003 … US-012/story.md`. The coordinator asked the user what to do next; the user had to reply "you finished us-002? continue to us-003 then" (line 51570).

---

## Resolution (2026-04-19)

Implemented as specified in §3. Validated end-to-end against a 12-story synthetic plan (`tmp/plan`) covering every transition in the state machine.

**What shipped**

- `checkpoint.sh coordinator --sync` rebuilds `stories_remaining` and `current_story` from `plan/user-stories/*/story.md`, sorted by `- execution_order:` (ties broken alphabetically), filtering out anything already in `stories_done`. Idempotent.
- `--story-done <story>` now re-syncs from disk before advancing, so mid-run story edits are picked up automatically. Auto-advances `current_story` to the next queued story.
- `--pause-after US-NNN` sets a user review gate. When `--story-done` completes that story, the coordinator clears `active_hub` but preserves `stories_remaining` and `pause_after`, entering PAUSED.
- `--clear-pause-after` resumes from PAUSED; combined with `--hub execution` it advances `current_story` to the head of the queue.
- `verify.sh` distinguishes three coordinator statuses: `ACTIVE` (hub active), `PAUSED` (pause gate hit), `IDLE` (no active hub). The IDLE branch emits `ungated_on_disk` and a `--sync` recommendation when stories exist on disk but are in neither `stories_remaining` nor `stories_done`, and a separate "queue ready but no active hub — run `--hub execution`" hint when the queue is populated but no hub has been activated yet (the typical state immediately after a planner handoff).
- `cmd_init` calls `cmd_coordinator --sync` directly; the ghost `sync-coordinator.sh` lookup and all references to that never-shipped script are removed. `sdlc-planner.md` Phase 7 invokes `checkpoint.sh coordinator --sync` at handoff.

**Validation**

A shell test harness (`tmp/p9-test.sh` + `tmp/p9-test-regression.sh`) exercises the state machine: fresh `--sync`, sequential `--story-done` across heterogeneous `execution_order` values (including ties), pause-and-resume, final-IDLE, idempotency check, and three corrupted-state regression cases (empty queue with ungated stories on disk; partial `stories_done` with empty queue; true all-done IDLE). All scenarios pass. The core regression from the baseline transcript — IDLE between stories despite a populated plan — no longer occurs.

**Incidental fixes**

Found and fixed while testing:
- `grep -v` in the `--story-done` path exited non-zero when the completed story was the last entry in `stories_remaining`, halting the script under `set -euo pipefail`. Wrapped with `|| true`.
- `yaml_read` returns the literal `"null"` for null YAML values; added explicit `[ "$var" = "null" ] && var=""` normalization for `active_hub`, `current_story`, and `pause_after` in both `checkpoint.sh` and `verify.sh`.
- `verify.sh` initially flagged synced stories as `ungated_on_disk` because it only compared against `stories_done`. Fixed to also exclude anything in `stories_remaining`.

---

## 1. Problem Statement

The coordinator goes IDLE after every single story completion, asking the user to manually route to the next story. This breaks the core promise of the orchestrator: that planning produces an ordered story queue which execution walks through autonomously.

The coordinator spec itself (`sdlc-coordinator.md` lines 125–136) correctly describes the intended behavior — after `--story-done`, run `verify.sh` and get the next story. The script logic in `checkpoint.sh` (cmd_coordinator, lines 117–133) is also correct: it reads `stories_remaining`, removes the completed story, and advances `current_story` to the first remaining entry. If the list is empty, it clears both `active_hub` and `current_story`.

The failure is in the **initial population** of `stories_remaining`. Two artifacts reference a `sync-coordinator.sh` script that should derive `stories_remaining` from `plan/user-stories/*/story.md` (sorted by `execution_order`):

- `checkpoint.sh:844` looks for `sync-coordinator.sh` in three candidate paths during `cmd_init`.
- `sdlc-planner.md:175` describes `sync-coordinator.sh` as the mechanism that "derives `stories_remaining` from `plan/user-stories/` artifacts sorted by `execution_order`, sets `current_story` to the first remaining story."

`find opencode -name sync-coordinator.sh` returns nothing. **The script does not exist in the repository.** `coordinator.yaml` therefore never receives a populated `stories_remaining` list, so every `--story-done` call finds an empty queue and falls to IDLE.

## 2. Root Cause Analysis

### 2.1 Missing implementation, ghost reference
`sync-coordinator.sh` is documented behavior with no implementation. The call site in `cmd_init` silently no-ops because it falls through all three candidate paths. No error is surfaced.

### 2.2 Coordinator queue is initialized in the wrong lifecycle moment
Even if `sync-coordinator.sh` existed and ran at `cmd_init`, it runs at the point when the coordinator first sees a project. Stories planned later (added after init) would not be picked up. The queue needs to be synced at the transition moment (planning → execution handoff), not only at init.

### 2.3 No observable signal when queue is empty-but-work-remains
`verify.sh` reports IDLE without distinguishing "all stories done" from "stories exist on disk but queue is unpopulated." An agent reading `status: IDLE` has no way to tell whether they should check `plan/user-stories/` for ungated work.

### 2.4 Coordinator has no fallback to disk
The coordinator spec says "trust the checkpoint." When the checkpoint says IDLE, the coordinator asks the user. It never scans `plan/user-stories/` itself to see whether stories exist that have not been queued.

## 3. Proposed Approach

Three stacked mechanisms (resolved 2026-04-19):

1. **Add `checkpoint.sh coordinator --sync`.** Reuse the existing `build_story_queue()` function already in `checkpoint.sh` (lines 175–189), which already reads every `plan/user-stories/*/story.md`, greps `^- execution_order:`, and sorts numerically. Expose it as a `--sync` flag on `cmd_coordinator`: read the sorted story list, filter out any already in `stories_done`, and write the result as `stories_remaining` and `current_story` in `coordinator.yaml`. Must be idempotent and safe to run repeatedly. No new script file — single source of truth is the existing `build_story_queue()` helper. Also remove the dead `sync-coordinator.sh` lookup in `cmd_init` (lines 837–856) and replace it with a direct `cmd_coordinator --sync` call. Update `sdlc-planner.md` Phase 7 step 2 to invoke `checkpoint.sh coordinator --sync` instead of the non-existent `sync-coordinator.sh`.

2. **Invoke `--sync` on every planner→execution transition AND on every `--story-done` call.** The sync step becomes part of the `--story-done` handler in `cmd_coordinator`, immediately before computing `current_story` from the queue. This way the queue always reflects the current state of `plan/user-stories/` whenever a story boundary is crossed.

3. **Honor `pause_after` in `coordinator.yaml`.** When `--story-done` completes a story, the handler checks whether the completed story matches a `pause_after: US-NNN` value. If so, `active_hub` is cleared (IDLE), but `stories_remaining` and `pause_after` are preserved, and `verify.sh` emits a distinct `status: PAUSED` recommendation ("resume with /sdlc-continue" rather than "ask user what to do"). This is the canonical opt-in review gate: the default is auto-advance; `pause_after` is how the user requests a stop.

4. **Add a fallback discovery path in the coordinator agent.** When `verify.sh` reports `IDLE` (not `PAUSED`), the coordinator agent (not the script) should verify by globbing `plan/user-stories/*/story.md` and comparing against `stories_done`. If ungated stories exist, the coordinator re-runs `checkpoint.sh coordinator --sync` and retries `verify.sh` before asking the user. This prevents the "queue was never populated" failure mode from stopping the pipeline entirely, and distinguishes a legitimate idle (all stories done) from a corrupted-queue idle.

## 4. Expected Impact / ROI

**Primary impact:** Eliminates the most frequent manual intervention point in the pipeline. In the baseline transcript, every story completion required a user reply to re-start execution. With 12 planned stories, this translates to at least 11 unnecessary handoffs per project (on top of any the user actually wants). Each handoff also resets coordinator context that then needs re-loading.

**Secondary impact:** Restores the planning→execution handoff guarantee. Planners produce a story graph; execution should consume it. Currently the graph is disconnected from the runtime because `stories_remaining` is never wired up.

**Tertiary impact:** Unblocks future multi-story metrics. With stories consumed sequentially and automatically, we can measure end-to-end project completion cost (currently impossible because the pipeline halts between stories).

**ROI consideration:** This is a tiny script (likely <100 lines of bash) with outsized unblocking effect. The fix cost is low; the unblocking value is "the system actually works as designed."

## 5. Success Metrics (for post-run verification)

Each metric is measurable from transcript and `.sdlc/` state:

- **M1 (hard):** After `checkpoint.sh coordinator --story-done <story>` in a multi-story run, `verify.sh` reports `hub: execution` and `current_story: <next-story>` (NOT `hub: null`). Verifiable by grepping verify.sh output in the transcript.
- **M2 (hard):** The coordinator never asks the user "what would you like to do next?" or equivalent between two stories that exist in `plan/user-stories/`. Verifiable by grepping coordinator messages for the phrase "start/continue planning, or begin a new implementation story."
- **M3 (hard):** `.sdlc/coordinator.yaml` contains a non-empty `stories_remaining: [...]` list at every point after planning completes, until all stories are done. Verifiable by inspecting checkpoint snapshots captured in the transcript.
- **M4 (soft):** End-to-end multi-story runs complete without user intervention between stories (excluding user-requested review milestones). Observable by counting user messages in the transcript between story-done events.
- **M5 (regression guard):** In a repository with a populated `plan/user-stories/` tree, running `checkpoint.sh coordinator --sync` exits 0 and produces a `coordinator.yaml` whose `stories_remaining` equals the disk-ordered story list minus `stories_done`. A shell test or CI check exercises this invariant. Additionally, `grep -r sync-coordinator.sh opencode/` returns zero matches (the dead reference is removed) — a lint check prevents future "documented script that does not exist" regressions by requiring every script path mentioned in agents/skills/scripts to resolve to a real file.

## 6. Risks & Tradeoffs

- **Risk:** Auto-advance could silently start a story the user did not intend to run (e.g., they wanted to stop after US-002 to review). **Mitigation:** the `pause_after: US-NNN` field in `coordinator.yaml` is the canonical opt-in pause mechanism. When the completed story matches `pause_after`, the coordinator clears `active_hub` (PAUSED state), preserves `stories_remaining`, and waits for the user. The default is auto-advance; pausing requires an explicit field value. Users set `pause_after` at plan time or mid-run via a coordinator instruction.
- **Risk:** If `execution_order` metadata is missing or inconsistent on a story, `build_story_queue()` falls back to `999` (the existing default in `checkpoint.sh:184`), which effectively sends un-annotated stories to the end of the queue in alphabetical order. This is almost always correct but may surprise users who reordered stories without updating metadata.
- **Risk:** Syncing on every `--story-done` call adds a disk-glob on every story boundary. Cost is negligible (~dozens of files).
- **Tradeoff:** The coordinator agent fallback to glob `plan/user-stories/` somewhat duplicates responsibility with the script's `--sync` path. Prefer the script path; treat the agent fallback as a defense-in-depth measure that logs a warning when it triggers (and should only trigger if `--sync` was never called or produced an empty queue despite stories existing on disk).

## 7. Resolved Questions

All four questions from the original draft are now resolved (2026-04-19).

1. **Where does `execution_order` live, and how is the queue derived?** → **Resolved.** The canonical location is already established: `story.md` files carry a `- execution_order: N` list item under the `## Dependencies` section (per `planning-stories/references/STORY-OUTLINE.md` and `DEPENDENCY-MANIFEST.md`). The existing `build_story_queue()` helper in `checkpoint.sh` (lines 175–189) already reads this format by grepping `^- execution_order:` and sorting numerically. **No new script is needed.** The fix is to expose this helper as `checkpoint.sh coordinator --sync`, have the planner call it at Phase 7, and have `cmd_coordinator --story-done` call it internally before computing the next `current_story`. This keeps the single source of truth in `checkpoint.sh` and eliminates the missing-script problem entirely.
2. **Mid-execution story additions.** → **Moot.** Stories are only added at plan time; there is no supported workflow that injects new stories mid-run. The sync step on every `--story-done` is sufficient to cover the legitimate case (edits to already-planned stories). A note in `sdlc-planner.md` should clarify that re-planning mid-run requires re-entering Phase 7 (which re-invokes `--sync`).
3. **Should the coordinator honor `pause_after`?** → **Confirmed, implement.** Users want the ability to set review gates without disabling auto-advance wholesale. `coordinator.yaml` gains an optional `pause_after: US-NNN` field. When `--story-done` completes that story, the handler clears `active_hub` (PAUSED), preserves `stories_remaining` and `pause_after`, and `verify.sh` reports `status: PAUSED` with a distinct recommendation (resume via `/sdlc-continue`, clear `pause_after` to move on). See §3 mechanism 3 and §6.
4. **Blocker escalation interaction.** → **Confirmed moot.** The engineering hub's blocker path does not call `checkpoint.sh coordinator --story-done`; it escalates without marking the story done. Therefore auto-advance is not triggered on a blocker. The coordinator-agent fallback in §3 mechanism 4 only activates on `status: IDLE` (not `BLOCKED`), so it cannot accidentally advance past a blocked story either.

## 8. Affected Agents and Skills (preliminary)

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/skills/sdlc-checkpoint/scripts/checkpoint.sh` | Modified | Add `cmd_coordinator --sync` flag that reuses the existing `build_story_queue()` helper (lines 175–189) to rebuild `stories_remaining` and `current_story` from disk, filtering `stories_done`. Wire `--story-done` to call `--sync` before computing the next `current_story`. Honor `pause_after`: when the completed story matches, clear `active_hub` but preserve `stories_remaining` and `pause_after`. Remove the dead `sync-coordinator.sh` lookup in `cmd_init` (lines 837–856) and replace it with a direct `cmd_coordinator --sync` call. |
| `opencode/.opencode/skills/sdlc-checkpoint/scripts/verify.sh` | Modified | Distinguish `PAUSED` (active_hub cleared but `pause_after` matches last done story and `stories_remaining` non-empty) from `IDLE` (genuine completion / empty queue). Emit different recommendations for each. |
| `.sdlc/coordinator.yaml` schema | Modified | Add optional `pause_after: US-NNN` field. Document default (absent = auto-advance). |
| `opencode/.opencode/skills/sdlc-checkpoint/references/api-coordinator.md` | Modified | Document the new `--sync` flag, the `pause_after` field, and PAUSED vs IDLE semantics. |
| `opencode/.opencode/skills/sdlc-checkpoint/references/resume-protocol.md` | Modified | Add `--sync` step to the planner→execution transition. Describe resume-from-PAUSED behavior. |
| `opencode/.opencode/agents/sdlc-coordinator.md` | Modified | Add fallback discovery path: when `verify.sh` reports IDLE but `plan/user-stories/*/story.md` contains ungated entries, re-run `checkpoint.sh coordinator --sync` and retry `verify.sh` before asking the user. Add explicit handling for `status: PAUSED` (report progress, wait for user). |
| `opencode/.opencode/agents/sdlc-planner.md` | Modified | Replace Phase 7 step 2 reference from `sync-coordinator.sh` to `checkpoint.sh coordinator --sync`. Add note that re-planning mid-run requires re-entering Phase 7 to re-sync the queue. |

---

## 9. Relation to Prior Proposals

- Foundational fix. No prior P addressed this because the failure mode only became visible once a run completed a second story and tried to advance.
- Interacts with P7 (scaffolding story ownership) because scaffolding is always the first story. P7's scaffolder signals completion via execution hub; the coordinator then needs the queue populated to know that US-002 is next. Without P9, P7 hands off to IDLE, not to the next feature story.
