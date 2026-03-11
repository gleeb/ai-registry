# Data Architecture Template

## Purpose

Use this format when drafting or refining a Data Architecture specification. The data architecture document is the single source of truth for data models, schema design, database technology choices, access patterns, caching, lifecycle, migration, and integrity. It must be validated before implementation proceeds.

## Contract gates

- REQUIRE all 11 sections to be substantive before the data architecture is considered complete.
- REQUIRE database technology choice to include rationale and trade-offs — no unsubstantiated recommendations.
- REQUIRE every enumerated query pattern to map to an index or justify full scan.
- REQUIRE migration strategy with versioning, tooling, and rollback.
- DENY proceeding to implementation before user validates the data architecture.
- ALLOW provisional draft only when clearly marked `PROVISIONAL - NOT VALIDATED`.

---

## Template

### 1) Metadata

| Field | Value |
|-------|-------|
| Document Version | 0.1.0 |
| Last Updated | [date] |
| Author | [name] |
| Status | Draft / Review / Approved |
| PRD Reference | plan/prd.md (version/date) |
| System Architecture Reference | plan/system-architecture.md (version/date) |

---

### 2) Data Architecture Overview

**Storage Philosophy**

- [Primary storage approach: relational-first, document-first, polyglot persistence, etc.]
- [Consistency vs availability trade-offs: strong consistency where needed, eventual consistency where acceptable]
- [Key principles: e.g., single source of truth per entity, avoid dual-writes, explicit ownership]

**Key Decisions Summary**

- [2–4 bullet points capturing the most consequential data architecture choices]
- [Each decision should be traceable to rationale in subsequent sections]
- [Examples: "PostgreSQL for transactional core; Redis for session and hot-path cache"; "Event sourcing for order lifecycle; relational for catalog"]

---

### 3) Entity Model

**Entities**

| Entity | Description | Ownership | Lifecycle |
|--------|-------------|-----------|-----------|
| [Name] | [What it represents; bounded context] | [Which component/service owns writes] | [Creation → Update → Archival/Deletion] |
| [Name] | [What it represents; bounded context] | [Which component/service owns writes] | [Creation → Update → Archival/Deletion] |
| ... | ... | ... | ... |

**Relationships and Cardinality**

| From Entity | Relationship | To Entity | Cardinality | Notes |
|-------------|---------------|----------|-------------|-------|
| [A] | [relationship type] | [B] | [1:1, 1:N, N:M] | [Optional: cascade, soft-ref, etc.] |
| [A] | [relationship type] | [B] | [1:1, 1:N, N:M] | [Optional: cascade, soft-ref, etc.] |
| ... | ... | ... | ... | ... |

**Entity-Relationship Description (ERD)**

```
[Text-based or Mermaid diagram describing the entity model]

Example (Mermaid):
erDiagram
    User ||--o{ Order : places
    Order ||--|{ OrderItem : contains
    Product ||--o{ OrderItem : "ordered in"
    User {
        uuid id PK
        string email
        timestamp created_at
    }
    Order {
        uuid id PK
        uuid user_id FK
        string status
        timestamp created_at
    }
```

---

### 4) Schema Design

For each entity, document the schema. Use the structure below per entity.

#### Entity: [EntityName]

| Field | Type | Constraints | Index | Notes |
|-------|------|-------------|-------|-------|
| [field_name] | [type: uuid, string, int, timestamp, jsonb, etc.] | [NOT NULL, UNIQUE, FK, CHECK, DEFAULT] | [PK, unique, btree, partial] | [Optional: format, validation, PII flag] |
| [field_name] | [type] | [constraints] | [index] | [notes] |
| ... | ... | ... | ... | ... |

**Indexes**

| Index Name | Columns | Type | Purpose |
|------------|---------|------|---------|
| [idx_entity_field] | [column(s)] | [btree, hash, gin, gist] | [Query pattern this supports] |
| ... | ... | ... | ... |

**Notes**

- [Denormalization decisions, computed fields, triggers, etc.]
- [PII handling: encrypted at rest, masked in logs, etc.]

---

### 5) Database Technology

| Aspect | Choice | Rationale | Trade-offs |
|--------|--------|-----------|------------|
| Primary Store | [e.g., PostgreSQL 16] | [Why: ACID, JSON support, extensions, team expertise] | [What we give up: e.g., horizontal scale limits] |
| Cache | [e.g., Redis 7] or None | [Why: session, hot-path, or "not needed for current load"] | [What we give up] |
| Search | [e.g., Elasticsearch, pg_trgm] or None | [Why: full-text, faceted search, or "basic ILIKE sufficient"] | [What we give up] |
| Message Store | [e.g., same DB, Kafka, SQS] | [Why: event sourcing, audit, or out-of-scope] | [What we give up] |
| Other | [Graph DB, TimescaleDB, etc.] or N/A | [Why] | [What we give up] |

**Technology Decision Rationale**

- [Paragraph explaining why SQL vs NoSQL, single vs polyglot, managed vs self-hosted]
- [Reference to system architecture constraints if applicable]

---

### 6) Data Access Patterns

**Read Patterns**

| Pattern | Description | Entity(ies) | Query Type | Index Used | Cached? |
|---------|-------------|-------------|------------|-----------|---------|
| [e.g., List orders by user] | [What the user/API does] | [Order] | [SELECT with WHERE, JOIN] | [idx_order_user_id] | [Yes/No] |
| [e.g., Get product by ID] | [What the user/API does] | [Product] | [SELECT by PK] | [PK] | [Yes] |
| ... | ... | ... | ... | ... | ... |

**Write Patterns**

| Pattern | Description | Entity(ies) | Operation | Transaction? | Idempotency |
|---------|-------------|-------------|-----------|--------------|-------------|
| [e.g., Create order] | [What the user/API does] | [Order, OrderItem] | [INSERT] | [Yes: order + items atomic] | [Idempotency key] |
| [e.g., Update user profile] | [What the user/API does] | [User] | [UPDATE] | [No] | [N/A] |
| ... | ... | ... | ... | ... | ... |

**Query Patterns by Feature**

| Feature | Read Queries | Write Queries | Notes |
|---------|--------------|---------------|-------|
| [e.g., Order history] | List orders, get order detail | Create order, cancel order | [N+1 risk: prefetch items] |
| [e.g., User profile] | Get user, get user preferences | Update user, update preferences | [Single-entity, low complexity] |
| ... | ... | ... | ... |

---

### 7) Caching Strategy

**What We Cache**

| Cache Key Pattern | Data | TTL | Invalidation |
|-------------------|------|-----|--------------|
| [e.g., user:{id}] | User entity | 15 min | On user update; write-through or invalidate |
| [e.g., product:{id}] | Product entity | 1 hour | On product update |
| [e.g., session:{id}] | Session data | 24 hours | On logout or expiry |
| ... | ... | ... | ... |

**Cache Layer**

- [Technology: Redis, Memcached, application-level, etc.]
- [Location: co-located with app, dedicated cluster, etc.]
- [Serialization: JSON, MessagePack, etc.]

**Invalidation Approach**

- [Write-through vs write-behind vs cache-aside]
- [Event-based invalidation: what events trigger invalidation]
- [TTL-only vs explicit invalidation]

**What We Do NOT Cache**

- [List of data that must always be fresh: e.g., cart, checkout state]
- [Rationale for not caching]

---

### 8) Data Lifecycle

**Creation**

| Entity | Creation Trigger | Owner | Initial State |
|--------|------------------|-------|---------------|
| [Entity] | [API call, event, batch job] | [Service] | [Default values, status] |
| ... | ... | ... | ... |

**Update**

| Entity | Update Triggers | Concurrency | Versioning |
|--------|-----------------|-------------|------------|
| [Entity] | [User action, event, cron] | [Optimistic lock, last-write-wins, etc.] | [Version column, updated_at] |
| ... | ... | ... | ... |

**Archival**

| Entity | Archive Trigger | Archive Destination | Retention |
|--------|-----------------|---------------------|-----------|
| [Entity] | [Age, status change, manual] | [Cold storage, separate table] | [e.g., 7 years for compliance] |
| ... | ... | ... | ... |

**Deletion and Retention**

| Entity | Deletion Type | Retention Policy | Compliance |
|--------|---------------|------------------|------------|
| [Entity] | [Hard delete, soft delete] | [e.g., 90 days after soft delete] | [GDPR right to erasure, etc.] |
| ... | ... | ... | ... |

---

### 9) Migration Strategy

**Schema Versioning**

- [Approach: migration files, versioned schema, etc.]
- [Naming convention: e.g., V001__create_users.sql, V002__add_order_status.sql]

**Migration Tooling**

| Tool | Purpose | Notes |
|------|---------|-------|
| [e.g., Flyway, Liquibase, Alembic, custom] | [Schema migrations] | [How it runs: at deploy, manual, etc.] |
| ... | ... | ... |

**Rollback Strategy**

- [Forward-only vs reversible migrations]
- [What happens if migration fails: rollback script, manual intervention]
- [Data backfill: how to handle new columns, data transforms]

**Seed Data**

| Environment | Seed Content | Source |
|-------------|--------------|--------|
| Development | [Sample users, products, etc.] | [Fixtures, factories, SQL scripts] |
| Staging | [Production-like subset or anonymized copy] | [Dump, synthetic generator] |
| Test | [Minimal set for integration tests] | [Seeded by test harness] |

**Test Data Strategy**

- [How test data is created: factories, fixtures, database seeds]
- [Isolation: per-test DB, transactions, shared fixtures]
- [Sensitive data: never real PII in test data]

---

### 10) Data Integrity

**Transaction Boundaries**

| Operation | Scope | Isolation Level | Notes |
|-----------|-------|-----------------|-------|
| [e.g., Create order] | [Order + OrderItem in single transaction] | [Read committed, Serializable] | [Atomicity required] |
| [e.g., Update user] | [Single row] | [Read committed] | [No cross-entity] |
| ... | ... | ... | ... |

**Consistency Model**

- [Strong consistency: where and why]
- [Eventual consistency: where and why; what are the guarantees]
- [Read-your-writes: required or not]

**Constraints**

| Constraint Type | Where Applied | Notes |
|-----------------|---------------|-------|
| Foreign keys | [Order.user_id → User.id] | [Cascade on delete: restrict, cascade, set null] |
| Unique | [User.email, Order.idempotency_key] | [Prevent duplicates] |
| Check | [Order.status IN (...), Order.total >= 0] | [Business rules] |
| Not null | [Per schema section] | [Required fields] |

---

### 11) Data Security

**Encryption**

| Data | At Rest | In Transit | Notes |
|------|---------|------------|-------|
| [Database] | [TDE, disk encryption] | [TLS] | [Provider-managed or self-managed] |
| [PII columns] | [Column-level encryption if applicable] | N/A | [Keys in secrets manager] |
| ... | ... | ... | ... |

**Access Control**

- [Database user roles: read-only replicas, app user, migration user]
- [Row-level security (RLS) if applicable]
- [Principle of least privilege: what each role can do]

**PII Handling**

- [Which entities/fields contain PII]
- [Masking in logs, backups, and non-production]
- [Cross-reference: see plan/security.md for full PII and compliance treatment]

---

## Quality Checklist

- [ ] All 11 sections are present and substantive — no placeholders.
- [ ] Database technology choice includes rationale and trade-offs.
- [ ] Every entity has schema: fields, types, constraints, indexes.
- [ ] Every enumerated read pattern maps to an index or justifies full scan.
- [ ] Caching strategy specifies: what, TTL, invalidation — or explicitly states "no caching" with rationale.
- [ ] Data lifecycle covers: creation, update, archival, deletion, retention for each entity.
- [ ] Migration strategy includes: versioning, tooling, rollback, seed data.
- [ ] Data integrity specifies: transaction boundaries, consistency model, constraints.
- [ ] Data security covers: encryption, access control, PII — with cross-ref to security plan.
- [ ] Entity model includes relationships and cardinality (ERD or equivalent).
- [ ] No orphaned entities — every entity is used in at least one access pattern.
- [ ] Unresolved questions and dependencies on other planning agents are documented.
