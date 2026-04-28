---
name: sdlc-plan-change-escalation
description: >
  Escalation protocol for the implementer (and execution sub-agents)
  when a plan artifact is materially wrong beyond what a defect
  incident can fix. Load this skill when discovering during
  implementation that api.md specifies an endpoint that doesn't exist,
  the architecture contradicts a newly-discovered constraint, the
  required wire_format is unimplementable as written, or the dispatched
  scope cannot be completed without rewriting a plan artifact.
  Triggers when an implementer encounters phrases like "endpoint
  doesn't exist", "contract unimplementable", "architecture
  contradicts", "the api.md is wrong, not the feature", or "no defect
  fix can satisfy this AC".
---

# Plan-Change Escalation (Implementer)

## Purpose

This skill defines exactly when and how an implementer (or any
execution sub-agent — code-reviewer, QA, acceptance-validator) emits
`BLOCKER: PLAN_CHANGE_REQUIRED` to escalate a plan defect that exceeds
the defect-incident lifecycle. The blocker propagates to the
engineering hub, which forwards it to the coordinator, which routes to
the planner under the plan-change protocol (P22).

The skill exists because the implementer's default escalation paths
(BINDING_MISMATCH, MISSING_CREDENTIALS, INCIDENT_REASSIGN,
WIRE_FORMAT_DIVERGENCE, OPERATIONAL) all assume the plan is correct
and the work is fixable inside the active dispatch. When the plan
itself is wrong — not a typo, not an AC mismatch, but a structural
defect that no amount of code work can fix — the implementer needs a
distinct escape hatch that does NOT consume an iteration count and
does NOT route to the planner via brownfield (which is for
pre-execution changes).

## When to Use

Load this skill when, during implementation or verification, you
encounter one of these patterns:

1. **Endpoint doesn't exist.** `api.md` declares an endpoint at
   `(provider, method, path)` and your smoke test (or a manual curl
   following the planner's `wire_format` block) returns 404 / "no
   such endpoint" from the live provider. The provider's
   documentation does not list this endpoint at all.
2. **Contract unimplementable as written.** `api.md`'s
   `wire_format.request_body_example` cannot be sent to the provider
   without modification (e.g., required field is missing, field type
   contradicts the provider's schema).
3. **Architecture contradicts a newly-discovered constraint.** The
   plan says component A talks to component B via mechanism X, but
   the runtime / framework / platform forbids X (e.g., the plan
   specifies a synchronous IPC call across processes that the
   platform implements only as async).
4. **Required external behavior is unavailable.** The AC requires the
   feature to do Y, and Y depends on a provider capability that the
   provider has retired, deprecated, or never offered (e.g., the
   model the AC names is no longer hosted).
5. **The active story's scope cannot be completed without artifact
   rewrite.** Not a binding mismatch (BINDING_MISMATCH covers a
   different problem — your code satisfies a different AC than the
   binding claimed). The artifact itself, in any reasonable
   interpretation, is wrong.

## When NOT to Use

- **NOT for binding mismatches.** Use the BINDING_MISMATCH HALT
  protocol — your code satisfies AC-K when the binding said AC-J.
  That's a contract-correction signal, not a plan defect.
- **NOT for missing credentials.** Use the MISSING_CREDENTIALS
  blocker. The plan is correct; the local environment is incomplete.
- **NOT for wire-format divergence between this story and a prior
  story.** Use the WIRE_FORMAT_DIVERGENCE blocker. The two `api.md`s
  disagree, but the routing destination is the planner anyway — the
  blocker's existing routing covers this case.
- **NOT for code-quality issues.** Lint, type errors, test failures,
  build failures. Use the standard remediation cycle.
- **NOT for incident scope expansion.** Use the
  INCIDENT_SCOPE_EXPANSION HALT. That signal already routes to the
  planner under P22 via the engineering hub's defect-incident mode.
- **NOT for "I don't like the plan."** The implementer's job is to
  satisfy the plan as written. If the plan is satisfiable but
  awkward, complete the work and surface the awkwardness in the
  staging doc's "Issues & Resolutions" or as a planning gotcha. The
  plan-change escalation is reserved for plans that are physically
  unimplementable.
- **NOT for ambiguous AC.** If the AC is unclear, surface the
  ambiguity via BINDING_MISMATCH or, if you've already started, via
  the architecture's HALT blocker. Plan-change escalation is for
  defects, not for fuzziness.

## Procedure

### Step 1 — Rule out the alternatives

Before emitting `BLOCKER: PLAN_CHANGE_REQUIRED`, walk through the
alternative escalation paths and confirm none fits:

| Symptom | Use this instead |
|---------|------------------|
| Code satisfies AC-K not AC-J | `BLOCKER: BINDING_MISMATCH` |
| `process.env.NAME` returns falsy | `BLOCKER: MISSING_CREDENTIALS` |
| Two stories' `api.md` disagree on the same endpoint | `BLOCKER: WIRE_FORMAT_DIVERGENCE` |
| Incident fix needs files outside SCOPE | `BLOCKER: INCIDENT_SCOPE_EXPANSION` |
| Root cause is in another completed story | `BLOCKER: INCIDENT_REASSIGN` |
| Lint/typecheck/test failures | Standard remediation cycle |

If ANY alternative fits the symptom, use that path. Plan-change
escalation is the residual case when the artifact itself is the
defect.

### Step 2 — Gather evidence

The blocker MUST cite concrete evidence. Without evidence, the
planner cannot triage the change and the coordinator may bounce the
escalation back as OPERATIONAL. Required evidence:

- **For wire defects:** the live provider's response (status code,
  body excerpt) showing the contract failure. A `curl -i` transcript
  is acceptable. The provider's documentation URL showing the actual
  expected shape (or showing the endpoint does not exist).
- **For architecture/runtime defects:** the runtime error message or
  platform documentation showing the contradiction. File:line
  citation of the plan artifact's contradicted clause.
- **For deprecated/missing provider capability:** the provider's
  changelog, deprecation notice, or model-list response showing the
  capability is unavailable. Date.
- **For unimplementable scope:** the specific clause in `story.md` /
  `api.md` / `hld.md` that is unimplementable, plus a one-paragraph
  diagnosis of why.

### Step 3 — Emit the blocker

The first line of your return message MUST be exactly:

```
STATUS: BLOCKED — PLAN_CHANGE_REQUIRED
```

Followed by these required fields (in this order, each on its own
labeled block):

```
ARTIFACT: <plan/path/to/file.md>
CLAUSE: <the specific clause / AC / wire_format block / architecture
section that is defective. Quote 1–3 lines verbatim.>
DEFECT_CLASS: endpoint-missing | contract-unimplementable |
              architecture-contradiction | capability-unavailable |
              scope-unimplementable
EVIDENCE:
  <Multi-line evidence per step 2. For wire defects, include a curl
  transcript. For architecture defects, include the runtime error.
  Include URLs to provider docs / changelogs.>
OBSERVED:
  <One paragraph: what happens when you try to satisfy the plan as
  written. File:line citation of any code you wrote in the attempt
  (which you will discard once the plan is fixed).>
RECOMMENDED_CLASS: 1 | 2 | 3 | 4
  <Your guess at the P22 classification. The planner decides
  authoritatively, but your guess helps. One sentence rationale.>
SUGGESTED_DELTA:
  <One paragraph: what change to the plan would unblock you. NOT a
  full re-plan — just the minimum delta you can see from your
  position. The planner is not bound by your suggestion.>
```

Do NOT continue work after emitting this blocker. Do NOT commit any
exploratory code that was needed to discover the defect — back it
out, leave the working tree clean, return the blocker.

### Step 4 — Return

Return the blocker to the engineering hub. The hub maps your
`BLOCKER: PLAN_CHANGE_REQUIRED` to its own
`VERDICT: blocked, reason: PLAN_CHANGE_REQUIRED` per the hub's
Completion Contract. The coordinator routes to the planner under the
plan-change protocol; the active story is suspended pending triage.

This blocker does NOT consume a code-review iteration count, a QA
iteration count, or a Phase-4 acceptance slot. It is a contract-level
escalation, not a code-quality remediation.

## Strict Prohibitions

- **Never modify a plan artifact yourself.** Implementers do not write
  to `plan/`. Any "I'll just edit api.md to make this work" is a
  protocol violation. The planner owns plan artifacts.
- **Never silently work around the defect.** Do not commit code that
  hits a different endpoint than the one in `api.md`, swaps in a
  different model than the one named, or otherwise diverges from the
  plan to "make tests pass." That produces silent plan drift and
  invalidates downstream traceability.
- **Never use this blocker to dodge hard work.** "This is hard" is
  not a plan defect. The blocker is reserved for cases where the
  plan, as written, cannot produce a working system regardless of
  effort.
- **Never invent the evidence.** The planner triage will read your
  EVIDENCE block. If the curl transcript is fabricated or the runtime
  error doesn't actually occur, the triage is corrupted and the
  resulting plan change is wrong.
- **Never escalate without trying the alternatives.** Walk the table
  in step 1. If MISSING_CREDENTIALS or WIRE_FORMAT_DIVERGENCE or
  BINDING_MISMATCH fits, use that path — it has cleaner routing and
  doesn't pause the entire active story.

## Relationship to Other Flows

- **Defect-incident mode.** When the dispatch envelope carries
  `INCIDENT MODE:`, the equivalent blocker is
  `INCIDENT_SCOPE_EXPANSION` (which already routes via P22). Use that
  blocker instead of `PLAN_CHANGE_REQUIRED` while in incident mode.
  The hub will surface incident-scope-expansion as
  `PLAN_CHANGE_REQUIRED` to the coordinator, but that translation is
  the hub's job, not yours.
- **Engineering hub Phase 4 acceptance.** When acceptance returns
  `CHANGES_REQUIRED` and the disagreement source is the planner's
  `wire_format` block (not your code), the hub itself emits
  `PLAN_CHANGE_REQUIRED` per its Completion Contract — you don't have
  to. This skill covers the implementer-discovered case during
  Phase 2 / Phase 3.
- **Brownfield protocol.** Brownfield runs before execution; this
  protocol runs during execution. If the project has not started any
  story (`stories_done: []`, `current_story: null`), the planner
  routes the change through brownfield instead, but you don't make
  that distinction — emit the blocker with the evidence and let the
  coordinator/planner decide.
- **`sdlc-plan-change-triage` skill.** That skill is the planner's
  handler for the dispatch the coordinator issues after this blocker
  fires. You never load that skill from the implementer. They are
  paired — yours raises the issue, theirs analyzes it.
