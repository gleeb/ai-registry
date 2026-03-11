# Planning Phases — Dependency Graph and Ordering

## Phase Dependency Graph

```
Phase 1: Requirements
  └── PRD Agent
        ↓ (PRD validated)

Phase 2: Architecture and Story Decomposition  [sequential within phase]
  ├── System Architecture Agent  (depends on: PRD)
  │     ↓ (Architecture validated)
  └── Story Decomposer Agent     (depends on: PRD, Architecture)
        ↓ (Stories validated: coverage, dependencies, contracts)

Phase 3: Per-Story Planning  [loop over stories in execution_order]
  For each US-NNN:
    ├── HLD Agent              (depends on: story.md, Architecture, Contracts)
    ├── API Design Agent       (depends on: story.md, Architecture, Contracts)  [if api in domains]
    ├── Data Architecture Agent (depends on: story.md, Architecture, Contracts) [if data in domains]
    ├── Security Agent          (depends on: story.md, Architecture)            [if security in domains]
    └── Design/UI-UX Agent     (depends on: story.md, PRD, HLD)               [if design in domains]
        ↓ (Per-Story Validator for US-NNN)

Phase 4: Cross-Cutting Concerns  [parallel within phase]
  ├── Security Agent (rollup mode)  (depends on: all per-story security.md files)
  ├── DevOps Agent                  (depends on: Architecture, all per-story artifacts)
  └── Testing Strategy Agent        (depends on: all per-story artifacts, acceptance criteria)
        ↓ (Cross-Story Validator)

Phase 5: Execution Readiness
  └── Full-chain Validator (depends on: everything)
        ↓

Phase 6: Optional SaaS Sync
  └── Sync skill (e.g., linear-sync)
        ↓

Phase 7: Handoff to Coordinator
```

## Phase Entry Gates

| Phase | Entry Condition |
|---|---|
| Phase 1 | User request received; plan/ folder state assessed |
| Phase 2 | PRD passes validation |
| Phase 2 (Story Decomposer) | Architecture passes validation |
| Phase 3 | Stories validated (coverage, dependency integrity, contracts created) |
| Phase 3 (per story) | Previous story in execution_order passed per-story validation (or stories are independent/parallel) |
| Phase 4 | ALL stories have passed per-story validation |
| Phase 5 | Phase 4 cross-cutting validation passes |
| Phase 6 | Phase 5 execution readiness validation passes; user opts into SaaS sync |
| Phase 7 | All planning complete; all validators passed |

## Parallelism Rules

### Between Phases
Phases are strictly sequential. Phase N+1 cannot start until Phase N's gate passes.

### Within Phase 2
Architecture THEN Story Decomposition. Story decomposition requires validated architecture as input.

### Within Phase 3
Agents within a single story can run in parallel (HLD, API, Data, Security all read the same inputs and produce independent outputs). Design depends on HLD (needs component structure for mockups), so it starts after HLD produces initial output.

Stories themselves are processed in execution_order. Stories with the same execution_order can be planned in parallel if the user prefers speed over sequential review.

### Within Phase 4
Security rollup, DevOps, and Testing Strategy can run in parallel (they read per-story artifacts but produce independent cross-cutting outputs).

## Incremental Planning (Brownfield)

When a change is proposed to an existing plan:

1. Run impact analysis to determine blast radius.
2. Present blast radius to user.
3. Re-plan only affected artifacts from the earliest affected phase forward.
4. Treat unaffected artifacts as constraints (not re-planned).
5. Validator checks consistency across all artifacts (new and existing).

See [brownfield-change-protocol.md](brownfield-change-protocol.md) for the full protocol.

## Phase Skip Policy

- The hub ALLOWS skipping a phase only with explicit user acknowledgment.
- The skipped phase's output is marked as `NOT PLANNED` in the validation report.
- Downstream phases that depend on the skipped phase must be warned about missing input.
- The validator flags any requirements that cannot be verified due to skipped phases.
