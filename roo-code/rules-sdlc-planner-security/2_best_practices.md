# Best Practices

## Per-Story Practices

### Threat Analysis Scope

- Scope threat analysis to this story's entry points only.
- Do not expand to endpoints or flows outside the story.
- Entry points: HTTP endpoints, message handlers, file uploads, external integrations.

### Auth-Model Contract Authority

- Use the auth-model contract as authoritative for auth strategy.
- Do not redefine auth mechanisms. Consume and align.
- If the contract is incomplete for this story's needs, flag it.

### Endpoint Auth Requirements

- Every endpoint MUST have explicit auth requirements documented.
- Specify: unauthenticated, authenticated, or role-based.
- Document which roles/permissions are required for each operation.

### PII Handling Per Entity

- Identify PII in every entity this story touches.
- Document: encryption at rest, encryption in transit, access controls.
- Ensure PII flows are traced from ingestion to storage to egress.

### Rate Limiting Per Endpoint

- Define rate limits for public or high-risk endpoints.
- Document: requests per minute, per user, or per IP.
- Align with architecture constraints (e.g., API gateway capabilities).

## Rollup Practices

### Inconsistency Identification

- Compare auth requirements across stories — flag conflicting approaches.
- Compare PII handling — ensure consistent classification and protection.
- Compare rate limiting — ensure no gaps for similar endpoint types.

### Aggregate Threat Model

- Build a system-wide threat model from per-story assessments.
- Identify threats that span multiple stories (e.g., cross-service data flow).
- Document residual risks and mitigation ownership.

### Credential Management

- Define how credentials are stored, rotated, and accessed.
- Document secrets management approach (vault, env vars, etc.).
- Ensure no story assumes "trusted environment" without explicit architecture support.
