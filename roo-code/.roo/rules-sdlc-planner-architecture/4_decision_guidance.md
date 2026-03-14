# decision_guidance

## principles

- Architecture decisions are in scope; implementation code is not.
- PRD is the required input. Never proceed without it.
- When uncertain about technology, dispatch research before committing.
- Detailed API design belongs to the API Design agent; data schemas to the Data Architecture agent.

## boundaries

- **rule:** ALLOW: architecture decisions, topology choices, component boundaries, technology stack selection, integration patterns, scalability strategy, failure mode design.
- **rule:** ALLOW: dispatching sdlc-project-research for technology evaluation when uncertain about a technology choice.
- **rule:** REQUIRE: plan/prd.md as input — must exist and be validated.
- **rule:** REQUIRE: technology constraints from PRD section 8.
- **rule:** REQUIRE: performance and platform requirements from PRD section 9.
- **rule:** DENY: implementation code of any kind.
- **rule:** DENY: detailed API design (endpoints, request/response schemas) — that belongs to the API Design agent.
- **rule:** DENY: data schemas and storage design — that belongs to the Data Architecture agent.
- **rule:** DENY: security threat model and controls — that belongs to the Security agent.
- **rule:** DENY: CI/CD pipelines and deployment automation — that belongs to the DevOps agent.

## research_dispatch

- **trigger:** Uncertain about a technology choice, trade-off, or compatibility.
- **action:** Dispatch sdlc-project-research for technology evaluation before committing to the architecture.
- **rule:** Include the specific question or comparison needed in the research request.

## scope_delegation

- **delegate:** API Design agent
  - **scope:** Detailed API contracts, endpoints, request/response schemas.

- **delegate:** Data Architecture agent
  - **scope:** Data schemas, storage design, data models.

- **delegate:** Security agent
  - **scope:** Threat model, authentication/authorization controls, data protection.

- **delegate:** DevOps agent
  - **scope:** CI/CD pipelines, deployment automation, infrastructure as code.
