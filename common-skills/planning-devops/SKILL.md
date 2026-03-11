---
name: planning-devops
description: Cross-cutting DevOps planning specialist. Use when the Planning Hub dispatches DevOps planning in Phase 4 after all per-story planning is complete. Reads per-story HLD artifacts, system architecture, and security overview. Designs CI/CD pipelines, deployment strategy, infrastructure, monitoring, and environment management. Writes to plan/cross-cutting/devops.md.
---

# Planning DevOps (Cross-Cutting, Phase 4)

## When to use
- Use when the Planning Hub dispatches DevOps planning work (`sdlc-planner-devops`).
- Use when all per-story planning (Phase 3) is complete and validated.
- Use when updating or revising existing DevOps plan.

## When NOT to use
- DENY use for implementation work — DevOps is planning only here.
- DENY use for per-story design decisions — those belong to Phase 3 agents.
- DENY use for security threat modeling — delegate to `planning-security`.
- DENY use before Phase 3 is complete (DevOps needs the full picture).

## Inputs required
1. `plan/system-architecture.md` — deployment topology, infrastructure requirements.
2. `plan/cross-cutting/security-overview.md` — security infrastructure requirements.
3. All `plan/user-stories/*/hld.md` — service topology from per-story designs.
4. All `plan/user-stories/*/story.md` — for build/deploy scope understanding.
5. `plan/prd.md` — NFRs for availability, scalability, performance.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

### Phase 1: Infrastructure Analysis

1. Read `plan/system-architecture.md` — extract deployment topology.
2. Read all per-story hld.md files — identify services, components, and their runtime needs.
3. Read `plan/cross-cutting/security-overview.md` — extract security infrastructure needs.
4. Read PRD NFRs — availability, scalability, performance targets.
5. Identify all deployable units and their dependencies.

### Phase 2: CI/CD Pipeline Design

1. Define pipeline stages: lint, test, build, deploy, verify.
2. Define test gates at each stage.
3. Define artifact management (container images, packages).
4. Define environment promotion strategy.
5. Define rollback procedures.

### Phase 3: Deployment and Infrastructure

1. Define deployment strategy (blue-green, canary, rolling) with rationale.
2. Define environment strategy (dev, staging, production).
3. Define infrastructure provisioning approach (IaC tool, cloud provider).
4. Define container/orchestration strategy if applicable.
5. Define secrets management aligned with security overview.
6. Define monitoring and observability (metrics, logging, tracing, alerting).

### Phase 4: Review and Completion

1. Present DevOps plan to user.
2. Apply sparring — challenge deployment strategy, infrastructure choices, monitoring gaps.
3. Write to `plan/cross-cutting/devops.md`.

## Output

- `plan/cross-cutting/devops.md` — the cross-cutting DevOps plan.

## Files

- [`references/DEVOPS-PLAN.md`](references/DEVOPS-PLAN.md): DevOps plan template and quality checklist.

## Troubleshooting

- If architecture is missing, report the blocker.
- If per-story artifacts are incomplete, flag which stories need completion.
- If security overview conflicts with proposed infrastructure, reconcile before completing.
