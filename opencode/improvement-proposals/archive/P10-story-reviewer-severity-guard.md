# P10: Story-Reviewer Severity-Escalation Guard and Iteration Cap

**Status:** Active — drafted 2026-04-18
**Relates to:** [P6 (Type Safety & Error Recovery)](./archive/P6-type-safety-and-error-recovery.md) — extends the severity guard from per-task to full-story scope
**Scope:** `opencode/.opencode/agents/sdlc-engineering-story-reviewer.md`, `opencode/.opencode/agents/sdlc-engineering.md` (Phase 3 loop accounting)
**Transcript evidence:** `ses_26105317cffeCAev1W8UP3BtK1` —
- US-002 Phase 3 story-review ran **4 iterations** before closure: i1 Changes Required (line ~13696), i2 Changes Required (~31120), i3 Changes Required (~33815), i4 Approved (~43991). Each iteration surfaced a new "Critical" finding (strict-shape handling, payload-size bounds, non-serializable payload edge case) that was not present in prior iterations.
- US-003 Phase 3 story-review ran **4 iterations** (lines 127435, 133823, 147577, 167153). Similar pattern: docs-evidence finding, then AC-1/AC-2 browser evidence gap, then new gaps discovered in remediation.

---

## 1. Problem Statement

The per-task `sdlc-engineering-code-reviewer` has an explicit **Severity Escalation Guard** (lines 80–96 of its spec): findings cannot be promoted from Suggestion to Important between iterations without new evidence, and a run where only Suggestion-class issues remain MUST verdict Approved regardless of iteration count.

`sdlc-engineering-story-reviewer` has **no equivalent guard**. `grep -nE "severity|escalation|iteration|scope|new evidence" opencode/.opencode/agents/sdlc-engineering-story-reviewer.md` returns only boilerplate severity categorization; there is no iteration-awareness, no cap on scope expansion, and no verdict rule tying iteration count to approval threshold.

As a result, each story-review iteration can legitimately scan the full story through a different lens (spec compliance, security, integration seams, payload edges, docs consistency, AC traceability) and surface a new "Important" or "Critical" finding. The implementer remediates, the next story-review pass opens a different lens, and the loop sustains. Observed depth: 4 story-review iterations per story in this run — on top of the per-task review+QA cycles already completed in Phase 2.

The cost is not only tokens and time. Phase 3 rework rewinds the pipeline back to Phase 2 remediation, re-running implementer/code-reviewer/QA loops on the same files. US-002 Phase 3 remediation alone consumed ~16 subagent dispatches (4 story-review iterations × ~4 downstream dispatches).

## 2. Root Cause Analysis

### 2.1 Scope asymmetry without iteration awareness
The story reviewer's role is intentionally broader than the per-task reviewer — it must catch cross-file and AC-level issues the per-task reviewer cannot see. This is correct. But "broader scope" without "iteration discipline" means the reviewer can always find something new, because "something new" is always within the larger scope.

### 2.2 No distinction between "new finding in new code" and "new finding in existing code"
When remediation produces new code, the next story-review pass legitimately covers that new code. But it also re-reads the existing (already-approved) code and may flag issues there. Without a rule, the reviewer cannot tell whether it's discovering genuine new risk or relitigating already-accepted tradeoffs.

### 2.3 No approval-threshold rule for Suggestion-only residuals
The per-task code-reviewer has "Suggestion-only residuals → Approved." The story reviewer does not. A story-reviewer iteration with nothing but suggestions can still return Changes Required, triggering another full remediation rewind for a nominal style point.

### 2.4 Phase 3 rewind is uncapped
`sdlc-engineering.md` Phase 3 instructions (lines 475–476, 529–532) cap per-task review iterations at 5 before architect self-implementation. There is no equivalent cap for story-level review iterations. A 4-iteration loop in this run was legal under current spec.

## 3. Proposed Approach

Six changes (implementation details TBD during discussion):

1. **Port the severity-escalation guard into `sdlc-engineering-story-reviewer.md`.** The full text from `sdlc-engineering-code-reviewer.md` lines 80–96 can be adapted with a story-scope framing: "A cross-task finding at iteration N+1 MUST be supported by new evidence — code that did not exist at iteration N, a newly discovered spec requirement, or an integration edge case revealed by the remediation."

2. **Add a story-review iteration cap at 3.** After 3 story-review iterations returning Changes Required for the same story, the engineering hub escalates on the 4th: either Oracle dispatch (see P14) for integration/complexity findings, or architect self-implementation at story scope for code-quality findings. **User intervention is NOT part of the runtime escalation path** — systemic misses are recorded in the planning-gotchas sibling file for post-run review (see Change #6). The pipeline MUST NOT silently continue a 4th story-review round.

3. **Add a graduated approval-threshold rule by iteration.** Mirrors the per-task code-reviewer's "Review exhaustion rule" at [sdlc-engineering-code-reviewer.md](../../.opencode/agents/sdlc-engineering-code-reviewer.md) line 94:
   - **Iteration 1 with Suggestion-only findings → Changes Required.** We are already in the loop; cost of addressing suggestions is low, and this preserves quality on the first pass.
   - **Iteration ≥ 2 with Suggestion-only findings → Approved.** Do not burn an Oracle or implementer cycle on nice-to-haves. Suggestions are recorded in the staging doc for a future story but do not block this story.

4. **Require the story reviewer to classify findings as "new-in-iteration-N" vs "rediscovered" — mandatory in iteration ≥ 2, but only when a finding lives in code that is unchanged since iteration N-1.** Findings in code that changed as part of iteration N-1 remediation are by construction new-in-N and do not need the tag. Findings in unchanged code MUST self-justify why they were not catchable at N-1 (e.g., "this integration seam was not exercised until Task 4 landed," "spec clarification from Oracle revealed this constraint"). Unexplained rediscoveries default to Suggestion-class. The Coverage Matrix (Change #5) makes this tractable: iteration 1 certifies exhaustive lens coverage, so any iteration 2+ finding in unchanged code is by construction an iteration-1 miss and must self-justify under the severity-escalation guard.

5. **Mandatory Review Coverage Matrix in every iteration.** Root-cause fix for the "lens rotation" loop described in Section 1. The story-reviewer MUST emit a Coverage Matrix as a required section of its output, with one row per lens. Each row is either `findings: [list with severities and file:line refs]` or `no findings: [one-line rationale citing what was examined]`. Bare "no findings" entries without rationale are a protocol violation.

   **Minimum hardcoded lenses** (every story-review report, every iteration, MUST acknowledge all of these):
   - Spec compliance (plan artifacts → code)
   - Cross-task integration seams
   - Full-story AC coverage and traceability
   - Security controls uniformity
   - Payload / input-boundary edges
   - Error-path and negative-case tests
   - Automated checks (lint / typecheck / tests)
   - Docs and staging-doc consistency
   - Comment policy

   **Plus story-specific lenses** the reviewer derives from the plan artifacts (PRD, HLD, API, Security, Testing, Story ACs) and adds to the same matrix. Examples: "PWA installability," "CDP timing sensitivity," "rate-limit edges," "cross-browser capability differences." The reviewer declares these lenses at the top of the matrix before filling rows, so the hub can audit completeness against plan scope.

   **Effect:** iteration 1 becomes certifiably exhaustive across all relevant lenses in a single pass. The mechanism eliminates the lens-of-the-day pattern that sustained 4-iteration loops in the transcript evidence, and makes the severity-escalation guard (Change #1) mechanically enforceable rather than contract-based.

6. **Planning-gotchas sibling file (post-run review, out-of-band).** Symmetrical to the existing skill-gotchas pattern at [sdlc-engineering.md](../../.opencode/agents/sdlc-engineering.md) lines 218–221. Records systemic planning misses observed at runtime without routing them to the user at runtime.
   - **Per-story sibling file:** `docs/staging/US-NNN-name.planning-gotchas.md`, created alongside the main staging doc and the skill-gotchas sibling.
   - **Trigger:** When the 3-iteration cap is hit and the hub escalates (to Oracle or architect self-implementation), the hub also writes a structured entry to the planning-gotchas file describing: (a) what the story reviewer kept finding across iterations, (b) which plan artifact should have caught it (PRD / HLD / API / Security / Testing / Story AC), (c) a candidate planning-side fix for future cycles.
   - **What is explicitly out of scope of this proposal:** there is NO runtime rollup, NO planner/coordinator read path during subsequent runs, and NO agent-driven propagation into planner subagents. Post-run review of the sibling files and any decision to promote lessons into planner agents, planner skills, or plan-artifact templates is a separate out-of-band process (the same pattern skill-gotchas uses — "Who reads it: The human, post-run"). That process may live in the registry-side evaluation workflow but is not part of the runtime SDLC, and the `docs/staging/*.planning-gotchas.md` files are not visible to downstream consumer projects via `scripts/setup-links.sh` anyway.

   **Effect:** when a story-review loop exceeds the cap, the systemic miss is captured in a structured, reviewable record rather than absorbed silently or surfaced as runtime user intervention. Promotion of the lesson into planning inputs is a deliberate, human-mediated step outside this proposal's scope.

## 4. Expected Impact / ROI

**Primary impact:** Caps the Phase 3 story-review treadmill. In this run, 8 of the ~40 story-level dispatches (20%) were rework driven by story-review iteration escalation that would not have happened under the proposed rules.

**Secondary impact:** Shortens total story wall-clock time. US-002 Phase 3 remediation alone took an estimated 60–90 minutes of compute across 4 story-review iterations. Capping at 2–3 iterations would save roughly half.

**Tertiary impact:** Forces genuine risks (the kind that warrant a 4th iteration) to escalate to Oracle or to architect self-implementation, rather than getting resolved via more implementer dispatches. This is more honest signal.

**Tradeoff:** Some genuine issues that would have been caught in iteration 4 will instead ship and get caught in Phase 4 (acceptance validation) or in post-release review. Accepted as long as the iteration cap is paired with stronger AC traceability in Phase 2 (see P16).

**ROI consideration:** This is a focused set of agent-spec and skill-reference edits across the story-reviewer, the engineering hub, the review-cycle reference, and a new planning-gotchas template. The saved compute per story is substantial. The main risk is accepting lower Phase 3 rigor, which is offset by stronger Phase 2 checks (P16).

## 5. Success Metrics (for post-run verification)

All measurable from transcript dispatch log:

- **M1 (hard):** Story-review iterations per story ≤ 3 on average, ≤ 4 maximum. Baseline: 4 per story in both US-002 and US-003.
- **M2 (hard):** Zero instances of story-reviewer returning "Changes Required" with findings that are exclusively Suggestion-class. Verifiable by parsing reviewer output in the transcript.
- **M3 (hard):** When story-review iteration ≥ 2, the reviewer's output includes a "new findings vs rediscovered findings" table with justification for each rediscovery. Verifiable by grepping reviewer output format.
- **M4 (soft):** Phase 3 rework dispatches (implementer re-dispatches after story-review Changes Required) drop by ≥ 40% relative to this run's baseline. Baseline: ~8 such dispatches in US-002 alone.
- **M5 (guard against regression):** Stories that PASS story-review but FAIL Phase 4 acceptance do not increase. If this metric moves the wrong way, the iteration cap was too aggressive and P16 needs to land first or simultaneously.
- **M6 (hard):** Every story-review report includes a complete Review Coverage Matrix — all minimum hardcoded lenses present, plus any story-specific lenses the reviewer derived from the plan artifacts declared at the top of the matrix. Every row is either a findings list (with severity and file:line refs) or a `no findings` entry with a one-line rationale. Verifiable by grepping the reviewer output format and counting lens rows against the hardcoded minimum.
- **M7 (soft):** Planning-gotchas sibling file exists for every story and contains ≥ 1 structured entry per iteration-cap escalation event. Verifiable by cross-referencing the staging directory against the dispatch log for escalation events. (Out of scope here: any downstream metric on whether the lesson was promoted into planning inputs — that is a separate out-of-band evaluation process, not a property of the runtime SDLC.)

## 6. Risks & Tradeoffs

- **Risk:** A genuinely important issue that reviewers have reasonable grounds to escalate gets suppressed by the guard. Mitigation: the guard permits escalation WITH cited new evidence — it does not forbid Important findings in iteration 2+, only requires justification. Reviewers acting in good faith are unaffected.
- **Risk:** The iteration cap forces escalation to Oracle (expensive model) for cases that a 4th review iteration would have resolved. Accepted tradeoff; Oracle is specifically designed for this case.
- **Tradeoff:** Some Suggestion-class findings that the user would have wanted fixed before closure will be deferred. Mitigation: the reviewer still records them in the staging doc; the user can choose to open a follow-up story.
- **Risk:** Review culture drift. If reviewers learn "Suggestion means Approved," they may stop using Suggestion for genuinely important-but-subtle issues. Guard language should emphasize that severity is determined by impact, not by desired verdict. The graduated rule (Change #3) partially mitigates this by keeping Suggestion-only findings as a blocker in iteration 1, so Suggestions retain signaling value on the first pass.
- **Risk:** Iteration-1 Coverage Matrix (Change #5) inflates single-pass token cost, since the reviewer must address every lens explicitly rather than surfacing whichever naturally emerge. Mitigation: net cost across the full story-review loop still drops because we collapse 4 shallow passes (observed baseline) into 1 exhaustive pass plus ≤ 2 verification-oriented passes. Measured via M4 (Phase 3 rework dispatches) and M5 (post-review Phase 4 failures).
- **Risk:** Coverage Matrix degenerates into a rote checkbox exercise — reviewer writes `no findings` on every non-trivial lens row without actually examining it. Mitigation: every `no findings` row MUST include a one-line rationale citing what was examined (e.g., "no findings: reviewed all 4 API handlers in src/api/ for input validation; all use the shared `validateRequest()` schema"). Bare `no findings` entries without rationale are a protocol violation, catchable via format check. The story-reviewer spec must make the rationale requirement explicit and illustrative.

## 7. Open Questions

1. ~~Should the iteration cap be 2, 3, or 4?~~ **Resolved:** cap at **3**; escalate on the 4th. Treat as a starting magic number; revisit once post-change metrics (M1) are in.
2. **Re-scoped:** The new-vs-rediscovered table is mandatory in iteration ≥ 2, but only required when a finding lives in code that is unchanged since iteration N-1 (Change #4). Confirm this scoping is sufficient, or should the table be unconditionally emitted in every iteration ≥ 2 regardless of whether any finding lands in unchanged code? Current recommendation: conditional — empty table is noise.
3. ~~Which escalation path is chosen?~~ **Resolved:** the user is never part of the runtime escalation path. Integration/complexity findings route to Oracle (see P14); code-quality findings route to architect self-implementation at story scope. Systemic misses (the class of issue that would previously have warranted user intervention) are captured as structured entries in the planning-gotchas sibling file (Change #6) for post-run review. Propagation of those lessons back into planning agents or skills is a deliberate human-mediated process that is explicitly out of scope of this proposal.
4. ~~Should the approval-threshold rule allow one Suggestion-to-Important escalation per story?~~ **Resolved:** the rule is graduated by iteration rather than by headcount (Change #3). Iteration 1 with Suggestion-only → Changes Required (address them; we're already looping). Iteration ≥ 2 with Suggestion-only → Approved. This avoids escalating to expensive models (Oracle, architect self-implementation) for style-only residuals while preserving first-pass quality.

## 8. Affected Agents and Skills (preliminary)

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-engineering-story-reviewer.md` | Modified | Add Severity Escalation Guard section (ported from code-reviewer lines 80–96 with story-scope framing). Add graduated approval-threshold rule (iter 1 vs iter ≥ 2). Require "new vs rediscovered" classification in iteration ≥ 2 for findings in unchanged code. Add required `## Review Coverage Matrix` output section with the hardcoded minimum lens list and the rule for declaring story-specific lenses derived from plan artifacts at the top of the matrix. Require one-line rationale for every `no findings` row. |
| `opencode/.opencode/agents/sdlc-engineering.md` | Modified | Phase 3 story-review loop: cap iterations at 3, escalate on the 4th to Oracle (integration/complexity) or architect self-implementation (code quality); never to the user. Track iteration count in checkpoint dispatch log. Wire planning-gotchas sibling file creation alongside existing skill-gotchas sibling creation (parallel to lines 218–221). On iteration-cap escalation, append structured entry to the planning-gotchas sibling file. File is written-only by the hub; not read, propagated, or rolled up during the run. |
| `common-skills/architect-execution-hub/references/review-cycle.md` | Modified | Document new story-level iteration cap (3) parallel to existing per-task cap. Document Coverage Matrix requirement. Document planning-gotchas escalation write path (write-only; post-run human review). |
| `common-skills/project-documentation/references/planning-gotchas-template.md` | Created | Template for the per-story `docs/staging/US-NNN-name.planning-gotchas.md` sibling file. Parallel to the existing `skill-gotchas-template.md` at the same path, including the same "Who reads it: the human, post-run" framing. Entry schema: trigger, recurring_finding, plan_artifact_category, missed_in_planning, suggested_planning_fix, runtime_resolution, discovered_in. |

**Explicitly NOT affected** (scope fence — to match the fact that this proposal only covers the runtime write path, not any evaluation or propagation path):

- `opencode/.opencode/agents/sdlc-coordinator.md` — NOT modified. No runtime read of any planning-gotchas rollup.
- `opencode/.opencode/agents/sdlc-planner.md` — NOT modified. No runtime load or subagent propagation of planning-gotchas entries.
- No repo-level rollup file is created. The per-story `docs/staging/*.planning-gotchas.md` is the only artifact, and it lives inside the consumer project's staging directory (it is not part of the `scripts/setup-links.sh` symlink surface for downstream projects).

---

## 9. Relation to Prior Proposals

- Direct extension of P6 (the severity guard is P6's mechanism; P10 applies it one level up to story scope, and Change #5's Coverage Matrix makes it mechanically enforceable rather than contract-based).
- **Interacts with P14 (Oracle escalation threshold):** the 3-iteration cap in Change #2 is precisely the story-scope trigger that routes to Oracle. P14 supplies the Oracle target, this proposal supplies the gate condition. Integration/complexity findings at the cap route to Oracle; code-quality findings route to architect self-implementation. The planning-gotchas write (Change #6) records the systemic miss regardless of which runtime path is taken, for later out-of-band human review.
- **Interacts with P16 (per-task AC traceability):** P16 pushes AC coverage verification into Phase 2 per-task reviews. When P16 is in place, the story-reviewer's "Full-story AC coverage and traceability" lens in the Coverage Matrix (Change #5) has less work to do in iteration 1 — most AC gaps have already been caught per-task — which shrinks the likelihood of hitting the 3-iteration cap. P10's M5 (guard against regression: stories that PASS story-review but FAIL Phase 4 acceptance) depends on P16 landing first or simultaneously; without P16, the Coverage Matrix's AC lens carries the full weight and the cap becomes riskier.
- **Shares philosophy with P15 (planner task risk annotations):** P15 is the planning-side complement — annotating risk at plan time. P10's planning-gotchas write is the execution-side capture of misses that slipped past plan time. Any future out-of-band evaluation pass that reviews planning-gotchas files and decides to promote a lesson into planner agents or skills would be a natural consumer alongside P15's annotations. That evaluation pass is explicitly out of scope of this proposal.
