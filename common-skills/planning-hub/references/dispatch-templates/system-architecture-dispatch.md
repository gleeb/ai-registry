# System Architecture Agent Dispatch Template

Use this template when dispatching `sdlc-planner-architecture` via `new_task`.

## Required Message Structure

```
PLAN: System Architecture

CONTEXT:
- [Reference to plan/prd.md — the PRD must exist and be validated]
- [Specific architectural concerns or constraints from the PRD]
- [Whether greenfield or extending existing architecture]

SCOPE:
- IN SCOPE: System topology, component boundaries, technology stack decisions, integration patterns, infrastructure overview
- OUT OF SCOPE: Detailed API contracts (API Design agent), data schemas (Data Architecture agent), security threat model (Security agent), CI/CD pipelines (DevOps agent)

EXISTING PLAN ARTIFACTS:
- plan/prd.md: [REQUIRED — must exist and be validated]
- plan/system-architecture.md: [exists / does not exist]
- [List any other relevant existing plan files]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- [Technology constraints from PRD section 8]
- [Performance requirements from PRD section 9]
- [Platform requirements from PRD section 9]
- [Deployment constraints from PRD section 8]

OUTPUT:
- Write the architecture specification to plan/system-architecture.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that plan/system-architecture.md has been written
2. Summary of key architectural decisions and trade-offs
3. Component inventory with responsibilities
4. Integration points and patterns chosen
5. Unresolved questions or deferred decisions
6. Dependencies on other planning agents (security, data, API)

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
