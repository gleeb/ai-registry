# Sparring Patterns for Per-Story API Design

## Philosophy

- Challenge design decisions that affect API quality and consumer experience.
- Surface trade-offs so the user can make informed decisions.
- Challenge assumptions before they become costly to change.

## Challenge Categories

### Endpoint Granularity

- Is this endpoint doing too much? Could it be split?
- Does this endpoint combine create + update? Should they be separate?
- Would consumers typically need both [X] and [Y], or would separate endpoints reduce over-fetching?

### Consistency

- Path uses [camelCase] but spec says kebab-case — align?
- [resourceName] here vs [resource_name] there — which convention?
- This endpoint is verb-noun but others are noun-only — standardize?

### Error Handling Completeness

- What happens when [concurrent update / duplicate create / invalid state transition]?
- Do we need 409 Conflict for this scenario?
- Rate limiting (429) — documented for all endpoints?
- **No vague error handling** — "Returns appropriate errors" is DENIED. Specify codes and conditions.

### Auth Per Endpoint

- This endpoint is marked public — intentional given the data it exposes?
- Some endpoints have role requirements, others don't — document the default?
- **No missing auth** — Every endpoint must declare auth requirements.

### Pagination Needs

- This endpoint returns a collection — what's the pagination strategy?
- Nested lists in the response — paginated or bounded?

### Contract Compliance

- Does this endpoint's schema align with the {contract} contract?
- If schema contradicts a consumed contract, flag immediately.

### Over-Fetching / Under-Fetching

- This response includes [nested object] — always needed, or optional/expandable?
- Getting [resource] requires 3 calls — would a batch endpoint reduce round trips?
- List endpoint returns full objects — would a summary shape with optional detail fetch be better?

### Idempotency for Write Ops

- Can this create/update be retried? Is idempotency documented?

## Anti-Pleasing Patterns (DENIED)

- **Vague error handling** — Specify error codes and conditions.
- **Missing auth** — Every endpoint must declare auth requirements.
- **Deferred versioning** — Define versioning strategy within architecture constraints; do not defer to "later."
- **Scope creep** — Endpoints for other stories' ACs are out of scope.
