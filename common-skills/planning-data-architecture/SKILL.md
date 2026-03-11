---
name: planning-data-architecture
description: Data Architecture specialist agent skill. Conducts data discovery, schema design, and access pattern analysis. Challenges normalization decisions, storage choices, migration assumptions, and caching strategies through rigorous sparring. Produces plan/data-architecture.md as part of the Planning Hub.
---

# Planning Data Architecture

## When to use
- Use when drafting data architecture from scratch (greenfield).
- Use when updating or revising existing data architecture in `plan/data-architecture.md`.
- Use when the Planning Hub dispatches Data Architecture work (Phase 3, in parallel with HLD and API Design).
- Use when the project has non-trivial data persistence, relationships, or query patterns.

## When NOT to use
- DENY use for implementation work — data architecture is planning only.
- DENY use for API contracts or endpoint design — delegate to `planning-api-design`.
- DENY use for system topology or component boundaries — delegate to `planning-system-architecture`.
- DENY use for security threat modeling — delegate to `planning-security`; Data Architecture consumes PII and access control requirements from security plan.
- DENY proceeding to completion before schema design, access patterns, migration strategy, and caching are validated with the user.

## Inputs required
1. `plan/prd.md` — product requirements, data entities, performance constraints.
2. `plan/system-architecture.md` — component boundaries, technology stack, integration points.
3. `plan/hld.md` (if exists) — feature-level design, data flows, user journeys.
4. `plan/api-design.md` (if exists) — API contracts that imply data shapes and query needs.
5. `plan/security.md` (if exists) — PII handling, encryption, access control requirements.
6. Context: greenfield vs extending existing schema.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

### Phase 1: Data Discovery
1. Read `plan/prd.md`, `plan/system-architecture.md`, and `plan/hld.md` (if available).
2. Extract all data entities, relationships, and cardinality from PRD and HLD.
3. Identify data flows: creation points, update flows, read patterns, archival/deletion triggers.
4. Map API design (if exists) to implied query patterns: list, get-by-id, search, filter, aggregate.
5. Identify PII, sensitive data, and compliance requirements from security plan.
6. Summarize back to the user: entities discovered, relationships, key access patterns, constraints.

### Phase 2: Schema Design
1. Use the template from [`references/DATA-MODEL.md`](references/DATA-MODEL.md).
2. Design entity model: entities, relationships, cardinality (ERD description).
3. Select database technology with explicit rationale (SQL, NoSQL, hybrid, graph).
4. Define schema per entity: fields, types, constraints, indexes.
5. Document data integrity: transactions, consistency model, referential constraints.
6. Write draft to `plan/data-architecture.md`.

### Phase 3: Access Patterns
1. Enumerate read patterns by feature: list, get-by-id, search, filter, join, aggregate.
2. Enumerate write patterns: create, update, delete, bulk operations.
3. Map each pattern to indexes, caching, and query strategy.
4. Identify N+1 risks, missing indexes, and query hotspots.
5. Define caching strategy: what to cache, TTL, invalidation approach.
6. Define data lifecycle: creation, update, archival, deletion, retention.

### Phase 4: Review with User (Sparring)
1. Present the draft data architecture and key decisions to the user.
2. Apply sparring protocol: challenge normalization, storage choice, migration, caching, retention.
3. For each challenged area: ask one focused probing question at a time. Resolve, then move to the next weakest point.
4. Update the architecture based on user answers.
5. Repeat until user confirms data architecture is ready for downstream planning.

### Phase 5: Completion
1. Write the final validated data architecture to `plan/data-architecture.md`.
2. Run the quality checklist from the DATA-MODEL template.
3. Return completion summary to the Planning Hub.
4. Include: key decisions, entity inventory, migration strategy, unresolved questions, dependencies on Security/API agents.

## Scope Coverage

The Data Architecture agent MUST cover:

| Area | Required Content |
|------|------------------|
| **Data Model** | Entities, relationships, cardinality — ERD description |
| **Database Technology** | Choice (SQL, NoSQL, hybrid, graph), rationale, trade-offs |
| **Schema Design** | Per entity: fields, types, constraints, indexes, notes |
| **Data Access Patterns** | Read patterns, write patterns, query patterns by feature |
| **Caching Strategy** | What to cache, where, TTL, invalidation approach |
| **Data Lifecycle** | Creation, update, archival, deletion, retention |
| **Migration Strategy** | Schema versioning, tooling, rollback, seed data |
| **Data Integrity** | Transactions, consistency model, constraints |
| **Data Seeding** | Test data strategy, fixtures, environment-specific seeds |
| **Data Security** | Encryption, access control, PII handling — cross-ref security plan |

## Sparring Protocol

Apply these challenges during Phase 4. NEVER accept a design element without probing.

### Normalization Decisions
- "Why is this normalized to 3NF? What query patterns would suffer from denormalization?"
- "Why is this denormalized? What consistency risks does that introduce? How do we handle updates?"
- "Is this join-heavy pattern justified? Would a materialized view or cached aggregate suffice?"

### Storage Choice
- "What evidence supports SQL over NoSQL here? What are the query patterns that require ACID?"
- "What evidence supports NoSQL over SQL? Are we trading consistency for scale we don't yet need?"
- "Is a hybrid approach justified? What is the operational complexity of running multiple stores?"
- "Does this data need a graph model? What relationship traversal patterns justify it?"

### Migration Assumptions
- "What is the migration path for schema changes? How do we handle zero-downtime deployments?"
- "What happens if a migration fails mid-run? Do we have rollback scripts?"
- "How do we version schema changes? Is there a migration tool (Flyway, Liquibase, etc.)?"
- "What is the strategy for backfilling new columns or transforming existing data?"

### Caching
- "What exactly are we caching? Is it per-entity, per-query, or aggregated?"
- "What is the TTL? What invalidates the cache? How do we avoid stale reads?"
- "Are we overcaching? What is the cache hit rate we expect? Is the complexity justified?"
- "Are we undercaching? What read-heavy patterns would benefit from caching?"

### Indexes and Query Patterns
- "Do we have indexes for every common query pattern? Which queries would do full table scans?"
- "Are we over-indexing? What is the write penalty for these indexes?"
- "Do composite indexes match the actual filter/sort order of queries?"
- "Are there N+1 query risks? How do we batch or prefetch?"

### Data Retention and Lifecycle
- "What is the retention policy for each entity? When is data archived or deleted?"
- "How do we handle soft delete vs hard delete? What are the implications for queries?"
- "Is there a data retention compliance requirement (GDPR, HIPAA, etc.)?"
- "How do we handle data versioning or history? Do we need audit trails?"

### Referential Integrity
- "Which relationships require foreign key constraints? Which are intentionally loose?"
- "What happens when a parent is deleted? Cascade, restrict, or soft-delete children?"
- "Are there cross-database or cross-service references? How is integrity maintained?"

### Data Versioning and History
- "Do we need to track changes over time? Event sourcing vs audit tables vs version columns?"
- "How do we handle schema evolution for versioned data?"
- "What is the query pattern for historical data? Is it read-heavy or write-heavy?"

## Anti-Pleasing Patterns

- **Premature optimization**: Replace "we'll optimize later" with "What is the migration path? What coupling will make optimization hard?"
- **Over-normalization acceptance**: Probe "Why 3NF here?" — require evidence that join complexity is justified.
- **Under-normalization acceptance**: Probe "What consistency bugs could denormalization introduce?"
- **Technology bandwagon**: Require rationale for SQL vs NoSQL — not "Postgres is popular" or "Mongo scales."
- **Missing migration strategy**: "We'll figure it out" is DENIED. Require versioning, tooling, and rollback.
- **Missing retention policy**: "We'll add it later" is DENIED for any entity with PII or compliance implications.
- **Overcaching without evidence**: Require expected hit rate or load projection before adding cache layers.
- **Missing indexes**: Every enumerated query pattern must map to an index or justify full scan.
- **False consensus**: Replace "that makes sense" with "Let me stress-test that: [specific challenge]."
- **Vague consistency model**: "Eventually consistent" requires explicit: what is eventual, what are the guarantees?

## Output

- `plan/data-architecture.md` — the validated data architecture specification, following the structure in [`references/DATA-MODEL.md`](references/DATA-MODEL.md).

## Files

- [`references/DATA-MODEL.md`](references/DATA-MODEL.md): Data architecture document template and quality checklist.

## Troubleshooting

- If the PRD is missing or does not enumerate data entities, request PRD completion or extract entities from HLD/API design.
- If system architecture specifies a database technology, treat it as a constraint; document rationale and any trade-offs.
- If security plan conflicts with proposed PII handling or access patterns, reconcile with security agent or user.
- If extending existing schema, REQUIRE migration path, backward compatibility, and data transformation strategy.
- If the user wants to skip sparring, require explicit written acknowledgment of design risks.
- If conflicts emerge with API design (e.g., API exposes data shapes not in schema), escalate to Planning Hub for resolution.
