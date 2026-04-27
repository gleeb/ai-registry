# P15: Planner-Level Task Risk and Complexity Annotations

**Status:** Archived (not implemented) — drafted 2026-04-18, revised 2026-04-27, fully implemented 2026-04-27, reverted and archived 2026-04-27.
**Relates to:** [P14 (Oracle Escalation Threshold)](./P14-oracle-escalation-threshold.md), planning-gotchas mechanism (see `common-skills/planning-gotchas/`), skill-iteration loop.
**Transcript evidence:** `ses_26105317cffeCAev1W8UP3BtK1` — US-003 `tasks.md` decomposition does not distinguish Task 4 ("PWA installability browser evidence with CDP") from Task 1 ("create theme provider") in any structural way. Both are flat task entries with equivalent metadata. At execution time there was no forward warning that Task 4 would involve cross-browser CDP + timing-sensitive assertions + service-worker lifecycle — three categories the engineering hub could have pre-staged differently had it known.

---

## Why Archived (decision recorded 2026-04-27)

P15 was drafted, refined, and fully implemented across the planner, hub, validator, story templates, staging-doc template, and a new shared `task-shapes.md` taxonomy. After the implementation landed, a review of the proposal against the existing reactive systems produced a unanimous decision to revert and archive it without keeping the changes. The reasoning, recorded here for future reference:

### 1. Functional overlap with reactive systems we already operate

| Concern P15 addressed | Existing mechanism that already handles it |
|---|---|
| "This task is harder than the planner expected" mid-run | Oracle Escalation Policy triggers 1 (`doc_queries > 8`) and 2 (3rd implementer attempt). Reactive, no a-priori labeling needed. |
| "We should have known this category is hard" | Planning-gotchas + skill iteration. Post-mortem learning that feeds the next cycle — exactly what gotchas are for. |
| "Pre-stage scaffolding for a known-shape task" | Skills + library cache. When a pattern recurs, the procedure becomes a skill; the skill itself is the mitigation. |
| "Reviewer should focus on X for this kind of task" | Code-reviewer already adapts to the diff. Static per-shape focus strings are a guess about what reviewers should care about, layered on top of what they already do. |
| "Limit how many tasks claim to be 'high risk'" | This is solving a problem the planner doesn't currently exhibit — there is no observed risk-inflation signal in any plan to date. |

The pattern across all five rows is the same: P15 attempts pre-emptive labeling for problems the existing reactive stack already detects with real evidence. Reactive evidence is strictly better than hypothesis-based labels because it's anchored in actual run data, not in a speculative taxonomy.

### 2. Costs P15 would impose on every story

- **Token footprint of the taxonomy file.** The implemented `task-shapes.md` was ~275 lines, read by the story decomposer, the engineering hub, and the plan validator on every story — three reads per story for content whose value was itself hypothesis-based.
- **Hard validator gate.** Every plan would be required to carry `shapes`, `scope_signals`, `derived_risk`, and conditional `justification` fields, with the validator rejecting on absence. That's a strict dependency on a hypothesis-based file across the entire planner output surface.
- **Two-tier annotation drift risk.** Story-level shapes (planner-owned) and task-level shapes (hub-derived at Phase 1c) have to stay in sync as the HLD evolves. That's an ongoing maintenance load on the hub for a feature whose payoff is unproven.

### 3. Worker-routing inconsistency with the Oracle Escalation Policy

P15's mid-execution `risk_upgrade_suggestion` block, emitted by the implementer, is a worker-originated routing signal even when framed as advisory. The Oracle Escalation Policy's "workers do not route" governor is invariant: implementer and code-reviewer prompts MUST NOT contain Oracle awareness, counters, or any routing question. Surfacing a "this task is actually harder" hint from the implementer is the same shape of cross-layer coupling the policy explicitly forbids. Keeping P15 would have forced either a special-case carve-out or a re-litigation of that governor.

### 4. The hypothesis-based content was a tell

The taxonomy was reverse-engineered from a single transcript (`ses_26105317cffeCAev1W8UP3BtK1`) and then expanded by analogy to cover SaaS / web-app surface area. That expansion was acknowledged in the proposal as hypothesis-based and intended to be pruned by post-run metrics over time. The honest read of "we'll add a forecasting layer and prune it later via metrics we haven't built yet" is that the cheaper path is to skip the forecasting layer and let the post-run metrics that already exist (gotchas) do the pruning of agent/skill content directly.

### 5. The reversion path was clean

P15's full implementation produced one unstaged-but-revertible commit's worth of changes (14 modified files + 1 new taxonomy file + 1 new proposal file). `git restore` plus removal of the new directory restored the system to its pre-P15 state without residue. The cost of having implemented P15 was bounded; the cost of leaving it in place would have been ongoing.

### What survives from this exploration

- **The vocabulary as a reference.** This file (now archived) preserves the taxonomy and risk-derivation thinking. Future planning-gotchas entries that reach for similar concepts can cite it as prior art rather than re-deriving.
- **The "workers do not route" stress test.** P15's implementer-side `risk_upgrade_suggestion` was a useful negative example — it makes the governor's reasoning more concrete by showing what an "advisory" worker-side routing signal would look like in practice.
- **The existing reactive stack is sufficient until proven otherwise.** No further action required. If, over the next several cycles, we observe a pattern where Oracle fires too late, gotchas don't feed back fast enough, or skills don't accumulate vocabulary on their own, *that* is the evidence that justifies revisiting a slimmer version of P15. Likely candidates for a slimmer revision: drop the implementer suggestion entirely, drop the hard validator gate, fold the taxonomy into the planner skill rather than a separate cross-agent reference, and key any pre-staging on observed gotcha frequency rather than planner forecast.

### Implementation footprint that was reverted

For the record, the following surface was changed by the P15 implementation and then reverted in full via `git restore`:

- `opencode/.opencode/agents/sdlc-planner.md` — Phase 2 dispatch directives
- `opencode/.opencode/agents/sdlc-planner-stories.md` — Step 3a + dependency manifest annotations + self-validation
- `opencode/.opencode/agents/sdlc-engineering.md` — Task Shape Annotations section, Phase 1c step, mid-execution risk-upgrade decision protocol, reviewer-focus injection at dispatch
- `opencode/.opencode/agents/sdlc-engineering-implementer.md` — Risk-Upgrade Suggestion section + completion-contract bullet
- `opencode/.opencode/agents/sdlc-plan-validator.md` — schema checks at per-story (Mode 2) and cross-story (Mode 3) levels
- `common-skills/planning-stories/references/STORY-OUTLINE.md` — `shapes`, `scope_signals`, `derived_risk`, `expected_query_budget`, `justification` fields on the manifest
- `common-skills/planning-stories/references/DEPENDENCY-MANIFEST.md` — five new field specs and validation rules
- `common-skills/project-documentation/references/staging-doc-template.md` — per-task Shapes / Scope signals / Derived risk / Expected query budget / Justification / Risk-upgrade history
- `common-skills/architect-execution-hub/references/phase1-task-decomposition.md` — step 6a "Task shape derivation"
- New file at `opencode/.opencode/references/task-shapes.md` (deleted on revert)

---

## Read Order

**Prerequisites** (read / land first):
- **P3** (archived) — P15 extends the planner's staging / context conventions P3 established.
- **P8** (archived) — cache-story context established the shape P15 annotates with risk.

**Consumers** (depend on this proposal):
- **P17** — task-class inference (A/B/C) reads P15's shape annotations; shared input with P18.
- **P18** — story-level mode selection (end-to-end vs phase-boundary) consumes P15's story-level risk roll-up; **strict prerequisite** — P18 collapses to "always end-to-end" without P15.
- **P20** — stories flagged with the `external-api-integration` shape are P20's natural population; P15 is how P20 knows which stories need wire-format blocks.
- **P22** — plan-change triage re-evaluates P15 annotations on affected stories when scope shifts.

**Suggested reading order** (earlier 2026-04-18 cluster): **P15 (you are here)** → P17 → P18. P15 is foundational to the planning-signal cluster.

---

## 1. Problem Statement

Tasks within a story are treated as uniformly shaped at plan time. The planner produces a flat list of tasks with titles, descriptions, and task-level ACs. The execution hub then dispatches them identically: same implementer, same per-task review cycle, same cache protocol, same 3-query budget.

But tasks are not uniform in risk. Some categories consistently explode in implementation cost, across the typical SaaS / web-app surface:

- Database schema migrations on hot tables, especially destructive ones (drops, renames, type changes)
- Long-running data backfills that require idempotency and resumability
- Deployment to managed platforms (Netlify, Vercel, Supabase, Fly.io, Cloudflare) where convention errors are silent until production
- Infra-as-code changes (Terraform, CDK, Pulumi) that touch shared state
- Background jobs and webhook delivery with at-least-once semantics
- Auth, tenant-isolation, and PII-handling boundary changes
- Browser automation, CDP, service-worker lifecycle (the originally observed failure)
- Type-system bridges across generics and mapped types
- Concurrency coordination across multiple independent lifecycles
- External API integration with undocumented failure modes

Without annotations, the hub cannot pre-stage:
- Expanded query budget for libraries in the high-risk domain
- Playwright / browser-evidence scaffolding up front
- A pre-committed reviewer focus (e.g., "verify migration uses `lock_timeout`" or "verify webhook signature path")
- Domain-appropriate verification gates (e.g., a destructive migration must show a rollback plan)

The hub discovers complexity at execution time, by failing first. That's expensive.

## 2. Root Cause Analysis

### 2.1 Planner contract stops at "what needs to happen"
The planner decomposes stories into tasks covering scope and dependencies. It does not surface "and this task has shape X which is known to be hard." There's no field in the current task schema for risk, shape, or complexity signals.

### 2.2 Planner has the information but no place to put it
When the planner writes tasks.md for US-003, the planner's own context already touches on CDP, Playwright cross-browser, installability prompts, etc. The planner is not unaware — it's just not asked to annotate. The signal is lost between Phase 1 and Phase 2.

### 2.3 No domain taxonomy
Even if we asked planners to annotate, there's no agreed vocabulary for complexity shapes. "Hard" is subjective; "involves Postgres DDL on a hot table without `CONCURRENTLY`" is specific.

### 2.4 No validator for annotations
If annotations existed but were optional or free-text, they'd drift. A taxonomy + a schema check in `plan-validator` closes the loop.

### 2.5 Shape conflated with difficulty
A naive design would have the planner assert difficulty/risk directly. That ignores skill-registry state — a `paas-deployment` task is trivial when a `netlify-deploy` skill exists and risky when no such skill exists. Conflating shape with risk loses this distinction.

## 3. Proposed Approach

### 3.1 Separate shape from risk

Three distinct concepts replace the previous single "complexity" axis:

- **Shape** — descriptive category of work. Planner-controlled. Stable vocabulary defined in the taxonomy reference. Multi-select per task. Says "this task involves X-class concerns."
- **Skill availability** — registry-checked mitigation. Says "we have a procedure for X already." Looked up at plan time and re-checked at dispatch time.
- **Scope signal** — descriptive scope qualifiers: `first-time`, `incremental`, `hot-path`, `cold-path`, `single-tenant`, `multi-tenant`, etc. Planner-asserted.

**Risk** is a *derived* signal computed from the three above, not an independent planner assertion. It drives query-budget overrides, scaffolding choices, and reviewer focus — **not** Oracle dispatch. Oracle dispatch remains governed by P14's existing reactive triggers; P15 does not introduce a proactive Oracle path.

Default derivation table:

| Shape weight (any present) | Skill present? | Scope signal | Resulting `derived_risk` |
|---|---|---|---|
| High-weight shape | Yes | Incremental / cold-path | low |
| High-weight shape | Yes | First-time / hot-path | medium |
| High-weight shape | No | Incremental / cold-path | medium |
| High-weight shape | No | First-time / hot-path | high |
| Only standard-weight shapes | — | — | low |

Each shape entry in the taxonomy declares its own weight (`high` or `standard`). The planner MAY override `derived_risk` with a `justification` field. The plan-validator rejects overrides without justification.

### 3.2 Complexity-shape taxonomy

A small, versioned, domain-grouped vocabulary. The taxonomy reference (`opencode/.opencode/references/task-shapes.md`) is the source of truth and is read by both the planner and the engineering hub. Each shape entry has two sections:

- **Qualifying examples** — read by the planner to decide whether to apply the label.
- **Execution implications** — read by the hub to decide what adjustments to apply when the label is present (oracle pre-authorize, query-budget delta, reviewer focus, scaffolding).

Initial domain-grouped vocabulary:

**Data & persistence**
- `schema-migration-additive` — new column/table, online-safe
- `schema-migration-destructive` — drops, renames, type changes; ordered rollout
- `postgres-lock-sensitive` — DDL on hot tables, `CREATE INDEX` without `CONCURRENTLY`, `ALTER TABLE` rewrites
- `data-backfill` — long-running, batched, idempotent, resumable
- `query-performance` — index design, EXPLAIN-driven, N+1 risk
- `transaction-boundary` — multi-statement atomicity, isolation level, distributed/saga patterns

**Deployment & release**
- `paas-deployment` — Netlify, Vercel, Render, Fly.io, Cloudflare Pages: build config, env vars, redirects, headers, edge functions
- `baas-integration` — Supabase, Firebase, PlanetScale: managed-backend platform-specific quirks (RLS policies, security rules)
- `container-deployment` — Docker, k8s, ECS, Cloud Run: image build, runtime config, health checks
- `infra-as-code` — Terraform, CDK, Pulumi changes that touch shared state
- `ci-cd-pipeline` — GitHub Actions / GitLab CI / build pipeline changes
- `dns-and-tls` — domain wiring, cert provisioning, propagation timing
- `deployment-ordering` — code-then-migration vs migration-then-code sequencing
- `zero-downtime-required` — blue/green, canary, drain semantics
- `feature-flag-rollout` — gradual exposure, kill-switch, cleanup debt

**Async & integration**
- `background-job` — queue semantics, idempotency, retries, poison-message handling
- `webhook-delivery` — at-least-once, signature verification, replay protection
- `external-api-integration` — third-party contract, rate limits, undocumented failure modes
- `event-driven-coupling` — pub/sub topology, schema evolution

**Auth, tenancy & security**
- `auth-boundary` — session/JWT/OAuth/SAML, scope checks, token lifecycle
- `tenant-isolation` — row-level security, cross-tenant leakage risk
- `pii-handling` — encryption at rest, log masking, audit trail
- `secret-management` — rotation, scoped credentials

**Observability & ops**
- `observability-instrumentation` — metrics/traces/logs other systems depend on
- `slo-sensitive` — change touches a path with a published SLO

**Cross-cutting**
- `type-system-bridge` — generics, mapped types, conditional types across module boundaries
- `concurrency-coordination` — locks, leases, race windows
- `cache-invalidation` — multi-layer caches, stampede risk

**Frontend**
- `browser-automation-evidence` — collapses CDP, service-worker lifecycle, and cross-browser assertions into one shape; applies when a task requires automated browser-side evidence

**Default**
- `standard` — applied when no other shape qualifies. Treated as standard-weight by the risk derivation.

### 3.3 Task schema

```yaml
- id: US-003-T4
  title: PWA installability acceptance evidence
  shapes: [browser-automation-evidence]   # 1–4 entries, multi-select
  scope_signals: [first-time, hot-path]
  derived_risk: high                       # computed; planner may override
  expected_query_budget: 15                # override of P8 default
  justification: >                         # required when derived_risk overridden
                                           # OR expected_query_budget overridden
    Installability prompts use beforeinstallprompt which varies by browser;
    CDP is required to trigger the prompt for evidence; service-worker
    readiness affects prompt timing.
```

### 3.4 Planner contract update

The planner MUST:
- Annotate at least one shape on every task. Tasks without a qualifying shape use `[standard]`.
- Multi-select up to 4 shapes per task. If more apply, the task is too big — split it. Plan-validator rejects > 4.
- Provide `scope_signals` for every task.
- Provide a `justification` whenever `derived_risk` is overridden or `expected_query_budget` is overridden.

### 3.5 Mid-execution risk-upgrade protocol

When the implementer discovers complexity not anticipated at plan time, it returns a **risk-upgrade suggestion** to the hub:

```yaml
risk_upgrade_suggestion:
  task_id: US-003-T4
  add_shapes: [concurrency-coordination]
  rationale: Discovered a race between SW activation and prompt dispatch.
  confidence: high
```

The hub decides one of:

- **Accept** — update task annotations on the artifact; expand remaining query budget; switch reviewer focus to the newly-revealed shape's checklist; allow P14's existing reactive Oracle triggers to fire on the next failure if needed.
- **Reject** — continue with current plan, log rationale.
- **Escalate** — return to planner for re-decomposition if the new shape invalidates task boundaries.

The suggestion is advisory; the hub owns the decision so a single point controls budget and reviewer focus. All upgrade events are logged for retrospective use against M3/M4. (Note: this protocol does not change Oracle-dispatch logic. If after the upgrade the task fails again, P14's reactive triggers escalate to Oracle the same way they would for any task.)

### 3.6 Mid-story task additions

Any task the hub adds mid-story (rare but possible) carries the same `shapes`, `scope_signals`, and derivation as planner-produced tasks. The plan-validator runs against the updated artifact at story close.

### 3.7 Plan-validator checks

The plan-validator ensures:
- Every task has a non-empty `shapes` array; every value exists in `task-shapes.md`.
- `shapes` array length ≤ 4.
- Every task has a `scope_signals` array.
- `justification` is present when `derived_risk` is overridden or `expected_query_budget` is overridden.
- `expected_query_budget` overrides are within sane bounds (1–30).
- Story-level: ≤ 40% of tasks may carry `derived_risk: high` without a story-level justification (anti-inflation guard).

## 4. Expected Impact / ROI

**Primary impact:** Allows the hub to pre-stage task-appropriate resources (browser runner, Playwright config, Postgres `lock_timeout` reviewer, expanded cache budget, domain-specific reviewer focus, rollback-plan gates for destructive migrations) instead of discovering needs mid-task. The execution savings come from avoiding failed implementer cycles that would otherwise be caused by the hub being underprepared for a shape it could have anticipated.

**Secondary impact:** Creates retrospective data for improving the taxonomy itself. Over many runs, we can see which shapes correlate with which costs, and refine weights and budget overrides empirically.

**Tertiary impact:** Provides shape vocabulary that downstream proposals (P17 task-class inference, P18 story-mode selection, P20 external-integration verification, P22 plan-change triage) consume directly. Without P15 these proposals lack a shared input.

**ROI consideration:** Low direct fix cost (schema edit + spec edits + validator check + new reference file). Value is realized at the hub through scaffolding and reviewer-focus decisions; not gated on any other proposal landing.

**Out of scope:** Proactive Oracle dispatch. Oracle-dispatch logic is governed entirely by P14's existing reactive triggers and is not modified here. If P15's annotations later prove useful for proactive dispatch, that would be a separate proposal.

## 5. Success Metrics (for post-run verification)

Measurable from planning artifacts and dispatch log:

- **M1 (hard):** Every task in every `tasks.md` has a non-empty `shapes` field. Verifiable by parsing plan artifacts.
- **M2 (hard):** Every task with `derived_risk` overridden or `expected_query_budget` overridden has a `justification` field. Plan-validator enforces.
- **M3 (soft):** Tasks annotated with non-`standard` shapes have higher observed execution cost than `standard` tasks — confirming the annotation is predictive. If not, the taxonomy or its weights need revision.
- **M4 (soft):** The distribution of shapes across a project is not degenerate (not all `standard`, not all `high`). A healthy mix.
- **M5 (soft):** Tasks annotated `derived_risk: high` show observably different hub behavior at dispatch (expanded budget applied, reviewer focus selected, scaffolding pre-staged) versus `standard`-risk tasks. Measures that annotations flow into execution adjustments.
- **M6 (soft):** Risk-upgrade suggestions accepted by the hub correlate with shapes that were missed at plan time — feeds taxonomy refinement.

## 6. Risks & Tradeoffs

- **Risk:** Planner over-annotates (everything is `risk: high`) to be safe, inflating query budgets and reviewer overhead and diluting the signal. Mitigation: validator rejects plans where > 40% of tasks are `derived_risk: high` without story-level justification.
- **Risk:** Taxonomy drift — shapes get added ad hoc, eventually become unmanageable. Mitigation: shapes live in one referenced file; additions require an explicit proposal.
- **Risk:** Annotation accuracy is only as good as the planner's domain knowledge. For novel technical areas, the planner won't know what's hard. Mitigation: conservative default (annotate when uncertain); risk-upgrade protocol (§3.5) catches misses; retrospective learning feeds future plans.
- **Risk:** Skill-registry lookup fails or returns stale data, causing wrong risk derivation. Mitigation: hub re-checks at dispatch; mid-execution upgrade can correct.
- **Tradeoff:** Planning gets slightly more expensive. Accepted; planning is cheap relative to execution.

## 7. Open Questions

Resolutions to prior open questions are recorded inline; no remaining open questions.

1. ~~Multi-select vs primary-plus-secondaries~~ **Resolved:** multi-select, max 4 per task. Validator-enforced cap (§3.4, §3.7).
2. ~~Where the taxonomy lives physically~~ **Resolved:** `opencode/.opencode/references/task-shapes.md`. Shared between planner and hub via the existing `.opencode/` symlink in `scripts/setup-links.sh` — no setup-script changes required.
3. ~~Implementer retroactive risk upgrade~~ **Resolved:** see §3.5 (risk-upgrade suggestion protocol).
4. ~~Shapes for hub-added tasks mid-story~~ **Resolved:** see §3.6 (same annotations, same validator).

## 8. Affected Agents and Skills

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-planner.md` | Modified | Task-annotation contract: require `shapes` and `scope_signals` on every task; reference taxonomy at `.opencode/references/task-shapes.md`. |
| `opencode/.opencode/agents/sdlc-planner-stories.md` | Modified | Same contract during story decomposition. |
| `opencode/.opencode/agents/sdlc-engineering.md` (hub) | Modified | Read taxonomy at dispatch; apply execution implications; implement risk-upgrade decision protocol (§3.5). |
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | Modified | Emit risk-upgrade suggestions when discovering hidden complexity (§3.5). |
| `opencode/.opencode/agents/sdlc-plan-validator.md` | Modified | Schema validation: shape membership, multi-select cap, scope-signal presence, justification requirements, anti-inflation guard. |
| `opencode/.opencode/references/task-shapes.md` | **Created** | Domain-grouped taxonomy with two sections per shape: qualifying examples (planner) and execution implications (hub). Each entry declares its weight (`high` or `standard`). |
| `opencode/.opencode/skills/planning-stories/references/STORY-OUTLINE.md` | Modified | Story manifest template extended with `shapes`, `scope_signals`, `derived_risk`, `expected_query_budget`, `justification` fields. |
| `opencode/.opencode/skills/planning-stories/references/DEPENDENCY-MANIFEST.md` | Modified | Field specs for the new manifest fields and validation rules 16–20. |
| `opencode/.opencode/skills/project-documentation/references/staging-doc-template.md` | Modified | Per-task entries gain `Shapes`, `Scope signals`, `Derived risk`, `Expected query budget`, `Risk-upgrade history` fields. |
| `opencode/.opencode/skills/architect-execution-hub/references/phase1-task-decomposition.md` | Modified | Step 6a — derive per-task shapes from story-level annotations + HLD design unit specifics; compute task-specific budget and risk; pre-stage reviewer focus. |
| `scripts/setup-links.sh` | Unchanged | The existing `.opencode/` symlink already exposes the new `references/` folder to projects. No action needed. |

**Implementation deviation from §3.3:** P15's draft schema located annotations on a hypothetical `plan/user-stories/<story>/tasks.md` file. The current SDLC system has no such artifact — story decomposition produces `story.md` (planner-owned), and task decomposition happens later in the engineering hub's staging document at Phase 1c. To match this reality:

- **Planner annotations live on `story.md`** in the `## Dependencies` manifest. The planner asserts story-level `shapes`, `scope_signals`, `derived_risk`, optional `expected_query_budget`, optional `justification`.
- **Task-level annotations are derived by the engineering hub at Phase 1c** in the staging doc Task Decomposition. Each task inherits its parent story's shapes by default; the hub MAY add task-specific shapes when a particular HLD design unit involves a shape the story as a whole did not, and recomputes the per-task budget by adding the per-shape Execution-implications deltas.
- **Validator coverage** spans story-level (Mode 2 per-story) and cross-story (Mode 3 anti-inflation). Task-level annotations are hub-internal and not currently validator-checked at plan time.

---

## 9. Relation to Prior Proposals

- P14 (Oracle Escalation Threshold) is **independent** of P15. Oracle dispatch follows P14's existing reactive triggers; P15 introduces no proactive Oracle-dispatch path. Earlier drafts of P15 included an `oracle_preauthorize` flag; that mechanism was intentionally removed to keep the Oracle protocol unchanged.
- P3 introduced planning-artifact conventions; P15 extends them with risk annotations.
- P16 (per-task AC traceability) benefits when tasks are annotated — the reviewer can load shape-specific AC templates.
- P17, P18, P20, P22 consume P15's shape vocabulary directly (see Read Order).
