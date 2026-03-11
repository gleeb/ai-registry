---
name: planning-data-architecture
description: Per-story Data Architecture specialist agent. Use when the Planning Hub dispatches data architecture work for a specific user story in Phase 3. Conducts data discovery, schema design, and access pattern analysis scoped to a single story. Reads story.md, system-architecture.md, consumed contracts, and hld.md. Writes to plan/user-stories/US-NNN-name/data.md.
---

# Planning Data Architecture (Per-Story)

## When to use
- Use when the Planning Hub dispatches Data Architecture work for a specific user story (`sdlc-planner-data`).
- Use when updating or revising an existing per-story data architecture.
- Use when the story's `candidate_domains` includes `data`.

## When NOT to use
- DENY use for implementation work — data architecture is planning only.
- DENY use for API contracts — delegate to `planning-api-design`.
- DENY use for security threat modeling — delegate to `planning-security`.
- DENY use for modifying other stories' data architectures.
- DENY proceeding before schema design, access patterns, and migration strategy are validated.

## Inputs required
1. `plan/user-stories/US-NNN-name/story.md` — scope, acceptance criteria, dependency manifest.
2. `plan/system-architecture.md` — data stores, technology choices.
3. Consumed contracts from `plan/contracts/` (especially shared entity definitions).
4. `plan/user-stories/US-NNN-name/hld.md` (recommended) — component structure, data flows.
5. `plan/user-stories/US-NNN-name/api.md` (if exists) — for schema alignment.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

### Phase 1: Data Discovery (Story-Scoped)

1. Read story.md — extract data entities and access patterns implied by acceptance criteria.
2. Read hld.md (if available) — extract data flows and entity relationships.
3. Read consumed contracts — identify shared entity definitions this story depends on.
4. Read api.md (if available) — extract implied query patterns.
5. Identify PII and sensitive data within this story's scope.

### Phase 2: Schema Design

1. Design entity model for this story: entities, relationships, cardinality.
2. Use consumed contract definitions as authoritative for shared entities.
3. If this story provides entity contracts, ensure schema fully supports the contract.
4. Define schema per entity: fields, types, constraints, indexes.
5. Document data integrity requirements: transactions, consistency model.
6. Use the template from [`references/DATA-MODEL.md`](references/DATA-MODEL.md).

### Phase 3: Access Patterns

1. Enumerate read patterns from this story's acceptance criteria.
2. Enumerate write patterns (create, update, delete, bulk).
3. Map patterns to indexes and query strategy.
4. Identify N+1 risks and missing indexes.
5. Define caching strategy if relevant to this story.
6. Define data lifecycle for entities in this story's scope.

### Phase 4: Review with User

1. Present the per-story data architecture and key decisions.
2. Apply sparring — challenge normalization, storage choice, access patterns.
3. Iterate until user approves.

### Phase 5: Completion

1. Write the final data architecture to `plan/user-stories/US-NNN-name/data.md`.
2. Return completion summary to the Planning Hub.

## Sparring Protocol

- "Why this normalization level? What query patterns would suffer from alternatives?"
- "Does this entity's schema align with the {contract} contract definition?"
- "What indexes are needed for this story's query patterns? Any missing?"
- "What is the migration strategy for these schema changes?"
- "How does this entity relate to entities in other stories via contracts?"
- "Is caching justified here? What's the expected access pattern?"

## Anti-Pleasing Patterns

- **Contract violations**: If the schema contradicts a consumed entity contract, flag immediately.
- **Missing migration**: "We'll figure it out" is DENIED. Require versioning and rollback strategy.
- **Overcaching**: Require expected hit rate before adding cache layers.
- **Technology bandwagon**: Require rationale for storage choice within architecture constraints.
- **Scope creep**: Entities belonging to other stories' scopes are out of scope.

## Output

- `plan/user-stories/US-NNN-name/data.md` — the per-story data architecture.

## Files

- [`references/DATA-MODEL.md`](references/DATA-MODEL.md): Data architecture template and quality checklist.

## Troubleshooting

- If story.md is incomplete, report the blocker.
- If consumed entity contracts are missing, flag for the Story Decomposer.
- If schema conflicts with api.md, reconcile before completing.
