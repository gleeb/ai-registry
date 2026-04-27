# P17: Ceremony Scaling Beyond Scaffolding — Task-Class Dispatch Policy

**Status:** Archived (not implemented) — drafted 2026-04-18, archived 2026-04-27.
**Relates to:** [P1 (Ceremony Scaling and Scaffolding)](./P1-ceremony-scaling-and-scaffolding.md) — extends P1's scaffolder-specific ceremony reduction to non-scaffolding work; [P15 (Planner Task Risk Annotations)](./P15-planner-task-risk-annotations.md) — archived prerequisite whose removal removes P17's input signal.
**Scope:** `opencode/.opencode/agents/sdlc-engineering.md` (dispatch policy), `opencode/.opencode/agents/sdlc-engineering-implementer.md`, task-shape taxonomy (see P15), dispatch-log schema
**Transcript evidence:** `ses_26105317cffeCAev1W8UP3BtK1` — US-002 had 5 tasks. Trivial tasks (e.g., "create interface file," "wire repository method") received the same dispatch ceremony (implementer + code-reviewer + QA + status update) as the non-trivial tasks (encryption, migration, serialization). Task-level dispatch overhead for a truly tiny task (<30 LOC, no external deps, covered by one trivial test) dominates the actual work.

---

## Why Archived (decision recorded 2026-04-27)

P17 was drafted as the task-level companion to P15's planner-side risk annotations. After P15 was implemented and reverted on 2026-04-27 (see P15's "Why Archived" section), P17 was reviewed against the same criteria and archived without implementation. The reasoning, recorded here for future reference:

### 1. Prerequisite removed — primary input signal no longer exists

P17's own Read Order is explicit: *"P15 — supplies the task-shape annotations P17's Class A/B/C inference consumes. Without P15 the inference has no signal."* Three of the four Class C triggers (`risk: high`, `oracle_preauthorize: true`, multi-library integration via shape vocabulary) are written in P15 vocabulary that no longer exists in the planner contract. The remaining triggers (LOC estimate, library count) are the weakest part of the rationale — both are ad-hoc heuristics without taxonomy backing, and both are post-hoc signals the planner does not currently produce.

P17 could be rewritten around different inputs, but at that point it is a different proposal. The proposal as drafted depends on a contract that has been retracted.

### 2. Functional overlap with reactive systems already in place

| Concern P17 addressed | Existing mechanism that already handles it |
|---|---|
| "Trivial tasks get heavy review" | Code-reviewer adapts to diff size on its own — a 12-line interface diff does not get a 200-line review. The reviewer is not the bottleneck; reviewer dispatch token cost on small diffs is small precisely because the diff is small. |
| "High-risk tasks need more review" | P14 Oracle Escalation Policy triggers reactively (3rd implementer attempt, `doc_queries > 8`, story-reviewer iteration cap hit). Reactive evidence is strictly better than a-priori labels because it is anchored in actual run failure, not in a forecast. |
| "Pre-stage scaffolding for known-shape tasks" | Skills + library cache. When a pattern recurs, the procedure becomes a skill; the skill itself is the mitigation. P15's archive made this point and it applies identically here. |
| "Implementer should self-review on tiny tasks" | The per-task iteration cap and code-reviewer's own diff-aware behavior already make small-diff review cheap. Replacing the reviewer dispatch with implementer self-review trades a fresh-eyes verification for the same eyes that produced the framing error — which is the failure mode the independent reviewer existed to cover. |

The pattern is the same as P15: P17 attempts pre-emptive labeling to optimize a path the existing reactive stack already handles with real evidence at lower or comparable cost.

### 3. Worker-routing inconsistency with the Oracle Escalation Policy

P17 §3.2 specifies that *"the implementer can request a class upgrade (A→B or B→C) when they detect hidden complexity at task kick-off; the hub must approve the upgrade."* This is a worker-originated routing signal — the same shape of cross-layer coupling P14's "workers do not route" governor (P14 §2.5) explicitly forbids and that P15's archive called out as a reason to revert. Keeping P17 would force either a special-case carve-out or a re-litigation of that governor.

### 4. Hypothesis-based metrics

The success metrics ("≥40% fewer dispatch tokens for Class A," "<30% auto-upgrade rate," "~150K tokens saved per story") are forecasts drawn from one transcript with no baseline measurement. P15's archive flagged this as a tell that the cheaper path is to skip the forecasting layer and let post-run gotchas do the pruning of agent/skill behavior directly. The same critique applies.

### 5. Self-review as the substitute for review is the riskiest claim

P17 §3.3 proposes that for Class A tasks, lint + typecheck + a checklist replace the code-reviewer dispatch. That is not a ceremony reduction — it is a verification reduction. The thing a fresh-eyes reviewer catches that lint cannot is exactly the thing a self-reviewing implementer also cannot catch: their own framing errors. The mitigation ("auto-upgrade on checklist failure") only fires when the implementer recognizes a failure, which is the situation the independent reviewer existed to cover. Without measured evidence that small-diff reviewer findings are dominated by Suggestion-class verdicts, removing the reviewer is a safety-budget reduction, not an efficiency gain.

### 6. No observed signal that motivates this change

P17 cited a single transcript (`ses_26105317cffeCAev1W8UP3BtK1`) and the assertion that ~8 of ~35 Phase 2 dispatches were reviewer/QA on plausibly Class A work. No baseline measurement of reviewer findings on those small diffs exists. If reviewers were producing Suggestion-only verdicts on every small diff, that would justify revisiting; that data has not been collected.

### What survives from this exploration

- **The Class A/B/C frame as vocabulary.** This file (now archived) preserves the three-tier framing and the self-review checklist contents. Future planning-gotchas entries that reach for similar concepts can cite it as prior art rather than re-deriving.
- **The metrics as post-hoc questions.** M2 ("Class A consumes ≥40% fewer dispatch tokens") and M5 ("Class A tasks do not have higher Phase 3 findings than Class B tasks of similar scope") are good questions to ask of dispatch logs even without the policy change. If a future cycle's logs show reviewers consistently producing Suggestion-only verdicts on small diffs, *that* is the evidence that justifies revisiting a slimmer P17 — likely without the implementer-side upgrade signal and without the self-review-replaces-review claim.
- **The existing reactive stack is sufficient until proven otherwise.** No further action required. Likely candidates for a future slimmer revision: drop the implementer-side class-upgrade signal entirely, drop the self-review-replaces-reviewer claim, key any ceremony reduction on observed reviewer-finding patterns rather than planner forecast.

### Implementation footprint

P17 was not implemented. No code or spec changes were made. Archival is a pure documentation move plus cross-reference updates in P18, P22, and INDEX.md.

---

## Read Order

**Prerequisites** (read / land first):
- **P1** (archived) — P17 extends P1's scaffolder-only ceremony reduction to feature stories.
- **P15** — supplies the task-shape annotations P17's Class A/B/C inference consumes. Without P15 the inference has no signal.

**Consumers** (depend on this proposal):
- **P18** — task-level (P17) and story-level (P18) scaling share the same planner annotation input; should be designed together.

**Suggested reading order** (earlier 2026-04-18 cluster): P15 → **P17 (you are here)** → P18.

---

## 1. Problem Statement

P1 established ceremony reduction for scaffolding stories (which have a different shape than feature work). Within feature stories, ceremony is flat: every task gets the full implementer → code-reviewer → QA → status-update sequence regardless of the task's size or risk.

This is wasteful for tiny or mechanical tasks. A task that adds a 12-line interface file with a matching 20-line test does not need an independent code-reviewer + QA pair — the implementer can self-review with a checklist and move on. Conversely, it's insufficient for tasks flagged high-risk (per P15): a CDP-adjacent task may warrant Oracle + code-reviewer + QA + a browser-evidence reviewer, not just the standard three.

Ceremony should scale with task class. Currently it's constant.

## 2. Root Cause Analysis

### 2.1 Dispatch policy is task-agnostic
`sdlc-engineering.md` Phase 2 dispatch logic treats every task as equivalent shape. There's no branching on task size, task shape, or task risk.

### 2.2 No objective task-size signal
Even if we wanted to scale by size, nothing in the current pipeline produces a pre-execution size estimate. (LOC touched, files touched, libraries touched are all post-hoc.) A small amount of planner-side estimation would suffice.

### 2.3 "Consistency" as an implicit value
There may be a learned instinct that applying the same ceremony to every task is "fair" or "rigorous." In practice it creates a lot of noise around trivial work and hides risk on non-trivial work.

### 2.4 Reviewer dispatches are cheap individually, expensive aggregated
One code-reviewer dispatch for a 12-line change is ~20K tokens. Across 5 tasks in a story where 2 are trivial, that's 40K tokens of low-value review. Across 10 stories in a project, ~400K. A 20% reduction on that alone is material.

## 3. Proposed Approach

Three-tier dispatch policy (implementation details TBD):

1. **Task classes.** Every task resolves to one of three classes based on planner-provided or implementer-confirmed signals:
   - **Class A (lightweight):** < 50 LOC expected, zero or one library, no risk annotation, no cross-file coordination. Dispatch policy: implementer self-review with checklist → status update. No independent reviewer or QA unless self-review flags concerns.
   - **Class B (standard):** default class. Dispatch policy: current ceremony (implementer → code-reviewer → QA → status update).
   - **Class C (heavyweight):** `risk: high` or `oracle_preauthorize: true` (per P15) or > 200 LOC expected or multi-library integration. Dispatch policy: Oracle advisory dispatch → implementer → code-reviewer → QA → (if browser/perf-sensitive) specialized reviewer → status update.

2. **Class inference and override.** The planner produces a class suggestion alongside P15 shape annotations. The implementer can request a class upgrade (A→B or B→C) when they detect hidden complexity at task kick-off; the hub must approve the upgrade. Downgrades require a stronger justification.

3. **Self-review contract for Class A.** Implementer self-review for Class A tasks uses an explicit checklist:
   - Lint + typecheck clean.
   - Test present and meaningful.
   - No new external dependency without planner approval.
   - No changes outside the task's declared scope.
   - AC binding (P16) confirmed.
   On any checklist failure, task auto-upgrades to Class B and dispatches a code-reviewer.

## 4. Expected Impact / ROI

**Primary impact:** Reduces dispatch count and token cost for trivial work. In this run, ~8 of ~35 Phase 2 dispatches were reviewer/QA on work that would plausibly have been Class A. Removing them saves ~150K tokens per story conservatively.

**Secondary impact:** Frees reviewer/QA attention for Class B and Class C work. When reviewers are dispatched on 5 trivial tasks out of 7, they develop rubber-stamp instincts that hurt the 2 non-trivial reviews. Scaling prevents this.

**Tertiary impact:** Makes ceremony proportional to risk. Combined with P15's annotations and P14's Oracle routing, high-risk tasks receive more review, low-risk tasks receive less. The total ceremony budget is better allocated.

**ROI consideration:** Medium implementation cost (dispatch-policy changes across hub + specs). Direct savings per story ~10–15% of dispatch cost. Compounds with P10/P11/P14 savings; this proposal on its own is solid but not transformative.

## 5. Success Metrics (for post-run verification)

Measurable from dispatch log and plan artifacts:

- **M1 (hard):** Every task has a declared class (A/B/C) in the task-context doc. Verifiable by staging-doc parse.
- **M2 (hard):** Class A tasks consume ≥ 40% fewer dispatch tokens than Class B tasks of similar LOC. Baseline: no such distinction exists.
- **M3 (hard):** Class A auto-upgrade events (self-review failed, dispatched reviewer) are logged. Rate should be < 30% — if higher, the class-inference heuristic is too aggressive.
- **M4 (soft):** Reviewer dispatch quality rises on Class B/C tasks (fewer Suggestion-class-only verdicts, more substantive findings). Qualitative.
- **M5 (regression guard):** Class A tasks do not have higher Phase 3 story-review findings than Class B tasks of similar scope. If they do, the lightweight ceremony is missing things.

## 6. Risks & Tradeoffs

- **Risk:** Class-A tasks ship bugs that Class-B review would have caught. Mitigation: self-review checklist is strict; lint + typecheck clean is required; auto-upgrade on any checklist failure. Bad Class A should self-escalate.
- **Risk:** Planners misclassify as A to reduce apparent cost. Mitigation: the planner's signal is a suggestion, not a contract; the implementer confirms/upgrades at kick-off; the story reviewer can retroactively flag "this should not have been Class A."
- **Risk:** Implementers degrade their self-review rigor over time. Mitigation: periodic auditing — sample Class A tasks and validate that self-review caught what a reviewer would have caught.
- **Tradeoff:** Class-C work becomes more expensive (added Oracle advisory + specialized reviewer). Accepted; this is high-risk work where the extra cost pays for itself.

## 7. Open Questions

1. Who writes the self-review checklist? Generic or shape-specific? Proposal: generic baseline + shape-specific additions (e.g., browser-automation shape adds "Playwright test runs clean in CI" to the checklist).
2. Can a task have class B for implementation but class A for review? Probably overengineering; start with unified class.
3. Should there be a Class D (purely generative or cosmetic, e.g., adding a README snippet)? Probably not — keep three classes, let trivial-trivial fall in Class A.
4. How does class interact with the per-task iteration cap? Class A with self-review failure auto-escalates to B and starts the B cap fresh, or inherits the A attempts? Proposal: fresh B cap.

## 8. Affected Agents and Skills (preliminary)

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-engineering.md` | Modified | Phase 2 dispatch policy branches on task class. |
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | Modified | Self-review checklist for Class A. Auto-upgrade protocol. |
| `opencode/.opencode/agents/sdlc-planner.md` | Modified | Planner produces class suggestion alongside P15 shapes. |
| Task-context template | Modified | Add `class` field with allowed values (A/B/C) and history (upgrades). |
| Dispatch-log schema | Modified | Capture class per dispatch for post-run analysis. |

---

## 9. Relation to Prior Proposals

- Extends P1 from scaffolding-specific to general-purpose ceremony scaling.
- Depends on P15 for the shape/risk annotations that feed class inference.
- Complementary to P14 (Oracle threshold) — Class C triggers proactive Oracle, Class A and B follow the reactive triggers.
- Paired with P16 (AC traceability), Class A's self-review checklist explicitly includes AC-binding confirmation.
