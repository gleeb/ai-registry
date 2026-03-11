---
name: planning-api-design
description: Per-story API Design specialist agent. Use when the Planning Hub dispatches API design work for a specific user story in Phase 3. Conducts API surface analysis and contract design scoped to a single story. Reads story.md, system-architecture.md, consumed contracts, and hld.md. Writes to plan/user-stories/US-NNN-name/api.md.
---

# Planning API Design (Per-Story)

## When to use
- Use when the Planning Hub dispatches API Design work for a specific user story (`sdlc-planner-api`).
- Use when updating or revising an existing per-story API design.
- Use when the story's `candidate_domains` includes `api`.

## When NOT to use
- DENY use for implementation work — API design is planning only.
- DENY use for database schemas — delegate to `planning-data-architecture`.
- DENY use for security threat modeling — delegate to `planning-security`.
- DENY use for modifying other stories' API designs.
- DENY proceeding before endpoint schemas and error cases are documented.

## Inputs required
1. `plan/user-stories/US-NNN-name/story.md` — scope, acceptance criteria, dependency manifest.
2. `plan/system-architecture.md` — integration points, API gateway patterns.
3. Consumed contracts from `plan/contracts/` (especially error format, auth model, shared DTOs).
4. `plan/user-stories/US-NNN-name/hld.md` (recommended) — component structure for endpoint mapping.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

### Phase 1: API Surface Analysis (Story-Scoped)

1. Read story.md — extract acceptance criteria involving API interactions.
2. Read hld.md (if available) — extract components that expose or consume endpoints.
3. Read consumed contracts — identify shared DTOs, error format, auth model.
4. Enumerate endpoints needed for this story's acceptance criteria.
5. Map each endpoint to an acceptance criterion.

### Phase 2: Contract Design

1. Select API style (REST, GraphQL, gRPC, etc.) consistent with architecture.
2. For each endpoint:
   - Path, HTTP method, description.
   - Request schema (headers, path params, query params, body).
   - Response schema (success, error variants).
   - Authentication and authorization requirements.
3. Use consumed contract definitions as authoritative for shared schemas.
4. If this story defines an API contract consumed by other stories, document it clearly.
5. Define error handling aligned with the error format contract (if exists).
6. Use the template from [`references/API-SPEC.md`](references/API-SPEC.md).

### Phase 3: Review with User

1. Present the per-story API design with rationale.
2. Apply sparring protocol — challenge granularity, consistency, error handling.
3. Iterate until user approves.

### Phase 4: Completion

1. Write the final API specification to `plan/user-stories/US-NNN-name/api.md`.
2. Return completion summary to the Planning Hub.

## Sparring Protocol

- "Is this endpoint doing too much? Could it be split?"
- "Does this endpoint's schema align with the {contract} contract?"
- "What error codes does this endpoint return? Are all failure modes documented?"
- "Does authentication align with the auth-model contract?"
- "How does this endpoint interact with the endpoints from dependent stories?"
- "Is pagination needed for this list endpoint? What's the expected data volume?"

## Anti-Pleasing Patterns

- **Vague error handling**: "Returns appropriate errors" is DENIED. Specify error codes and conditions.
- **Missing auth**: Every endpoint must declare its auth requirements.
- **Contract violations**: If an endpoint's schema contradicts a consumed contract, flag immediately.
- **Inconsistent patterns**: All endpoints in this story must use the same pagination, error format, and naming conventions.
- **Scope creep**: Endpoints for other stories' acceptance criteria are out of scope.

## Output

- `plan/user-stories/US-NNN-name/api.md` — the per-story API specification.

## Files

- [`references/API-SPEC.md`](references/API-SPEC.md): API specification template and quality checklist.

## Troubleshooting

- If story.md or architecture is missing, report the blocker.
- If consumed contracts are missing or incomplete, flag for the Story Decomposer.
- If the API design conflicts with the story's HLD, reconcile before completing.
