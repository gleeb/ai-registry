# API Specification Template

## Purpose

Use this format when drafting or refining an API design document. The API spec is the contract between API producers and consumers. It must be complete, consistent, and implementable before development begins.

## Contract Gates

- REQUIRE all sections to be substantive before the API spec is considered complete.
- REQUIRE every endpoint to have request schema, response schema, and documented error cases.
- DENY placeholders such as "TBD" or "to be determined" — document the decision or mark as deferred with rationale.
- DENY inconsistent naming, pagination, or error formats across endpoints without explicit rationale.
- ALLOW provisional draft only when clearly marked `PROVISIONAL - NOT VALIDATED`.

---

## 1. Metadata

| Field | Value |
|-------|-------|
| Document Version | 0.1.0 |
| Last Updated | [date] |
| API Owner | [name or team] |
| Status | Draft / Review / Approved |
| Related Plans | plan/prd.md, plan/system-architecture.md, plan/hld.md, plan/security.md |

---

## 2. API Overview

### 2.1 API Style

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| Primary style | REST / GraphQL / gRPC / WebSocket / Hybrid | [Why this style fits the use case: query complexity, real-time needs, client ecosystem, etc.] |
| Alternative considered | [e.g., GraphQL] | [Why it was not chosen] |

### 2.2 Base URL Pattern

| Environment | Base URL |
|-------------|----------|
| Production | `https://api.{domain}/v1` |
| Staging | `https://api-staging.{domain}/v1` |
| Local/Dev | `http://localhost:{port}/v1` |

### 2.3 Versioning Approach

- **Method**: URL path / Header / Query param / Content negotiation
- **Format**: `v1`, `v2` (semantic major versions)
- **When to version**: Breaking changes only (see Section 8)

---

## 3. Authentication

### 3.1 Method

| Method | Use Case | Details |
|--------|----------|---------|
| Bearer JWT | User-authenticated requests | Access token in `Authorization: Bearer <token>` |
| API Key | Service-to-service, machine clients | `X-API-Key: <key>` or `Authorization: ApiKey <key>` |
| OAuth2 Client Credentials | Server-to-server | Token endpoint, client_id, client_secret |

### 3.2 Token Format

- **Access token**: JWT with claims: `sub`, `exp`, `iat`, `scope` (or custom claims)
- **Token lifetime**: [e.g., 15 minutes]
- **Refresh flow**: [Describe refresh token endpoint and flow, or "Not applicable"]

### 3.3 Token Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/token` | POST | Exchange credentials for access token |
| `/auth/refresh` | POST | Exchange refresh token for new access token |
| `/auth/revoke` | POST | Revoke token(s) |

---

## 4. Common Conventions

### 4.1 Naming

| Convention | Rule | Example |
|------------|------|---------|
| Resource names | Plural nouns, kebab-case | `/users`, `/order-items` |
| Path parameters | Singular, kebab-case | `/users/{user-id}` |
| Query parameters | camelCase or snake_case (pick one) | `?pageSize=20` or `?page_size=20` |
| JSON fields | camelCase | `{ "firstName": "Jane" }` |
| Headers | Pascal-Case or kebab-case | `X-Request-ID`, `Content-Type` |

### 4.2 Pagination

| Aspect | Convention |
|--------|-------------|
| Type | Cursor-based / Offset-based |
| Query params | `cursor` + `limit` OR `page` + `pageSize` |
| Default page size | [e.g., 20] |
| Max page size | [e.g., 100] |
| Response format | `{ "data": [...], "nextCursor": "..." }` or `{ "data": [...], "total": N, "page": 1 }` |

### 4.3 Filtering

| Aspect | Convention |
|--------|-------------|
| Query param pattern | `filter[field]=value` or `field=value` |
| Operators | `eq`, `neq`, `gt`, `gte`, `lt`, `lte`, `in`, `contains` |
| Example | `?filter[status]=active&filter[createdAt][gte]=2024-01-01` |

### 4.4 Sorting

| Aspect | Convention |
|--------|-------------|
| Query param | `sort` |
| Format | `sort=field1,-field2` (minus for descending) |
| Allowed fields | Document per endpoint |

### 4.5 Error Format

All error responses use this structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable message",
    "details": [
      { "field": "email", "reason": "Invalid format" }
    ],
    "requestId": "uuid",
    "timestamp": "ISO8601"
  }
}
```

---

## 5. Endpoint Groups

Group endpoints by resource or domain. For each group, document:

- Path prefix
- Auth requirements
- Endpoints with method, path, description, request schema, response schema, error cases

### 5.1 [Resource/Domain Name] (e.g., Users)

**Path prefix**: `/users`  
**Auth**: Bearer JWT required; scope: `users:read`, `users:write`

| Method | Path | Description |
|--------|------|-------------|
| GET | `/users` | List users with pagination and filtering |
| GET | `/users/{user-id}` | Get user by ID |
| POST | `/users` | Create user |
| PATCH | `/users/{user-id}` | Update user (partial) |
| DELETE | `/users/{user-id}` | Soft-delete user |

#### GET /users

**Description**: List users with optional filtering and sorting.

**Request**:
- Headers: `Authorization: Bearer <token>`, `Accept: application/json`
- Query: `cursor`, `limit`, `filter[status]`, `filter[role]`, `sort`

**Response (200)**:
```json
{
  "data": [
    {
      "id": "uuid",
      "email": "string",
      "firstName": "string",
      "lastName": "string",
      "status": "active|inactive|pending",
      "createdAt": "ISO8601"
    }
  ],
  "nextCursor": "string|null",
  "hasMore": true
}
```

**Error cases**:
| Code | HTTP | Condition |
|------|------|-----------|
| UNAUTHORIZED | 401 | Missing or invalid token |
| FORBIDDEN | 403 | Insufficient scope |
| INVALID_FILTER | 400 | Invalid filter field or value |

#### GET /users/{user-id}

**Description**: Get a single user by ID.

**Request**:
- Path: `user-id` (UUID)
- Headers: `Authorization: Bearer <token>`

**Response (200)**:
```json
{
  "id": "uuid",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "status": "string",
  "createdAt": "ISO8601",
  "updatedAt": "ISO8601"
}
```

**Error cases**:
| Code | HTTP | Condition |
|------|------|-----------|
| UNAUTHORIZED | 401 | Missing or invalid token |
| FORBIDDEN | 403 | Insufficient scope |
| NOT_FOUND | 404 | User does not exist |

#### POST /users

**Description**: Create a new user. Idempotency key supported.

**Request**:
- Headers: `Authorization: Bearer <token>`, `Idempotency-Key: <key>` (optional)
- Body:
```json
{
  "email": "string (required)",
  "firstName": "string (required)",
  "lastName": "string (required)",
  "password": "string (required, min 8 chars)"
}
```

**Response (201)**:
```json
{
  "id": "uuid",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "status": "pending",
  "createdAt": "ISO8601"
}
```

**Error cases**:
| Code | HTTP | Condition |
|------|------|-----------|
| UNAUTHORIZED | 401 | Missing or invalid token |
| FORBIDDEN | 403 | Insufficient scope |
| VALIDATION_ERROR | 400 | Invalid or missing fields |
| CONFLICT | 409 | Email already exists |
| IDEMPOTENCY_CONFLICT | 409 | Idempotency key reused with different body |

---

### 5.2 [Next Resource Group]

Repeat the same structure for each endpoint group.

---

## 6. Error Handling

### 6.1 Standard Error Response Format

```json
{
  "error": {
    "code": "string",
    "message": "string",
    "details": [],
    "requestId": "string",
    "timestamp": "string"
  }
}
```

### 6.2 Error Code Registry

| Code | HTTP | Description |
|------|------|-------------|
| UNAUTHORIZED | 401 | Missing, expired, or invalid authentication |
| FORBIDDEN | 403 | Authenticated but not authorized for this resource |
| NOT_FOUND | 404 | Resource does not exist |
| VALIDATION_ERROR | 400 | Request body or params invalid |
| CONFLICT | 409 | Resource state conflict (e.g., duplicate) |
| RATE_LIMIT_EXCEEDED | 429 | Too many requests |
| INTERNAL_ERROR | 500 | Unexpected server error |
| SERVICE_UNAVAILABLE | 503 | Temporary outage |
| [Add project-specific codes] | | |

### 6.3 HTTP Status Mapping

| Scenario | HTTP | Error Code |
|----------|------|------------|
| Success | 200, 201, 204 | — |
| Bad request (malformed) | 400 | VALIDATION_ERROR |
| Unauthenticated | 401 | UNAUTHORIZED |
| Insufficient permissions | 403 | FORBIDDEN |
| Resource not found | 404 | NOT_FOUND |
| Method not allowed | 405 | METHOD_NOT_ALLOWED |
| Rate limited | 429 | RATE_LIMIT_EXCEEDED |
| Server error | 500 | INTERNAL_ERROR |

---

## 7. Rate Limiting

### 7.1 Limits

| Tier | Limit | Window |
|------|-------|--------|
| Anonymous | 10 req | per minute |
| Authenticated | 100 req | per minute |
| Premium | 1000 req | per minute |

### 7.2 Headers

| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Max requests per window |
| `X-RateLimit-Remaining` | Remaining requests in current window |
| `X-RateLimit-Reset` | Unix timestamp when window resets |
| `Retry-After` | Seconds to wait (when 429) |

### 7.3 Retry Guidance

- On 429: Wait `Retry-After` seconds, then retry with exponential backoff.
- On 5xx: Retry with exponential backoff; use idempotency keys for writes.

---

## 8. Versioning Strategy

### 8.1 How Versions Are Indicated

- **Location**: URL path (e.g., `/v1/users`)
- **Default**: Latest stable version when no version specified

### 8.2 Deprecation Policy

| Phase | Duration | Action |
|-------|----------|--------|
| Deprecation announced | 6 months | `Deprecation` header, docs update |
| Sunset | 12 months | Endpoint returns 410 Gone |
| Removal | After sunset | Endpoint removed |

### 8.3 Breaking vs Non-Breaking Changes

- **Non-breaking**: Add optional fields, add endpoints, add enum values (if clients ignore unknown)
- **Breaking**: Remove fields, change types, remove endpoints, change error codes → requires new version

---

## 9. WebSocket / Real-time Contracts (if applicable)

### 9.1 Connection

| Aspect | Specification |
|--------|---------------|
| URL | `wss://api.{domain}/v1/ws` |
| Auth | Query param `token` or first message with auth payload |
| Heartbeat | Client sends ping every 30s; server responds with pong |

### 9.2 Message Format

```json
{
  "type": "event|request|response",
  "id": "optional-correlation-id",
  "payload": {}
}
```

### 9.3 Events

| Event | Description | Payload |
|-------|-------------|---------|
| `user.updated` | User profile changed | `{ "userId": "...", "changes": [...] }` |
| `order.status_changed` | Order status updated | `{ "orderId": "...", "status": "..." }` |

---

## 10. API Security

### 10.1 CORS

| Aspect | Configuration |
|-------|---------------|
| Allowed origins | `https://app.{domain}`, `https://admin.{domain}` (no wildcard in production) |
| Allowed methods | GET, POST, PUT, PATCH, DELETE, OPTIONS |
| Allowed headers | Authorization, Content-Type, X-Request-ID, Idempotency-Key |
| Max age | 86400 |

### 10.2 Security Headers

| Header | Value |
|--------|-------|
| Strict-Transport-Security | max-age=31536000; includeSubDomains |
| X-Content-Type-Options | nosniff |
| X-Frame-Options | DENY |
| Content-Security-Policy | [Define as needed] |

### 10.3 Input Validation

- **Request size limit**: 1 MB for JSON bodies
- **Content-Type**: Require `application/json` for POST/PUT/PATCH
- **Path/query params**: Validate types, lengths, allowed values per endpoint

### 10.4 Request Size Limits

| Endpoint type | Limit |
|---------------|-------|
| Standard | 1 MB |
| File upload | [e.g., 10 MB] |

---

## 11. Documentation Approach

### 11.1 OpenAPI / Swagger

- **Format**: OpenAPI 3.0
- **Location**: `/openapi.json` or `/docs/openapi.json`
- **Hosting**: Static file or generated at build time

### 11.2 Examples

- Provide at least one request/response example per endpoint in the OpenAPI spec.
- Provide a Postman/Insomnia collection for manual testing.
- Document common flows (e.g., "Create user → Verify email → Login") in a separate examples doc.

### 11.3 Developer Portal (if applicable)

- API keys, sandbox access, SDKs
- Changelog and version history
- Status page link

---

## Quality Checklist

Before marking the API spec complete, verify:

- [ ] Every endpoint has a documented path, method, and description
- [ ] Every endpoint has request schema (headers, params, body as applicable)
- [ ] Every endpoint has success response schema
- [ ] Every endpoint has documented error cases with codes and HTTP status
- [ ] Naming conventions are consistent across all endpoints
- [ ] All list endpoints support pagination
- [ ] Pagination format is consistent (cursor or offset, same param names)
- [ ] Filtering and sorting conventions are defined and applied consistently
- [ ] Authentication and authorization are specified per endpoint or group
- [ ] Write operations (POST, PUT, PATCH) that need idempotency have it documented
- [ ] Error response format and error code registry are complete
- [ ] Rate limiting policy is defined with headers and retry guidance
- [ ] Versioning strategy and deprecation policy are documented
- [ ] CORS and security headers are specified
- [ ] Request size limits and input validation approach are documented
- [ ] API documentation approach (OpenAPI, examples) is defined
- [ ] WebSocket/real-time contracts are documented if applicable
