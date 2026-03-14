# Best Practices for Cross-Cutting DevOps

## Service Topology Understanding

- Read ALL per-story `hld.md` files to understand the full service topology.
- Do not assume service boundaries — extract them from the artifacts.
- Map every deployable unit to its HLD source story.
- Align deployment topology with architecture deployment topology.

## Architecture Alignment

- Deployment strategy must align with system-architecture.md deployment topology.
- Infrastructure choices must respect architecture constraints.
- Do not introduce deployment patterns that contradict the architecture.

## Secrets Management

- Align secrets management with security-overview.md requirements.
- Define where secrets are stored, how they are injected, and rotation strategy.
- Do not hardcode or assume ad-hoc secret handling.

## Infrastructure as Code

- Use IaC for all infrastructure — no manual provisioning.
- Define which IaC tool (Terraform, Pulumi, CloudFormation, etc.) and why.
- All environments must be provisioned from the same IaC definitions.

## Monitoring Coverage

- Every service identified in per-story HLDs must have monitoring defined.
- Define metrics, logging, tracing, and alerting for each service type.
- No service may be deployed without a monitoring plan.

## Environment Parity

- Dev, staging, and production must have parity for critical infrastructure.
- Document what may differ (scale, data) and what must match (config, topology).
- Avoid environment-specific surprises in production.

## Rollback Strategy

- Rollback procedure is required — not optional.
- Define how rollback is triggered, what gets rolled back, and verification steps.
- Document rollback time expectations and data consistency considerations.
