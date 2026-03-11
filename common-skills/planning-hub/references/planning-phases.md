# Planning Phases — Dependency Graph and Ordering

## Phase Dependency Graph

```
Phase 1: Requirements
  └── PRD Agent
        ↓ (PRD validated at "high" on all 8 dimensions)
Phase 2: Architecture  [parallel within phase]
  ├── System Architecture Agent  (depends on: PRD)
  └── Security Agent             (depends on: PRD)
        ↓ (Validator: architecture + security consistent with PRD)
Phase 3: Detailed Design  [parallel where independent]
  ├── HLD Agent              (depends on: PRD, Architecture)
  ├── API Design Agent       (depends on: PRD, Architecture)
  ├── Data Architecture Agent (depends on: PRD, Architecture)
  ├── DevOps Agent           (depends on: Architecture, Security)
  └── Design/UI-UX Agent    (depends on: PRD, HLD)
        ↓ (Validator: all Phase 3 outputs consistent)
Phase 4: Stories & Test Plan
  ├── User Stories           (output of HLD Agent, verified here)
  └── Testing Strategy Agent (depends on: all above)
        ↓ (Final Validator: full traceability check)
Phase 5: Optional SaaS Sync
  └── Sync skill (e.g., linear-sync)
        ↓
Phase 6: Handoff to Coordinator
```

## Phase Entry Gates

| Phase | Entry Condition |
|---|---|
| Phase 1 | User request received; plan/ folder state assessed |
| Phase 2 | PRD passes all 8 validation dimensions at "high" |
| Phase 3 | Phase 2 validator passes (architecture + security consistent with PRD) |
| Phase 4 | Phase 3 validator passes (all detailed design documents consistent) |
| Phase 5 | Phase 4 final validator passes; user opts into SaaS sync |
| Phase 6 | All planning complete; all validators passed |

## Parallelism Rules

Within a phase, agents that do not depend on each other's output can run in parallel:

- **Phase 2**: System Architecture and Security can run in parallel.
- **Phase 3**: HLD, API Design, and Data Architecture can start together (all depend on PRD + Architecture, not each other). DevOps depends on Architecture + Security. Design depends on PRD + HLD (so it starts after HLD produces initial output).
- **Phase 4**: User Story verification and Testing Strategy can run in parallel.

## Incremental Planning

When only part of the plan needs updating:
1. Identify which plan artifacts are stale or missing.
2. Determine the earliest affected phase.
3. Run only from that phase forward.
4. Treat existing unaffected artifacts as constraints (not re-planned).
5. Validator still checks consistency across all artifacts (new and existing).

## Phase Skip Policy

- The hub ALLOWS skipping a phase only with explicit user acknowledgment.
- The skipped phase's output is marked as `NOT PLANNED` in the validation report.
- Downstream phases that depend on the skipped phase must be warned about missing input.
- The validator flags any requirements that cannot be verified due to skipped phases.
