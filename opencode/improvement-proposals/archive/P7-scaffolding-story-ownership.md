# P7: Scaffolding Story Ownership

**Status:** Implemented — decisions recorded, files created/modified
**Relates to:** [P1 (Ceremony Scaling)](./P1-ceremony-scaling-and-scaffolding.md), [P2 (Context Management)](./P2-context-management-and-memory.md), [P3 (Verification Pipeline)](./P3-verification-pipeline.md)
**Scope:** `opencode/.opencode/agents/sdlc-engineering.md`, `opencode/.opencode/agents/sdlc-engineering-scaffolder.md`, `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md`, `opencode/.opencode/agents/sdlc-planner-stories.md`, `common-skills/planning-stories/references/DEPENDENCY-MANIFEST.md`, `common-skills/planning-stories/references/STORY-OUTLINE.md`
**Transcript evidence:** `ses_264266feeffe804Vnge3sKB2DA` — US-001-scaffolding, second run after P1-P6 changes. Scaffolder completed correctly; hub entered Phase 1b and invented Tasks 1/2/3 duplicating all scaffolder output; 4+ review/remediation cycles on already-done work; adversarial reviewer severity-escalated non-issues.

---

## 1. Problem Statement

P1 designed the scaffolder as a "mini-hub" that owns scaffold work and returns a single STATUS to the engineering hub, which then "proceeds to Phase 1." This design assumed Phase 0b scaffolding is a *pre-step* for a feature story. For the special case where the scaffolding story *is* the story (US-001-scaffolding), this assumption is wrong:

- Scaffolder completed successfully: 38/38 checklist items passed, `verify:full` exited 0, scaffold-reviewer Approved.
- Hub resumed with `SCAFFOLD STATUS: COMPLETE`, then entered Phase 1a/1b/1c.
- Phase 1c read the HLD's Design Units (DU-A, DU-B) and invented 3 tasks decomposing the same files the scaffolder had already created.
- Phase 2 dispatched the adversarial `sdlc-engineering-code-reviewer` (not the scaffold-reviewer) for Tasks 1/2/3.
- The reviewer ran 4+ iterations. Iter 2 flagged "missing `coverage.thresholds`" as Important — directly contradicting P3's explicit decision ("Thresholds are NOT set during scaffold"). Iter 3 invented a bureaucratic "missing Library Documentation Cache Usage section" as Important. At transcript line 25591 the reviewer explicitly reasoned: "I need to identify a minor, legitimate suggestion within the scope of task 1 without fabricating any issues. Let's find that!"

Root causes:

1. **No story_type signal.** The hub had no way to know that a scaffolding story should not enter Phase 1/2/3.
2. **Phase 0b lacks a story-complete exit path.** After `SCAFFOLD STATUS: COMPLETE`, the only path was "proceed to Phase 1" — regardless of whether Phase 1 was needed.
3. **Adversarial reviewer "must find one Suggestion" floor creates severity-escalation pressure.** The floor itself is sound (catches lazy reviews), but the lack of a ceiling let the reviewer convert Suggestion-class nits into Important findings across iterations, triggering unnecessary remediation cycles.

---

## 2. Root Cause Analysis

### 2.1 Mental model mismatch between P1 intent and P1 implementation

P1's written intent (section 3.3, Open Question #3): *"Resolved by architecture: scaffolder-hub ends when scaffold-reviewer approves and returns STATUS to engineering hub. Hub proceeds to Phase 1."*

The phrase "proceeds to Phase 1" was written assuming scaffolding = pre-step for a feature story. For US-001-scaffolding specifically, there is no feature story content after the scaffold — the ACs are the scaffold itself. The P1 author was thinking of "Phase 0b + US-NNN-feature" but wrote instructions that also apply to "US-001-scaffolding-only."

**Evidence:** `story.md` `Files Affected` table exactly matches the scaffolder FILE MANIFEST. `hld.md` has two Design Units (DU-A, DU-B) that correspond directly to the scaffold checklist sections. There is no feature logic beyond the scaffold.

### 2.2 Phase 1c task decomposition is unconditional

`sdlc-engineering.md` Phase 1c reads hld.md Design Units and breaks them into tasks. It applies a 4-file-per-task sizing constraint, splitting the 7 Files Affected into three tasks. This decomposition ran on already-delivered work.

**Evidence:** Staging doc `US-001-scaffolding.md` was created at transcript line 10170 with Tasks 1/2/3. Context docs `.task-1.context.md`, `.task-2.context.md`, `.task-3.context.md` followed at lines 10236–10300. None of this content was in the plan.

### 2.3 Adversarial reviewer severity escalation

The code-reviewer's "adversarial by default" stance includes a floor: "every review must produce at minimum one Suggestion-level finding." This is correct behavior. The problem is the absence of a ceiling:

- Iter 1 (line 17661): `vitest.config.ts` missing `coverage.reporter` → Important. Legitimate.
- Iter 2 (line 20831): `vitest.config.ts` missing `coverage.thresholds` → Important. Contradicts P3 ("Thresholds NOT set during scaffold"). Severity-escalation from prior review context.
- Iter 3 (line 25694): staging doc missing "Library Documentation Cache Usage section" → Important. Pure documentation bureaucracy. New finding introduced in iteration 3 to justify blocking.
- Iter 3 reviewer self-report (line 25591): "I need to identify a minor, legitimate suggestion within the scope of task 1 without fabricating any issues."

The "floor" pressure (must find one finding) created downstream incentive to keep finding *something* blockable.

---

## Implementation Decisions

### story_type manifest field

**Decision:** Add `story_type: scaffolding | feature | integration | infrastructure` to the dependency manifest schema. Default: `feature` (absent = feature). US-001-scaffolding MUST declare `story_type: scaffolding`.

- Defined in: `common-skills/planning-stories/references/DEPENDENCY-MANIFEST.md`
- Embedded in template: `common-skills/planning-stories/references/STORY-OUTLINE.md`
- Required by: `opencode/.opencode/agents/sdlc-planner-stories.md` (Scaffolding Story section + validation checklist + Candidate Domain table)

### Engineering hub fast-path

**Decision:** Phase 0b is restructured with `story_type` read as Step 0b-0. If `story_type: scaffolding`, dispatch scaffolder and — on COMPLETE — return `STORY STATUS: COMPLETE` to the coordinator. Do NOT enter Phase 1, 1a, 1b, 1c, 2, or 3.

The previous "greenfield detection fallback" path remains intact for non-scaffolding stories that happen to run on a greenfield project.

**Key change:** Line 161 of the original hub ("After scaffold completes and docs gate passes, proceed to Phase 1") now applies only when `story_type != scaffolding`. For scaffolding stories, the hub's responsibility ends at the Phase 0b exit.

### Scaffolder self-validation (Phase S5b)

**Decision:** When dispatched with `STORY_TYPE: scaffolding`, the scaffolder reads `story.md` Files Affected + ACs during Phase S0 (stored in memory, not passed to the implementer). After Phase S5 (docs gate), it runs Phase S5b:

1. Bash check that every file in Files Affected exists and is non-empty.
2. Confirm `verify:full` passed.
3. Confirm scaffold-reviewer Approved (or verify:full passing is sufficient after self-implementation).
4. Map each AC to available evidence (file existence, verify:full, or "browser-validation-only").
5. If any file missing or gate failing → `SCAFFOLD STATUS: PARTIAL`.

The implementer dispatch is unchanged — it still uses the checklist as ACs (no plan artifacts). The self-validation is the scaffolder's own final gate, run after the reviewer.

**Rationale:** This closes the gap where the scaffolder could return COMPLETE without verifying against the story's formal ACs. The scaffold-reviewer checks the scaffold checklist; Phase S5b checks the story contract. These are complementary.

### Adversarial reviewer ceiling (severity escalation guard + review exhaustion rule)

**Decision:** Add two new sections to `sdlc-engineering-code-reviewer.md` after the existing "Adversarial by default" section:

1. **Severity escalation guard:** A finding that was Suggestion-class in iteration N MUST NOT be re-classified as Important in iteration N+1 without new evidence. If only Suggestion-class findings remain, verdict is Approved regardless of iteration count.

2. **Review exhaustion rule:** At iteration 2+, if all prior Critical/Important findings are resolved and remaining findings are Suggestion-class, return Approved. New Important/Critical findings introduced in iteration 2+ must justify why they were not catchable in iteration 1.

3. **Verdict Rules table addition:** "Iteration 2+ with all prior Critical/Important findings resolved and only Suggestion-class residual → Approved."

**What is NOT changed:** The floor ("every review must produce at minimum one Suggestion-level finding") remains. It is correct — a zero-finding review is a signal to look harder. The fix is the ceiling, not removing the floor.

---

## 3. Affected Agents and Skills

| File | Change Type | Description |
|------|-------------|-------------|
| `common-skills/planning-stories/references/DEPENDENCY-MANIFEST.md` | Modified | Added `story_type` field definition + scaffolding story example + validation rule 15 |
| `common-skills/planning-stories/references/STORY-OUTLINE.md` | Modified | Added `story_type` to manifest template; template rules note for US-001 |
| `opencode/.opencode/agents/sdlc-planner-stories.md` | Modified | Scaffolding Story section: require story_type; validation checklist: 2 new checks; Candidate Domain table: added story_type column |
| `opencode/.opencode/agents/sdlc-engineering.md` | Modified | Phase 0b: restructured with Step 0b-0 (read story_type), Scaffolding Story Fast-Path branch, Greenfield Detection Fallback (existing logic) |
| `opencode/.opencode/agents/sdlc-engineering-scaffolder.md` | Modified | Phase S0: Step 2 reads story.md in scaffolding-story mode; Phase S5b: story-level self-validation; Completion Contract: STORY AC VALIDATION block; Explicit boundary note for scaffolding-story mode |
| `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md` | Modified | Added Severity escalation guard section; added Review exhaustion rule section; added iteration 2+ rule to Verdict Rules |

---

## 4. Open Questions — Resolved

1. **Who does final AC validation for a scaffolding story?** Resolved: scaffolder self-validates (Phase S5b). No acceptance-validator dispatch needed. Scaffold-reviewer + Phase S5b self-validation = story acceptance gate.

2. **Should story_type be optional or required?** Resolved: optional (default `feature`). Only scaffolding stories need it. Requiring it on every story adds maintenance burden with no benefit.

3. **Should the "adversarial by default" floor be removed?** Resolved: No. The floor catches lazy reviews. The problem is the ceiling. Severity escalation guard + review exhaustion rule add the ceiling without weakening the floor.

4. **Does this change affect non-scaffolding stories?** Resolved: No. The hub fast-path activates only on `story_type: scaffolding`. The greenfield detection fallback (existing behavior) runs for all other stories. The code-reviewer changes affect all feature stories but only constrain escalation behavior (iteration 2+ with resolved prior findings) — correct feature reviews are unaffected.

---

## 5. Success Metrics

- US-001-scaffolding completes in: 1 scaffolder dispatch (which internally dispatches implementer + scaffold-reviewer), no code-reviewer dispatches, no Phase 1/2/3 context docs, no task decomposition.
- Hub returns `STORY STATUS: COMPLETE` for US-001 and coordinator routes to US-002 without user intervention.
- Verification: transcript for US-001 shows no `task-N.context.md` files, no `sdlc-engineering-code-reviewer` dispatches.
- For feature stories: review iteration 2+ with resolved Critical/Important findings terminates at Approved rather than requiring a third dispatch.
