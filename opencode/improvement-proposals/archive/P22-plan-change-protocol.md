# P22: Plan Change Protocol (Within-Execution)

**Status:** Implemented — 2026-04-27 (drafted 2026-04-22; resolved + landed 2026-04-27 across coordinator, planner hub, planner-stories, planner-api, planner-architecture, engineering hub, engineering implementer; new on-demand skills `sdlc-plan-change-triage`, `sdlc-plan-change-escalation`, `sdlc-plan-change-recordkeeping`; checkpoint flags `--plan-change-open` / `--plan-change-close`)
**Sequencing:** Depends on P19 (a plan change that introduces a new provider must declare its `required_env`). Consumes P21 classification (Category D → P22). Compatible with P18 (plan-change dispatch is a distinct reset boundary from phase boundaries).
**Relates to:** P15 (risk annotations — re-evaluated on plan change), P16 (AC map — updated by plan change), P19, P20 (a plan change adding an external provider requires a fresh `wire_format` block), P21
**Scope:**
- `opencode/.opencode/agents/sdlc-coordinator.md` (new dispatch verb `plan-change-triage`)
- `opencode/.opencode/agents/sdlc-planner.md` (new `plan-change-triage` mode; blast-radius analysis)
- `opencode/.opencode/agents/sdlc-planner-stories.md`, `sdlc-planner-api.md`, `sdlc-planner-architecture.md` (amendment producers)
- `opencode/.opencode/agents/sdlc-engineering.md` (accepts "story amendment" dispatches)
- Checkpoint state schema (`coordinator.yaml` gains `plan_changes:`)
- `.sdlc/plan-changes/` directory
**Transcript evidence:** `ses_24a319c81ffelunHGnCfk7KcBT` — US-004. The user stated mid-execution: *"at the point of giving the api-key and specifying the free models and/or the specific multimodel, I would have wanted to change the plan to not include openai at all for now and just keep the open router, and do a new requirement that after adding the openrouter api-key it will search and give a drop down of all the free models with image vision to pick from."* This describes two distinct plan changes — a dependency removal (drop OpenAI) and a new requirement (free-model selector) — with different blast radii. The pipeline had no protocol for either. The user observed: *"this could fundamentally change the entire plan or user stories going forward, or just be a simple addition that doesn't actually affect the rest of the plan."* The coordinator had no mechanism to tell which of those two it was, and no mechanism to route either appropriately.

---

## Read Order

**Prerequisites** (read / land first):
- **P19** — plan changes that add or remove external providers update `required_env` and `.env.example` atomically inside the PC-NNN artifact (§3.2). The blast-radius scan reads P19's state directly.
- **P21** — P21 Category D (plan gap) is P22's primary inbound trigger; P21 incidents whose scope grows beyond one-or-two ACs also escalate here. Read P21 first so you understand where the hand-offs come from.
- **P20** — plan changes that add new external integrations re-run P20 §3.1 `wire_format` verification; retirements remove the corresponding smoke tests.
- **P15** — plan changes may introduce or remove risk shapes; the blast-radius scan re-evaluates P15 annotations on affected stories.
- **P16** — plan changes that add or alter ACs update P16's AC→task map, and any affected completed stories get a P16 evidence re-review.

**Consumers** (depend on this proposal):
- None within this batch. P22 is the terminal node of the 2026-04-22 cluster — it absorbs changes from everywhere but does not feed anything else.
- Long-range: a future proposal on "plan-change metrics and planner-feedback loops" would read P22's `.sdlc/plan-changes/` audit trail as input.

**Suggested batch reading order** (2026-04-22 cluster): P19 → P20 → P16 (amended §3.5) → P21 → P14 (amended trigger 5) → **P22 (you are here)**.

---

## 1. Problem Statement

Plans change during execution. Some changes are additive and local ("also add a filter field"). Others are foundational ("swap the entire provider abstraction"). Most are somewhere in between. The pipeline currently treats all of them the same way: the user asks the coordinator, the coordinator re-dispatches the engineering hub with free-text instructions, and the engineering hub tries to absorb the change into whatever story is in flight. That pattern silently mishandles two cases out of three:

- **Additive changes within the active story.** Often absorbed correctly by the hub, but no record of the change is kept — the story's `story.md` and `acs` are not updated, so downstream validation measures against the old plan. Evidence of this pattern is sparse in the US-004 transcript because the user's plan-change request was never actually executed; it was discussed and set aside. But the pattern is available on inspection of how mid-story instruction changes have flowed historically.
- **Multi-story changes.** These require downstream stories to be re-planned (removed, added, re-scoped, or re-sequenced). The hub has no authority over the plan, so it either silently ignores the cross-story implications or enters a deadlock where the hub says "that needs re-planning" and the coordinator has no path to dispatch the planner for a non-greenfield replan.
- **Foundational changes.** These invalidate large portions of the existing plan (architecture change, dependency swap, new cross-cutting concern). The current pipeline treats them as a new planning session from scratch, which over-corrects — much of the existing plan is still valid. There is no concept of "partial replan" in the planner.

The second and third cases are the ones the user explicitly named as worrying. A mid-execution provider swap (drop OpenAI) touches stories that haven't started yet but were written assuming dual-provider support. A mid-execution addition of a free-model selector feature is — depending on implementation — either an amendment to US-004 (if the picker is scoped into photo intake) or a new story placed before the next execution story (if it's reusable).

The goal of P22 is to give plan changes a first-class protocol with a deterministic classification, a planner-owned blast-radius analysis, and a coordinator-managed routing decision.

## 2. Root Cause Analysis

### 2.1 Planner is single-shot and greenfield-only

`sdlc-planner.md` and its sub-agents (stories, api, architecture, design, testing, devops, data, security, hld) are structured as a phased pass from empty to complete plan. They do not have a "given an existing plan and a change request, produce a diff" mode. Any plan modification falls back on repeating planning from scratch, which is both slow and destructive of work in progress.

### 2.2 No change-record artifact

There is no file that records "on date D, the plan was changed in way X because of reason R." Plan changes are implicit in git history (if they happen via file edits), but they are not enumerated in a way a future agent or user can audit. Without this, it's impossible to measure how often plans change, what shapes of changes happen, or which shapes tend to cause trouble.

### 2.3 No blast-radius analysis

Even if the planner had a diff mode, nothing computes "which stories, artifacts, and tests are affected by this change." The coordinator would need the blast radius to make a sensible routing decision (absorb in active story vs. pause downstream stories vs. re-plan a slice), and without it the coordinator is effectively guessing.

### 2.4 Coordinator cannot authorize the hub to modify plan artifacts

The engineering hub is an executor of the plan, not a modifier of it. When a user requests a change via the coordinator, the hub has two unsatisfactory options: modify the plan artifact informally (violating the planner's ownership) or ignore the plan drift and build something different than the plan describes (what often happens). There is no structural "the planner owns plan artifacts; the hub gets fresh instructions derived from them" protocol for mid-execution changes.

### 2.5 P21 Category D has nowhere to go without P22

A user report classified as Category D (plan gap) in P21 requires a mechanism to add to the plan. P21 hands off to P22 for that mechanism. Without P22, Category D degenerates into either "the coordinator tells the user this isn't in scope" (refusing valid requests) or "the coordinator dispatches the hub to build it anyway" (violating §2.4). P22 closes the loop.

## 3. Proposed Approach

Four pieces: a coordinator verb, a planner mode, a classification taxonomy, and a routing rule.

### 3.1 Coordinator dispatch verb: `plan-change-triage`

The coordinator enters this mode when any of the following happens:

- User issues an explicit plan-change request. Surface shapes:
  - "I want to add/remove/change <capability>"
  - "Change the plan so that..."
  - "Instead of <A> let's do <B>"
- P21 classification returns Category D.
- The engineering hub escalates with `BLOCKER: PLAN_CHANGE_REQUIRED` (defined below) — this happens when a story in flight discovers its plan artifacts are materially incorrect beyond a single defect (e.g., the api.md contract is unimplementable because the provider was deprecated).

Upon entering the mode, the coordinator:
1. Records the change request verbatim in `.sdlc/plan-changes/<PC-NNN>/request.md`.
2. Dispatches the planner in `plan-change-triage` mode (§3.2).
3. Awaits the planner's blast-radius report and classification (§3.3).
4. Presents the classification to the user for approval.
5. On approval, routes per §3.4.
6. Updates `coordinator.yaml: plan_changes[]` with the resolved outcome.

The coordinator does NOT approve or execute the plan change without the user's explicit confirmation on the planner's classification.

### 3.2 Planner mode: `plan-change-triage`

The planner (aggregator agent) receives the change request and produces a structured triage report. It does not modify any plan artifact in this mode — this is analysis only. The report contains:

```yaml
plan_change_triage:
  id: PC-002
  request_summary: "Drop OpenAI provider; require free-model selector after OPENROUTER_API_KEY set."
  affected_artifacts:
    - plan/architecture.md                      # dependency diagram references OpenAI
    - plan/user-stories/US-004-photo-intake-identification/api.md
    - plan/user-stories/US-004-photo-intake-identification/story.md
    - plan/user-stories/US-007-provider-selection/story.md   # planned-but-not-started
    - plan/cross-cutting/required-env.md                      # remove OPENAI_API_KEY entry
  affected_stories:
    completed:
      - US-004-photo-intake-identification   # needs amendment (category C-like incident via P21) OR replan
    in_flight: []
    planned:
      - US-007-provider-selection             # may be retired or reduced
      - US-008-settings-ui-v2                 # model selector is net-new scope here
  new_stories_required:
    - US-00X-free-model-selector              # or absorbed into US-004 amendment
  risk_shapes_affected:
    - external_integration                     # per P15
  required_env_delta:
    remove:
      - OPENAI_API_KEY
    add: []
  wire_format_delta:
    remove:
      - https://api.openai.com/v1/chat/completions
    add: []
  classification: multi-story                  # see §3.3
  recommended_routing:
    - amend US-004 story with free-model-selector AC (additive-within-story)
    - retire US-007 (out of scope post-change)
    - re-evaluate US-008 scope
  estimated_cost:
    planner_replan_scope: one slice (3 stories)
    execution_impact: US-004 incident-style amendment, US-007 cancelled, US-008 rescoped
```

The blast-radius scan is mechanical: the planner reads the change request, lists the plan artifacts whose semantics would change, walks the story dependency graph forward from those artifacts, and classifies per §3.3. It uses P15's risk annotations and P19's `required_env` map as direct inputs.

### 3.2.1 Forward-impact scan (mechanical rule)

The blast-radius scan is only meaningful if it actually walks forward through the plan. The user's central concern with mid-execution changes is that a Class 1 or Class 2 misclassification could silently corrupt a not-yet-started story whose plan was written assuming the pre-change shape. To prevent that, the triage must:

1. **Enumerate every planned story explicitly.** For each story in `stories_remaining` (i.e. every planned and in-flight story other than completed ones), the triage report lists it as either `affected` (with a reason) or `unaffected` (with a one-line justification). Implicit "I didn't mention it so it's fine" is forbidden — an absent story is a bug in the triage, not a pass.
2. **Apply artifact-reachability as the mechanical rule.** For each plan artifact modified by the change (story.md, api.md, hld.md, architecture.md, cross-cutting/*), enumerate every other story whose artifacts reference it (via import, contract reference, shared cross-cutting doc, or shared external integration). Any story with an inbound reference is `affected` until the planner argues otherwise in `triage.md`.
3. **Surface the verdict per story in the report.** The `affected_stories.planned` list is the union of (artifact-reachability matches) and (planner judgment). Each entry carries its justification. Each `unaffected` planned story carries its one-line justification too — written down, not implicit.

This is what makes the boundary between Class 1 and Class 3 mechanically checkable rather than a planner gut call. It is also what enables §3.4.1.

### 3.3 Classification taxonomy

Every triage produces exactly one of four classes:

- **Class 1 — Additive within active story.** Change affects only the story currently in execution (or the next one, if no execution is in flight) and its ACs. No downstream stories are impacted. Example: "add a title field to the form." Route: planner produces an amendment to the active story's `story.md` + `api.md` + `hld.md` as needed; hub accepts the amended dispatch and adds to the current phase.
- **Class 2 — Additive new story.** Change adds net-new capability that doesn't fit cleanly into an active or near-future story. No existing stories are invalidated. Example: "add a model-selector dropdown" when no existing story has a model-selection AC. Route: planner produces a new `story.md` in `plan/user-stories/US-00X-...`, inserts it in the execution sequence at the user's preferred slot.
- **Class 3 — Multi-story replan.** Change invalidates or re-scopes two or more planned stories. Example: "drop OpenAI." Completed stories may need incident-style amendments (Category C per P21); planned stories may be retired, merged, or rescoped. Route: planner is dispatched in a targeted replan mode over the affected slice only (not the whole plan); coordinator pauses any downstream story dispatches until the slice replan completes.
- **Class 4 — Foundational.** Change invalidates the architecture, the cross-cutting contracts, or the overall scope. Example: "change target platform from web to desktop." Route: full planner re-dispatch starting from `architecture.md`; explicit user confirmation on scope; existing completed stories may remain valid, may need rework, or may be explicitly preserved as-is with known drift.

The planner's classification is a recommendation. The user confirms or overrides via the coordinator presentation step.

### 3.4 Routing rule

| Class | Who acts | What they produce | When execution resumes |
|-------|----------|-------------------|------------------------|
| 1 | Planner produces story.md amendment. Hub accepts amendment within active phase. | Updated story.md, api.md, hld.md in place; `plan_changes[PC-NNN]` logged. | Immediately, within active story. |
| 2 | Planner produces new story.md; coordinator inserts in sequence. | New `plan/user-stories/US-00X-.../`; updated `stories_remaining`. | After the current story completes (or immediately if insertion order is prior to active). |
| 3 | Planner runs targeted replan over affected slice. Stories retired, merged, rescoped as determined by the triage. Completed stories with AC impact get incident tickets (P21 Category C). | Updated story.md files for the slice; possibly new or removed stories; `plan_changes[PC-NNN]` logged with affected-story list. | After slice replan is approved by user. Active story may be suspended or continue based on whether it's in the slice. |
| 4 | Full replanner re-dispatch. | Re-derived `architecture.md`, `stories.md` inventory, per-story artifacts as needed. | After full user approval. |

In all four classes, if the change introduces a new external integration, P20's `wire_format` verification runs as part of the planner pass. If it removes one, the retirement updates P19's `required_env` and `.env.example` accordingly.

### 3.4.1 Dispatch lock for affected planned stories

When the triage produces a non-empty `affected_stories.planned` list (any class), the coordinator writes a dispatch lock into `coordinator.yaml`:

```yaml
plan_changes:
  - id: PC-NNN
    status: open
    blocks_dispatch_until: PC-NNN.decision
    affected_planned_stories:
      - US-007-provider-selection
      - US-008-settings-ui-v2
```

The coordinator's pre-dispatch check refuses to dispatch any story listed in any open PC-NNN's `affected_planned_stories`, returning a pointer to the open PC-NNN instead. The lock is released when:
- `decision.md` records user approval, AND
- The planner has emitted the post-change `story.md` for that story (or recorded its retirement).

Class 1 changes that legitimately have no planned-story impact produce an empty `affected_planned_stories` list and impose no lock — the active story continues uninterrupted. The lock is the structural answer to "a mid-execution change can't quietly leak into a future story": the future story physically cannot be dispatched until the plan-change resolution touches it.

### 3.5 Hub escalation: `BLOCKER: PLAN_CHANGE_REQUIRED`

When the engineering hub discovers during execution that a plan artifact is materially wrong in a way a defect incident cannot fix (e.g., api.md specifies an endpoint that doesn't exist; required architecture contradicts a newly-discovered constraint), it returns:

```
BLOCKER: PLAN_CHANGE_REQUIRED
STORY: US-NNN-...
REASON: <narrative>
EVIDENCE: <citation>
RECOMMENDED CLASS: <1 | 2 | 3 | 4>   # hub's guess; planner decides authoritatively
```

The coordinator treats this as a `plan-change-triage` trigger equivalent to a user-initiated change. The active story is suspended pending triage.

### 3.6 Change record

Every plan change, regardless of class, produces `.sdlc/plan-changes/<PC-NNN>/`:
- `request.md` — verbatim user request or hub blocker.
- `triage.md` — planner's blast-radius report.
- `decision.md` — user's approval/override with timestamp.
- `artifacts-changed.md` — post-facto list of files that were actually modified.
- `pc.yaml` — structured status (class, opened, closed, outcome).

`coordinator.yaml: plan_changes[]` maintains a pointer list for quick lookup.

### 3.7 Packaging: which surfaces become on-demand skills

P22 is invoked rarely (most stories run to completion without a plan change), but the procedural surface is heavy. Pinning the entire protocol into always-on agent context would inflate every agent's baseline for a path most sessions never take. The split below keeps always-on context narrow (recognizers only) and puts heavy procedural prose behind skill descriptions that match the conditions under which they're needed.

| Surface | Packaging | Why |
|---------|-----------|-----|
| Coordinator: trigger recognition (user plan-change phrasing, P21 Category D handoff, hub `BLOCKER: PLAN_CHANGE_REQUIRED`), routing per §3.4, dispatch-lock enforcement per §3.4.1 | **Always-on** in `sdlc-coordinator.md` | The trigger *is* the user message or the hub return — the recognizer must run before any dispatch decision. Cannot be lazy-loaded. The recognizer + routing logic is small (a few paragraphs); the heavy detail lives in the skills below. |
| Planner: `plan-change-triage` mode, blast-radius scan (§3.2), forward-impact scan (§3.2.1), classification taxonomy (§3.3), partial replan procedure | **On-demand skill** `sdlc-plan-change-triage` | Planner enters this mode only when dispatched by the coordinator. The skill's description matches the dispatch verb; loads on entry. The planner's greenfield baseline does not need this prose at all. |
| Engineering implementer: when and how to emit `BLOCKER: PLAN_CHANGE_REQUIRED` (§3.5) | **On-demand skill** `sdlc-plan-change-escalation` | Implementer hits this condition only when discovering an artifact is materially wrong beyond a defect (endpoint doesn't exist, contract unimplementable, architecture contradicts a newly discovered constraint). Skill description triggers exactly on those phrases; baseline implementer context stays focused on building, not on plan-change protocol. |
| Engineering hub: accepting amended dispatches per §3.4 row 1 (Class 1) | **Always-on** in `sdlc-engineering.md` | Hub must recognize an "amended dispatch" envelope on every dispatch it receives. Trivial recognizer; tiny footprint. Not worth a skill. |
| Change-record artifact convention (§3.6) | **On-demand skill** `sdlc-plan-change-recordkeeping`, shared by coordinator and planner | Only relevant once a PC-NNN is opened. Both coordinator (request.md, decision.md, pc.yaml) and planner (triage.md, artifacts-changed.md) reach for it then. Single shared skill avoids duplicating the directory convention in two agent files. |

Net effect on always-on context: each affected agent grows by a recognizer paragraph plus a skill pointer. The full procedure (triage report shape, classification taxonomy, forward-impact rule, escalation blocker shape, artifact convention) lives in three skills loaded on demand.

## 4. Expected Impact / ROI

**Primary impact:** The two observed US-004 change requests (drop OpenAI; add free-model selector) become routable. Each gets a classification, a blast-radius view, a user-confirmed decision, and a record. The current pipeline has nowhere to route either.

**Secondary impact:** Engineering hub regains a clean scope. "What am I supposed to build?" is always and only "what the current story's plan artifacts say, possibly as amended by an approved PC-NNN." The hub never needs to infer whether a user's new instruction supersedes the plan — the coordinator resolves that via P22 first.

**Tertiary impact:** Planner gains a partial-replan mode it didn't have. The cost of accommodating a provider swap goes from "restart planning" to "replan the affected 3-story slice." On a project with 20 stories that's an order-of-magnitude saving.

**Quaternary impact:** Data accumulates for post-mortem. Plan change frequency, class distribution, average blast radius — all become measurable quality signals on the original plan's fitness.

**ROI consideration:** Non-trivial implementation cost (new coordinator verb, new planner mode, new artifact convention, new escalation channel). Cost is front-loaded; one-time. The payoff is every plan change that happens from this point forward flowing through a known channel rather than corrupting the plan or the execution silently.

## 5. Success Metrics (for post-run verification)

- **M1 (hard):** Every user message matching a plan-change shape produces a `.sdlc/plan-changes/<PC-NNN>/` directory with populated `request.md` and `triage.md`. Verifiable by directory inspection.
- **M2 (hard):** Every PC-NNN directory has a `decision.md` reflecting user approval or override. No plan change is executed without a recorded decision. Verifiable by presence check.
- **M3 (hard):** For Class 3 plan changes, `stories_remaining` and affected story files reflect the replan; pre-change and post-change snapshots exist in the PC-NNN directory. Verifiable by diff.
- **M4 (hard):** When a plan change adds or removes an external integration, `.env.example`, `plan/cross-cutting/required-env.md`, and the relevant story's `api.md.wire_format` are all updated in the same PC-NNN. Verifiable by cross-file timestamp check.
- **M5 (soft):** Zero instances of the engineering hub modifying plan artifacts (story.md, api.md, architecture.md) outside of a plan-change flow. Verifiable by git blame cross-referenced with dispatch logs.
- **M6 (soft):** Median time from user plan-change request to classification presentation drops below 10 minutes (planner triage only, no full replan needed for the presentation step).

## 6. Risks & Tradeoffs

- **Risk: planner over-classifies changes as Class 3/4 when Class 1/2 would suffice.** Consequence: unnecessary replans, slowed delivery. Mitigation: §3.3's definition is tight; "invalidates two or more planned stories" is a specific, checkable criterion. When the planner is uncertain, it recommends the smaller class with a noted caveat, and the user can override.
- **Risk: user bypasses the protocol by describing plan changes as defects in P21.** Consequence: Category C handles something that should have been Class 3. Mitigation: P21 has an explicit escalation path from incident to plan-change (when incident scope grows beyond an AC or two). The two protocols are mutually aware.
- **Risk: too much ceremony for trivial changes.** Consequence: "change the button color" triggers a triage, user is annoyed. Mitigation: Class 1 is very light — the planner produces a one-line story.md amendment within minutes and the hub accepts it without re-reading the whole plan. The ceremony per class is proportional to scope.
- **Risk: plan-change directory noise.** Consequence: `.sdlc/plan-changes/` fills with many small entries. Mitigation: this is a feature, not a bug — it's the audit trail P22 exists to create. Archiving policy can trim old resolved entries if size becomes a concern.
- **Tradeoff: user must approve classification before action.** One extra exchange on every change. Acceptable — mid-execution plan changes deserve explicit confirmation.
- **Tradeoff: the planner needs a partial-replan capability it doesn't currently have.** This is real new implementation work, not a prompt tweak.

## 7. Open Questions

1. **What's the boundary between Class 1 (amend active story) and Class 2 (new story)?** Proposal: if the change adds an AC that shares implementation context with an existing AC in the active story → Class 1; if it's independent → Class 2. The planner justifies the call in triage.md.
2. **Does Class 3 re-plan all affected stories, or only re-score their acceptance readiness?** Proposal: re-plan. "Re-scoring" without editing artifacts leaves a plan that still claims the old shape. Full re-plan produces the authoritative artifacts.
3. **Interaction with already-completed stories.** When Class 3 implicates a completed story (e.g., drop-OpenAI invalidates an AC in US-004 that claimed dual-provider support — US-004 only did OpenRouter so this is hypothetical, but future stories might), does the completed story get a P21 incident or a Class 3 amendment? Proposal: P21 incident per the AC being contradicted; the PC-NNN entry references the incident.
4. **Versioning plan artifacts on Class 3/4 changes.** Do we snapshot the pre-change plan somewhere? Proposal: git history is already the snapshot; PC-NNN stores a summary diff rather than a full snapshot. If git history is later rewritten for some reason, the PC-NNN summary is a weaker but durable record.
5. **Planner-level cache invalidation.** When P22 retires an external provider, the lib-cache entries for that provider should be marked stale. Mechanism? Proposal: PC-NNN records `cache_invalidations:` list; checkpoint.sh has a follow-up action to mark those entries stale on the next run.
6. **Scope interaction with P18 (reset boundary).** Class 1 amendments ride the active story's existing dispatch contract; Class 2 stories inherit normal dispatch at creation; Class 3 replans preserve existing dispatch shape unless the re-plan changes task shapes. Matches existing conventions without needing new rules. (Earlier draft referenced P17 ceremony scaling here; P17 was archived 2026-04-27 without implementation, so no class inheritance is involved.)

## 8. Affected Agents, Skills, and Files (preliminary)

Per §3.7, heavy procedural prose moves into on-demand skills. Agent files gain only recognizers and skill pointers.

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-coordinator.md` | Modified | Add `plan-change-triage` dispatch verb; recognize triggers (user plan-change phrase, P21 Category D, hub `PLAN_CHANGE_REQUIRED`); enforce dispatch lock per §3.4.1 on every pre-dispatch check; load `sdlc-plan-change-recordkeeping` skill when opening a PC-NNN. |
| `opencode/.opencode/agents/sdlc-planner.md` | Modified | Register `plan-change-triage` mode; on entry, load `sdlc-plan-change-triage` skill. No triage prose lives in the agent file itself. |
| `opencode/.opencode/agents/sdlc-planner-stories.md` | Modified | Support amendment to existing story.md and new story creation mid-execution. Procedure inherited from `sdlc-plan-change-triage` skill; story-agent file only adds the I/O hook. |
| `opencode/.opencode/agents/sdlc-planner-api.md` | Modified | Support api.md amendment; re-verify `wire_format` per P20 when a new external integration enters. Triggered from triage skill. |
| `opencode/.opencode/agents/sdlc-planner-architecture.md` | Modified | Support partial architecture amendment on Class 3/4 changes. Triggered from triage skill. |
| `opencode/.opencode/agents/sdlc-engineering.md` | Modified | Accept amended story dispatches (active-story mid-phase). Recognizer-only addition; the amended-dispatch envelope shape lives in the agent file because it's checked on every dispatch. |
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | Modified | Add a one-line skill pointer to `sdlc-plan-change-escalation`. Skill description matches "plan artifact is materially wrong beyond a defect" conditions. No always-on protocol prose. |
| `opencode/.opencode/skills/sdlc-plan-change-triage/SKILL.md` | Created | Planner skill — triage mode, blast-radius scan (§3.2), forward-impact scan (§3.2.1), classification taxonomy (§3.3), partial replan procedure. Loaded on `plan-change-triage` dispatch. |
| `opencode/.opencode/skills/sdlc-plan-change-escalation/SKILL.md` | Created | Implementer skill — when and how to emit `BLOCKER: PLAN_CHANGE_REQUIRED` per §3.5. Description matches "endpoint doesn't exist", "contract unimplementable", "architecture contradicts newly-discovered constraint", and similar materially-wrong-artifact conditions. |
| `opencode/.opencode/skills/sdlc-plan-change-recordkeeping/SKILL.md` | Created | Coordinator/planner shared skill — `.sdlc/plan-changes/<PC-NNN>/` directory convention per §3.6 and `coordinator.yaml: plan_changes[]` schema per §3.4.1. Loaded on PC-NNN open. |
| `opencode/.opencode/skills/sdlc-checkpoint/references/api-coordinator.md` | Modified | Document `plan_changes:` array on `coordinator.yaml` including `blocks_dispatch_until` and `affected_planned_stories` fields. |
| `.sdlc/plan-changes/` directory convention | Created | Per-change artifact directory per §3.6 (convention specified inside the recordkeeping skill). |

---

## 9. Relation to Prior Proposals

- **P15 (risk annotations):** Consumed by the planner's blast-radius scan. When a change adds a risk shape, annotations for affected stories update.
- **P16 (AC traceability):** Consumed to identify which ACs are affected when a plan change touches api.md or hld.md. AC-bound tasks get tagged for rework.
- **P17 (ceremony scaling) — archived 2026-04-27:** P17 was archived without implementation. P22 has no dependency on P17; new or amended stories follow the existing flat ceremony.
- **P18 (reset boundary):** Plan-change dispatch is a distinct boundary from the phase boundaries P18 introduces. Compatible; orthogonal.
- **P19 (environment secrets):** `required_env` delta is a mandatory field in triage per §3.2. Plan changes that touch credentials flow through P19.
- **P20 (external integration contract verification):** New or swapped integrations re-run P20's `wire_format` verification as part of planner triage; removed integrations retire their smoke tests.
- **P21 (user-reported triage):** P21 Category D routes here directly. P21 Category C may escalate here when incident scope grows beyond the one-or-two AC threshold defined in P21 §3.2.
