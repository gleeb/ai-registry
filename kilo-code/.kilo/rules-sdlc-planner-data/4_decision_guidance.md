# Decision Guidance

## Normalization Level

| Situation | Guidance |
|-----------|----------|
| High read volume, few writes | Prefer denormalization for read performance. |
| Strong consistency requirements | Prefer normalization; document consistency strategy. |
| Cross-service queries | Avoid joins across services; use eventual consistency or materialized views. |
| Audit/compliance needs | Normalize audit trail; keep transactional data as needed for queries. |

## Storage Technology (Within Architecture Constraints)

| Entity Type | Typical Choice | When to Deviate |
|-------------|----------------|-----------------|
| Relational data with joins | Relational DB | Architecture explicitly allows document store. |
| Flexible schema, document-shaped | Document store | Strong transactional requirements. |
| Key-value lookups | Key-value store | Complex query patterns. |
| Time-series, events | Time-series or event store | Architecture specifies otherwise. |

## Caching Strategy

| Pattern | Use When |
|---------|----------|
| Cache-aside | Read-heavy, acceptable stale reads. |
| Write-through | Strong read consistency needed. |
| No cache | Write-heavy or low read volume. |
| Distributed cache | Multiple service instances need shared cache. |

## When to Flag Contract Issues

- Consumed contract is missing fields this story needs.
- Consumed contract has incorrect types or constraints.
- Contract version mismatch between provider and consumer.
- This story needs to extend a contract — escalate for coordination.

## When to Escalate

- Storage choice conflicts with architecture.
- Migration strategy cannot meet downtime requirements.
- PII handling requires security or compliance review.
- Cross-story data dependencies not covered by contracts.
- Contract ownership unclear or disputed.
