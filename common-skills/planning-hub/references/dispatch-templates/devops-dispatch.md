# DevOps Agent Dispatch Template

**DISPATCH TO**: `sdlc-planner-devops`

Use this template when dispatching `sdlc-planner-devops` via the Task tool for Phase 4 cross-cutting DevOps planning.

## Required Message Structure

```
PLAN: Cross-Cutting DevOps

CONTEXT:
- All per-story planning is complete and validated
- plan/system-architecture.md: REQUIRED (deployment topology, infrastructure requirements)
- plan/cross-cutting/security-overview.md: REQUIRED (security infrastructure requirements)
- plan/user-stories/*/story.md: REQUIRED (all stories for build/deploy scope)
- plan/user-stories/*/hld.md: [list available — for service topology]
- [Whether this is greenfield infrastructure or adding to existing]

SCOPE:
- IN SCOPE: CI/CD pipeline design, deployment strategy, infrastructure provisioning, environment strategy, monitoring and observability, container/orchestration strategy, secrets management
- OUT OF SCOPE: Per-story implementation details, application code, security controls (Security agent)

EXISTING PLAN ARTIFACTS:
- plan/cross-cutting/devops.md: [exists / does not exist]
- plan/system-architecture.md: REQUIRED
- plan/cross-cutting/security-overview.md: [exists / does not exist]
- [List all existing per-story hld.md files for service topology reference]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- Architecture deployment topology and infrastructure requirements
- Security infrastructure requirements (secrets management, network policies, TLS)
- Per-story service boundaries from HLD files
- PRD NFRs for availability, scalability, performance

SHARED SPARRING RULES:
Read and apply skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- Write DevOps plan to plan/cross-cutting/devops.md

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Confirmation that plan/cross-cutting/devops.md has been written
2. CI/CD pipeline overview (stages, gates, artifacts)
3. Deployment strategy (blue-green, canary, rolling, etc.)
4. Environment strategy (dev, staging, production)
5. Infrastructure components and provisioning approach
6. Monitoring and alerting strategy
7. Unresolved DevOps questions or blockers

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Re-dispatch (after validation feedback)

When re-dispatching after Plan Validator returns NEEDS WORK, add:

```
VALIDATOR GUIDANCE (from Plan Validator):

REASONED CORRECTIONS:
[Paste the corrections section from the Plan Validator's guidance package.
Each correction includes what's wrong, what the better artifact looks like,
and the reasoning chain explaining why.]

DOCUMENTATION:
[Paste any fetched documentation excerpts from the guidance package.]
[Paste any documentation fetch instructions — if included, use context7 MCP
to retrieve the specified docs before revising. Search for the exact terms,
library, and sections specified.]

IMPROVEMENT INSTRUCTIONS:
[Paste the consolidated improvement instructions from the guidance package.
These are specific, actionable steps to follow.]

Apply the corrections and follow the improvement instructions. If documentation
fetch instructions are included, retrieve the docs via context7 first — they
contain the context needed to produce the correct artifact.
```
