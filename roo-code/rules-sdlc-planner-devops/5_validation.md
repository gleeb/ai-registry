# Self-Validation for Cross-Cutting DevOps

## Posture

**Default FAIL** — Do not write `devops.md` until all checks pass. If any check fails, iterate on the plan before writing.

## Validation Checks

### All Services Have Deployment Config

- Every service identified in per-story HLDs has deployment configuration defined.
- No deployable unit is missing from the plan.
- Service topology from HLDs matches deployment topology in devops.md.

### CI/CD Covers All Test Types

- Pipeline includes gates for unit, integration, E2E (as defined in testing strategy).
- No test type that exists in the plan is absent from the pipeline.
- Pass/fail criteria defined for each gate.

### Rollback Procedure Exists

- Rollback procedure is documented step by step.
- Trigger, execution, and verification are defined.
- No "we can roll back" without a procedure.

### Monitoring Covers All Services

- Every service has metrics, logging, or tracing defined.
- Alerting strategy exists for critical failures.
- No service is deployed without a monitoring plan.

### Secrets Management Aligned with Security

- Secrets management approach aligns with security-overview.md.
- No conflicts between DevOps plan and security requirements.
- Storage, injection, and rotation are addressed.

## Validation Flow

1. Run all checks after deployment and infrastructure design phase.
2. If any check fails — iterate, do not write.
3. Do not write `devops.md` until all checks pass.
4. Report validation status to the user upon completion.
