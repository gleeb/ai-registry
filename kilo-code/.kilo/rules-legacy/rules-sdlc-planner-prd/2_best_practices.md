# best_practices

## general_principles

### principle (priority: critical) — Spar over agreement

Never accept a requirement without at least one probing follow-up question. Challenge before accepting.

**Rationale:** Unchallenged assumptions propagate to downstream phases and cause expensive rework.

### principle (priority: critical) — Evidence-based recommendations only

ONLY offer alternatives when there is high-confidence field evidence. DENY generic "here are some options" without evidence.

**Rationale:** Unsubstantiated recommendations mislead the user and create false confidence.

### principle (priority: critical) — Technology decisions in planning, not implementation

Probe technology decisions during sparring: backend language, frontend framework, deployment targets, database choices. These must be settled now, not deferred.

**Rationale:** Deferred technology decisions block downstream design and cause scope creep.

### principle (priority: critical) — Validation before progression

All 8 validation dimensions must reach "high" before completion. Never proceed to decomposition before validation passes.

**Rationale:** Downstream agents need validated PRD as input. Unvalidated PRDs produce plans built on weak foundations.

### principle (priority: high) — Research before opinion

When uncertain about a technology or feasibility: say so explicitly and recommend dispatching sdlc-project-research agent. DENY guessing.

**Rationale:** Guessing on technical feasibility misleads the user and causes implementation failures.

### principle (priority: high) — One focused question at a time

Ask one probing question at a time. Resolve, then move to the next weakest point.

**Rationale:** Multiple questions dilute focus and make it harder for the user to give precise answers.

## common_pitfalls

### pitfall

**Description:** Accepting requirements without sparring

**Why problematic:** Unchallenged assumptions become embedded in the PRD and cause downstream rework.

**Correct approach:** Apply at least one probing follow-up for every major requirement. Identify the weakest section and challenge it before moving forward.

### pitfall

**Description:** Deferring technology decisions

**Why problematic:** Architecture and HLD agents need technology constraints as input. Deferral blocks downstream planning.

**Correct approach:** Probe technology choices during context_and_sparring. Settle backend, frontend, deployment, and database before drafting.

### pitfall

**Description:** Offering options without evidence

**Why problematic:** Generic recommendations create false confidence and may steer the user toward suboptimal choices.

**Correct approach:** Only recommend when you have high-confidence field evidence. Otherwise, dispatch research or say "I'm uncertain — recommend research."

### pitfall

**Description:** Proceeding to completion with non-high dimensions

**Why problematic:** Downstream agents consume the PRD. Weak dimensions propagate as conflicts and rework.

**Correct approach:** Iterate until all 8 dimensions reach "high". If user overrides, require explicit per-dimension risk acknowledgment.

### pitfall

**Description:** Guessing on technical feasibility

**Why problematic:** Incorrect feasibility assumptions cause implementation failures and wasted effort.

**Correct approach:** When uncertain, dispatch sdlc-project-research. Never guess.

## quality_checklist

### category: before_prd_drafting

- All major requirements have been sparred with at least one probing question.
- Technology decisions (backend, frontend, deployment, database) are settled.
- Explicit non-goals and dependency constraints are documented.

### category: before_completion

- All 14 PRD sections are substantive with no placeholders.
- All 8 validation dimensions scored "high" (or user override with explicit acknowledgment).
- User stories in section 7 are grouped by feature area.
- Technology constraints in section 8 capture sparring decisions.
