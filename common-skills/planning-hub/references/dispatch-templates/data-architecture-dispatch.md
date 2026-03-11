# Data Architecture Agent Dispatch Template

Use this template when dispatching `sdlc-planner-data` via `new_task`.

## Required Message Structure

```
PLAN: Data Architecture

CONTEXT:
- [Reference to plan/prd.md]
- [Reference to plan/system-architecture.md — storage and data flow decisions]
- [Reference to plan/hld.md — data entities per feature]
- [Whether greenfield or extending existing data layer]

SCOPE:
- IN SCOPE: Data models, entity relationships, database schema design, storage strategy (SQL/NoSQL/hybrid), migration strategy, data access patterns, caching strategy, data lifecycle
- OUT OF SCOPE: API endpoint design (API Design agent), implementation of migrations (execution phase), infrastructure provisioning (DevOps agent)

EXISTING PLAN ARTIFACTS:
- plan/prd.md: [REQUIRED]
- plan/system-architecture.md: [REQUIRED]
- plan/hld.md: [REQUIRED or in progress]
- plan/data-architecture.md: [exists / does not exist]
- plan/api-design.md: [if exists, reference for data shapes]
- plan/security.md: [if exists, reference for data protection]
- [List any other relevant existing plan files]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- [Data entities implied by user stories and HLD]
- [Storage technology decisions from architecture]
- [Data protection requirements from security plan]
- [Performance and scalability requirements from PRD]

OUTPUT:
- Write the data architecture to plan/data-architecture.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that plan/data-architecture.md has been written
2. Entity inventory with key fields and relationships
3. Storage technology decisions and rationale
4. Data access pattern summary
5. Migration strategy (if extending existing data)
6. Caching strategy
7. Unresolved questions or deferred decisions

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
