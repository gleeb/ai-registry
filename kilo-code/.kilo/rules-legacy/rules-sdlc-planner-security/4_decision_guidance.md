# Decision Guidance

## Auth Strategy (Within Architecture Constraints)

| Situation | Guidance |
|-----------|----------|
| Public endpoint (e.g., login, health) | Document as unauthenticated; apply rate limiting. |
| User-facing API | Require authenticated token; document required scopes. |
| Service-to-service | Use service identity (mTLS, JWT, API key); align with architecture. |
| Admin operations | Require elevated role; document audit logging. |
| Internal-only endpoint | Document network boundary; do not assume "internal = safe" without architecture support. |

## Data Classification Levels

| Level | Examples | Handling |
|-------|----------|----------|
| Public | Marketing content, public config | No special controls. |
| Internal | Internal docs, non-PII logs | Access control; no external exposure. |
| Confidential | Business data, non-PII user data | Encryption, access control, audit. |
| Sensitive/PII | Names, emails, SSN, health data | Encryption, strict access control, retention, deletion. |

## When to Escalate Conflicts

- Auth-model contract does not support this story's requirements.
- Per-story controls conflict (e.g., different auth strategies for similar endpoints).
- PII handling is inconsistent across stories.
- Architecture does not specify trust boundaries — cannot assume.
- Compliance requirement (GDPR, HIPAA, etc.) is unclear or unmet.

## Rollup vs Per-Story Scope Decisions

| Decision | Per-Story | Rollup |
|----------|-----------|--------|
| Endpoint auth | Define for this story's endpoints | Aggregate; flag inconsistencies |
| PII in this story's entities | Identify and protect | Aggregate flows; ensure consistency |
| Rate limiting for this story | Define per endpoint | Ensure no gaps across similar endpoints |
| Credential management | Consume from contract | Define system-wide approach |
| Cross-story threat (e.g., data flow A→B→C) | Out of scope | Analyze in rollup |
| Compliance (e.g., GDPR) | Story-specific handling | System-wide compliance view |
