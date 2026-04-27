# P16: Per-Task Reviewer AC Traceability and Evidence Binding

**Status:** Implemented 2026-04-27 — drafted 2026-04-18; amended 2026-04-22 (real-integration evidence clause added — §3.5); resolved decisions and implemented 2026-04-27.
**Relates to:** [P5 (Testing Strategy)](./archive/P5-testing-strategy-and-coverage.md), [P10 (Story-Reviewer Severity Guard)](./archive/P10-story-reviewer-severity-guard.md), [P19 (Environment Secrets)](./P19-environment-secrets-protocol.md), [P20 (External Integration Contract Verification)](./P20-external-integration-contract-verification.md) — complementary; P10 caps Phase 3, P16 shifts catch-work into Phase 2 so the cap is safe; P19 supplies the credential mechanism that P16's real-integration evidence consumes; P20 supplies the `wire_format` and smoke-test artifacts that P16's AC traceability binds to
**Scope:** `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md`, `opencode/.opencode/agents/sdlc-engineering-qa.md`, `opencode/.opencode/agents/sdlc-engineering-implementer.md`, staging-doc task-context schema
**Transcript evidence:** `ses_26105317cffeCAev1W8UP3BtK1` — in both US-002 and US-003, the story-reviewer surfaced AC-level gaps that per-task reviewers had not flagged:
- US-002 story-review i2: payload serialization correctness — no per-task review had verified AC "data round-trips across browser restart with complex payload shapes."
- US-003 story-review i1: docs-evidence gap — no per-task review had checked that docs-evidence artifacts referenced the ACs they purported to satisfy.
- US-003 story-review i3: browser evidence per AC — per-task reviews had confirmed code quality but never traced evidence-per-AC.

Additional evidence for the 2026-04-22 amendment: `ses_24a319c81ffelunHGnCfk7KcBT` — US-004 shipped with per-task code reviews all green, story-review green, acceptance-validator green, against ACs that were all structurally framed in terms of external-provider behavior ("user uploads image → receives identification"). Every gate measured evidence against stubbed network responses; no gate noticed that no AC had ever been observed against the real OpenRouter endpoint. The amendment adds a real-integration evidence requirement for ACs whose behavior is defined in terms of an external provider — the pattern is not an AC-traceability defect in the "does the test exist" sense, it is an AC-traceability defect in the "what kind of evidence counts" sense.

---

## Read Order

**Prerequisites** (read / land first):
- **P5** (archived) — established the testing-strategy conventions P16 extends with AC-binding discipline.
- P10 (light) — P16 shifts catch-work into Phase 2 so P10's Phase 3 iteration cap is safe; the two proposals pair.
- **P19** (2026-04-22 amendment) — §3.5's `evidence_class` distinguishes `real` from `stub-only`; the `stub-only` value flows into P19's `ACCEPTED-STUB-ONLY` validator verdict.
- **P20** (2026-04-22 amendment) — §3.5's `evidence_class: real` is defined as "QA's `external_integration_evidence` (P20 §3.3) records `ran-200`"; P20 supplies the evidence shape P16 §3.5 binds to.

**Consumers** (depend on this proposal):
- **P10** — the Phase 3 iteration cap is only safe once P16 has front-loaded AC traceability into Phase 2.
- **P11** — validator workload drops when P16 pre-renders AC evidence.
- **P20** — the reviewer conformance check in P20 §3.4 extends P16's reviewer contract. §3.5 (amended) is the bridge.
- **P21** — classification (§3.1 step 2) reads P16's AC→task map to identify candidate stories from behavioral descriptions.

**Suggested batch reading order** (2026-04-22 cluster): P19 → P20 → **P16 (you are here; amended §3.5)** → P21 → P14 (amended trigger 5) → P22.

---

## 1. Problem Statement

Per-task reviewers (code-reviewer, QA) evaluate code and tests against the task's immediate scope. They do NOT systematically check "which ACs does this task claim to satisfy, and does the evidence produced by this task actually satisfy them?" That check happens only in Phase 3 (story-reviewer) and Phase 4 (acceptance-validator).

The consequence is a late discovery of AC gaps. A task completes Phase 2 with green code review and green QA. It enters Phase 3. The story reviewer notices the task was supposed to satisfy AC-2, but the test suite for that task tests implementation details, not AC-2's observable behavior. Changes Required. Back to Phase 2.

The fix surfaced late costs more than it would have cost at per-task review time: the implementer's context has moved on, tests may need restructuring, and other tasks that depend on this one may need follow-on changes.

## 2. Root Cause Analysis

### 2.1 ACs are defined at story scope, consumed at task scope without binding
Stories have ACs. Tasks have descriptions. The mapping of "which task satisfies which AC" is implicit in the task list, not an explicit contract. Reviewers have no structured way to check the mapping.

### 2.2 Task-context doc doesn't require AC binding
Per P3's task-context template, a task doc captures scope, approach, libraries, risks. It does not require "ACs this task satisfies" as a mandatory field. Without the field, reviewers have no anchor.

### 2.3 Reviewer contract is shape-based, not outcome-based
Code reviewer checks code quality, type safety, test coverage. QA checks that tests pass and are meaningful. Neither has a step "for each AC this task claims, locate the evidence (code + test) that demonstrates the AC is met."

### 2.4 Phase 3 absorbs the entire AC-traceability burden
When Phase 3 is the ONLY place AC traceability is checked, it bottlenecks there. Because each story-review iteration runs AC traceability against the full story, any gap anywhere restarts remediation.

## 3. Proposed Approach

Five changes (implementation details TBD). Item 5 was added 2026-04-22 per user feedback that the US-004 contract defect was primarily a testing-and-evidence gap, not a documentation-fidelity gap.

1. **Require `acs_satisfied` in task-context doc.** Authored by the **engineering hub during Phase 1 task decomposition** (the hub already owns task-context creation per `sdlc-engineering.md`). Each `ac_id` is a stable reference into `plan/user-stories/<story>/story.md`, which is the canonical home for AC statement text — task-context docs reference, never duplicate, the AC text. Every task-context doc must include:
   ```yaml
   acs_satisfied:
     - ac_id: AC-2
       rationale: >
         This task implements the persistence layer used by AC-2's
         "data survives browser restart" scenario.
       evidence_path:
         - src/db/persistence.ts  # implementation
         - tests/integration/persistence-restart.test.ts  # evidence
       # Optional: name specific test identifiers ONLY when a single test
       # file covers multiple ACs and disambiguation is needed. Otherwise
       # the file path alone is sufficient — keeps bindings stable across
       # describe/it renames.
       tests:
         - "persistence > survives full browser restart"
     - ac_id: AC-3
       rationale: …
   ```
   Tasks not satisfying any AC must explicitly say `acs_satisfied: []` with a reason (e.g., "refactor-only, no AC delta"). The implementer treats this list as an **input contract** for the dispatch, not as something they author after the fact: if implementation reveals a mismatch (the task actually satisfies a different AC, or cannot satisfy a claimed one), the implementer HALTs with a binding-mismatch blocker and the hub revises the binding before re-dispatch.

2. **Extend code-reviewer contract with AC traceability check.** For each entry in `acs_satisfied`, the reviewer verifies:
   - The referenced implementation path exists and contains logic relevant to the AC's statement.
   - The referenced evidence (test) path exists and meaningfully exercises the AC's observable behavior.
   - The test would fail if the AC were violated (not just if the implementation changed shape).
   Findings: missing-evidence → Critical; weak-evidence → Important; narrative-mismatch → Suggestion.

3. **Extend QA contract with AC evidence rendering.** QA produces, as part of its output, an AC-by-AC evidence summary for each AC the task claims. The story reviewer in Phase 3 consumes these summaries instead of re-deriving from scratch. Transforms story-review from exploratory to audit.

4. **Implementer prompt includes AC binding hints.** When the hub dispatches a task, the delegation packet includes the task's `acs_satisfied` list with each AC's statement text, so the implementer writes code and tests with the AC in mind from minute one, not as an afterthought.

5. **Real-integration evidence clause for externally-bound ACs (added 2026-04-22).** When an AC's statement describes behavior that crosses an external-provider boundary (the AC's implementation touches a file whose request builder targets a host declared in `api.md`'s `wire_format` block per P20), the task's `acs_satisfied` entry gains an `evidence_class` field with enumerated values:

   ```yaml
   acs_satisfied:
     - ac_id: AC-2
       rationale: >
         Identifies bottles in an uploaded image via the OpenRouter
         vision model and returns them to the user.
       evidence_path:
         - src/features/media/identify-bottles.ts
         - tests/unit/identify-bottles.test.ts          # evidence_class: stub
         - tests/integration/photo-intake-identification.test.ts  # evidence_class: real
       evidence_class: real    # strongest evidence available for this AC
   ```

   Values:
   - `real` — at least one test with `test-mode: real` (P19 §3.5) has been observed (or skip-logged with env-unset) executing against the real provider, and QA's `external_integration_evidence` (P20 §3.3) records a `ran-200` for the endpoint. This is the default expectation for externally-bound ACs.
   - `stub-only` — only mocked-fetch tests exist. Acceptable transitionally, but drives the story's overall verdict toward `ACCEPTED-STUB-ONLY` (P19 §3.6).
   - `static-analysis-only` — neither test ran real traffic (env unset during this execution AND not previously recorded). The reviewer is relying on code inspection to verify the wire format matches `api.md`. Flagged `Important` — not Critical, because it may be temporarily unavoidable, but the AC is not yet ship-ready by the stronger standard.

   The reviewer contract (item 2) extends to verify the `evidence_class` value against the artifacts actually present. A claim of `evidence_class: real` with no corresponding QA `external_integration_evidence` entry is a **Critical** finding: the implementer or reviewer has misrepresented the evidence. This closes the US-004 pattern where every gate nodded through stub-only evidence against an AC that was definitionally about real-provider behavior.

   Stories whose ACs have no external-integration scope carry `evidence_class: n/a` (or omit the field); the clause applies only to externally-bound ACs. Identification of "externally bound" is mechanical: the task's implementation files import the fetch/request-builder module that targets an `api.md` external host.

## 4. Expected Impact / ROI

**Primary impact:** Shifts AC-traceability catch-work from Phase 3 into Phase 2, where it's cheaper. This is the prerequisite that makes P10's story-review iteration cap safe — without P16, capping Phase 3 iterations risks shipping AC gaps; with P16, Phase 2 has caught them already.

**Secondary impact:** Reduces Phase 4 acceptance-validator workload. When every task has rendered AC evidence, the validator's job becomes "confirm the evidence" (cheap) rather than "discover the evidence" (expensive, cf. P11's 7-hour run).

**Tertiary impact:** Makes task-level staging docs self-describing for AC tracing. A future agent or human auditor can read the per-task staging doc and know what the task is claimed to prove. Valuable beyond this pipeline.

**ROI consideration:** Medium implementation cost (3 agent specs + 1 template). High compounded impact by unlocking P10's iteration cap and reducing P11's validator workload. One of the highest-leverage changes in this batch.

## 5. Success Metrics (for post-run verification)

Measurable from staging docs and reviewer outputs:

- **M1 (hard):** Every task-context doc has an `acs_satisfied` field (possibly empty with reason). Verifiable by parsing staging docs.
- **M2 (hard):** Per-task code-review outputs include an AC-traceability section with one entry per claimed AC. Verifiable by inspecting reviewer output format.
- **M3 (hard):** Story-review iterations that flag AC-level gaps as Critical/Important drop by ≥ 50% vs. baseline. Baseline: US-002 had 2 such findings, US-003 had 3.
- **M4 (soft):** Total story-review iterations per story drop (paired with P10's cap being easier to meet). Target: ≤ 2 iterations per story average.
- **M5 (soft):** Phase 4 validator duration drops (the validator reads pre-rendered AC evidence rather than discovering it). Paired with P11's budget cap — easier to respect when evidence is pre-staged.

## 6. Risks & Tradeoffs

- **Risk:** Implementers and reviewers perform AC binding performatively (checkbox theater) without actually checking that evidence tests behavior. Mitigation: reviewer is explicitly asked "would this test fail if the AC were violated?" — a concrete, answerable question.
- **Risk:** Bindings become stale when code evolves across tasks. Mitigation: the binding is per-task-context doc, not global; each task snapshots its own bindings.
- **Risk:** ACs that are cross-cutting (e.g., "app works offline") cannot be bound to a single task's evidence. Mitigation: allow multiple tasks to share an AC binding; the story reviewer aggregates.
- **Tradeoff:** Per-task reviewer runs slightly longer per dispatch. Cost recovered by reduced Phase 3 iterations.

## 7. Resolved Decisions

(Originally "Open Questions"; resolved 2026-04-27.)

1. **AC statements live in `plan/user-stories/<story>/story.md`.** Task-context docs reference ACs by `ac_id` only and never duplicate the statement text. No separate `acceptance-criteria.yaml` is introduced.
2. **The engineering hub authors `acs_satisfied` during Phase 1 task decomposition** — not the planner, not the implementer. Rationale: per `sdlc-engineering.md`, task decomposition and per-task context-doc creation are already hub responsibilities; the planner outputs at story scope and does not decompose into tasks, so it cannot author task-level bindings. The implementer treats the binding as an input contract: if implementation reveals a mismatch, the implementer HALTs with a binding-mismatch blocker and the hub revises before re-dispatch (rather than the implementer silently rewriting the binding to match what they built — which would be checkbox theater).
3. **`evidence_path` is file paths only by default**, with an optional `tests:` sub-list of describe/it identifiers used **only** when a single test file covers multiple ACs and the reviewer needs disambiguation. Default file-path-only because describe/it names rename frequently during refactoring; the brittleness cost outweighs the precision gain in the common case where one test file maps to one AC.
4. **Complements Phase 4 acceptance-validation; does not replace it.** Phase 4 remains the final independent confirmation. P16 front-loads the evidence so the validator's job becomes "confirm the evidence" (cheap) rather than "discover the evidence" (expensive — see §4 Secondary impact).

## 8. Affected Agents and Skills (preliminary)

| File | Change Type | Description |
|------|-------------|-------------|
| Task-context template | Modified | Add mandatory `acs_satisfied` field with schema (ac_id reference into `story.md`, rationale, evidence_path file list, optional `tests:` disambiguation list, `evidence_class` for externally-bound ACs). |
| `opencode/.opencode/agents/sdlc-engineering.md` (hub) | Modified | Hub **authors** `acs_satisfied` during Phase 1 task decomposition; populates each task-context doc with bindings before dispatch. Handles binding-mismatch HALTs by revising the binding (or the task scope) before re-dispatch. |
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | Modified | Implementer treats `acs_satisfied` as an input contract from the dispatch packet — writes code/tests against the explicit ACs, but does NOT edit `acs_satisfied`. HALTs with a binding-mismatch blocker if the task cannot satisfy a claimed AC or actually satisfies a different one. |
| `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md` | Modified | Add AC-traceability verification step with severity mapping. Verify `evidence_class` against artifacts present (§3.5). |
| `opencode/.opencode/agents/sdlc-engineering-qa.md` | Modified | QA renders AC-by-AC evidence summary in output. |
| `opencode/.opencode/agents/sdlc-engineering-story-reviewer.md` | Modified | Story reviewer consumes per-task AC summaries as primary input instead of re-deriving. |

---

## 9. Relation to Prior Proposals

- P5 introduced testing-strategy conventions; P16 extends them with AC-binding discipline.
- P10 caps Phase 3 iterations; P16 makes the cap safe by catching AC gaps earlier.
- P11 bounds the validator; P16 makes validation cheap by pre-staging evidence.
- P15 annotates task shapes; AC traceability naturally aligns with shapes (e.g., a `cross-browser-assertion` shape pairs with browser-evidence ACs).
- **P19 (environment secrets):** `evidence_class: real` depends on credentials being available; P19 supplies both the mechanism (env vars) and the `ACCEPTED-STUB-ONLY` verdict that receives `evidence_class: stub-only` ACs.
- **P20 (external integration contract verification):** §3.5's `evidence_class: real` consumes P20's QA-rendered `external_integration_evidence`. The two proposals cover opposite sides of the same gate: P20 ensures real traffic exists; P16 ensures reviewers and validators check that it exists before signing off on externally-bound ACs.
- **P21 (defect triage):** When an incident's verification step produces real-path evidence for a previously-stub-only AC, P16 §3.5 is the mechanism by which the story's evidence classification upgrades from `stub-only` to `real` and unlocks the `ACCEPTED` verdict promotion.
