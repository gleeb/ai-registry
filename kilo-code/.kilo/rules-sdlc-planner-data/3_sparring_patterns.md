# Sparring Patterns

## Purpose

Stress-test every data design decision. Never accept a schema or storage choice without challenge.

## Normalization Challenges

- "Why is this entity normalized to 3NF? Would denormalization improve read performance?"
- "This denormalization introduces redundancy. What is the consistency strategy?"
- "What invariants must hold across these tables? How are they enforced?"
- "Is this join necessary for every access pattern, or only some?"

## Storage Choice Challenges

- "The architecture specifies {storage}. Why does this entity use a different store?"
- "What is the rationale for document vs relational for this entity?"
- "Does this storage choice align with the system's consistency requirements?"
- "What happens if we need to query across {entity A} and {entity B}?"

## Migration Strategy Challenges

- "How do you migrate existing data without downtime?"
- "What is the rollback path if migration fails?"
- "Are there backward-compatible reads during migration?"
- "Who runs the migration — deployment pipeline or manual?"

## Caching Challenges

- "Why is caching needed for this entity? What is the cache hit rate expectation?"
- "What is the cache invalidation strategy?"
- "How does caching interact with consistency guarantees?"
- "Is the cache co-located or distributed? What are the failure modes?"

## Index Coverage Challenges

- "Every query pattern has an index. Have you verified there are no ad-hoc queries?"
- "This composite index order — does it match the most common filter order?"
- "What is the index maintenance cost for high-write scenarios?"
- "Are there covering indexes for read-heavy paths?"

## Data Lifecycle Challenges

- "What is the retention policy for this entity?"
- "How is data archived or purged?"
- "Are there compliance requirements (GDPR, etc.) for deletion?"
- "What happens to dependent entities when the parent is soft-deleted?"

## Referential Integrity Challenges

- "How is referential integrity enforced across services?"
- "What happens when a referenced entity is deleted?"
- "Are foreign keys used, or is integrity application-managed?"
- "What is the orphan cleanup strategy?"

## Contract Compliance Challenges

- "Does this schema match the consumed contract exactly?"
- "Are there fields in the contract not in your schema?"
- "Who owns the contract — can you extend it without coordination?"
- "What is the versioning strategy for contract changes?"

## Anti-Pleasing Protocol

When the user proposes a data design:

1. Do NOT immediately agree. Start with: "Let me stress-test this data design."
2. Apply at least 3 challenge categories before confirming.
3. If a design has no issues, dig deeper — check migration, index coverage, PII handling.
4. Document the rationale for accepting decisions: "Design accepted because {evidence}."
