# P18a: One Coordinator → Hub Trip Per Story (End-to-End Completion Contract)

**Status:** Resolved (Implemented 2026-04-27). Supersedes [P18 (archived)](./P18-hub-coordinator-reset-boundary.md).
**Relates to:** [P9](./P9-coordinator-story-queue-advance.md) (between-story coordinator auto-advance), [P10](./P10-story-reviewer-severity-guard.md) (story-reviewer iteration cap), [P11](./P11-acceptance-validator-readonly.md) (acceptance-validator read-only), [P14](./P14-oracle-escalation-threshold.md) (Oracle escalation), [P15 (archived)](./P15-planner-task-risk-annotations.md), [P17 (archived)](./P17-ceremony-scaling-feature-stories.md), [P18 (archived)](./P18-hub-coordinator-reset-boundary.md)
**Scope:** `opencode/.opencode/agents/sdlc-engineering.md` (Completion Contract + Dispatch Protocol), `opencode/.opencode/agents/sdlc-coordinator.md` (Phase 3 Dispatch + Phase 4 Progress Synthesis).
**Transcript evidence:** Same as P18 — `ses_26105317cffeCAev1W8UP3BtK1` and `ses_26105317cffeCAev1W8UP3BtK1-continued`. Hub return summaries showed within-story round-trips at coordinator boundaries that the hub's own end-to-end contract was supposed to prevent.

---

## 1. Problem Statement

The engineering hub's documented completion contract is end-to-end: dispatch once per story, run Phases 0a → 6, return a terminal verdict. In practice the hub returns at intermediate slices and the coordinator re-dispatches per a residual "what should I do next?" pattern in the hub's Completion Contract (`sdlc-engineering.md` line 836: *"open questions, deviations from plan, and anything the coordinator must decide next"*). The coordinator then synthesizes that recommendation in its Phase 4 Progress Synthesis and re-dispatches.

The result is 3–4 within-story coordinator↔hub round-trips when one was intended. Cost is not the dollar bill (cache reads dominate, those are cheap); the cost is **agent focus and attention**: long sub-sessions degrade quality (the canonical example is the 7h15m acceptance-validator over-run inside a 7h53m hub dispatch), and unnecessary coordinator turns inflate user-visible latency and transcript noise.

P18 attempted a bimodal fix gated on P15 annotations. With P15 archived, P18a takes the simpler and equally effective path: lock the existing implicit end-to-end flow into an explicit contract.

## 2. Root Cause Analysis

### 2.1 Hub completion contract solicits a recommendation it should not produce

`sdlc-engineering.md` Completion Contract item 5 (line 836) reads:

> Risks and constraints — open questions, deviations from plan, and **anything the coordinator must decide next**.

Read at runtime, the hub interprets this as "produce a list of things you want the coordinator to decide on" — i.e., a recommendation. That contradicts the autonomy principle stated at line 41 ("This agent runs fully autonomously. NEVER ask the user for confirmation, clarification, or approval during execution") because routing decisions ARE coordinator decisions, and asking the coordinator to make them is the inversion of authority P18 §2.1 identified.

### 2.2 Hub return verdicts are not enumerated

The coordinator handles a fan of return shapes — `STORY STATUS: COMPLETE`, `BLOCKER: MISSING_CREDENTIALS`, `ACCEPTED-STUB-ONLY`, generic blockers, semantic-review escalations — but there is no canonical enum the hub must emit. New verdict shapes accrete over time and the coordinator's verdict-handling logic becomes a string-matching surface. A small enum (`done | blocked | escalated`) carrying a free-form `reason` string is enough to keep coordinator logic deterministic.

### 2.3 No explicit one-dispatch-per-story rule

The hub's Workflow phases (0a, 0b, 1, 1c, 2, 3, 3b, 4, 5, 6) imply one continuous run, but the spec does not state "one dispatch per story" anywhere. The coordinator's Phase 3 (Dispatch) does not state it either. Without an explicit rule, both agents drift toward whatever the dispatch envelope shape suggests.

## 3. Proposed Approach

Two contract edits, no infrastructure additions.

### 3.1 Engineering hub (`sdlc-engineering.md`)

**a. Make the dispatch contract explicit.** Add a single sentence to the Dispatch Protocol section: each coordinator dispatch corresponds to one story; the hub runs Phases 0a → 6 to a terminal verdict; the hub does not return mid-story progress summaries or solicit re-dispatch.

**b. Replace Completion Contract item 5.** Drop *"anything the coordinator must decide next."* Replace with a constrained statement: deviations and risks for audit purposes only — the hub does NOT recommend coordinator next actions; routing decisions are the coordinator's domain.

**c. Add an explicit verdict enum.** State that the hub returns one of:
- `done` — story completed end-to-end (Phases 0a → 6 cleared, including Phase 6 auto-approve or user-approve). Equivalent to today's `STORY STATUS: COMPLETE`.
- `blocked` — workflow halted on a condition the coordinator must resolve before re-dispatch (missing credentials, milestone pause, plan-change required, defect-incident handoff). Equivalent to today's `BLOCKER: …` and `MILESTONE_PAUSE` shapes.
- `escalated` — workflow halted on a condition requiring user decision relayed via the coordinator (Oracle ESCALATION REPORT, story-review iteration cap with no actionable Oracle/architect remediation, semantic-reviewer flag of unreliable work, acceptance-validation cap reached). Equivalent to today's various Tier 4 and cap-hit escalation paths.

`ACCEPTED-STUB-ONLY` is a sub-flavor of `done` (story is closeable but with a credential-gap caveat the coordinator presents to the user). The verdict carries a structured `notes` block with the per-AC stub-only annotation; the coordinator's existing handling at `sdlc-coordinator.md` line 244 already handles this and is unchanged.

**d. Reaffirm "Phase 2 task-level dispatch is hub-internal."** P18 §3.4 made this point and it is unchanged: per-task implementer/reviewer/QA dispatches are nested inside the hub sub-session. They never surface as coordinator-visible round-trips.

### 3.2 Coordinator (`sdlc-coordinator.md`)

**a. Phase 3 (Dispatch).** Add one sentence: engineering hub dispatches are end-to-end (one per story); the coordinator does not request mid-story progress reports.

**b. Phase 4 (Progress Synthesis).** Replace the generic "decide next action" language with verdict-keyed routing:
- `done` → Story Completion Transition (already specified).
- `blocked` → classify per Escalation Taxonomy (already specified — Operational / Knowledge / Product-Planning / Missing-Credentials / Oracle-Escalation Reports). The taxonomy stays; the trigger that enters it just shifts from "hub returns blocker" to "hub returns `blocked`."
- `escalated` → user-decision path (the existing Oracle escalation handling).

The coordinator does NOT interpret a free-form recommendation. It maps the verdict + reason to a routing decision using the existing taxonomy.

**c. Trust Hierarchy.** The existing language at lines 150–157 already states the subtask's completion result is authoritative. Reaffirm this in the verdict-keyed routing section so no future drift re-introduces "second-guess the recommendation" behavior.

### 3.3 What is explicitly NOT in P18a

- **No bimodal mode.** No `phase_boundary` option. The hub always runs end-to-end per story.
- **No `dispatch_mode` field on coordinator state.** Not needed.
- **No `coordinator.yaml: phase_boundary` user override.** Not needed.
- **No new dispatch envelope fields.** The existing dispatch templates carry one story per dispatch; that contract becomes explicit, not changed.
- **No context-budget introspection.** Same reasoning as P18 §3.4 — agents cannot see their own context size.
- **No per-task coordinator dispatch.** Phase 2 task-level orchestration stays hub-internal.

## 4. Expected Impact / ROI

**Primary impact.** Within-story coordinator↔hub round-trips drop from observed 3–4 per complex story (US-003 chain) and 2–3 per simple story to a flat 1 per story. The defect was contract drift, not architecture; the fix is a contract edit.

**Secondary impact.** Coordinator routing logic becomes a small switch on `done | blocked | escalated` instead of a string-match surface across accreting verdict shapes. Easier to audit, easier to extend.

**Tertiary impact.** Transcripts become trivially indexable: one parent coordinator turn per story, one nested hub sub-session per story, named.

**ROI consideration.** This is a docs/prompt change, not a code change. Implementation cost is two file edits totaling a few dozen lines. The defect being fixed is a known runtime pathology with clear transcript evidence. Net win.

## 5. Success Metrics (for post-run verification)

All measurable from transcripts and the dispatch log.

- **M1 (hard):** Every story produces exactly one coordinator → engineering hub dispatch event from STATE_READY (or STATE_IN_PROGRESS resume) to STATE_DONE for that story. Verifiable by counting `coordinator → sdlc-engineering` Task tool dispatches per story in the transcript.
- **M2 (hard):** No hub return message contains free-form "next coordinator action" recommendations beyond the enumerated verdict + reason. Verifiable by grepping hub return summaries for "recommend," "next action," "should I," etc.
- **M3 (hard):** Every hub return message is a `done | blocked | escalated` verdict with a structured `reason` block. Verifiable by parsing return summaries.
- **M4 (soft):** p95 hub sub-session duration drops as a side effect of fewer redispatches inflating the parent. Today's worst case is 7h53m; target < 90 min p95. (Same metric as P18 M4.)
- **M5 (regression guard):** No hub dispatch ever surfaces a mid-story "progress" return that the coordinator interprets as "do this next." If one appears, the contract drift has returned and the spec needs reinforcement.

## 6. Risks & Tradeoffs

- **Risk:** A pathological story consumes excessive context inside one end-to-end hub run before the hub returns `blocked`. Mitigation: the existing reactive stack handles this — P11 (validator path-scoped writes), P14 (Oracle escalation triggers including `doc_queries > 8` and `implementer_attempts >= 2`), P10 (story-reviewer cap of 3), and the per-task QA retry cap (2). Phase-boundary mode would have been belt-and-suspenders; the suspenders are in place.
- **Risk:** A story that does turn out to need user input mid-run gets stuck inside the hub waiting for nothing. Mitigation: this case maps to `blocked` with a `MILESTONE_PAUSE` reason (already specified in `sdlc-engineering.md` Phase 2 step I) or to a Review Milestone trigger (story.md). Both are existing, terminal returns to the coordinator.
- **Risk:** The verdict enum's `escalated` case absorbs too many disparate cases (Oracle, semantic-reviewer flag, acceptance cap) and the coordinator's routing on `escalated` becomes its own string-match surface. Mitigation: the structured `reason` carries the escalation source. The coordinator's Escalation Taxonomy already enumerates the cases — `escalated` just provides the canonical envelope.
- **Tradeoff:** Long single sub-sessions are still possible. Accepted; the worst-case agents (validator, story-reviewer) have their own caps.
- **Tradeoff:** The hub cannot defer "I'm not sure, what do you want?" decisions to the coordinator at runtime. Accepted; this is the autonomy principle the hub already documents (line 41) being made consistent across the contract.

## 7. Open Questions

1. **Should `done` always include the structured per-AC summary** that Phase 4 acceptance produces, or only when stub-only? Proposal: always include — the coordinator can ignore it when not stub-only, but it makes the dispatch log self-describing for retrospective audits.
2. **Should `blocked` be allowed to halt before Phase 0a (e.g., on `MISSING_CREDENTIALS` from the readiness gate)?** Yes — already specified at `sdlc-engineering.md` line 215. The verdict-keyed return is the natural place to formalize that this does not violate "end-to-end" because Phase 0a is end-to-end's first phase, and a Phase 0a halt is still a single coordinator → hub trip.
3. **Should the coordinator log the verdict on `coordinator.yaml`?** Probably yes — a `last_engineering_verdict` field would make `verify.sh` recovery from interrupted state easier. Out of scope for P18a's two-file edit; revisit as a small follow-up if useful.

## 8. Affected Agents and Skills

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-engineering.md` | Modified | Dispatch Protocol: add explicit "one dispatch per story, end-to-end" sentence. Completion Contract: drop "anything the coordinator must decide next"; add `done \| blocked \| escalated` verdict enum with reason structure; reaffirm Phase 2 task-level dispatch is hub-internal. |
| `opencode/.opencode/agents/sdlc-coordinator.md` | Modified | Phase 3 (Dispatch): add "engineering hub dispatches are end-to-end (one per story)" sentence. Phase 4 (Progress Synthesis): rewrite as verdict-keyed routing on `done \| blocked \| escalated`; reaffirm Trust Hierarchy. |

No other agents, skills, or infrastructure files are touched. No checkpoint schema changes. No new templates.

---

## 9. Relation to Prior Proposals

- **P9 (between-story auto-advance):** Complementary. P9 handles boundaries between stories; P18a handles the within-story trip. Neither subsumes the other.
- **P10 (story-reviewer cap), P11 (validator scope), P14 (Oracle escalation):** Implemented reactive caps. Their interaction with P18a is "the hub run is bounded internally even when it's a single end-to-end dispatch." P18a does not change them.
- **P15 (archived):** Was a prerequisite for P18's bimodal mode-selection rule. P18a does not consume planner annotations and is independent of any P15 successor proposal.
- **P17 (archived):** Was the task-level analogue of P18's story-level mode selection. P18a's "Phase 2 task-level dispatch is hub-internal" reaffirmation covers the same surface without the class-A/B/C taxonomy.
- **P18 (archived, superseded):** P18a is the simplified version of P18 stripped of the bimodal architecture and the planner-annotation dependency. The contract-clarity fix (P18 §3.3) is preserved verbatim in P18a §3.1–§3.2.
- **P21 (defect-incident triage), P22 (plan-change protocol):** Both introduce distinct dispatch primitives outside the standard story flow. They are compatible with P18a — defect-incident dispatches and plan-change dispatches are still single-trip operations in their own right; the `blocked` verdict's reason field carries the handoff signal when the hub detects mid-story that one of these is required.
