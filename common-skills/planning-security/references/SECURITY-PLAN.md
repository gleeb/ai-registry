# Security Plan Template

## Contents
- Purpose
- Contract gates
- Template (13 sections)
- Quality checklist

## Purpose
Use this format when drafting or refining the security plan document (`plan/security.md`).

The security plan defines the security posture, threat model, and controls for the product. It must be comprehensive enough for developers to implement security correctly and for reviewers to verify compliance.

## Contract gates
- REQUIRE all 13 sections to be substantive before the security plan is considered complete.
- REQUIRE threat model to cover all data assets and trust boundaries.
- DENY deferring security to implementation — all security decisions must be made here.
- DENY proceeding without data classification for all data types handled by the system.

## Template

---

### 1) Metadata

| Field | Value |
|-------|-------|
| Document Version | 0.1.0 |
| Last Updated | [date] |
| Security Owner | [name] |
| Status | Draft / Review / Approved |
| Related Documents | PRD, System Architecture |

---

### 2) Security Overview

- Security posture statement: what level of security is appropriate for this product.
- Key security principles governing the design (e.g., defense in depth, least privilege, zero trust).
- Trust boundaries: where trusted and untrusted zones meet.
- Regulatory context: which regulations or standards apply (if any).

---

### 3) Data Classification

| Data Type | Classification | Handling Requirements | Storage | Retention |
|---|---|---|---|---|
| [e.g., user credentials] | Restricted | Encrypted at rest, never logged | [location] | [policy] |
| [e.g., user profile] | Confidential | Encrypted in transit | [location] | [policy] |
| [e.g., public content] | Public | No special handling | [location] | [policy] |

**Classification levels**:
- **Restricted**: Highest sensitivity. Breach causes severe damage. Encryption mandatory at rest and in transit.
- **Confidential**: Business-sensitive. Encryption in transit required. Access controls mandatory.
- **Internal**: Not public, but breach impact is limited. Standard access controls.
- **Public**: No sensitivity. No special handling required.

---

### 4) Threat Model

**Assets**: List all valuable assets (data, services, infrastructure, credentials).

**Threat Actors**: Who might attack this system?
- [e.g., external attackers, malicious insiders, automated bots]

**Threat Scenarios (STRIDE)**:

| Category | Threat | Asset | Likelihood | Impact | Risk | Mitigation |
|---|---|---|---|---|---|---|
| **S**poofing | [identity spoofing scenario] | [asset] | H/M/L | H/M/L | [rating] | [control] |
| **T**ampering | [data tampering scenario] | [asset] | H/M/L | H/M/L | [rating] | [control] |
| **R**epudiation | [action denial scenario] | [asset] | H/M/L | H/M/L | [rating] | [control] |
| **I**nformation Disclosure | [data leak scenario] | [asset] | H/M/L | H/M/L | [rating] | [control] |
| **D**enial of Service | [availability scenario] | [asset] | H/M/L | H/M/L | [rating] | [control] |
| **E**levation of Privilege | [privilege escalation scenario] | [asset] | H/M/L | H/M/L | [rating] | [control] |

---

### 5) Authentication Strategy

- Authentication method: [JWT, session-based, OAuth 2.0, API keys, etc.]
- Authentication flow: step-by-step description.
- Session management: token lifetime, refresh mechanism, revocation.
- Multi-factor authentication: required/optional, methods.
- Password policy: minimum length, complexity, breach detection.
- Account lockout: threshold, duration, recovery.

---

### 6) Authorization Model

- Authorization approach: [RBAC, ABAC, policy-based, etc.]
- Roles and permissions:

| Role | Permissions | Scope |
|---|---|---|
| [role name] | [list of permissions] | [scope/resources] |

- Access control enforcement point: where and how authorization is checked.
- Default deny: all access denied unless explicitly granted.

---

### 7) Credential and Secret Management

- Where credentials/secrets are stored: [vault, env vars, encrypted config, etc.]
- Encryption method for stored credentials.
- Rotation policy: frequency, procedure.
- Access control: who can read secrets, audit trail.
- Emergency procedures: compromised credential response.
- Secrets that must NEVER appear in: code, logs, error messages, client-side storage.

---

### 8) Data Protection

**At Rest**:
- Encryption algorithm and key length.
- Key management approach (KMS, manual, etc.).
- Which data stores are encrypted.

**In Transit**:
- TLS version and cipher suite requirements.
- Certificate management approach.
- Internal service-to-service encryption requirements.

**In Use**:
- Memory protection considerations.
- Sensitive data scrubbing from logs and error messages.

---

### 9) API Security

- Rate limiting: limits per endpoint group, response headers, retry guidance.
- Input validation: approach (allowlist vs denylist), sanitization.
- CORS policy: allowed origins, methods, headers.
- Content Security Policy (CSP): directives.
- Request size limits.
- SQL injection, XSS, CSRF prevention measures.

---

### 10) Compliance Requirements

| Regulation/Standard | Applicability | Key Requirements | Status |
|---|---|---|---|
| [e.g., GDPR] | [why it applies] | [key requirements] | [compliant/in-progress/gap] |

- Data residency requirements: where data must be stored geographically.
- Audit requirements: what needs to be logged, retention period.
- Right to deletion: how user data deletion requests are handled.
- Data portability: how user data export requests are handled.

---

### 11) Security Testing Requirements

These requirements are handed off to the Testing Strategy agent for inclusion in the test plan.

- **SAST**: Static analysis tools and frequency.
- **DAST**: Dynamic analysis tools and frequency.
- **Dependency scanning**: tool, frequency, vulnerability threshold.
- **Penetration testing**: scope, frequency, provider.
- **Security review**: code review security checklist items.

---

### 12) Incident Response Considerations

- **Detection**: How security incidents are detected (monitoring, alerts, logs).
- **Response**: Initial response procedure (who is notified, escalation path).
- **Recovery**: How to recover from a breach (credential rotation, data assessment, communication).
- **Post-incident**: Review process, lessons learned, control improvements.

---

### 13) Security Risks and Mitigations

| Risk | Likelihood | Impact | Current Mitigation | Residual Risk | Accepted? |
|---|---|---|---|---|---|
| [risk description] | H/M/L | H/M/L | [mitigation in place] | H/M/L | Yes/No |

---

## Quality checklist
- REQUIRE all 13 sections are present and substantive — no placeholders.
- REQUIRE data classification covers all data types handled by the system.
- REQUIRE threat model uses STRIDE and covers all trust boundaries.
- REQUIRE authentication strategy is fully specified (method, flow, session management).
- REQUIRE authorization model defines all roles, permissions, and enforcement points.
- REQUIRE credential management specifies storage, encryption, rotation, and emergency procedures.
- REQUIRE data protection addresses at-rest, in-transit, and in-use scenarios.
- REQUIRE API security covers rate limiting, input validation, CORS, and CSP.
- REQUIRE compliance requirements are identified with gap analysis.
- REQUIRE security testing requirements are concrete enough for the Testing Strategy agent.
- REQUIRE all identified risks have mitigations or explicit acceptance.
