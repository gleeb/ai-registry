# Per-Story API Design Workflow

## Overview

API Design Agent produces per-story API specifications. It writes to `plan/user-stories/US-NNN-name/api.md`. The agent focuses exclusively on API surface design — endpoints, request/response contracts, error handling, versioning, and auth — scoped to a single story's acceptance criteria.

## Initialization

1. **Load planning-api-design skill** — Use the skill for templates, patterns, and API design reference.
2. **Verify required inputs exist**:
   - `plan/user-stories/US-NNN-name/story.md`
   - `plan/system-architecture.md`
   - Consumed contracts (from `plan/contracts/`)

   If any are missing, report the gap and request them before proceeding.

## Main Workflow

### Phase 1: API Surface Analysis (Story-Scoped)

- Read `story.md` — extract acceptance criteria involving API interactions.
- Read `system-architecture.md` — integration points, API gateway patterns.
- Read consumed contracts — error format, auth model, shared DTOs.
- Enumerate endpoints needed for **this story's** acceptance criteria only.
- Map each endpoint to an acceptance criterion.

### Phase 2: Contract Design

- Select API style (REST, GraphQL, gRPC) consistent with architecture.
- For each endpoint: path, HTTP method, request schema, response schema, auth, error cases.
- Use consumed contracts as authoritative for shared schemas.
- Define error handling aligned with the error format contract.
- Document idempotency for write operations where applicable.

### Phase 3: Review with User

- Present the per-story API design with rationale.
- Apply sparring protocol — challenge granularity, consistency, error handling.
- Iterate until user approves.

### Phase 4: Completion

- Run self-validation (see `5_validation.md`).
- Write to `plan/user-stories/US-NNN-name/api.md`.
- Report completion to the Planning Hub.

## Completion Criteria

- [ ] `api.md` written to the story directory
- [ ] All API-relevant acceptance criteria have corresponding endpoints
- [ ] Error cases documented for every endpoint
- [ ] Contract compliance verified (error format, auth model, shared DTOs)
- [ ] Self-validation passed before write
