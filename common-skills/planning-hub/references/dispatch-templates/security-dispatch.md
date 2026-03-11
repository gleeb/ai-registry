# Security Agent Dispatch Template

Use this template when dispatching `sdlc-planner-security` via `new_task`.

## Required Message Structure

```
PLAN: Security Plan and Threat Model

CONTEXT:
- [Reference to plan/prd.md — PRD must exist and be validated]
- [Security & Privacy section from PRD (section 9)]
- [Data handling, credentials, PII identified in PRD]
- [Whether greenfield or updating existing security plan]

SCOPE:
- IN SCOPE: Threat model, security requirements, authentication/authorization strategy, data protection, compliance requirements, security testing requirements
- OUT OF SCOPE: Implementation of security controls (execution phase), CI/CD security (DevOps agent), detailed API auth specs (API Design agent)

EXISTING PLAN ARTIFACTS:
- plan/prd.md: [REQUIRED]
- plan/security.md: [exists / does not exist]
- plan/system-architecture.md: [if exists, reference for attack surface analysis]
- [List any other relevant existing plan files]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- [Security & Privacy NFRs from PRD section 9]
- [Credential and PII handling from PRD]
- [Compliance or regulatory requirements]
- [Trust boundaries from architecture (if available)]

OUTPUT:
- Write the security plan to plan/security.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that plan/security.md has been written
2. Threat model summary (assets, threats, mitigations)
3. Authentication/authorization strategy
4. Data classification and protection requirements
5. Compliance requirements identified
6. Security testing requirements for the Testing Strategy agent
7. Unresolved security concerns or accepted risks

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
