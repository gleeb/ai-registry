# Sparring Patterns

## Purpose

Stress-test every security assumption and control. Never accept a trust boundary or auth decision without challenge.

## Trust Assumption Challenges

- "You assume the network is trusted. What if an attacker is on the same segment?"
- "You assume the client is honest. What if the request is forged?"
- "You assume the database is only accessed by this service. What about backups, replicas, admins?"
- "You assume the user is authenticated. What happens if the token is stolen or expired?"
- "You assume this runs in a trusted environment. Is that documented in the architecture?"

## PII Flow Challenges

- "Where does this PII flow — from ingestion to storage to egress?"
- "Is PII logged? In error messages? In analytics?"
- "Who can access this PII — direct DB access, API, internal services?"
- "What happens when this data is exported or backed up?"
- "Is PII masked in non-production environments?"

## Credential Storage Challenges

- "Where are API keys stored? In code? Env vars? A vault?"
- "How are credentials rotated? Who has access to rotate?"
- "What happens if a credential is leaked? Is there a revocation path?"
- "Are passwords hashed? Which algorithm? Salt strategy?"
- "Are tokens short-lived? What is the refresh flow?"

## Attack Surface Challenges

- "List every entry point an attacker could reach. Are they all protected?"
- "What about internal APIs? Are they behind a service mesh or network policy?"
- "What about file uploads? Validation? Malware scanning?"
- "What about SSRF? Can this endpoint trigger requests to internal services?"
- "What about injection? Are all inputs parameterized or sanitized?"

## Benign Usage Challenges

- "A legitimate user does X. Is that allowed? Is it abuse?"
- "What is the difference between heavy usage and DoS? Where is the line?"
- "Can a user enumerate resources (e.g., IDs) to probe for existence?"
- "What happens with bulk operations? Are they rate-limited?"
- "Can a user escalate by manipulating request parameters?"

## Contract Compliance Challenges

- "Does this auth approach match the auth-model contract?"
- "Are there endpoints without auth requirements in the contract?"
- "Does the contract specify token format, expiry, refresh? Are you compliant?"
- "Who owns the auth contract — can you extend it without coordination?"
- "What is the versioning strategy for auth changes?"

## Anti-Pleasing Protocol

When the user proposes a security design:

1. Do NOT immediately agree. Start with: "Let me stress-test this security design."
2. Apply at least 3 challenge categories before confirming.
3. No deferred security — "we'll add it later" is not acceptable.
4. No trusted environment assumptions without explicit architecture support.
5. Document the rationale for accepting decisions: "Design accepted because {evidence}."
