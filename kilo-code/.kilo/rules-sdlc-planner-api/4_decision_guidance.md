# Decision Guidance for Per-Story API Design

## API Style Selection

- Select API style (REST, GraphQL, gRPC) **within architecture constraints**.
- Architecture defines system boundaries and integration points — do not deviate.

## Batch Endpoints

- Use batch endpoints when: the flow requires many sequential calls, and a single batch would reduce latency and round trips.
- Avoid when: the story's ACs do not require batch semantics; prefer standard CRUD unless justified.

## Cursor vs Offset Pagination

- **Cursor**: Prefer when list order is stable and clients need to page through large datasets without skipping/duplicates.
- **Offset**: Acceptable when architecture or existing contracts use it; ensure consistency with consumed contracts.
- Follow architecture patterns — if contracts specify one, use it.

## When to Flag Contract Issues

- Schema contradicts a consumed contract — flag immediately, do not proceed without resolution.
- Consumed contracts missing or incomplete — flag for Story Decomposer; document assumptions.
- Error format in design does not match contract — flag and align.

## When to Escalate to Hub

- Story scope is unclear or ACs conflict.
- Architecture does not define integration points needed for this story.
- Contract conflicts require cross-story or cross-domain resolution.
- HLD suggests endpoints that conflict with story ACs — escalate for reconciliation.

## Boundaries

- **ALLOW**: Endpoint design, request/response contracts, error handling, versioning (per architecture), auth, idempotency.
- **DENY**: Implementation (no code, no framework selection), data schema design (consume from data-architecture), scope beyond this story.
