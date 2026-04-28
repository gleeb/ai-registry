---
name: sdlc-plan-change-triage
description: >
  Plan-change triage: blast-radius and forward-impact scan, four-class
  classification, and partial replan procedure. Load this skill in the
  PLANNER HUB (`sdlc-planner`) when dispatched with a
  `DIRECTIVE: PLAN_CHANGE_TRIAGE` from the coordinator. Triggered when
  the user requests a mid-execution plan change ("change the plan so
  that...", "instead of X let's do Y", "drop X", "add capability Z"),
  when a P21 Category D triage routes here, or when the engineering hub
  returns `BLOCKER: PLAN_CHANGE_REQUIRED`.
---

# Plan-Change Triage

## Purpose

This skill is the **planner hub's** handler for mid-execution plan changes.
It performs analysis only — it does NOT modify plan artifacts in triage
mode. The triage produces a structured report (classification + blast
radius + recommended routing) that the coordinator presents to the user
for approval. After approval, the planner re-enters under the routing
verb (amendment, new story, slice replan, or full replan) and writes
artifacts under the normal planner workflow.

The skill exists because greenfield planning and brownfield re-planning
have a structural blind spot: neither produces a "given an existing plan
and a change request, what's the minimal correct response" verdict. The
plan-change triage fills that gap.

## When to Use (planner-hub only)

Load this skill in `sdlc-planner` when the dispatch envelope contains:

```
DIRECTIVE: PLAN_CHANGE_TRIAGE
REQUEST: <user message verbatim, or hub blocker payload>
SOURCE: user | category-D | hub-blocker
PC_ID: PC-NNN                 # allocated by the coordinator before dispatch
```

The dispatch payload may also include:
- `RECOMMENDED_CLASS:` — present only when SOURCE is `hub-blocker` (the hub
  may guess; the planner decides authoritatively).
- `EVIDENCE:` — for hub-blocker dispatches, the citation that justified
  `BLOCKER: PLAN_CHANGE_REQUIRED`.
- `TARGET_STORY:` — for hub-blocker dispatches, the story in flight when
  the blocker fired.

Do NOT load this skill for credential registration (`CREDENTIAL_REGISTRATION`),
greenfield planning, or full-plan replans triggered outside the
plan-change protocol. Those have their own dispatches.

## When NOT to Use

- **Never load in the coordinator.** The coordinator's role is trigger
  recognition and dispatch, not triage authoring.
- **Never load in any execution agent.** The implementer escalates via
  `BLOCKER: PLAN_CHANGE_REQUIRED` (see `sdlc-plan-change-escalation`)
  but does not perform triage itself.
- **Do not use to "absorb" trivial mid-flight clarifications** that the
  active story can satisfy without artifact changes (e.g., a user
  asking "make the button blue" mid-story when the story.md AC already
  permits styling decisions). Those flow through the active engineering
  hub dispatch as ordinary instructions, not the plan-change protocol.

## Core Principles

1. **Analysis before action.** Triage produces a report; it does NOT
   write to `plan/`, `architecture.md`, story.md, api.md, hld.md, or any
   cross-cutting artifact. Writes happen on the post-approval routing
   pass.
2. **Mechanical over judgmental.** The forward-impact scan is rule-driven
   (artifact-reachability + explicit per-story enumeration). The
   classification taxonomy is the planner's narrowing of mechanical
   results, not a free-form gut call.
3. **Every planned story gets a verdict.** No implicit passes. An
   absent story in `affected_stories.planned` is a triage bug.
4. **Smaller class on tie.** When the evidence is consistent with two
   adjacent classes (e.g., "could be Class 1 amendment or Class 2 new
   story"), recommend the smaller class with a noted caveat. The user
   can override during the coordinator's confirmation step.
5. **No ceremony for impossible classes.** Class 4 (foundational) is
   reserved for changes that genuinely invalidate `architecture.md` or
   the cross-cutting contracts. Do not over-classify normal multi-story
   changes as Class 4 to avoid the partial-replan work.
6. **The recordkeeping artifact is shared.** This skill produces
   `triage.md`; `request.md`, `decision.md`, and `pc.yaml` live with
   the coordinator and follow the conventions in
   `sdlc-plan-change-recordkeeping`.

## Procedure

### Step 1 — Read the request and the live plan

1. Read the dispatch envelope's `REQUEST:` payload verbatim. Do NOT
   paraphrase before analysis — the user's exact phrasing carries
   semantics (e.g., "instead of X" implies retirement, "also add Y"
   implies addition).
2. Read `plan/system-architecture.md`, `plan/cross-cutting/required-env.md`,
   `plan/cross-cutting/external-contracts/*.md`, and every story's
   `story.md`. Skip `hld.md`, `api.md`, `data.md`, `security.md`,
   `design/` until the artifact-reachability scan flags them in step 3.
3. Read `.sdlc/coordinator.yaml` for `stories_done`, `stories_remaining`,
   and `current_story`. The triage classifies story impact relative to
   this list (completed / in_flight / planned).

### Step 2 — Identify modified artifacts (blast-radius seed)

For the request, enumerate the plan artifacts whose **semantics** would
change to satisfy it. Examples:

- "Drop OpenAI" → `plan/cross-cutting/required-env.md` (remove
  `OPENAI_API_KEY`), `plan/cross-cutting/external-contracts/openai.md`
  (retire), every story's `api.md` that references the OpenAI provider,
  `architecture.md` (provider-abstraction discussion).
- "Add a free-model selector after `OPENROUTER_API_KEY` is set" →
  ambiguous: either US-004 `story.md` + `api.md` (if absorbed) or a new
  `story.md` (if separate). The classification step resolves which.
- "Change target platform from web to desktop" →
  `architecture.md` (foundational), every story (cross-cutting impact).

The output of this step is a list of artifact paths and one-line reasons.
Record this list — it becomes the `affected_artifacts:` field of the
triage report.

### Step 3 — Forward-impact scan (mechanical)

This step is what makes the boundary between Class 1/2 and Class 3
mechanically checkable rather than a planner gut call. Two passes:

**Pass A — Artifact-reachability.** For each artifact identified in step
2, find every other story whose artifacts reference it inbound:

- `story.md` references via `Consumed contracts:` or `Files Affected:`.
- `api.md` references via shared `wire_format` blocks pointing at the
  same `(provider, method, path)`.
- `hld.md` references via shared component names from
  `architecture.md`'s component inventory.
- `required-env.md` references via shared `required_env` declarations.
- `design/` references via shared design tokens / mockup components.

Any story with an inbound reference is `affected` until argued otherwise.

**Pass B — Per-story enumeration.** For every story in `stories_done`,
`stories_remaining`, and `current_story`:
1. Mark it `affected` if Pass A flagged it OR if the request explicitly
   names it.
2. Mark it `unaffected` only with a one-line written justification (this
   sentence appears in `triage.md`'s per-story verdict list).
3. Implicit "I didn't mention it so it's fine" is forbidden. An absent
   story is a triage bug.

The output of step 3 is the per-story verdict list and the
`affected_stories: { completed, in_flight, planned }` partition.

### Step 4 — Classify

Apply the four-class taxonomy in order. Pick the **smallest** class
consistent with the evidence:

#### Class 1 — Additive within active story

Conditions (ALL must hold):
- The change adds, narrows, or refines an AC or behavior in exactly one
  story, AND that story is `current_story` (or the next entry in
  `stories_remaining` if no story is in flight).
- `affected_stories.planned` is empty.
- `affected_stories.completed` is empty.
- The change does NOT introduce a new external integration (no new
  `required_env`, no new `wire_format` block).
- The implementation context — files in scope, tests, design tokens —
  overlaps with an existing AC or task in the active story.

Recommended routing: planner produces `story.md` + `api.md` + `hld.md`
amendments in place. Hub accepts the amendment within the active
phase. Dispatch lock remains empty.

#### Class 2 — Additive new story

Conditions (ALL must hold):
- The change adds net-new capability that doesn't fit cleanly into the
  active or near-future story.
- `affected_stories.planned` is empty (existing planned stories retain
  their shape).
- `affected_stories.completed` is empty.
- The change has a recognizable scope boundary (you can write a
  `story.md` for it without bleeding into existing scopes).

Recommended routing: planner produces a new `story.md` and inserts it
at the user's preferred slot in `execution_order`. Dispatch lock remains
empty.

#### Class 3 — Multi-story replan

Conditions (ANY one is sufficient):
- `affected_stories.planned` contains 2 or more entries.
- `affected_stories.completed` contains an entry whose AC is materially
  contradicted (this also triggers a P21 Category C incident; see
  step 6).
- The change retires an external integration referenced by 2 or more
  stories.

Recommended routing: planner runs a targeted replan over the affected
slice. Stories may be retired, merged, rescoped, or amended. Dispatch
lock blocks every story in `affected_stories.planned` until the slice
replan resolves.

#### Class 4 — Foundational

Conditions (ANY one is sufficient):
- The change invalidates `architecture.md` (target platform, primary
  language, primary persistence layer, security model).
- The change invalidates a cross-cutting contract that ≥ half of stories
  depend on (e.g., the auth model, the deployment topology).
- The user explicitly frames the request as a re-scope ("change the
  whole project to be a desktop app instead of a web app").

Recommended routing: full planner re-dispatch starting from
`architecture.md`. Existing completed stories may remain valid, may need
rework, or may be explicitly preserved as-is with known drift —
documented per-story in the triage report. Dispatch lock blocks
**every** story in `stories_remaining` until the user approves the new
plan.

### Step 5 — Compose the triage report

Write `.sdlc/plan-changes/<PC-NNN>/triage.md` with this exact structure
(YAML front-matter followed by per-story justifications):

```yaml
---
plan_change_triage:
  id: PC-NNN
  triaged_at: <ISO-8601>
  request_summary: <one-paragraph plain-English summary of the request>
  classification: 1 | 2 | 3 | 4
  classification_rationale: <one-paragraph justification quoting the rule(s)
    from the taxonomy that applied>
  affected_artifacts:
    - path: plan/...
      reason: <one-line>
  affected_stories:
    completed:
      - id: US-NNN-name
        verdict: affected | unaffected
        reason: <one-line>
    in_flight:
      - id: US-NNN-name
        verdict: affected | unaffected
        reason: <one-line>
    planned:
      - id: US-NNN-name
        verdict: affected | unaffected
        reason: <one-line>
  new_stories_required:
    - id: US-00X-tentative-slug
      summary: <one-line>
      insertion_hint: before US-NNN | after US-NNN | execution_order: K
  risk_shapes_affected:
    - <P15 risk shape, if any>
  required_env_delta:
    add: [VAR_NAME]
    remove: [VAR_NAME]
  wire_format_delta:
    add:
      - provider: <name>
        method: <GET|POST|...>
        path: <url>
    remove:
      - provider: <name>
        method: <GET|POST|...>
        path: <url>
  recommended_routing:
    - <one-line action>
  dispatch_lock:
    affected_planned_stories: [US-NNN-name, ...]
  estimated_cost:
    planner_replan_scope: <none | one-amendment | slice-of-N | full>
    execution_impact: <one-line>
---

# Triage report PC-NNN

## Per-story verdicts

(Per the per-story enumeration rule, every story in stories_done +
stories_remaining + current_story appears here with its one-line
verdict + reason. This is NOT the same as affected_stories above —
the front-matter only lists stories where the verdict matters
operationally; this section is the exhaustive enumeration the
mechanical rule requires.)

- US-001-...: <verdict> — <reason>
- US-002-...: <verdict> — <reason>
- ...

## Classification rationale (long form)

<2–4 paragraph narrative referencing the taxonomy rule that applied,
the per-story evidence, and any caveats (e.g., "could be Class 1 if
absorbed into US-004's photo-intake AC; recommending Class 2 because
the model-selector capability is reusable across future stories that
may consume providers").>

## P21 / P19 / P20 cross-references

(For each completed story marked `affected`, note whether a P21
Category C incident is required and reference the AC. For required_env
deltas, note the P19 atomicity requirement. For wire_format deltas,
note the P20 verification step that will run on the routing pass.)
```

### Step 6 — Cross-protocol bookkeeping

Before returning, populate the bookkeeping fields the triage triggers:

1. **P21 incidents for affected completed stories.** If
   `affected_stories.completed` lists any story with `verdict: affected`
   and the contradiction is at the AC level, emit
   `recommended_actions: open_p21_incident: INC-PROVISIONAL` per
   completed story. The coordinator opens the incident on the routing
   pass; this skill only flags the requirement.
2. **P19 required_env atomicity.** If `required_env_delta` is non-empty,
   the routing pass MUST update `.env.example`,
   `plan/cross-cutting/required-env.md`, and the relevant `api.md` in
   the same change. The triage report flags this so the routing-pass
   dispatch (e.g., to `sdlc-planner-api`) knows to apply atomicity.
3. **P20 wire_format verification.** If `wire_format_delta.add` is
   non-empty, the routing pass MUST re-run `wire_format` curl
   verification per P20 §3.1. If `wire_format_delta.remove` is
   non-empty, the routing pass MUST retire the corresponding smoke
   tests in `tests/integration/_shared/`.
4. **P15 risk annotations.** If `risk_shapes_affected` is non-empty,
   the routing pass MUST refresh per-story `risk_annotations` in any
   story with a changed shape.

These cross-protocol items appear in the triage report; the planner
does NOT execute them in triage mode. They are signals to the routing
pass.

### Step 7 — Return

Return to the planner hub with this verdict:

```
DIRECTIVE: PLAN_CHANGE_TRIAGE — VERDICT
PC_ID: PC-NNN
CLASSIFICATION: 1 | 2 | 3 | 4
TRIAGE_REPORT: .sdlc/plan-changes/PC-NNN/triage.md
DISPATCH_LOCK: <affected_planned_stories list, comma-separated, or "none">
RECOMMENDED_ROUTING: <one-line summary>
NEW_STORIES_REQUIRED: <count or 0>
P21_INCIDENTS_REQUIRED: <count or 0>
SUMMARY: <2–3 sentence plain-English summary the coordinator can present>
```

The planner hub relays this verdict to the coordinator, which presents
to the user (per `sdlc-plan-change-recordkeeping`'s `decision.md` flow)
and routes per the user's approval.

## Routing Pass (post-approval)

Triage does NOT write artifacts. After the coordinator records the
user's `decision.md` and re-dispatches the planner with
`DIRECTIVE: PLAN_CHANGE_APPLY`, the planner hub follows the routing
table per the approved class:

| Class | Routing-pass dispatches |
|-------|-------------------------|
| 1 | `sdlc-planner-stories` (amendment), then `sdlc-planner-api` and/or `sdlc-planner-hld` if api/hld touched. Plan-validator (per-story mode). |
| 2 | `sdlc-planner-stories` (new story), then `sdlc-planner-hld`/`sdlc-planner-api`/`sdlc-planner-data`/`sdlc-planner-security`/`sdlc-planner-design` per `candidate_domains`. Plan-validator (per-story mode). |
| 3 | For each affected story: amendment or retirement via `sdlc-planner-stories`. For each new story: same as Class 2. For retired external integrations: api.md retirement + smoke-test retirement. Plan-validator (cross-story mode) over the affected slice. |
| 4 | Re-dispatch from Phase 2 (`sdlc-planner-architecture`) and re-run subsequent phases for affected scope. Plan-validator (full-chain mode). |

Each routing-pass dispatch carries `PLAN_CHANGE_MODE: <amendment | new-story | retire-story | retire-integration>` so the dispatched sub-agent knows it is operating under PC-NNN rather than greenfield/brownfield. Sub-agents that don't natively support amendment mode fall back to producing a complete artifact and the planner replaces in place.

After the routing pass completes, append the resolved file list to
`.sdlc/plan-changes/<PC-NNN>/artifacts-changed.md` and update
`pc.yaml: status: closed, closed_at: <ISO-8601>`.

## Strict Prohibitions

- **Never write to `plan/`, `architecture.md`, `story.md`, `api.md`,
  `hld.md`, `data.md`, `security.md`, or `design/` from triage mode.**
  All writes happen on the post-approval routing pass.
- **Never skip the per-story enumeration.** An absent story in the
  per-story verdict list is a contract violation, not a shortcut.
- **Never classify above the smallest fitting class.** Over-classifying
  a Class 1/2 change as Class 3 is a real cost — it pauses unrelated
  planned stories and forces unnecessary replans. The taxonomy is
  ordered for a reason.
- **Never absorb a multi-story change into Class 1 to avoid replan
  work.** If `affected_stories.planned` is non-empty, the change is at
  least Class 3.
- **Never invent a class.** The taxonomy has exactly four classes; if
  the request defies all four (extremely rare), HALT and return
  `STATUS: TRIAGE_BLOCKED` with a one-paragraph diagnosis.
- **Never approve the change.** User approval happens via the
  coordinator's `decision.md` step. Triage produces a recommendation,
  not an authorization.

## Relationship to Other Flows

- **P19 (`required_env`).** When `required_env_delta` is non-empty, the
  routing pass treats the three-artifact write (`.env.example`,
  `required-env.md`, story `api.md`) as atomic per P19.
- **P20 (`wire_format`).** When `wire_format_delta.add` is non-empty,
  the routing pass re-runs P20's curl verification. This is mandatory.
- **P21 (Category D / Category C).** Category D incoming dispatches
  arrive here via the coordinator; Category C escalations from
  defect-incident mode (where scope grew beyond the AC bound) also
  arrive here. The triage report flags any completed-story AC
  contradictions for P21 Category C incident filing on the routing
  pass.
- **P15 (risk annotations).** Any story whose shape changes during the
  routing pass gets a refreshed `risk_annotations` block.
- **P16 (AC traceability).** When `api.md` or `hld.md` ACs change, the
  routing pass re-runs P16's AC→task mapping for the affected story.
- **Credential-registration.** A request like "add OPENROUTER_API_KEY
  for tests" is normally `CREDENTIAL_REGISTRATION`, not a plan change.
  The credential-registration skill's scope-change detection is what
  routes ambiguous cases here. If the dispatch envelope was
  `PLAN_CHANGE_TRIAGE` because credential-registration returned
  `ROUTE_TO_PLAN_CHANGE`, the original variable name is in `REQUEST:`
  for context.
- **Brownfield protocol.** The brownfield protocol is the pre-existing
  mechanism for plan changes BEFORE execution starts. This skill is
  for plan changes DURING execution — the difference is whether
  `current_story` is set and whether `stories_done` is non-empty. If
  triage detects no execution has started (`stories_done: []` and
  `current_story: null`), recommend routing through brownfield instead
  of plan-change protocol.

## References

- `references/triage-report-template.md` — full skeleton of `triage.md`
  with field-by-field commentary.
- `references/classification-decision-tree.md` — flowchart for the
  four-class decision when evidence is mixed.
