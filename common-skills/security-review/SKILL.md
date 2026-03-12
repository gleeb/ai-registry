---
name: security-review
description: >
  Security review framework for implementation code. Use when the code reviewer
  receives a dispatch with SECURITY_REVIEW: true, when reviewing code that touches
  authentication, authorization, input handling, data access, secrets, or network
  communication. Covers OWASP Top 10, CWE Top 25, secrets scanning, and
  platform-specific security (React Native).
---

# Security Review

## Overview

Structured security review to complement the standard code review. Loaded by the code reviewer when the dispatch includes `SECURITY_REVIEW: true` or when the task touches security-sensitive areas.

## When to Load

- Story has `security` in `candidate_domains`
- Task touches authentication or authorization logic
- Task handles user input (forms, API parameters, file uploads)
- Task accesses or modifies data storage
- Task involves network communication or API calls
- Task manages secrets, tokens, or credentials

## Review Framework

### 1. Input Validation

- All user-supplied input is validated before use
- Validation happens at the boundary (API handler, form submission), not deep in business logic
- Reject-by-default: only explicitly allowed input passes through
- No raw SQL interpolation — parameterized queries only

### 2. Authentication & Authorization

- Auth checks are present on all protected routes/endpoints
- Token validation uses established libraries, not custom parsing
- Session management follows platform best practices
- Role/permission checks happen server-side, not client-only

### 3. Secrets Management

Load [`references/secrets-scanning-checklist.md`](references/secrets-scanning-checklist.md) for the full checklist.

- No hardcoded API keys, tokens, passwords, or connection strings in source code
- Secrets loaded from environment variables or secret managers
- `.env` files are in `.gitignore`
- No secrets in logs, error messages, or user-facing output

### 4. OWASP Top 10

Load [`references/owasp-top-10-checklist.md`](references/owasp-top-10-checklist.md) for the full checklist.

Review against the current OWASP Top 10 categories, focusing on the ones relevant to the task.

### 5. Platform-Specific Security

For React Native projects, load [`references/react-native-security.md`](references/react-native-security.md).

## Review Output Format

Add a `## Security Review` section to the standard code review output:

```
## Security Review

### Findings

#### Critical
- file.ts:42 — [finding] → [remediation]

#### Important
- file.ts:78 — [finding] → [remediation]

#### Informational
- [observation or recommendation]

### Security Summary
- Input validation: [adequate / gaps found]
- Auth/authz: [adequate / gaps found]
- Secrets: [clean / issues found]
- OWASP: [relevant categories checked]
```

## Severity Classification

| Severity | Criteria | Examples |
|----------|----------|---------|
| Critical | Exploitable vulnerability, data exposure | SQL injection, hardcoded secrets, missing auth check |
| Important | Security weakness, defense-in-depth gap | Missing input validation, overly permissive CORS, weak session config |
| Informational | Best practice recommendation | Consider CSP headers, add rate limiting, use secure cookie flags |

## References

- [`references/owasp-top-10-checklist.md`](references/owasp-top-10-checklist.md)
- [`references/secrets-scanning-checklist.md`](references/secrets-scanning-checklist.md)
- [`references/react-native-security.md`](references/react-native-security.md)
