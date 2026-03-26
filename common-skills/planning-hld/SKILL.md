---
name: planning-hld
description: Per-story HLD specialist agent. Use when the Planning Hub dispatches HLD work for a specific user story in Phase 3. Produces a high-level design scoped to a single user story, defining component structure, data flows, integration points, and technology choices. Reads story.md, system-architecture.md, and consumed contracts. Writes to plan/user-stories/US-NNN-name/hld.md.
---

# Planning HLD (Per-Story)

## When to use
- Use when the Planning Hub dispatches HLD work for a specific user story (`sdlc-planner-hld`).
- Use when updating or revising an existing per-story HLD.

## When NOT to use
- DENY use before the story's `story.md` and system architecture are validated.
- DENY use for story decomposition — the Story Decomposer agent handles that.
- DENY use for LLD generation — LLDs are created by the `sdlc-architect` during execution.
- DENY use for modifying other stories' HLD files.
- DENY use for implementation work.

## Inputs required
1. `plan/user-stories/US-NNN-name/story.md` — scope, acceptance criteria, dependency manifest.
2. `plan/system-architecture.md` — component boundaries, technology stack.
3. Consumed contracts from `plan/contracts/` (listed in story's dependency manifest).
4. `plan/prd.md` — for traceability back to requirements.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

### Phase 1: Context Gathering

1. Read the story's `story.md` — extract scope, acceptance criteria, and dependency manifest.
2. Read `plan/system-architecture.md` — extract components referenced in the story's `architecture_components`.
3. Read consumed contracts from `plan/contracts/` — understand shared interfaces this story depends on.
4. Read `plan/prd.md` sections referenced in the story's `prd_sections` — for traceability.
5. Confirm scope: is this initial design or a revision based on validation feedback?

### Phase 2: Component Design

1. For each architecture component this story touches, define:
   - Component responsibilities within this story's scope.
   - Internal module structure (if the component is complex enough).
   - Data flow within and between components.
   - Integration points with other stories (via contracts).
2. Use consumed contract definitions as authoritative — do not redefine shared interfaces.
3. If the story provides contracts, ensure the design supports the contract definition.
4. Technology choices must align with `plan/system-architecture.md`.
5. **Integration realization design**: Read the story's `## Integration Strategy` section. For each external dependency listed:
   - If **mock**: design the mock implementation — define the adapter/repository interface, describe the in-memory data structure or fixture approach, and specify what fake data to provide. The implementer will build exactly what is described here.
   - If **interface-only**: define the adapter interface with method signatures and return types. Specify the file location. Note that consumers will use a mock implementation until a later story provides the real one.
   - If **real**: describe the connection approach (driver, ORM, SDK), configuration source (env vars, config file), and initialization steps. Note that infrastructure must be provisioned before implementation.
   - If **realize**: identify the prior story's mock, describe how the real implementation replaces it (swap adapter, change DI binding, update config), and specify what interface is preserved.
   Document all integration realization decisions in the HLD's `#### Integration realization` subsection. This is critical context that prevents the implementer from guessing.

### Phase 3: Design Documentation

1. Use the template from [`references/HLD.md`](references/HLD.md).
2. For each major design unit:
   - Outcome statement (what is observable when done).
   - Parent linkage (story ID, PRD sections).
   - Scope (in and out).
   - High-level design (architecture approach, key interfaces, data contracts).
   - Acceptance criteria mapping (which story ACs this design unit addresses).
   - Dependencies (on contracts, other story artifacts, external systems).
3. Verify every story acceptance criterion is addressed by at least one design unit.
4. Check that no design unit is out-of-scope for this story.

### Phase 4: Review with User

1. Present the per-story HLD draft.
2. Apply sparring protocol — challenge component boundaries, probe integration points, verify traceability.
3. Iterate until the user approves.

### Phase 5: Completion

1. Write the final HLD to `plan/user-stories/US-NNN-name/hld.md`.
2. Return completion summary to the Planning Hub.

## Sparring Protocol

- "Does this component do too much for one story? Should part of it move to another story?"
- "How does this integrate with the {contract} contract? Are the interface assumptions correct?"
- "Which acceptance criterion does this design unit satisfy? Show me the trace."
- "What happens at the boundary between this story's components and the next story's?"
- "Is this technology choice consistent with the architecture? What's the rationale?"
- "Where are the error paths? What happens when {integration point} fails?"
- "The story mocks {dependency}. Is the mock implementation detailed enough for the implementer to build it without questions?"
- "The adapter interface for {dependency} — will it still work when the real connection replaces the mock in {story}?"
- "This design uses a real {dependency}. Who provisions the infrastructure? Is the DevOps plan aware?"

## Anti-Pleasing Patterns

- **Scope creep**: Challenge any design that goes beyond the story's acceptance criteria.
- **Vague acceptance criteria**: DENY "it should work correctly" — demand specific observable conditions.
- **Contract violations**: If the design contradicts a consumed contract, flag immediately.
- **Missing error cases**: Always ask about error handling at integration points.
- **Over-design**: HLD is high-level. Push back on function signatures or implementation details.

## Output

- `plan/user-stories/US-NNN-name/hld.md` — the per-story High-Level Design.

## Files

- [`references/HLD.md`](references/HLD.md): HLD section template and quality checklist.

## Troubleshooting

- If story.md is incomplete, report the blocker to the Planning Hub.
- If architecture components referenced by the story don't exist, flag for the Architecture agent.
- If a consumed contract is missing or incomplete, flag for the Story Decomposer.
- If the design conflicts with sibling stories' designs (via contracts), escalate to the Hub.
