# Decision Guidance for Planning Hub

## Parallel vs Sequential Within Phase 3

- **Parallel**: HLD, API, Data, Security can run in parallel for a single story — they read the same inputs (story.md, architecture, contracts) and produce independent outputs.
- **Sequential dependency**: Design depends on HLD. Design agent needs component structure from HLD for mockups. Dispatch Design after HLD produces output.
- **Story ordering**: Stories are processed in `execution_order`. Within a story, HLD/API/Data/Security parallel; Design after HLD. Between stories, sequential by execution_order (unless stories are independent and user prefers parallel).

## Validation Failures

- **First failure**: Re-dispatch the agent with specific feedback. Surface what failed and what to fix.
- **Repeated failures (2–3 cycles)**: Escalate to user. Ask: "Validation has failed repeatedly. Options: (a) iterate with more specific guidance, (b) accept partial output with documented gaps, (c) skip this artifact with acknowledgment."
- **Do not** silently retry indefinitely or bypass validation.

## Brownfield Change Level Classification

| Level | Re-plan scope |
|-------|---------------|
| **PRD** | Architecture, Story Decomposer, affected stories, cross-cutting |
| **Architecture** | Affected stories, cross-cutting |
| **Story (internal)** | Only the affected story |
| **Story (contract)** | Owner story, all consumers of the contract, cross-cutting |
| **Cross-cutting** | Only the affected cross-cutting concern (DevOps, Testing, Security) |

Use the Change Propagation Table in brownfield-change-protocol for exact rules.

## Skip Policy

- **Require explicit user acknowledgment** — Never skip a phase or validation gate without the user explicitly approving.
- When user requests skip: Surface what will be missing, what downstream phases will lack, and what the validator cannot verify.
- Mark skipped outputs as `NOT PLANNED` in the validation report.
- Document the skip in change-log.md.

## When to Escalate to User

- Validation fails repeatedly after 2–3 re-dispatch cycles.
- User requests to skip a phase or gate.
- Brownfield impact analysis reveals large blast radius — present options and ask user to confirm or narrow scope.
- Circular dependencies detected in story execution order.
- Missing skills or modes — an agent cannot be dispatched because the required skill is unavailable.
- Conflict between artifacts that requires user resolution (e.g., PRD vs architecture, contract vs consumer).
