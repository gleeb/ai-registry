# `triage.md` template

Skeleton for `.sdlc/plan-changes/<PC-NNN>/triage.md`. Every field is
required; mark "none" or "[]" when there is genuinely nothing rather
than omitting the field.

```yaml
---
plan_change_triage:
  id: PC-NNN
  triaged_at: 2026-MM-DDThh:mm:ssZ
  request_summary: >
    <One paragraph in plain English. Capture both the literal request
    and the inferred intent. Example: "User asked to drop OpenAI as a
    provider and add a free-model selector that appears after
    OPENROUTER_API_KEY is set. The selector should query OpenRouter for
    free vision-capable models.">

  classification: 1 | 2 | 3 | 4
  classification_rationale: >
    <One paragraph quoting the rule(s) from the skill's taxonomy that
    applied. Example: "Class 3 — affected_stories.planned contains 2
    entries (US-007-provider-selection, US-008-settings-ui-v2), and the
    change retires an external integration referenced by 2 stories
    (US-004 + US-007). Either condition alone qualifies as Class 3 per
    the taxonomy.">

  affected_artifacts:
    - path: plan/system-architecture.md
      reason: <one-line>
    - path: plan/cross-cutting/required-env.md
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
        method: <GET|POST>
        path: <url>
    remove:
      - provider: <name>
        method: <GET|POST>
        path: <url>

  recommended_routing:
    - <one-line action — e.g., "amend US-004 story with model-selector AC">
    - <one-line action — e.g., "retire US-007 (out of scope post-change)">

  dispatch_lock:
    affected_planned_stories: [US-NNN-name, ...]

  estimated_cost:
    planner_replan_scope: none | one-amendment | slice-of-N | full
    execution_impact: <one-line>

  cross_protocol:
    p21_incidents_required: <count>
    p19_atomic_writes_required: true | false
    p20_wire_format_verifications_required: <count>
    p15_risk_refresh_required: true | false
---

# Triage report PC-NNN

## Per-story verdicts (mechanical)

Every story in `stories_done`, `stories_remaining`, and `current_story`
appears here. An absent story is a contract violation.

- US-001-...: <verdict> — <reason>
- US-002-...: <verdict> — <reason>

## Classification rationale (long form)

<2–4 paragraph narrative referencing the taxonomy rule that applied,
the per-story evidence, and any caveats.>

## Routing-pass plan

<Bulleted list of the dispatches the planner will issue if the user
approves. Each bullet names the sub-agent and the artifact it will
produce or modify.>

## Cross-protocol bookkeeping

- **P21 incidents:** <list per affected completed story, or "none">
- **P19 atomicity:** <required_env vars affected, or "none">
- **P20 wire_format:** <endpoints requiring re-verification, or "none">
- **P15 risk refresh:** <stories needing annotation refresh, or "none">

## Caveats and known unknowns

<Anything the triage could not determine without user clarification.
Each caveat is a sentence the coordinator may surface to the user
during the decision step.>
```
