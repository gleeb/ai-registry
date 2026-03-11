# API Design Agent Dispatch Template

Use this template when dispatching `sdlc-planner-api` via `new_task`.

## Required Message Structure

```
PLAN: API Design and Contracts

CONTEXT:
- [Reference to plan/prd.md]
- [Reference to plan/system-architecture.md — component boundaries and integration points]
- [Reference to plan/hld.md — feature-level design context]
- [Whether greenfield or extending existing APIs]

SCOPE:
- IN SCOPE: API contracts, endpoint specifications, request/response schemas, authentication flows, versioning strategy, error response formats, rate limiting policy
- OUT OF SCOPE: Implementation of APIs (execution phase), database schemas (Data Architecture agent), infrastructure/deployment (DevOps agent)

EXISTING PLAN ARTIFACTS:
- plan/prd.md: [REQUIRED]
- plan/system-architecture.md: [REQUIRED]
- plan/hld.md: [REQUIRED or in progress]
- plan/api-design.md: [exists / does not exist]
- plan/security.md: [if exists, reference for auth requirements]
- [List any other relevant existing plan files]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- [Integration points from system architecture]
- [Data entities and operations from HLD]
- [Authentication/authorization from security plan]
- [Performance requirements from PRD (rate limits, latency)]

OUTPUT:
- Write the API specification to plan/api-design.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that plan/api-design.md has been written
2. Endpoint inventory with methods and paths
3. Authentication/authorization approach per endpoint group
4. Error handling and response format conventions
5. Versioning strategy
6. Unresolved questions or deferred decisions

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
