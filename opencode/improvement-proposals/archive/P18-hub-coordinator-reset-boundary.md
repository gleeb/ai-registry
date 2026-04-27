# P18: Principled Hub ↔ Coordinator Reset Boundary

**Status:** Archived (not implemented) — drafted 2026-04-18, superseded by P18a 2026-04-27.
**Sequencing:** Assumed P15 (planner risk annotations) as a strict prerequisite. P15 was archived 2026-04-27, removing the input signal for P18's bimodal mode-selection rule. P18 was reviewed against the same criteria as P15/P17 and superseded by P18a — a simplified always-end-to-end design that drops the bimodal architecture but keeps the contract-clarity fix that was P18's core value.
**Relates to:** [P9](./P9-coordinator-story-queue-advance.md) (coordinator auto-advance), [P11](./P11-acceptance-validator-readonly.md) (acceptance-validator read-only), [P15 (archived)](./P15-planner-task-risk-annotations.md), [P17 (archived)](./P17-ceremony-scaling-feature-stories.md), [P18a](./P18a-hub-coordinator-end-to-end-contract.md) (successor, implemented)
**Scope:** `opencode/.opencode/agents/sdlc-coordinator.md`, `opencode/.opencode/agents/sdlc-engineering.md`, `opencode/.opencode/skills/sdlc-checkpoint/references/api-coordinator.md`, `opencode/.opencode/skills/sdlc-guide/` (dispatch contract pages)
**Transcript evidence:** `ses_26105317cffeCAev1W8UP3BtK1` and `ses_26105317cffeCAev1W8UP3BtK1-continued` (combined 25h13m, 129 child sessions). Hub return summaries at lines 82149–82357 and coordinator redispatches at 51641–51651 and 82348–82357 show the "recommend next coordinator action" pattern. Nested acceptance-validator sub-session ran 7h15m / ~2.4M input tokens / 32 files modified without returning a verdict (same event as P11's motivating case).

---

## Why Archived (decision recorded 2026-04-27)

P18 was drafted with a bimodal design — `end-to-end` mode for simple stories, `phase-boundary` mode for complex/risky stories — gated by P15's story-level risk annotations. After P15 was archived 2026-04-27 without implementation, P18's mode-selection rule (§3.2) lost its input signal. The mode-selection rule is not the part of P18 that creates value — the contract-clarity fix is — so the proposal was rewritten as **P18a (always-end-to-end)** rather than carrying P18 forward in degenerate form.

### What P18a preserves from P18

The two real findings, both independent of any planner annotation:

1. **Contract conflict (§2.1).** The engineering hub's completion contract declares end-to-end execution per story, but the coordinator's Phase 4 dispatch language and the hub's Completion Contract still solicit a "what should I do next?" recommendation. The coordinator wording wins at runtime, so end-to-end never happens.
2. **No single reset policy (§2.2).** Without an explicit one-dispatch-per-story rule, the hub returns at arbitrary slices and the coordinator re-dispatches per the recommendation — producing 3–4 within-story round-trips on a story that should have taken one.

Both are addressed by P18a's two-file contract edit (`sdlc-engineering.md` + `sdlc-coordinator.md`), with no infrastructure additions and no planner-annotation dependency.

### What P18 attempted that P18a drops

- **Bimodal architecture (§3.1).** Phase-boundary mode required a per-story selection signal. Without P15, the only honest options were "always end-to-end" or "always phase-boundary." Always-phase-boundary inflates round-trips on simple stories without evidence the safety net is needed; always-end-to-end is what the hub's existing completion contract already promises and what was failing only because of the residual coordinator wording.
- **Selection rule (§3.2).** Moot without a signal.
- **`dispatch_mode: end_to_end | phase_boundary` field on coordinator state (§8).** Not added.
- **`coordinator.yaml: phase_boundary` user override (§3.2).** Not added — overrides without a default mode-selection rule are degenerate.
- **M2 metric** (counting 2–4 dispatches on complex stories). Replaced with M1' "exactly one engineering hub dispatch per story" in P18a.

### What handles the pathological-story risk that motivated phase-boundary mode

P18 §6's worry — "simple stories that turn complex mid-run don't get the phase-boundary safety net" — lands on the existing reactive stack in P18a:

- **Hub blocker/escalation** — already in the completion contract.
- **P11** (acceptance-validator read-only) — implemented 2026-04-21. The 7h15m validator over-run that drove P18's worst-case is bounded directly at the validator agent.
- **P14** (Oracle escalation) — implemented 2026-04-26. Reactive triggers (3rd implementer attempt, `doc_queries > 8`, story-reviewer iteration cap hit) catch runtime difficulty without planner forecast.
- **P10** (story-reviewer iteration cap) — implemented 2026-04-21. Caps Phase 3 at 3 iterations.
- **P9** (coordinator auto-advance) — implemented 2026-04-19. Handles between-story boundaries.

Phase-boundary mode would have been belt-and-suspenders. The suspenders are in place.

### What survives from this exploration

- **The "workers do not route" insight.** P18 §3.4's "no per-task dispatch — Phase 2 already dispatches sub-agents per task internally — we already get the per-task reset *inside* the hub's sub-session graph" carries forward into P18a verbatim. This is now reaffirmed in the engineering hub spec.
- **The contract-clarity fix.** P18a implements §3.3's "remove recommend-next-action; return enum-typed verdict" without the bimodal scaffolding around it.

### Implementation footprint that was NOT changed

P18 was not implemented. No code or spec changes were made under P18. P18a's implementation is described in P18a §3.

---

## Read Order

**Prerequisites** (read / land first):
- **P15** — **strict prerequisite**. P18's mode-selection rule (§3.2) consumes P15's story-level risk annotations; without P15, P18 collapses to "always end-to-end" and misses the complex-story case entirely.
- **P9** — handles between-story boundaries; P18 handles within-story boundaries. Read P9 first to understand what P18 does NOT cover.
- **P11** — bounds the acceptance validator directly; P18 narrows the ambient context the validator inherits. Defense in depth; read P11 to understand the orthogonal validator mitigation.
- **P17** — task-level ceremony scaling; P18 is the story-level analogue. Designed together from the same planner annotation input.

**Consumers** (depend on this proposal):
- **P21** — incident dispatch is a distinct reset boundary from P18's phase boundaries. Compatible, orthogonal. P21 readers should know P18 exists so they don't conflate the two.
- **P22** — plan-change dispatch is another distinct reset boundary. Same compatibility note.

**Suggested reading order** (earlier 2026-04-18 cluster): P15 → P17 → **P18 (you are here)**.

---

## 1. Problem Statement

The engineering hub and the coordinator currently round-trip multiple times within a single story. The hub does a phase's worth of work, returns a "concise progress summary" with a "recommended next coordinator action", the coordinator re-dispatches the hub per that recommendation, and the loop repeats 3–4 times before the story closes. US-003 took four separate hub dispatches to complete.

This is not what either agent's contract is supposed to say:

- The hub's **completion contract** ([opencode/.opencode/agents/sdlc-engineering.md](../.opencode/agents/sdlc-engineering.md) line ~77) declares end-to-end execution: dispatch once per story, return when the story is done or blocked.
- The hub's **dispatch protocol** (same file, line ~72) concedes mid-story progress returns.
- The coordinator's **Phase 4: Progress Synthesis** ([opencode/.opencode/agents/sdlc-coordinator.md](../.opencode/agents/sdlc-coordinator.md) lines 107–113) explicitly instructs the hub to return a progress summary with a recommended next coordinator action.

The two contracts directly contradict each other. In practice the coordinator's wording wins, because the hub reads the dispatch message at the start of each dispatch and complies with it. The result is that "end-to-end" never happens.

Two problems follow from that:

1. **Unnecessary coordinator turns.** Each extra round-trip costs coordinator output tokens, user-visible latency, and transcript noise. The coordinator parses a summary it could have inferred from checkpoint state, and issues a near-identical redispatch.
2. **Uneven context accumulation across sub-sessions.** Some hub dispatches are small (Phase 1b context load). Others balloon enormously — the worst we've observed is the US-003 acceptance validator running 7h15m / ~2.4M input tokens / 32 files modified before the parent coordinator exhausted the user's token budget. At that scale, attention degrades: the validator exceeded its read-only contract, looped on the same files, and stopped returning coherent verdicts. P11 addresses that one agent; P18 addresses the general shape.

A third factor bears mention and then dismissal: the long silences in the transcript (1h30m and 5h gaps between top-level coordinator turns) are user-side token-budget resets, not pipeline stalls. They look like coordinator idleness but they're not evidence of anything the pipeline should fix. The pipeline-side problem is purely the *within-story* round-tripping, not the *between-story* silences (those are P9).

## 2. Root Cause Analysis

### 2.1 Coordinator contract asks for a recommendation the hub should never be giving

The hub is the domain expert on its own workflow. The coordinator asking "what should I do next?" inverts the intended authority: the hub should be running its own workflow to completion and reporting results, not solving the coordinator's dispatch problem for it. The current wording ("recommended next coordinator action") comes from an earlier iteration where the hub was still being defined; it's stale.

### 2.2 No single reset policy, so every dispatch carves an arbitrary slice

Because there's no stated rule about *when* the hub is supposed to return, the hub returns whenever its current prompt feels "complete enough" and defers the rest via the recommend-action field. That produces slices that don't correspond to any named phase — sometimes it returns mid-Phase-2, sometimes after Phase 3 review iteration 2, sometimes only after Phase 4. Transcripts are hard to reason about and per-sub-session context sizes are unpredictable.

### 2.3 Agents cannot introspect their own context length

Per-step metadata (input tokens, cache-read, output) is written to the transcript after each step but the model cannot see its own past-step metadata during planning. Cumulative session length is not surfaced to the model as a first-class value. opencode does not inject a "budget used X of Y" system message today. So any rule that says "return when your context is high" is wishful thinking the hub cannot reliably satisfy.

This rules out budget-driven resets as the primary mechanism. Phase-boundary resets are what remains, because phase transitions are events the hub can observe directly in its own workflow.

### 2.4 Risk-informed planning exists but isn't consumed here

P15 introduces planner-level task risk annotations (`browser-automation`, `cdp-interaction`, `cross-package-refactor`, etc.). Those annotations are the natural input to a per-story decision about how much ceremony a hub dispatch deserves. P18 is where that input finally gets used. P18 is sequenced explicitly after P15 because P18's selection rule has no meaningful signal without P15's annotations.

## 3. Proposed Approach

**Planner-driven adaptive reset boundary.**

### 3.1 Two modes

- **End-to-end mode.** Coordinator dispatches the hub once per story. Hub runs Phases 1b → 2 → 3 → 4, reports a terminal result (done or blocked), does not solicit redispatch.
- **Phase-boundary mode.** Coordinator dispatches the hub separately for each phase transition: Phase 1b (context), Phase 2 (implement + code review loop), Phase 3 (story review), Phase 4 (acceptance). 2–4 dispatches per story. The hub's return at each boundary is terminal for that phase — no "recommended next action".

### 3.2 Selection rule

Driven by P15 annotations on the story (P15 is a prerequisite):

- **Simple story** — ≤2 tasks AND no risk shapes → end-to-end mode.
- **Complex/risky story** — ≥3 tasks OR any risk shape → phase-boundary mode.

A user override is available via a `coordinator.yaml: phase_boundary: true | false` hint, which wins over the rule when set explicitly. This is the escape hatch for stories whose annotations turn out to be misjudged in practice.

### 3.3 Contract changes

- **Coordinator Phase 4 language.** Remove "recommend next coordinator action" from the dispatch contract. Replace with: in end-to-end mode, the hub reports one of `done | blocked | escalated`; in phase-boundary mode, the hub reports `phase-complete | phase-blocked` and includes which phase. In neither mode does the hub propose the next coordinator step.
- **Hub completion contract.** Make the behavior explicit and bimodal. Add a short "current mode" directive to each dispatch so the hub knows whether it's running end-to-end or for a single phase.
- **Acceptance validator reset (P11) remains orthogonal.** Regardless of hub mode, the validator runs with its own read-only, budget-capped contract. Phase-boundary mode happens to give the validator a fresh sub-session boundary for free, which is a bonus, but it's not the only mitigation.

### 3.4 What *not* to build

- No context-budget introspection plumbing. Agents can't see their own context today, and adding a pre-turn injection just to satisfy "return when high" adds complexity for limited gain. If phase-boundary mode turns out not to be enough for the worst-case stories, revisit.
- No per-task dispatch. Too chatty, too much coordinator-turn overhead, and the hub's Phase 2 already dispatches sub-agents per task internally — we already get the per-task reset *inside* the hub's sub-session graph. Per-task coordinator-level dispatch would be redundant.

## 4. Expected Impact / ROI

**Primary impact:** Simple stories stop round-tripping. US-005–class stories should go from 2–3 coordinator↔hub round-trips to 1. Complex stories (US-003 class) should go from 4+ to 2–3, with named phase boundaries instead of arbitrary slices.

**Secondary impact:** Worst-case sub-session length drops. The 7h15m validator over-run happened inside a 7h53m hub dispatch — phase-boundary mode naturally scopes Phase 4 to its own fresh dispatch, which caps the validator's ambient context at the Phase 4 handoff bundle rather than the full Phase 3 churn above it. This does not *replace* P11's fix but it narrows the blast radius.

**Tertiary impact:** Transcripts become sensible to analyze. Each sub-session corresponds to a named thing: "US-003 Phase 2", "US-003 Phase 3". Right now sub-sessions are arbitrary and hard to index.

**ROI consideration:** This is a docs/prompt change, not a code change. Fix cost is low. The unblocking value is that the hub's completion contract stops contradicting the coordinator's dispatch contract, and the worst-case sub-session attention problem gets a cap.

**Cost-vs-focus framing (responding to the user's question):** Cache-read tokens dominate the token bill, so the dollar cost of the redispatches is small. The actual cost is **agent focus and attention**: long sub-sessions show quality degradation (the validator over-run is the canonical example), and unnecessary coordinator turns inflate the user-visible latency of a story. P18 reduces the focus cost far more than the dollar cost, and the user should evaluate it on that axis.

## 5. Success Metrics (for post-run verification)

All measurable from transcripts and checkpoint state:

- **M1 (hard):** In simple stories (per P15 annotations), the coordinator issues exactly one engineering hub dispatch per story. Verifiable by counting coordinator→engineering dispatch events per story in the transcript.
- **M2 (hard):** In complex/risky stories, the coordinator issues 2–4 engineering hub dispatches per story, each corresponding to a named phase. Verifiable by matching dispatch messages against phase identifiers.
- **M3 (hard):** No hub return message includes the phrase "recommended next coordinator action" or equivalent. Verifiable by grepping hub return summaries.
- **M4 (soft):** p95 hub sub-session duration drops below 90 minutes. Today's worst case is 7h53m.
- **M5 (soft):** p95 hub sub-session input tokens drop below 500K. Today's worst case is ~2.4M.
- **M6 (regression guard):** No hub dispatch exceeds 60 minutes in end-to-end mode without a phase checkpoint; if it does, the story should have been routed to phase-boundary mode and P15 annotations probably missed it. This is a planner-feedback metric, not a hub metric.

## 6. Risks & Tradeoffs

- **Risk:** Simple stories that turn out to be complex mid-run don't get the phase-boundary safety net. Mitigation: the hub's own blocker/escalation path (already in the completion contract) still works — if a simple story stumbles, the hub returns `blocked`, the coordinator can re-route in phase-boundary mode for the next dispatch.
- **Risk:** Phase-boundary mode loses some context between phases (the implementer's design rationale from Phase 2 isn't automatically present in Phase 3). Mitigation: P16 (per-task AC traceability) and the task-context docs already carry the necessary state across phase boundaries. If they don't, that's a P16 gap, not a P18 gap.
- **Risk:** Coordinators may not reliably infer the mode from P15 annotations. Mitigation: explicit selection rule in §3.2; the coordinator can always be manually overridden via `coordinator.yaml`.
- **Tradeoff:** Phase-boundary mode costs more coordinator turns than end-to-end for a given story (2–4 vs 1), but fewer than the current unbounded pattern (which hits 4+ for complex stories anyway and 2–3 for simple ones). Net win.
- **Tradeoff:** Not building budget introspection means we can't react to genuinely pathological context growth within a single phase. Acceptable — P11 handles the one known pathological agent (the validator); if a different agent shows the same pattern, we can add budget plumbing later.

## 7. Open Questions

1. **Phase 2 is itself iterative** (implementer → reviewer → implementer → reviewer for each task). Is the phase boundary drawn *around* the whole Phase 2 iteration, or *inside* it (e.g. "return after each review iteration")? Inside is chattier but caps per-sub-session context more tightly. Around is cleaner. Recommendation leans toward "around" for the first version, with an explicit metric (M4/M5) that tells us if per-iteration splits become necessary.
2. **Interaction with P17 (ceremony scaling).** P17 proposes Class A/B/C task-level ceremony scaling. P18 proposes story-level dispatch-mode selection. They're compatible but the planner annotation that drives P17 ("task class") is similar to the one that drives P18 ("story risk"). Worth deciding whether one annotation serves both or they're distinct. Since both depend on P15, this is best decided when P15 is specified.
3. **Who writes the phase-boundary return summary in phase-boundary mode?** The hub, the outgoing Phase agent (implementer/reviewer/validator), or both? Keeping it on the hub is consistent with the current design; delegating to the phase agent reduces hub context but risks inconsistent summary format.
4. **Override precedence.** The `coordinator.yaml: phase_boundary` user override wins over P15-driven selection. Should there be a *per-phase* override (e.g. "force phase-boundary for Phase 4 specifically") for projects where the validator is the only pain point? Probably yes, but not in v1.

## 8. Affected Agents and Skills (preliminary)

| File | Change Type | Description |
|------|-------------|-------------|
| [opencode/.opencode/agents/sdlc-coordinator.md](../.opencode/agents/sdlc-coordinator.md) | Modified | Phase 4 (Progress Synthesis) dispatch language: remove "recommend next coordinator action"; add mode-selection rule per §3.2; document phase-boundary return semantics. |
| [opencode/.opencode/agents/sdlc-engineering.md](../.opencode/agents/sdlc-engineering.md) | Modified | Completion contract bimodal: document end-to-end vs phase-boundary modes; return enums per §3.3; remove recommendation-of-next-action from the return contract. |
| `opencode/.opencode/skills/sdlc-checkpoint/references/api-coordinator.md` | Modified | Document the `dispatch_mode: end_to_end | phase_boundary` field on coordinator state; document the `phase: 1b | 2 | 3 | 4` field used in phase-boundary dispatch returns. |
| `opencode/.opencode/skills/sdlc-guide/` (whichever page carries dispatch contracts) | Modified | Surface the mode-selection rule in the shared dispatch guide so planning agents know how their annotations feed P18. |
| [opencode/.opencode/agents/sdlc-planner.md](../.opencode/agents/sdlc-planner.md) | Modified (light) | Reference the mode-selection rule so planners know their risk annotations (P15) drive P18 selection. |

---

## 9. Relation to Prior Proposals

- **P9 (coordinator auto-advance):** Handles the *between*-story boundary. P18 handles the *within*-story boundary. Complementary; neither subsumes the other.
- **P11 (acceptance-validator read-only):** Handles the one known pathological agent. P18 provides a structural cap that reduces how much context that agent can inherit in the first place. Defense in depth.
- **P15 (planner risk annotations):** Prerequisite. Supplies the input signal P18's selection rule consumes. P18 is sequenced to land strictly after P15; without P15 annotations, the selection rule has no meaningful signal and the proposal degenerates into "always end-to-end", which misses the complex-story case entirely.
- **P17 (ceremony scaling):** Task-level analogue of P18's story-level mode selection. Should be designed together — the annotation taxonomy in §7 Q3 is the shared design point.
- No prior P addressed the hub↔coordinator round-trip pattern because the previous analyses focused on individual agent contracts rather than the inter-agent dispatch contract.
