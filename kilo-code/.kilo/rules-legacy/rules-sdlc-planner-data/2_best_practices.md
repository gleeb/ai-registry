# Best Practices

## Per-Story Scoping

- Design entities only for this story's scope. Do not expand to unrelated entities.
- A story touching more than 3 new entities may need scope reduction.
- Entities consumed from other stories are out of scope for schema design — use their contracts.

## Contract Authority

- Use consumed entity contracts as authoritative. Do not redefine shared schemas.
- If a consumed contract is incomplete, flag it — do not invent fields.
- When this story provides a contract, ensure it is complete for consumers.

## Storage Alignment

- Align storage choices with `plan/system-architecture.md`.
- Do not introduce new storage technologies without architecture approval.
- Document rationale when choosing between relational, document, key-value, or other stores.

## Index Design

- Define an index for every query pattern.
- Avoid over-indexing: each index has a write cost.
- Document composite index order for multi-column queries.

## Migration Strategy

- Every schema change requires a migration strategy.
- Document forward and backward compatibility.
- Specify migration steps, ordering, and rollback approach.

## PII Identification

- Identify PII in every entity this story touches.
- Document classification level (e.g., sensitive, confidential).
- Ensure encryption-at-rest and access controls are addressed in security planning.
