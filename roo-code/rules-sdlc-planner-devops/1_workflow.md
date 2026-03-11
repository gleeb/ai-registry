# Cross-Cutting DevOps Workflow (Phase 4)

## Overview

DevOps Agent produces the cross-cutting DevOps plan. It writes to `plan/cross-cutting/devops.md`. The agent focuses on infrastructure analysis, CI/CD pipeline design, deployment strategy, environment management, and monitoring — synthesizing inputs from all per-story HLD artifacts, system architecture, and security overview.

## Initialization

1. **Load planning-devops skill** — Use the skill for templates, patterns, and DevOps reference.
2. **Verify required inputs exist**:
   - `plan/system-architecture.md`
   - `plan/cross-cutting/security-overview.md`
   - All `plan/user-stories/*/hld.md` (per-story HLDs)
   - All `plan/user-stories/*/story.md` (for build/deploy scope)

   If any are missing, report the gap and request them before proceeding.

## Main Workflow

### Phase 1: Infrastructure Analysis

- Read all per-story `hld.md` files — extract full service topology.
- Read `system-architecture.md` — deployment topology, infrastructure requirements.
- Read `security-overview.md` — security infrastructure needs.
- Read PRD NFRs — availability, scalability, performance targets.
- Identify all deployable units and their dependencies.

### Phase 2: CI/CD Pipeline Design

- Define pipeline stages: lint, test, build, deploy, verify.
- Define test gates at each stage.
- Define artifact management (container images, packages).
- Define environment promotion strategy.
- Define rollback procedures.

### Phase 3: Deployment and Infrastructure

- Define deployment strategy (blue-green, canary, rolling) with rationale.
- Define environment strategy (dev, staging, production).
- Define infrastructure provisioning approach (IaC tool, cloud provider).
- Define container/orchestration strategy if applicable.
- Define secrets management aligned with security overview.
- Define monitoring and observability (metrics, logging, tracing, alerting).

### Phase 4: Review with User

- Present DevOps plan to user.
- Apply sparring protocol — challenge deployment strategy, rollback procedures, monitoring coverage, environment parity.
- Iterate until user approves.

### Phase 5: Completion

- Run self-validation (see `5_validation.md`).
- Write to `plan/cross-cutting/devops.md`.
- Report completion to the Planning Hub.

## Completion Criteria

- [ ] `devops.md` written to `plan/cross-cutting/`
- [ ] All services from per-story HLDs have deployment configuration
- [ ] CI/CD pipeline defined with stages and gates
- [ ] Deployment strategy documented with rationale
- [ ] Monitoring planned for all services
- [ ] Self-validation passed before write
