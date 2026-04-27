# P21: User-Reported Check and Defect Triage Protocol

**Status:** Implemented — 2026-04-27 (drafted 2026-04-22; resolved decisions 2026-04-27; landed 2026-04-27 across coordinator, engineering hub, implementer, code-reviewer, acceptance-validator, Oracle, and the sdlc-checkpoint api-execution reference)
**Sequencing:** Depends on P19 (needed to reproduce against real endpoints when the reported issue involves external integration). Depends on — and informs — P22 (plan-change protocol) because one of P21's four triage outcomes is "this is a plan gap." Compatible with P18's hub-coordinator reset boundary; P21 introduces a new dispatch mode distinct from story execution.
**Relates to:** P11 (validator read-only — mirrored here for the reproduce step), P14 (Oracle escalation — extended by this proposal to cover complex defect incidents), P16 (AC traceability — consumed during classification), P18 (reset boundary), P19, P20, P22
**Scope:**
- `opencode/.opencode/agents/sdlc-coordinator.md` (new dispatch verb, classification procedure)
- `opencode/.opencode/agents/sdlc-engineering.md` (new `defect-incident` lifecycle mode)
- `opencode/.opencode/agents/sdlc-engineering-oracle.md` (new incident-consult trigger — see P14 amendment)
- Checkpoint state schema (`execution.yaml` extended with `incidents:` list)
- `.sdlc/incidents/` directory for per-incident artifacts
**Transcript evidence:** `ses_24a319c81ffelunHGnCfk7KcBT` — US-004 had been checkpointed as `completed_phases: [0,1,2,3,3b,4,5,6]` when the user reported "I click Choose file and nothing happens." There was no protocol for this. The user had to manually dispatch the engineering hub with an explanation-only request. The hub responded but did not create a task, did not create a staging doc, did not increment any counter, and did not update the checkpoint. When a second issue (401 unauthorized) surfaced, the same ad-hoc pattern repeated. The story was being materially modified while still marked complete.

---

## Read Order

**Prerequisites** (read / land first):
- **P19** — defect-incident reproduction against external endpoints requires real credentials; P21's reproduce step (§3.2 step 1) routes through P19's `MISSING_CREDENTIALS` escalation when `required_env` is unset.
- **P16** — classification (§3.1 step 2) consumes P16's AC→task map to match user-described behaviors to candidate stories. Without P16, the inference is noisier; with P16 it narrows to AC-level matches directly.
- **P20** — the `verify` step (§3.2 step 4) re-runs P20 smoke tests to confirm defects are resolved against real traffic; defects that turn out to be `wire_format` defects escalate back into P20's plan-validation path.
- P14 (light) — P21 §3.3 extends P14 with trigger 5; read P14 to understand the existing four triggers before adding the fifth.
- P18 (light) — P21's defect-incident dispatch is its own reset boundary distinct from P18's phase boundaries; compatible, not conflicting.

**Consumers** (depend on this proposal):
- **P14 trigger 5** — introduced by P21 §3.3; the amended P14 reads P21's defect-incident lifecycle to route external-contract defects to Oracle as first-line investigator.
- **P22** — Category D (plan gap) routes to P22's triage; incidents whose scope grows beyond one-or-two ACs also escalate to P22.

**Suggested batch reading order** (2026-04-22 cluster): P19 → P20 → P16 (amended §3.5) → **P21 (you are here)** → P14 (amended trigger 5) → P22.

---

## 1. Problem Statement

When a user interacts with the system outside the planner→hub→validator flow — reporting a bug, asking "is this supposed to work?", asking "when will this be done?", or discovering a plan gap — the pipeline has no protocol. The coordinator is the only entry point available to the user, but the coordinator's phase router only knows how to route stories that are actively being planned or executed. A user observation against a completed story falls through all the cracks.

Two orthogonal failure modes result:

1. **Classification is missing.** The user reports a behavior. That behavior could mean any of four different things: the feature is already done and the user doesn't know how to use it; the feature is planned for a later story the user hasn't seen yet; the feature is done but broken (a real defect); or the feature was never in the plan at all (a plan gap). The coordinator has no structured way to decide which case applies. In the US-004 transcript, the coordinator defaulted to "dispatch engineering for an explanation" — which handles case 1 well, case 3 partially, and cases 2 and 4 not at all.

2. **Lifecycle is missing.** Once a real defect is identified, there is no engineering-hub mode for "fix a bug in a completed story." The hub treated both US-004 issues as ad-hoc incidents: no incident ID, no iteration counter, no staging document, no reset boundary. The completed story's checkpoint was never updated to reflect that the story was being actively modified. Two full rounds of investigate-fix-verify happened outside the checkpoint system's view.

The user's explicit concern — *"you mention that the coordinator needs to specify the story id, how does he know, maybe the user doesn't even know either, that's the crux of it"* — lands on classification. The fix cannot be "ask the user for a story ID." The user frequently doesn't know which story a behavior belongs to, and in the plan-gap case (category D below) no story ID exists yet. Classification must be something the coordinator infers from the user's message plus the plan state.

## 2. Root Cause Analysis

### 2.1 Coordinator lacks a triage verb

`sdlc-coordinator.md`'s routing table distinguishes "start planning," "execute a story," "resume from checkpoint," and similar. It does not distinguish "user is asking about behavior against current state." The coordinator has no prompt-time cue that tells it "this message is a check/report, not a work request."

### 2.2 No classifier over plan state

Even if the coordinator recognized the triage verb, there is no procedure for mapping a behavioral description to the plan. The planner-produced artifacts (story.md, acs, ac→task mapping from P16, completion state from execution.yaml) are in principle sufficient to answer "is this feature in a completed story, a planned story, or neither" — but no agent is tasked with reading them that way.

### 2.3 Engineering hub has no "modify a completed story" mode

The hub's lifecycle (Phase 0 through Phase 6) presumes an active story in the planner→execution pipeline. A completed story that needs a fix has no re-entry door. The coordinator's only tool is "dispatch the hub with a free-text prompt and hope it figures something out," which is what happened twice in US-004.

### 2.4 Defect work does not produce durable state

Without a lifecycle primitive, a defect fix leaves no durable record. The US-004 transcript shows two substantive defect fixes — hardcoded demo credentials, wrong OAuth mechanism — that modified test files and source files, but `execution.yaml` still listed US-004 as `completed_phases: [0,1,2,3,3b,4,5,6]` throughout. A post-mortem reader has no way to discover that US-004 went through two post-acceptance iterations. This both muddles the record and prevents any metric from tracking defect incidents per story.

### 2.5 Oracle is never consulted on external-integration defects

The US-004 second defect — "OpenRouter returns 401 because the auth mechanism in api.md is wrong" — is the exact kind of cross-cutting, contract-shape, multi-file-implication problem where Oracle's analytical depth pays off (see P14). Instead, the engineering hub muddled through with a standard implementer retry. No structural rule routes external-contract defects to Oracle. P21 plugs this gap by naming defect-incident as an Oracle-eligible trigger; P14 receives the corresponding amendment.

## 3. Proposed Approach

Four changes, corresponding to the two orthogonal failure modes (classification then lifecycle).

### 3.1 Coordinator triage verb and classifier

A new dispatch mode on the coordinator: `triage-user-report`. It is not selected by the user directly; the coordinator enters it when the user's message matches any of the following shapes (prompt-level recognition):

- "is X supposed to work?"
- "when I do X, Y happens" / "when I do X, nothing happens"
- "is X implemented?" / "when will X be done?"
- "I think X is broken"
- "I don't see X"
- Any message describing an observed behavior against the running system.

Upon entering triage mode, the coordinator executes the following procedure before answering the user:

1. **Read the plan inventory.**
   - Read `plan/user-stories/*/story.md` manifests (titles, ACs, status from execution.yaml).
   - Read `plan/cross-cutting/` aggregates where present (required-env.md from P19, acceptance map from P16).
   - Read the current execution checkpoint.
2. **Infer the target story or non-story.**
   - Match behavioral keywords in the user's message against story titles, AC text, and task descriptions.
   - Produce a ranked shortlist of candidate stories (typically 1–3). Maintain a `null` candidate for "this might be outside the plan entirely."
3. **Classify.** Produce exactly one category:
   - **Category A — Already implemented.** One or more candidate stories are in `completed_phases: [...,6]`, and the behavior described maps to an AC that was accepted. Coordinator's response: point the user to the story and explain how to invoke the feature (may dispatch the hub in explanation-only mode for detailed how-to if needed, but only after classification).
   - **Category B — Planned for future.** One or more candidate stories exist in `stories_remaining` but have not yet reached execution. Coordinator's response: name the story, show its ACs, state the planned execution order, offer to advance it if the user prioritizes.
   - **Category C — Defect against completed story.** One or more candidate stories are in `completed_phases: [...,6]` AND the described behavior contradicts an AC the story claimed to satisfy. Coordinator's response: open a defect incident per §3.2 below, dispatch the hub in incident mode.
   - **Category D — Plan gap.** No candidate story covers the behavior, no planned future story covers it either. Coordinator's response: route to P22's plan-change-triage flow. This is not necessarily a defect; it may be a legitimate scope expansion. P22 decides.
4. **Confirm classification with the user BEFORE acting.** Present the classification in one short paragraph — "I believe this is a (A/B/C/D) because (evidence from step 2)" — and a single question: "Does that match your intent? (yes / no / different story)." This is the one interactive gate; the user confirms or redirects, the coordinator does not silently route. Confirmation is cheap and eliminates misrouted incidents.
5. **Act on the confirmed classification.**

The procedure is deliberately inference-first, user-confirm-second. The user may still not know the story ID, but the user does know whether the classification sounds right.

### 3.2 Defect Incident lifecycle primitive in the engineering hub

When the coordinator opens a defect incident (Category C), it dispatches the hub in a new `defect-incident` mode. The mode is compact and explicit.

**State.** `.sdlc/incidents/<incident-id>/` directory with:
- `incident.md` — narrative (reporter, date, reported behavior, confirmed classification, target story, reproduction steps, ACs contradicted).
- `investigation.md` — implementer/Oracle working notes.
- `fix-plan.md` — proposed diff summary and affected files.
- `verification.md` — evidence that the fix restored the ACs, including real-traffic smoke-test rerun if external (per P20).
- `incident.yaml` — structured state (status, iteration count, verdict).

`execution.yaml` gains:
```yaml
incidents:
  - id: INC-001
    story: US-004-photo-intake-identification
    status: open | investigating | fix-proposed | verifying | resolved | escalated
    iterations: 1
    opened_at: 2026-04-22T10:00:00Z
    oracle_consulted: false
    verdict: null
```

**Workflow.**
1. **Reproduce.** Hub reproduces the reported behavior against real code, using P20's smoke test convention where an external integration is involved. If the behavior cannot be reproduced, status → `not_reproduced` and the hub returns to coordinator with a request for clarification (possibly with a one-shot dispatch to explanation mode to help the user refine).
2. **Investigate.** Hub dispatches the implementer with the target story's lib-cache pre-loaded (incident mode inherits the story's context — no fresh cold-start). Iteration cap mirrors P10's story-reviewer cap (3 iterations). If cap reached → escalate to Oracle (new P14 trigger, §3.3 below). Two reassignment outcomes are possible during investigation, per §7.3:
   - **Root cause in a different completed story.** The incident's `target story` is reassigned (`git mv` on the artifact directory if needed); `incident.md` records the originating story for traceability; the implementer additionally loads the new target story's lib-cache; the workflow continues from step 3.
   - **Root cause in a story not yet executed.** The incident is closed with verdict `reclassified-to-B` and no fix is attempted. Control returns to the coordinator, which delivers the Category B response (planned-execution timeline) to the user. The unbuilt story is the work; an incident against it would be meaningless.
3. **Propose fix.** Implementer produces a minimal diff plan. Reviewer validates against the contradicted ACs (narrow P16 pass, not full story-review).
4. **Verify.** Re-run the smoke test (P20 §3.2) and any AC-bound tests (P16). When real-path evidence is recorded, update the story's acceptance verdict per P19 §3.6 (e.g., promote `ACCEPTED-STUB-ONLY` to `ACCEPTED`).
5. **Close.** Update `incidents[].status: resolved`; leave the story's `completed_phases` untouched but annotate the story.md with a reference to the incident for traceability. The story is not "re-completed"; it was always complete structurally — the incident is an amendment, not a re-run.

**Deduplication.** New reports do not trigger a scan over existing incidents. Each report opens a new incident by default. The coordinator merges into a prior incident only when the user explicitly references it (e.g., "same as INC-001"); in that case the new report is appended to the referenced incident's reporter list and no new incident is created. See §7.2.

**Distinction from full re-execution.** A defect incident is not a new story and not a re-run of the original story. It is a focused, time-bounded amendment with a specific scope: restore a specific AC by fixing a specific defect. If the incident's scope grows beyond one-or-two ACs or introduces new ACs, the coordinator escalates to P22 plan-change — the problem is no longer a defect, it is a scope delta.

### 3.3 Oracle routing for complex defect incidents (P14 extension)

P21 supplies a fifth trigger for P14's Oracle-escalation table:

5. **Defect-incident trigger.** When a `defect-incident` is opened with any of these properties, Oracle is dispatched as the first-line investigator (not as escalation):
   - The contradicted AC involves an external integration (touches api.md with `wire_format` block per P20).
   - The reproduced behavior indicates a cross-cutting contract mismatch (wrong auth, wrong envelope, wrong serialization) rather than a local logic bug.
   - The story's original execution consumed ≥ 8 doc queries or ≥ 3 implementer retries on the now-contradicted AC (reuses P14's query and retry thresholds; signals that the original implementation path was already off the beaten track).

For all other defect incidents (local logic bugs, UI regressions, simple state bugs), Oracle is available as an explicit escalation target on iteration 3 per P14's retry-budget trigger, same as in story execution.

### 3.4 Coordinator presentation templates

To keep triage responses consistent, the coordinator uses a fixed three-line classification preamble for every `triage-user-report` reply:

```
TRIAGE: <A | B | C | D>
TARGET: <story-id | none>
EVIDENCE: <one-line justification citing which story.md/AC/execution state>
```

Followed by the action-appropriate content (explanation, timeline, incident-opened notice, or plan-change handoff). The preamble makes post-mortem parsing trivial and makes the classification auditable by the user without reading narrative.

## 4. Expected Impact / ROI

**Primary impact:** The US-004 protocol gap closes. User-reported issues get a named channel with a deterministic outcome (A/B/C/D + confirmed classification) instead of ad-hoc free-text coordination. No story is silently modified while marked complete; every post-acceptance change is a visible incident.

**Secondary impact:** Plan-gap discovery becomes first-class. Category D channels legitimate scope-expansion requests into P22 instead of burying them in an engineering hub that cannot answer them. The user's earlier question — "what if it's a planning gap?" — has a home.

**Tertiary impact:** Incident data accumulates. Per-story incident count becomes a measurable quality signal: stories with high incident counts indicate planning or testing gaps (feedback into P15/P16/P20).

**Quaternary impact:** Oracle starts earning its keep on the exact defects where its analytical breadth matters (external contract mismatches), per the P14 amendment. This complements the existing task-shape trigger.

**ROI consideration:** Medium implementation cost — new coordinator dispatch mode, new hub mode, new state primitive, new directory convention. Zero ongoing cost once in place. High payoff: every user-reported issue so far (two in US-004 alone) would have flowed through this protocol cleanly instead of through ad-hoc dispatches.

## 5. Success Metrics (for post-run verification)

- **M1 (hard):** Every user message that matches a triage-shape receives a `TRIAGE: <A|B|C|D>` preamble before any action is taken. Verifiable by transcript grep.
- **M2 (hard):** No engineering-hub dispatch modifies a completed story's source tree without a corresponding open incident in `execution.yaml`. Verifiable by cross-checking commit timestamps and incident timestamps.
- **M3 (hard):** Every defect incident produces a populated `.sdlc/incidents/<id>/` directory with at least `incident.md`, `investigation.md`, and `verification.md`. Verifiable by directory inspection.
- **M4 (hard):** Category C incidents touching external integrations trigger Oracle as first-line investigator (P14 trigger 5). Verifiable by joining incident metadata to Oracle dispatch log.
- **M5 (soft):** User must confirm/redirect the classification in fewer than ~20% of cases where the coordinator proposes one (low false-positive classifier). Otherwise the classifier is returning too much ambiguity and needs refinement.
- **M6 (soft):** Median time from user report → classification reply drops below 2 minutes (coordinator inference only, no subagent dispatch).

## 6. Risks & Tradeoffs

- **Risk: over-triggering triage on unrelated conversational messages.** A user saying "why does this code work like this?" could be mistaken for a behavior report. Mitigation: the triage shapes are narrow and specifically behavior-oriented. When in doubt, the coordinator asks "is this a check about whether something works in the app?" before classifying.
- **Risk: classification false positives — calling a defect a plan gap or vice versa.** Mitigation: the user-confirmation step in §3.1 step 4 catches this cheaply. Misclassification costs one extra user exchange.
- **Risk: incidents become a parallel workflow that duplicates story execution.** Mitigation: incident scope is explicitly narrow ("one or two ACs, minimal diff"). Anything that grows beyond that escalates to P22 plan-change. The boundary is part of §3.2.
- **Risk: completed-story source tree churn confuses downstream consumers.** Mitigation: story.md receives an `incidents:` reference block so readers know which post-acceptance changes happened. Commit messages for incident fixes are prefixed `[INC-NNN]` for grep-ability.
- **Risk: Oracle over-dispatch under §3.3.** Mitigation: the external-integration and complexity conditions are conjunctive with specific triggers, not broad. Ordinary local bugs still follow the P14 retry-budget path.
- **Tradeoff: adds one more dispatch mode to coordinator and one to hub.** Acceptable — the taxonomy is shallow (four categories, one new hub mode) and orthogonal to the existing planner/execution modes.

## 7. Resolved Decisions (2026-04-27)

The questions raised during drafting are resolved as follows; substantive changes have been propagated into §3.2.

1. **Plan-gap incidents (Category D) are not filed as incidents.** Category D produces no `.sdlc/incidents/` artifact and is routed entirely through P22 to the planner. The incident lifecycle is reserved for defects against completed stories.

2. **No proactive deduplication across reports.** Each user report opens its own incident by default. The coordinator does not scan prior incidents on every triage trying to merge — that would require reading every incident on every report and is rejected as too expensive. Deduplication occurs only when the user explicitly references a specific prior incident or report (e.g., "this is the same thing as INC-001"); in that case the coordinator appends the new report to the referenced incident's reporter list rather than opening a new one.

3. **Investigation-time reassignment or reclassification.** Two sub-cases, both grounded in §3.2 step 2:
   - **Different completed story.** If investigation reveals the root cause lives in a *different already-completed* story, the incident's `target story` is reassigned to that story. `incident.md` records the originating story for traceability, the implementer additionally loads that story's lib-cache (per §7.4), and the fix proceeds. The bug is real and must be fixed; the incident is not abandoned.
   - **Story not yet executed.** If investigation reveals the behavior depends on a *story that has not yet been executed*, this is not a defect. The incident is closed with verdict `reclassified-to-B`, no fix is attempted, and the coordinator answers the user with the planned-execution timeline (Category B response from §3.1). Issuing a defect-fix against unbuilt code is meaningless — the work *is* the future story; treat the report as an inquiry.

4. **Lib-cache inheritance with optional supplementation.** The implementer dispatched into incident mode inherits the target story's existing lib-cache (no fresh cold-start cost) and may add incident-specific entries as needed. When a §7.3 reassignment shifts the target to a different completed story, the implementer additionally loads that story's lib-cache before continuing.

5. **Oracle consultation does not reset the incident iteration counter.** An incident follows the same process and protocol as any other task — Oracle is a within-iteration consultation, not a budget reset. The counter tracks investigate-propose-verify cycles, not agents dispatched.

6. **Stub-only verdicts auto-upgrade on real-traffic verification.** When the verify step (§3.2 step 4) produces real-traffic evidence per P19/P20, the original story's `ACCEPTED-STUB-ONLY` verdict promotes to `ACCEPTED`. The upgrade is recorded in `verification.md`.

## 8. Affected Agents, Skills, and Files (preliminary)

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-coordinator.md` | Modified | Add `triage-user-report` dispatch mode; add classification procedure per §3.1; add `TRIAGE:` preamble template per §3.4. |
| `opencode/.opencode/agents/sdlc-engineering.md` | Modified | Add `defect-incident` lifecycle mode per §3.2 with workflow, iteration cap, and incident-artifact schema. |
| `opencode/.opencode/agents/sdlc-engineering-oracle.md` | Modified | Add defect-incident consult entry point per §3.3. |
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | Modified (light) | Accept incident-scoped dispatch with `target_acs` narrowed to a subset. |
| `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md` | Modified (light) | In incident mode, review narrows to the contradicted ACs, not the full task-or-story. |
| `opencode/.opencode/agents/sdlc-engineering-acceptance-validator.md` | Modified (light) | Re-run narrow validation on the affected ACs after incident verify; support verdict upgrade per P19 §3.6. |
| `opencode/.opencode/skills/sdlc-checkpoint/references/api-execution.md` | Modified | Document `incidents:` array schema on `execution.yaml`. |
| `.sdlc/incidents/` directory convention | Created | Per-incident artifact directory per §3.2. |
| `opencode/improvement-proposals/P14-oracle-escalation-threshold.md` | Amended (separate) | Add trigger 5 per §3.3. |

---

## 9. Relation to Prior Proposals

- **P11 (validator read-only):** The incident verify step (§3.2 step 4) is narrow, read-most, and follows the same budget cap principles. Not a new violation path.
- **P14 (Oracle escalation):** Extended by §3.3. See P14 amendment note.
- **P15 (planner risk annotations):** Stories annotated with risk shapes (external-integration, browser-evidence, CDP) are empirically more likely to produce Category C incidents. Post-mortem data from incident counts feeds back into P15's annotation taxonomy.
- **P16 (AC traceability):** Classification in §3.1 step 2 consumes P16's AC→task map. Without P16 the inference is noisier; with P16 it narrows to AC-level matches directly.
- **P18 (hub-coordinator reset boundary):** Incident dispatch is its own reset boundary. Not part of Phase 1b/2/3/4 rotation. Compatible — just a distinct dispatch shape.
- **P19 (environment secrets):** Reproducing external-integration defects (most Category C) requires real credentials; P21's reproduce step routes through P19's MISSING_CREDENTIALS escalation when required_env is unset, rather than reproducing against a stub.
- **P20 (external integration contract verification):** P21's verify step (§3.2 step 4) re-runs P20's smoke test. A defect whose root cause is a wrong `wire_format` block escalates back into P20's plan-validation path to correct api.md, not just the code.
- **P22 (plan change protocol):** Category D routes here. Incidents that grow beyond scope also route here.
