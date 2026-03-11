# Shared Contracts Registry Specification

## Purpose

The contracts registry (`plan/contracts/`) holds shared interface definitions that span multiple user stories. A contract defines a data shape, API contract, authentication model, or other interface that one story owns and other stories consume.

Contracts enable **mechanical impact analysis**: when a contract changes, the system knows exactly which stories must be re-validated.

## Contract File Format

Each file in `plan/contracts/` follows this structure:

```markdown
# Contract: {contract-name}

## Owner
- story: US-NNN
- rationale: Why this story owns the contract definition

## Consumers
- US-NNN-feature-a (uses {specific aspect})
- US-NNN-feature-b (uses {specific aspect})

## Contract Definition

### Data Shape / API Contract / Auth Model
{The actual contract definition — fields, types, constraints, endpoints, etc.}

### Invariants
{Rules that must always hold — e.g., "email must be unique", "auth token expires after 1h"}

### Versioning
- current_version: 1
- breaking_change_policy: {What constitutes a breaking change}
```

## Naming Convention

Contract files use kebab-case names that describe the shared interface:

- `auth-model.md` — authentication and authorization model
- `product-entity.md` — shared product data shape
- `api-error-format.md` — standardized error response shape
- `user-profile.md` — shared user profile data model

## Ownership Rules

1. Every contract has exactly ONE owner story — the story that first defines it.
2. The owner story is responsible for the contract's accuracy and completeness.
3. Consumer stories depend on the contract but do not modify it.
4. If a consumer needs the contract changed, the owner story must be re-planned first.

## Change Propagation

When a contract changes:

1. The **owner story** is re-planned to reflect the change.
2. The **Plan Validator** runs impact analysis tracing all consumer stories.
3. Each **consumer story** is re-validated (and re-planned if the change breaks assumptions).
4. **Cross-cutting concerns** (security overview, testing strategy) are re-validated.

## Creating Contracts

The **Story Decomposer** (Phase 2) identifies contracts during story decomposition:

1. Scan story outlines for shared data shapes, API contracts, and auth models.
2. When two or more stories reference the same interface, extract it as a contract.
3. Assign ownership to the story that defines the interface (typically the earlier story in execution order).
4. Create the contract file in `plan/contracts/`.
5. Update each story's dependency manifest to reference the contract.

## Consuming Contracts

Planning agents in Phase 3 (HLD, API Design, Data Architecture, Security) must:

1. Read all contracts listed in the story's `consumes_contracts` dependency manifest field.
2. Use contract definitions as authoritative — do not redefine shared interfaces locally.
3. If a local design conflicts with a consumed contract, flag it as a blocker for the Hub to resolve.
