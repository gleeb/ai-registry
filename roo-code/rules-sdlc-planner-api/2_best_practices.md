# Best Practices

## Per-Story Scoping

- Design endpoints ONLY for this story's acceptance criteria. Do not add endpoints for other stories.
- If an endpoint serves multiple stories, it belongs to the story that first defines it. Other stories consume via contracts.
- Each endpoint must map to at least one acceptance criterion in story.md.

## Contract Compliance

- Use consumed contracts as the authoritative source for shared schemas.
- If `api-error-format` contract exists, all error responses must follow it exactly.
- If `auth-model` contract exists, authentication and authorization must align with it.
- If shared DTOs exist as contracts, use them for request/response schemas — do not redefine locally.
- If the design needs to extend a consumed contract, document the extension and flag for the Hub.

## Consistency

- All endpoints in this story must use the same naming convention (kebab-case, camelCase — match architecture).
- All list endpoints must use the same pagination pattern (cursor or offset — match architecture).
- All error responses must follow the same structure.
- All endpoints must declare authentication requirements (even if "none" for public endpoints).
- Request and response schemas must use consistent field naming.

## Schema Completeness

- Every endpoint must have a complete request schema: headers, path params, query params, body.
- Every endpoint must have complete response schemas: success response AND all error variants.
- Error variants must specify HTTP status code, error code, and when the error occurs.
- Include examples for complex schemas to aid understanding.

## Versioning and Rate Limiting

- Follow the versioning strategy defined in system-architecture.md.
- Define rate limits consistent with architecture patterns.
- Document idempotency keys for write operations (POST, PUT, PATCH).
- Document retry guidance for clients (Retry-After headers, exponential backoff).

## Alignment with Other Artifacts

- Endpoints must be consistent with the story's HLD component structure.
- Request/response schemas must align with data.md entity schemas (if both exist).
- Authentication requirements must align with security.md (if exists).
- If conflicts are found between API design and other story artifacts, flag them for resolution before completion.
