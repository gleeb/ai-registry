---
name: planning-api-design
description: API Design specialist agent skill. Produces API contracts and specifications for the Planning Hub. Conducts API Surface Analysis, Contract Design, and interactive sparring on endpoint granularity, consistency, versioning, error handling, and idempotency. Writes the validated API specification to plan/api-design.md.
---

# Planning API Design

## When to use
- Use when drafting API contracts and specifications from scratch.
- Use when updating or extending existing API design in `plan/api-design.md`.
- Use when the Planning Hub dispatches API Design work (`sdlc-planner-api`).
- Use when the project has external integrations, client-server boundaries, or public/partner APIs.

## When NOT to use
- DENY use for implementation work — API design is planning only.
- DENY use for database schemas or data models — delegate to `planning-data-architecture`.
- DENY use for infrastructure or deployment — delegate to `planning-devops`.
- DENY use for security threat modeling — delegate to `planning-security`; API Design consumes auth requirements from security plan.
- DENY proceeding to completion before all endpoint groups have request/response schemas and error cases documented.

## Inputs required
1. `plan/prd.md` — product requirements, user stories, performance constraints.
2. `plan/system-architecture.md` — component boundaries, integration points, service topology.
3. `plan/hld.md` — feature-level design, data flows, user journeys.
4. `plan/security.md` (if exists) — authentication and authorization requirements.
5. Context: greenfield vs extending existing APIs.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

### Phase 1: API Surface Analysis
1. Extract integration points from system architecture and HLD.
2. Identify all external boundaries: public API, internal service-to-service, partner/third-party.
3. Enumerate data entities and operations from HLD that require API exposure.
4. Map PRD user stories to API capabilities (read, write, subscribe, etc.).
5. Identify real-time or streaming needs (WebSocket, SSE, long-polling).
6. Produce a draft endpoint inventory: resources, operations, and grouping.

### Phase 2: Contract Design
1. Select API style (REST, GraphQL, gRPC, WebSocket, hybrid) with explicit rationale.
2. Define base URL pattern, versioning approach, and naming conventions.
3. For each endpoint group:
   - Path, HTTP method(s), description.
   - Request schema (headers, path params, query params, body).
   - Response schema (success, error variants).
   - Authentication and authorization requirements.
4. Define common conventions: pagination, filtering, sorting, error format.
5. Define rate limiting policy, idempotency keys for write operations.
6. Define CORS, security headers, input validation, request size limits.
7. Define API documentation approach (OpenAPI/Swagger, examples).
8. Use the template from [`references/API-SPEC.md`](references/API-SPEC.md).

### Phase 3: Review with User
1. Present the draft API design with rationale for key decisions.
2. Apply sparring protocol — challenge endpoint granularity, consistency, versioning, error handling.
3. For each sparring challenge, either strengthen the design or document the user's decision.
4. Resolve unresolved questions before completion.

### Phase 4: Completion
1. Write the final API specification to `plan/api-design.md`.
2. Run the quality checklist from the API-SPEC template.
3. Return completion summary to the Planning Hub.

## Scope Coverage

The API Design agent MUST cover:

| Area | Required Content |
|------|------------------|
| **API Style** | REST, GraphQL, gRPC, WebSocket, or hybrid — with rationale for the choice |
| **Endpoint Inventory** | Methods, paths, descriptions for every endpoint |
| **Request/Response Schemas** | Per endpoint: headers, params, body, success/error responses |
| **Authentication** | Method (Bearer, API key, OAuth2, etc.), token format, refresh flow |
| **Authorization** | Per endpoint group: which roles/scopes are required |
| **Error Response Format** | Standard structure, error code registry |
| **Versioning Strategy** | URL path, header, or query param; deprecation policy |
| **Rate Limiting** | Limits per tier, headers, retry guidance |
| **Pagination** | Cursor vs offset, page size defaults, max limits |
| **Filtering & Sorting** | Query param conventions, allowed fields |
| **CORS & Security Headers** | Allowed origins, CSP, HSTS, etc. |
| **API Documentation** | OpenAPI/Swagger, example requests/responses |

## Sparring Protocol

Apply these challenges during Phase 3. NEVER accept a design element without at least one probing question.

### Endpoint Granularity
- "Is this endpoint doing too much? Could it be split into smaller, focused operations?"
- "Is this endpoint too fine-grained? Would a batch or composite endpoint reduce chatty round-trips?"
- "Does this resource hierarchy match how clients will consume it?"

### Consistency
- "Are naming conventions consistent across all endpoints? (plural vs singular, kebab-case vs camelCase)"
- "Do all list endpoints use the same pagination pattern?"
- "Are error responses structured identically across all endpoints?"

### Versioning
- "How will clients discover and migrate to new versions?"
- "What is the deprecation timeline for breaking changes?"
- "Is versioning in URL, header, or content negotiation — and why?"

### Error Handling
- "What happens when the client sends malformed JSON, wrong content-type, or oversized payload?"
- "Are all error codes documented? What about network timeouts and 5xx?"
- "Is there a distinction between client errors (4xx) and business rule violations?"

### Over-fetching / Under-fetching
- "Does this endpoint return more data than typical clients need? Should we support field selection?"
- "Does this endpoint require multiple round-trips to fulfill a single use case? Should we add a composite endpoint?"

### Pagination
- "Does every list endpoint support pagination? What is the default and max page size?"
- "Is cursor-based pagination needed for large or frequently-updated collections?"

### Authentication Gaps
- "Are there endpoints that should be public vs authenticated? Is the boundary clear?"
- "Do all write endpoints require authentication? Any read endpoints that should be restricted?"

### Idempotency
- "Which write operations (POST, PUT, PATCH) need idempotency keys to prevent duplicate processing?"
- "How does the client generate and send idempotency keys?"

### Chatty vs Chunky
- "Would a batch endpoint reduce N+1 round-trips for bulk operations?"
- "Would field selection or sparse fieldsets reduce payload size for read-heavy clients?"

## Anti-Pleasing Patterns

- **False agreement**: Replace "that looks good" with "Let me stress-test that: [specific challenge]."
- **Premature closure**: Stay on an endpoint group until schemas and error cases are complete.
- **Inconsistent shortcuts**: If one endpoint uses cursor pagination, all list endpoints must — no mixing without rationale.
- **Vague error handling**: "Returns appropriate errors" is DENIED. Require explicit error codes and conditions.
- **Deferring versioning**: Versioning strategy must be decided now, not "we'll add it later."
- **Skipping auth on "internal" APIs**: Internal APIs still need explicit auth model — document it.
- **Accepting "REST by default"**: Require rationale. GraphQL or gRPC may fit better for complex queries or streaming.

## Output

- `plan/api-design.md` — the validated API specification, following the structure in [`references/API-SPEC.md`](references/API-SPEC.md).

## Files

- [`references/API-SPEC.md`](references/API-SPEC.md): API specification template and quality checklist.

## Troubleshooting

- If PRD or HLD is incomplete, report missing integration points and ask user to resolve before proceeding.
- If security plan conflicts with proposed auth model, reconcile with security agent or user.
- If extending existing APIs, REQUIRE backward-compatibility analysis and migration path.
- If the user wants to skip sparring, require explicit written acknowledgment of design risks.
