# DevOps Agent Dispatch Template

Use this template when dispatching `sdlc-planner-devops` via `new_task`.

## Required Message Structure

```
PLAN: DevOps and Infrastructure

CONTEXT:
- [Reference to plan/prd.md — deployment and platform constraints]
- [Reference to plan/system-architecture.md — component topology and infrastructure needs]
- [Reference to plan/security.md — security controls for infrastructure]
- [Whether greenfield or extending existing infrastructure]

SCOPE:
- IN SCOPE: CI/CD pipeline design, deployment strategy, environment management (dev/staging/prod), infrastructure requirements, monitoring and observability, container/orchestration strategy, secrets management
- OUT OF SCOPE: Application code (execution phase), database schema (Data Architecture agent), API implementation (execution phase)

EXISTING PLAN ARTIFACTS:
- plan/prd.md: [REQUIRED]
- plan/system-architecture.md: [REQUIRED]
- plan/security.md: [REQUIRED or in progress]
- plan/devops.md: [exists / does not exist]
- [List any other relevant existing plan files]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- [Deployment targets from PRD section 8]
- [Platform requirements from PRD section 9]
- [Component topology from system architecture]
- [Security controls from security plan (secrets, TLS, access)]
- [Performance/availability SLAs from PRD]

OUTPUT:
- Write the DevOps plan to plan/devops.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that plan/devops.md has been written
2. CI/CD pipeline overview (stages, triggers, gates)
3. Environment inventory (dev, staging, prod) with characteristics
4. Deployment strategy (blue-green, rolling, canary, etc.)
5. Monitoring and alerting approach
6. Secrets management approach
7. Unresolved questions or deferred decisions

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
