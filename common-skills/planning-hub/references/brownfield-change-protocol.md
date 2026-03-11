# Brownfield Change Protocol

## Purpose

This protocol defines how the Planning Hub handles changes to an existing plan — whether initiated by the user, discovered during validation, or triggered by external requirements changes. It replaces ad-hoc re-planning with a structured impact-first approach.

## Change Levels

| Level | What Changed | Example |
|-------|-------------|---------|
| **PRD** | Product requirements, user story groups, NFRs, constraints | "Add multi-tenant support" |
| **Architecture** | System topology, component boundaries, technology stack | "Switch from monolith to microservices" |
| **Story (internal)** | Story scope, acceptance criteria, design within a single story | "Add password reset to auth story" |
| **Story (contract)** | A shared contract definition changes | "Add 'role' field to auth-model contract" |
| **Cross-cutting** | DevOps, testing strategy, security overview | "Add staging environment" |

## Change Propagation Table

| Change Level | Re-validate Architecture | Re-validate Affected Stories | Re-plan Affected Stories | Re-validate Cross-Cutting |
|-------------|------------------------|----------------------------|------------------------|--------------------------|
| PRD | YES | YES (all that trace to changed sections) | YES (if scope changed) | YES |
| Architecture | n/a (it IS architecture) | YES (all that use changed components) | YES (if boundaries moved) | YES |
| Story (internal) | NO | NO (only the changed story) | n/a (it IS the story) | MAYBE (if testing/security affected) |
| Story (contract) | NO | YES (all consumers of changed contract) | YES (consumers may need re-planning) | YES (security, testing) |
| Cross-cutting | NO | NO | NO | n/a (it IS cross-cutting) |

## Impact Analysis Flow

Before any re-planning, the Hub MUST run impact analysis:

```
1. User states the proposed change
2. Hub classifies the change level (PRD / Architecture / Story / Cross-cutting)
3. Hub dispatches Plan Validator in IMPACT ANALYSIS mode:
   - Validator reads dependency manifests and contracts
   - Validator traces the dependency graph from the change point
   - Validator reports the BLAST RADIUS:
     - Which stories are affected
     - Which contracts are affected
     - Which cross-cutting concerns need re-validation
     - Estimated re-planning scope (number of stories, agents)
4. Hub presents the blast radius to the user
5. User confirms or narrows the re-planning scope
6. Hub re-dispatches ONLY the minimum required agents
```

## Re-Planning Rules

### PRD Change

1. Run impact analysis to identify affected PRD sections.
2. Dispatch PRD agent to update `plan/prd.md`.
3. Dispatch Validator to check architecture alignment.
4. If architecture is affected, dispatch Architecture agent.
5. Run Story Decomposer in incremental mode — update affected story outlines, add/remove stories.
6. For each affected story: re-dispatch per-story agents (Phase 3 loop).
7. Re-validate cross-cutting concerns.

### Architecture Change

1. Dispatch Architecture agent to update `plan/system-architecture.md`.
2. Run impact analysis to identify stories using changed components.
3. If component boundaries moved, run Story Decomposer in incremental mode.
4. For each affected story: re-dispatch per-story agents.
5. Re-validate cross-cutting concerns.

### Story (Internal) Change

1. Re-plan only the affected story — re-dispatch relevant Phase 3 agents.
2. Re-validate the story with Per-Story Validator.
3. If the story provides contracts, check whether the change affects the contract — if yes, escalate to "Story (contract)" level.
4. If the story's testing or security posture changed significantly, flag for cross-cutting re-validation.

### Story (Contract) Change

1. Re-plan the owner story first.
2. Update the contract file in `plan/contracts/`.
3. Run impact analysis to identify all consumer stories.
4. For each consumer: re-validate, and re-plan if the contract change breaks assumptions.
5. Re-validate security overview and testing strategy.

### Cross-Cutting Change

1. Re-plan only the affected cross-cutting concern (DevOps, Testing, Security overview).
2. Re-validate with Cross-Story Validator.
3. No per-story re-planning unless the cross-cutting change introduces new per-story requirements.

## Incremental Story Decomposition

When the Story Decomposer runs in incremental mode:

1. Read existing story outlines and dependency manifests.
2. Identify which stories are affected by the upstream change.
3. Update affected story outlines (scope, acceptance criteria, dependencies).
4. Add new stories if the change introduces new scope.
5. Mark removed scope as deprecated (do not delete stories — mark as `status: removed` with rationale).
6. Update contracts registry if shared interfaces changed.
7. Re-assign execution order if dependencies changed.

## Hub Responsibilities

The Planning Hub MUST:

- NEVER skip impact analysis before re-planning.
- NEVER re-plan unaffected stories (waste of user time and tokens).
- ALWAYS present the blast radius to the user before proceeding.
- ALWAYS use the minimum re-planning scope that addresses the change.
- TRACK change history in `plan/validation/change-log.md` (append-only).
