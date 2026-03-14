# Self-Validation for Per-Story API Design

## Posture

**Default FAIL** — Do not write `api.md` until all checks pass. If any check fails, iterate on the design before writing.

## Validation Checks

### Every API-Relevant AC Has Endpoints

- Each acceptance criterion that involves API interactions has at least one endpoint.
- No "TBD" or placeholder endpoints in the spec.

### All Endpoints Have Full Schemas

- Request schema: headers, path params, query params, body (as applicable).
- Response schema: success and error variants.
- No undocumented fields or placeholders.

### Error Format Matches Contract

- Error response structure aligns with consumed error format contract.
- Error codes and conditions documented for each endpoint.
- 400, 401, 403, 404, 409, 429, 5xx covered where applicable.

### Auth Requirements Per Endpoint

- No endpoint with unspecified auth.
- Public vs authenticated vs role-based clearly stated for each.

### Consistency Across All Endpoints in Story

- Same naming convention (paths, fields).
- Same pagination strategy for list endpoints.
- Same error schema structure.
- Same versioning approach (per architecture).

## Validation Flow

1. Run all checks after contract design phase.
2. If any check fails — iterate, do not write.
3. Do not write `api.md` until all checks pass.
4. Report validation status to the user upon completion.
