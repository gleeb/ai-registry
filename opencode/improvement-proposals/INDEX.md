# SDLC Execution Pipeline — Improvement Proposals

**Origin:** Post-mortem analysis of sessions `ses_278b8ce55ffeKxlkK4NQaSyTHd` (US-001-scaffolding first run), `ses_264266feeffe804Vnge3sKB2DA` (US-001-scaffolding second run after P1–P6), `ses_2639886c2ffeMI2wLZcZ43UJrP` (scaffolding + US-002-local-persistence-foundation run to token exhaustion), `ses_26105317cffeCAev1W8UP3BtK1` (US-002 + US-003-pwa-shell-baseline run to token exhaustion after P1–P8), and `ses_24a319c81ffelunHGnCfk7KcBT` (US-004-photo-intake-identification finish + user validation revealing external-integration, credential, defect-handling, and plan-change protocol gaps)
**Date:** 2026-04-13 (P1–P6) / 2026-04-17 (P7, P8) / 2026-04-18 (P9–P18) / 2026-04-22 (P19–P22 + amendments to P14 and P16)
**Scope:** `opencode/` agents, skills, and execution workflow. All proposals target the OpenCode SDLC system specifically.

---

## Active Proposals

Drafted from analysis of `ses_26105317cffeCAev1W8UP3BtK1` (P13–P18) and `ses_24a319c81ffelunHGnCfk7KcBT` (P19–P22 + amendments). Discussion and prioritization pending.

| ID | Title | Theme | Expected Primary Impact |
|----|-------|-------|-------------------------|
| [P13](./P13-lib-cache-breadth-incentive.md) | Incentivize Comprehensive `lib-cache` Entries | Context / Cache | Raise cache quality bar; add cross-story cache promotion; cut doc queries 30–40% |
| [P19](./P19-environment-secrets-protocol.md) | Environment-Variable-Based Secrets Protocol | Credentials / Readiness | **Implemented 2026-04-23.** Planner declares `required_env` covering all external-service variables (API keys, BaaS credentials, DB URLs, storage, webhooks); hub gates Phase 0a on env presence; implementers halt instead of fabricating placeholders; validator downgrades to `ACCEPTED-STUB-ONLY` on missing creds. User-initiated mid-execution credential registration and pre-P19 project retrofit are routed by the coordinator to the planner hub, which loads the new `credential-registration` skill — the planner has the artifact context (`api.md`, architecture, cross-story scope) needed to detect scope-changes-in-disguise and escalate them to P22 rather than writing declarations blindly. Foundational for the P19–P22 cluster. |

### Rough Sequencing

Suggested dependency order (see each proposal's §9 for details):

1. **Foundational / tooling first** — done (P9 landed 2026-04-19; P10, P11, P12 landed 2026-04-21). Low-risk, high-unblock; landed before anything else.
2. **Review discipline cluster** — done (P16 landed 2026-04-27). Shifted AC-evidence catch-work earlier into Phase 2, reinforcing the Phase 3 cap P10 already established.
3. **Dispatch contracts** — P18a (implemented 2026-04-27). P18 was archived the same day after P15's removal collapsed the bimodal mode-selection rule to a single mode in practice; P18a captures the surviving end-to-end contract fix without the planner-annotation dependency. (P17 was archived 2026-04-27 alongside P15: with P15's task-shape annotations gone, P17's Class A/B/C inference lost its primary input signal, and P17 also reproduced P15's "workers do not route" inconsistency.)
4. **Efficiency refinements** — P13. Compounds with the rest; lower individual urgency.
5. **Credentials foundation (P19)** — lands before P20/P21/P22 because their verification steps reference P19's env-var mechanism. Zero ongoing cost; unlocks the rest of the 2026-04-22 batch.
6. **External-integration verification (P20)** — implemented 2026-04-27. Strictly after P19 (real traffic needs credentials). Also depends on P16's amended `evidence_class` clause being in place.
7. **User-report triage (P21)** — after P19 (for defect reproduction against real endpoints) and after P16 (for AC→story inference during classification). Activates P14's trigger 5 and feeds P22 Category D.
8. **Plan-change protocol (P22)** — implemented 2026-04-27. Lands after P21 (consumes P21 Category D) and is logically paired with P19/P20 (plan changes that touch integrations go through P19's `required_env` update and P20's `wire_format` re-verification).

---

## Archived Proposals

Resolved proposals are kept as a permanent decision record. They explain why the agents and skills are shaped the way they are.

| ID | Title | Status | Primary Impact |
|----|-------|--------|----------------|
| [P1](./archive/P1-ceremony-scaling-and-scaffolding.md) | Ceremony Scaling & Scaffolding Strategy | Resolved | Reduce dispatch count and review cycles for simple tasks |
| [P2](./archive/P2-context-management-and-memory.md) | Context Management & Memory Architecture | Resolved | Eliminate redundant file reads across subagent sessions |
| [P3](./archive/P3-verification-pipeline.md) | Verification Pipeline & Command Batching | Resolved | Reduce bash calls from ~100 to ~30 per story |
| [P4](./archive/P4-documentation-lookup-strategy.md) | Documentation Lookup Strategy (context7/Tavily) | Resolved | Cache documentation lookups, prevent re-querying |
| [P5](./archive/P5-testing-strategy-scaffold-verification.md) | Testing Strategy & Scaffold Verification | Resolved | Eliminate low-value tests, scale testing intensity by phase |
| [P6](./archive/P6-type-safety-and-error-recovery.md) | Type Safety & Error Recovery Patterns | Resolved | Reduce compile-fix-compile iteration cycles |
| [P7](./archive/P7-scaffolding-story-ownership.md) | Scaffolding Story Ownership | Resolved | Make scaffolder own full story lifecycle; skip Phase 1/2/3 for scaffolding stories; cap reviewer severity escalation |
| [P8](./archive/P8-cache-budget-coverage-embedding.md) | Story-Level Cache, Query Budget, Coverage Parsing, Role-Aware Embedding | Resolved | Cut documentation queries ~3x; ban LLM reads of coverage artifacts; emit `COVERAGE:` lines from verify.sh; inventory-only source for implementers |
| [P9](./archive/P9-coordinator-story-queue-advance.md) | Coordinator Story-Queue Population and Auto-Advance | Resolved | `checkpoint.sh coordinator --sync` rebuilds `stories_remaining` from disk; `--story-done` auto-advances between stories; `pause_after` gates user reviews; `verify.sh` distinguishes `ACTIVE` / `PAUSED` / `IDLE` with self-heal on `ungated_on_disk` |
| [P10](./archive/P10-story-reviewer-severity-guard.md) | Story-Reviewer Severity-Escalation Guard and Iteration Cap | Resolved | Cap Phase 3 story-review iterations at 3; Coverage Matrix + New-vs-Rediscovered Audit; graduated Suggestion-only rule (iter 1 blocks, iter ≥2 approves); planning-gotchas sibling file for post-run human review |
| [P11](./archive/P11-acceptance-validator-readonly.md) | Acceptance Validator Scope Boundary — Path-Scoped Write Allowlist | Resolved | Path-scoped `edit:` allowlist (catch-all deny first, then allow for evidence, validation report, skill-gotchas); explicit bash-write prohibition in the validator spec; agent-side Pre-Completion Self-Check that runs `git status --porcelain` and reverts any off-allowlist writes before returning. Engineering hub is untouched to keep it compact; hub-side audit is a deferred follow-up if observability warrants it. |
| [P12](./archive/P12-verify-staging-drift-fix.md) | Fix `verify.sh` Staging-Doc Drift Heuristic | Resolved | Replaced the broken `- [x]` regex with a convention-aware awk parser that walks `### Task` sections and recognises `✓`/`✅`/`complete`/`done` markers on headings and `**Status:**` lines (legacy `- [x]` still honoured). Drift warning is now three-way directional — silent on agreement, "staging ahead ... trusting staging doc" when staging is further, "checkpoint ahead ... inspect manually" otherwise. Added `tests/test-verify.sh` smoke suite with four fixture scenarios. Eliminates false "staging doc is more current" warnings that previously fired on every verify.sh invocation. |
| [P14](./archive/P14-oracle-escalation-threshold.md) | Count-Based Oracle Escalation on Complex Browser/Integration Work | Resolved (Implemented 2026-04-26) | Cost-arithmetic framing replaced with count-based triggers (doc queries, implementer attempts, reviewer iterations); cross-cutting governors (default-cycle precondition, per-task cap of 1/2/3-with-coordinator-approval, per-story soft cap of 3); hub-internal trigger evaluation with explicit decline logging; full Oracle dispatch envelope (failing AC/test, error symptoms, prior attempts verbatim, scope block); SCOPE COMPLIANCE check on Oracle output reverts out-of-scope edits; `dispatch-log.jsonl` schema extended with `counters`, `scope`, `decline_reason`. **Worker invariant (P14 §2.5):** implementer and code-reviewer agents are deliberately not modified — routing is hub-internal. Triggers 3 and 5 reference P15 / P21 and remain dormant until those land. |
| [P15](./archive/P15-planner-task-risk-annotations.md) | Planner-Level Task Risk and Complexity Annotations | Archived (Not Implemented, 2026-04-27) | Drafted, refined, and fully implemented; reverted on the same day after review. Pre-emptive task-shape labeling overlapped with three reactive systems already in place (Oracle Escalation Policy triggers 1+2 for runtime difficulty; planning-gotchas + skill iteration for category-level learning; library cache for per-task knowledge). Implementer-side `risk_upgrade_suggestion` also conflicted with P14's "workers do not route" governor. Token cost (~275-line taxonomy file read by planner + hub + validator on every story) for hypothesis-based content was not justified by measurable payoff. See archived proposal's "Why Archived" section for the full reasoning. Revisit only if multiple cycles produce evidence that the reactive stack is too slow. |
| [P16](./archive/P16-per-task-ac-traceability.md) | Per-Task Reviewer AC Traceability and Evidence Binding (amended: `evidence_class: real/stub-only/static-analysis-only` per P20) | Resolved (Implemented 2026-04-27) | Engineering hub authors `acs_satisfied` binding (ac_id, rationale, evidence_path, optional `tests:`, `evidence_class`) in each per-task context doc during Phase 1c. Implementer treats binding as input contract and HALTs with `BLOCKED — BINDING_MISMATCH` rather than silently rewriting it; hub revises before re-dispatch (no review-iteration cost). Code-reviewer verifies AC traceability per-task with severity mapping (missing evidence → Critical, shape-not-behavior tests → Important, narrative mismatch → Suggestion) and verifies `evidence_class` against test-mode headers. QA renders one `AC EVIDENCE SUMMARY` block per bound AC with behavioral-coverage falsification check. Story reviewer audits per-task summaries (no re-derivation), feeding the Full-story AC coverage and traceability lens of the Review Coverage Matrix. Front-loads Phase 3 catch-work into Phase 2 so the P10 iteration cap stays safe. Agent-facing surfaces (templates, dispatch envelopes, agent specs) carry the behaviour without proposal-ID breadcrumbs. |
| [P17](./archive/P17-ceremony-scaling-feature-stories.md) | Ceremony Scaling Beyond Scaffolding — Task-Class Dispatch | Archived (Not Implemented, 2026-04-27) | Drafted 2026-04-18, archived without implementation 2026-04-27 alongside P15. Three-tier (A/B/C) dispatch policy depended on P15's task-shape annotations for Class A/B/C inference — with P15 archived, the primary input signal no longer exists. P17 also reproduced P15's "workers do not route" inconsistency (implementer-side class-upgrade requests) and proposed replacing the code-reviewer dispatch with implementer self-review on Class A tasks, which trades fresh-eyes verification (the failure mode the independent reviewer existed to cover) for ceremony reduction without measured evidence that small-diff reviewer findings are dominated by Suggestion-class verdicts. Existing reactive systems (P14 Oracle escalation, code-reviewer's own diff-aware behavior, per-task iteration cap) cover the ceremony-scaling concern with real evidence rather than a-priori labels. See archived proposal's "Why Archived" section for full reasoning. Revisit only if dispatch logs eventually show reviewer findings on small diffs are consistently Suggestion-only. |
| [P18](./archive/P18-hub-coordinator-reset-boundary.md) | Principled Hub ↔ Coordinator Reset Boundary | Archived (Not Implemented, Superseded by P18a, 2026-04-27) | Drafted 2026-04-18 with a bimodal design (`end-to-end` vs `phase-boundary` per-story dispatch mode) gated on P15 risk annotations. Archived 2026-04-27: with P15 archived, the mode-selection rule had no input signal, and the only honest options were "always end-to-end" or "always phase-boundary." Always-phase-boundary inflates round-trips on simple stories without evidence the safety net is needed; always-end-to-end is what the hub's existing completion contract already promises and was failing only because of residual coordinator wording. The contract-clarity findings (§2.1, §2.2) were preserved verbatim into **P18a (always-end-to-end)**, which implements the two-file contract edit without the bimodal scaffolding or planner-annotation dependency. Pathological-story safety net is covered by the implemented reactive stack (P10, P11, P14). |
| [P18a](./archive/P18a-hub-coordinator-end-to-end-contract.md) | One Coordinator → Hub Trip Per Story (End-to-End Completion Contract) | Resolved (Implemented 2026-04-27) | Drafted and implemented same day as P18's archival. Replaces P18's bimodal design with a single rule: each coordinator → engineering-hub dispatch corresponds to exactly one user story; the hub runs Phases 0a → 6 to a terminal `VERDICT: done \| blocked \| escalated` with structured `reason:` tags (`MISSING_CREDENTIALS`, `MILESTONE_PAUSE`, `OPERATIONAL`, `KNOWLEDGE_GAP`, `PRODUCT_PLANNING`, `PLAN_CHANGE_REQUIRED`, `ORACLE_ESCALATION_REPORT`, `STORY_REVIEW_CAP_HIT_NO_REMEDIATION`, `SEMANTIC_REVIEW_UNRELIABLE`, `ACCEPTANCE_CAP_REACHED`); coordinator routes on the verdict + tag rather than free-form recommendations. Two-file contract edit (`sdlc-engineering.md` Dispatch Protocol + Completion Contract; `sdlc-coordinator.md` Phase 3 Dispatch + Phase 4 verdict-keyed routing + Trust Hierarchy + Transition Rules), no infrastructure changes, no planner-annotation dependency. Pathological-story safety net relies on the implemented reactive stack (P10 story-reviewer cap, P11 validator scope, P14 Oracle escalation triggers). |
| [P20](./archive/P20-external-integration-contract-verification.md) | External Integration Contract Verification via Real-Traffic E2E | Resolved (Implemented 2026-04-27) | Drafted 2026-04-22, resolved + implemented 2026-04-27. Planner-api emits a `wire_format` block per external endpoint (method, URL, auth mechanism with `value_source` linked to `required_env`, headers, request_body_example, response_shape_example) verified at plan time via `mode: curl` (preferred), `provider-doc-quote`, `cassette`, or `cached-from-cross-cutting`; verified blocks land in the new `plan/cross-cutting/external-contracts/<provider>.md` cross-cutting artifact (parallel to P19's `required-env.md`, NOT a `lib-cache` extension — see Resolved Decision §7.4). Implementer writes a `// test-mode: real` smoke test per endpoint that `test.skip`s when `required_env` is unset (no silent stub fallback); shared endpoints reuse `tests/integration/_shared/` with a `BLOCKED — WIRE_FORMAT_DIVERGENCE` blocker on conflicts. Code-reviewer adds Wire-Format Conformance as a critical gate (auth shape, credential source, headers, request-body shape, smoke-test presence). QA emits an `external_integration_evidence` block per endpoint (status: `ran-200 \| ran-non-200(expected\|unexpected) \| skipped-no-env`, redacted `request_headers_sent`, `response_shape_summary`, `FLAG: WIRE_FORMAT_FAILURE` on contract mismatch). Acceptance-validator's verdict vocabulary expands to `COMPLETE \| ACCEPTED-STUB-ONLY \| CHANGES_REQUIRED \| INCOMPLETE` with strict precedence; engineering hub Phase 4 routes `CHANGES_REQUIRED` by disagreement source — request-builder bug → implementer remediation (consumes acceptance slot); planner `wire_format` defect → `VERDICT: blocked, reason: PLAN_CHANGE_REQUIRED` with QA evidence (does not consume an acceptance slot). Applies prospectively only — US-001..US-004 are not retrofitted (Resolved Decision §7.1). |
| [P22](./archive/P22-plan-change-protocol.md) | Plan Change Protocol (Within-Execution) | Resolved (Implemented 2026-04-27) | Drafted 2026-04-22; resolved + implemented 2026-04-27. Coordinator gains a **Plan-Change Triage** protocol triggered by user plan-change phrasing, P21 Category D handoffs, hub `VERDICT: blocked, reason: PLAN_CHANGE_REQUIRED`, and planner `ROUTE_TO_PLAN_CHANGE` verdicts (e.g. credential-registration scope-change-in-disguise); allocates a `PC-NNN` id, opens an audit trail at `.sdlc/plan-changes/<PC-NNN>/` (`request.md`, `pc.yaml`, `triage.md`, `decision.md`, `artifacts-changed.md`), and registers an open dispatch lock via the new `coordinator.yaml: plan_changes[]` index (managed by `checkpoint.sh coordinator --plan-change-open / --plan-change-close`; surfaced by `verify.sh`). Planner gains two modes: `PLAN_CHANGE_TRIAGE` (loads `sdlc-plan-change-triage` skill — blast-radius scan, mechanical forward-impact scan that explicitly enumerates every planned story as `affected` (with reason) or `unaffected` (with one-line justification), four-class taxonomy: Class 1 additive within active story, Class 2 new story, Class 3 multi-story partial replan, Class 4 foundational re-derivation; produces `triage.md` and a verdict) and `PLAN_CHANGE_APPLY` (post-approval routing pass that dispatches the affected planner sub-agents — stories for amendment/new/retire, api for `wire_format_delta` add/edit/retire with atomic `required_env` updates and P20 re-verification, architecture for Class 4 re-derivation only — and appends every change to `artifacts-changed.md`). Engineering hub recognizes amended dispatches under `AMENDED_BY: PC-NNN`, re-reads plan artifacts from disk, re-decomposes changed ACs, resets invalidated tasks and Phase 4 acceptance, and audits the amendment in its staging doc. Implementer gains an on-demand `sdlc-plan-change-escalation` skill (loaded only when a plan artifact itself is wrong beyond a defect — endpoint doesn't exist, contract unimplementable, architecture contradicts a runtime constraint) which emits `STATUS: BLOCKED — PLAN_CHANGE_REQUIRED` with structured ARTIFACT/CLAUSE/DEFECT_CLASS/EVIDENCE/OBSERVED/RECOMMENDED_CLASS/SUGGESTED_DELTA payload (strict prohibitions against using it for binding mismatches, missing creds, or wire-format divergence — each has its own dedicated route). Shared `sdlc-plan-change-recordkeeping` skill defines the per-PC directory layout, `pc.yaml` schema, and dispatch-lock computation. Heavy procedural prose (triage analysis, escalation rubric, recordkeeping schemas) lives in three on-demand skills rather than always-on agent context — the agent files carry only trigger recognition and one-line skill pointers. The forward-impact scan is the §3.2.1 mechanical rule that closes the original concern: every planned story is explicitly enumerated, and any story listed in `affected_planned_stories` is dispatch-locked until the PC closes — a future story physically cannot be dispatched until the plan-change resolution touches it. |
| [P21](./archive/P21-user-reported-check-defect-triage.md) | User-Reported Check and Defect Triage Protocol | Resolved (Implemented 2026-04-27) | Drafted 2026-04-22; resolved decisions + implemented 2026-04-27. Coordinator gains a `triage-user-report` mode triggered by behavior-shaped user messages ("is X supposed to work?", "I click Y and nothing happens"); classifier reads plan inventory and stories_remaining/stories_done to produce category A (already implemented), B (planned), C (defect against completed story), or D (plan gap), with a fixed three-line `TRIAGE: A\|B\|C\|D / TARGET: <story-id\|none> / EVIDENCE:` preamble on every reply. Category C dispatches the engineering hub in a new `defect-incident` mode (artifact directory at `.sdlc/incidents/<INC-NNN>/` with `incident.md`, `investigation.md`, `fix-plan.md`, `verification.md`, plus an inherited copy of the target story's lib-cache); the hub runs a 5-step lifecycle (reproduce → investigate → propose fix → verify → close) capped at 3 iterations, with Oracle dispatched first-line under P14 trigger 5 for external-integration / cross-cutting-contract defects. Reassignment (root cause in a different completed story) reroutes the incident with both stories' lib-caches loaded; reclassification (root cause in a not-yet-executed story) closes the incident as `reclassified-to-B` and the coordinator delivers the Category B response. Stub-only verdicts auto-promote to `ACCEPTED` when the verify step exercises real traffic (P19 §3.6). Deduplication is reactive only — the coordinator merges into a prior incident only when the user explicitly references it; no proactive scanning of incidents on every triage. Implementer / code-reviewer / acceptance-validator / Oracle agents accept incident-mode dispatch envelopes (narrow scope, `INCIDENT_REASSIGN` / `INCIDENT_RECLASSIFY` / `INCIDENT_SCOPE_EXPANSION` HALT signals, narrow review against contradicted ACs only, `INCIDENT_PASS \| INCIDENT_FAIL \| INCIDENT_PROMOTE_VERDICT` validator verdicts). `execution.yaml` gains an `incidents:` array tracked via `checkpoint.sh execution --incident-{open,init,update}` flags. |

---

## Context

A simple 4-task scaffolding story (React + Vite + PWA) consumed 2h56m, 1.4M input tokens, 33.6M cache-read tokens, 19 subagent dispatches, and 20 sessions to produce ~500 lines of code. The analysis identified six interconnected areas for improvement (P1–P6). A second run after those fixes revealed a seventh gap (P7): the engineering hub still entered Phase 1/2/3 after the scaffolder completed, duplicating the scaffolder's entire output and triggering adversarial review cycles on already-finished work. A third post-mortem, on the first feature story (US-002-local-persistence-foundation) run after P1–P7, exposed an eighth cluster (P8): the P4 cache was status-only instead of content-bearing (34 doc queries for one small story), coverage artifacts were read by the LLM directly rather than grepped from structured stdout, and source-file embedding was paid for by implementers but benefited only read-only roles. All eight have been addressed.

A fourth post-mortem covered `ses_26105317cffeCAev1W8UP3BtK1` — a 9h6m session that completed US-002 and approximately two thirds of US-003 before token exhaustion. That run exposed nine new problem clusters (P9–P17) spanning workflow (coordinator auto-advance broken by a missing `sync-coordinator.sh` script), review discipline (Phase 3 story-reviewer lacks severity escalation guards, creating a 4-iteration treadmill per story), role boundary (Phase 4 acceptance-validator ran 7h 15m and modified 32 files), tooling noise (`verify.sh` false-positive drift warnings on every run), context quality (lib-cache entries are minimally compliant rather than comprehensive, producing ~32 doc queries per story vs. P8's ≤10 target), model routing (no Oracle escalation for hard browser / CDP tasks), planning signal (no risk/complexity annotations to route from), review quality (ACs not bound to tasks, so Phase 3 discovers evidence gaps), and dispatch efficiency (flat ceremony across trivial and heavy tasks).

A fifth post-mortem extended that session with `ses_26105317cffeCAev1W8UP3BtK1-continued` (combined 25h13m, 129 child sessions, US-002 + US-003 + US-005 + US-008 partial). That continuation exposed one additional cluster (P18): the engineering hub and the coordinator round-trip 3–4 times per story because the coordinator's Phase 4 dispatch language asks the hub to "recommend next coordinator action", contradicting the hub's end-to-end completion contract. The hub complies with the dispatch wording rather than its own contract. In the worst case this produced a 7h53m hub sub-session with a nested 7h15m acceptance-validator over-run (the same event motivating P11) — P18 caps how much ambient context such long sub-sessions can inherit by drawing reset boundaries at named phases instead of ad-hoc slices. P18 does not address the long between-turn gaps observed in the transcript; those were user-side token-budget resets, not pipeline stalls.

A sixth post-mortem covered `ses_24a319c81ffelunHGnCfk7KcBT` — the completion of US-004-photo-intake-identification and the user's first end-to-end validation against the shipped product. The story was checkpointed `completed_phases: [0,1,2,3,3b,4,5,6]` but failed on first real use: the `PhotoIntakeHarness` shipped with a hardcoded `demo-api-key` and mocked fetch plumbing, and after that was fixed the app still returned 401 because the planner's `api.md` described an invented internal-proxy envelope that placed the OpenRouter key in the request body instead of an `Authorization: Bearer` header. Every gate — implementer, code-reviewer, QA, story-reviewer, acceptance-validator — validated against the internal (wrong) contract; no test ever touched the real OpenRouter endpoint. The session also surfaced four interacting protocol gaps: (1) no agent has a protocol for user-reported behavior on a completed story, producing ad-hoc hub dispatches with no incident lifecycle; (2) no agent has a protocol for mid-execution plan changes (the user wanted to drop OpenAI and add a free-model selector, with no route for either); (3) no convention for sharing credentials with the pipeline (a key placed in `tests/resources/openrouter-free.key.txt` was masked by security-minded agents rather than consumed); and (4) no mechanism for ACs whose statements reference external-provider behavior to require real-traffic evidence before acceptance. P19–P22 address these four gaps as a single dependency-ordered batch, with amendments to P14 (Oracle handles external-contract defect incidents as first-line) and P16 (`evidence_class` field on AC traceability distinguishes real-traffic from stub-only evidence).

---

## Dependency Graph

```mermaid
flowchart LR
    P1["P1: Ceremony Scaling"]
    P2["P2: Context Management"]
    P3["P3: Verification Pipeline"]
    P4["P4: Documentation Lookup"]
    P5["P5: Testing Strategy"]
    P6["P6: Error Recovery"]
    P7["P7: Scaffolding Story Ownership"]
    P8["P8: Cache / Budget / Coverage / Embedding"]
    P9["P9: Coordinator Queue Advance"]
    P10["P10: Story-Reviewer Guard"]
    P11["P11: Validator Read-Only"]
    P12["P12: verify.sh Drift Fix"]
    P13["P13: lib-cache Breadth"]
    P14["P14: Oracle Escalation"]
    P15["P15: Planner Risk Annotations<br/>(archived 2026-04-27)"]
    P16["P16: AC Traceability"]
    P17["P17: Ceremony Scaling v2<br/>(archived 2026-04-27)"]
    P18["P18: Hub-Coordinator Reset Boundary<br/>(archived, superseded by P18a 2026-04-27)"]
    P18a["P18a: One Trip Per Story<br/>(implemented 2026-04-27)"]
    P19["P19: Environment Secrets<br/>(implemented 2026-04-23)"]
    P20["P20: External Contract Verification<br/>(implemented 2026-04-27)"]
    P21["P21: User-Report Triage / Defect Incident"]
    P22["P22: Plan Change Protocol"]

    P1 --> P2
    P1 --> P3
    P1 --> P5
    P1 --> P7
    P2 --> P4
    P4 --> P5
    P5 --> P6
    P4 --> P6
    P3 --> P7
    P2 --> P8
    P3 --> P8
    P4 --> P8

    P3 --> P12
    P7 --> P9
    P6 --> P10
    P5 --> P16
    P16 --> P10
    P8 --> P13
    P6 --> P14
    P10 --> P14
    P1 --> P17

    P11 --> P18
    P17 --> P18
    P9 --> P18

    P18 -.supersedes.-> P18a
    P11 --> P18a
    P9 --> P18a
    P14 --> P18a
    P10 --> P18a

    style P15 stroke-dasharray: 5 5,opacity:0.5
    style P17 stroke-dasharray: 5 5,opacity:0.5
    style P18 stroke-dasharray: 5 5,opacity:0.5

    P19 --> P20
    P19 --> P21
    P19 --> P22
    P16 --> P20
    P20 --> P16
    P20 --> P21
    P16 --> P21
    P21 --> P22
    P21 --> P14
    P20 --> P14
```

- **P1 → P2:** Ceremony scaling requires context management (fewer dispatches means less re-reading, but remaining dispatches need better context).
- **P1 → P3:** Scaffolding skill includes verification script templates.
- **P1 → P5:** Scaffold task type drives relaxed testing tier.
- **P1 → P7:** P1 created the scaffolder mini-hub but left a gap: the hub still entered Phase 1 after scaffold completion for scaffolding stories.
- **P2 → P4:** Library context caching is a specific instance of the general context management strategy.
- **P4 → P5:** Documentation lookup failures cause test approach failures (CSS import edge case).
- **P5 → P6:** Test failure escalation protocol connects to error recovery patterns.
- **P4 → P6:** Missing documentation leads to type errors from incorrect API usage.
- **P3 → P7:** P7's self-validation relies on the verify:full script established in P3.
- **P2 → P8:** P8's story-level lib-cache and role-aware source embedding refine P2's context-management model.
- **P3 → P8:** P8's coverage-emission rule is enforced inside the P3 `scripts/verify.sh` pipeline.
- **P4 → P8:** P8 tightens P4's documentation-lookup cache into a content-bearing artifact with a hard budget.
- **P3 → P12:** P12 fixes the staging-doc drift heuristic inside P3's `verify.sh` pipeline.
- **P7 → P9:** P9 adds `checkpoint.sh coordinator --sync` (replacing the never-shipped `sync-coordinator.sh`) that P7's post-scaffold handoff and all subsequent story completions depend on.
- **P6 → P10:** P10 ports the severity-escalation guard P6 added to the code-reviewer into the story-reviewer.
- **P16 → P10:** P10's Phase 3 iteration cap is only safe once P16 has front-loaded AC traceability into Phase 2.
- **P5 → P16:** P16 extends P5's testing-strategy conventions with AC-binding discipline.
- **P8 → P13:** P13 follows up P8's cache schema with a breadth incentive and cross-story cache promotion.
- **P6 → P14:** P6 introduced Oracle as an escalation pattern; P14 specifies quantitative thresholds that trigger it.
- **P10 → P14:** P10's iteration cap is the trigger that routes story-level escalations to Oracle in P14.
- **P15 → P14 (severed):** P15 was archived 2026-04-27 without implementation. P14's trigger 3 (`oracle_preauthorize` flag) is dormant in practice — the planner contract does not produce the flag and the hub treats every task as `oracle_preauthorize: false`. P14's other triggers (1, 2, 4, 5) are unaffected.
- **P1 → P17 (archived):** P17 extended P1's ceremony scaling from scaffolding-only to general task classes (A/B/C). P17 was archived 2026-04-27 alongside P15 — see archived P17's "Why Archived" section for the full reasoning.
- **P15 → P17 (severed, both archived):** P17 was originally specified to consume P15's shape/risk annotations for task-class inference. P15 was archived 2026-04-27, removing P17's primary input signal; P17 was archived the same day for that reason plus its own concerns (worker-routing inconsistency, self-review-replaces-review claim).
- **P15 → P18 (severed, both archived):** P18 was originally specified to use P15's story-level risk roll-up for end-to-end vs phase-boundary mode selection. With P15 archived, the bimodal architecture lost its input signal — P18 was archived 2026-04-27 and replaced by P18a, which drops the bimodal design entirely and locks in always-end-to-end via a contract edit.
- **P11 → P18 (archived):** P11 bounded the acceptance validator directly; P18 was meant to narrow the ambient context that validator inherits via phase-boundary resets. With P18 archived, P11 stands alone — P18a's always-end-to-end mode relies on P11 (and P10, P14) as the runtime safety net that keeps long single sub-sessions bounded.
- **P17 → P18 (severed, both archived):** P17 was the task-level analogue of P18's story-level dispatch-mode selection; the two were designed to share the same planner annotation input. With both archived 2026-04-27, neither dependency edge exists.
- **P9 → P18 (archived):** P9 handled the between-story boundary; P18 was to handle the within-story boundary. With P18 archived, P9 stands alone — P18a now covers the within-story contract.
- **P18 ⇒ P18a (supersedes):** P18a is the simplified successor to P18, drafted and implemented 2026-04-27. P18a preserves P18's contract-clarity findings (§2.1 conflict between hub end-to-end contract and coordinator's "recommend next action" wording; §2.2 absence of an explicit reset rule) and drops everything that depended on P15 (bimodal mode selection, `dispatch_mode` state field, `coordinator.yaml: phase_boundary` override). The two-file edit (`sdlc-engineering.md`, `sdlc-coordinator.md`) is the entirety of P18a's implementation footprint.
- **P9 → P18a:** Same as the original P9 → P18 edge — P9 owns between-story boundaries, P18a owns the within-story boundary (one trip per story).
- **P11 → P18a:** P11's path-scoped validator-write boundary is the load-bearing safety net for P18a's always-end-to-end mode: long single sub-sessions cannot blow up because the worst-case agent (validator) is bounded at its own permission schema.
- **P14 → P18a:** P14's reactive Oracle escalation triggers (`doc_queries > 8`, 3rd implementer attempt, story-reviewer cap) are the runtime mechanism that catches difficulty inside an end-to-end run without needing planner-annotated mode selection.
- **P10 → P18a:** P10's story-reviewer iteration cap (3) is the explicit terminating bound on Phase 3 inside an end-to-end hub run.
- **P19 → P20:** Real-traffic verification at plan time and at QA time requires a real credential. P19's `required_env` declaration and Phase 0a gate are the mechanisms P20 consumes.
- **P19 → P21:** Reproducing a Category C defect against an external endpoint requires a real credential; P21's reproduce step routes through P19's `MISSING_CREDENTIALS` escalation when `required_env` is unset.
- **P19 → P22:** Plan changes that add or swap external providers update the `required_env` declaration and `.env.example` atomically in the PC-NNN artifact; the planner's partial-replan reads P19 state as part of blast-radius analysis.
- **P16 ↔ P20:** P16 §3.5 (amended) carries the `evidence_class` field that binds to P20's `external_integration_evidence`; P20's reviewer conformance check extends P16's reviewer contract. The two proposals cover different sides of the same real-evidence gate.
- **P20 → P21:** P21's defect-incident verify step re-runs P20's smoke tests. Incidents that turn out to be `wire_format` defects escalate from code-level fixes back into P20's plan-validation path.
- **P16 → P21:** P21's classification step (§3.1 step 2) consumes P16's AC→task map to identify candidate stories from a user's behavioral description.
- **P21 → P22:** P21 Category D (plan gap) hands off to P22's triage. Incidents whose scope grows beyond the one-or-two-AC threshold also escalate from P21 to P22.
- **P21 → P14:** P21 §3.3 introduces trigger 5 on P14 — defect incidents against external-integration ACs dispatch Oracle as first-line investigator rather than escalation.
- **P20 → P14:** P14 trigger 5's "external integration" condition is checked against P20's `wire_format` declaration; the two must stay aligned or the trigger misfires.

---

## Measured Impact (US-001 baseline → after all proposals)

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| Subagent dispatches per 4-task scaffold | 19 | ~8-10 | ~50% |
| Total input tokens per scaffold story | 1.4M | ~500-700K | ~50-65% |
| Cache-read tokens per scaffold story | 33.6M | ~15-20M | ~40-50% |
| Bash calls per scaffold story | 318 | ~80-100 | ~70% |
| Duration for scaffold story | ~3 hours | ~1-1.5 hours | ~50% |
| context7 calls per scaffold story | 44 | ~12-16 | ~65% |

---

## How to Add a New Proposal

1. Create `PN-short-title.md` in this folder (not in `archive/`).
2. Add a row to the Active Proposals table above.
3. Work through the proposal: discuss open questions, refine the approach, implement changes.
4. When resolved: move the file to `archive/`, update the row here to Resolved and move it to the Archived table.
