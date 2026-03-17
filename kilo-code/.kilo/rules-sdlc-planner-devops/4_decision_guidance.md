# Decision Guidance for Cross-Cutting DevOps

## Deployment Strategy Selection

- **Blue-green**: Prefer when zero-downtime is critical and rollback must be instant. Higher resource cost (two full environments).
- **Canary**: Prefer when gradual rollout reduces risk and traffic can be split. Requires traffic routing capability.
- **Rolling**: Prefer when resource constraints matter and brief degradation is acceptable. Simpler but slower rollback.
- Document the rationale for the chosen strategy — do not default without justification.

## Container vs Serverless

- **Containers**: Prefer when stateful components, custom runtimes, or fine-grained control are needed.
- **Serverless**: Prefer when event-driven, stateless, and variable load fit the workload.
- Align with system-architecture.md — do not contradict architecture decisions.

## IaC Tool Selection

- **Terraform**: Broad provider support, declarative, mature ecosystem.
- **Pulumi**: Code-as-IaC, good for teams preferring programming languages.
- **CloudFormation**: Native to AWS, tight integration.
- Choose based on cloud provider, team expertise, and existing tooling. Document the choice.

## Monitoring Tool Selection

- Consider: metrics (Prometheus, CloudWatch, Datadog), logging (ELK, Loki, CloudWatch Logs), tracing (Jaeger, X-Ray, Zipkin).
- Align with architecture and existing observability stack.
- Ensure all services can emit to the chosen stack.

## Environment Strategy

- **Dev**: Fast feedback, may use mocks, lower fidelity.
- **Staging**: Production-like, used for pre-release validation.
- **Production**: Full scale, real data, strict change control.
- Define promotion criteria between environments.
- Document what may differ and what must match.

## Boundaries

- **ALLOW**: CI/CD design, deployment strategy, infrastructure provisioning, monitoring, environment management, rollback procedures.
- **DENY**: Application code, security threat modeling (delegate to Security agent), per-story implementation details.
