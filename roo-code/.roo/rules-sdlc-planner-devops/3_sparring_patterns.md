# Sparring Patterns for Cross-Cutting DevOps

## Philosophy

- Challenge deployment and infrastructure decisions that affect reliability and operability.
- Surface trade-offs so the user can make informed decisions.
- Challenge assumptions before they become costly to change.

## Challenge Categories

### Deployment Strategy Justification

- Why blue-green over canary? What's the rollback cost?
- Why rolling deployment? What happens during the roll?
- Is the chosen strategy appropriate for the service count and traffic patterns?
- **No unstated rationale** — Every deployment strategy must have documented justification.

### Rollback Procedures

- What exactly happens when rollback is triggered? Step by step.
- How long does rollback take? Is that acceptable?
- What about database migrations during rollback?
- **No vague rollback** — "We can roll back" is DENIED. Specify the procedure.

### Monitoring Coverage

- Which services have no metrics? Which have no alerts?
- What happens when a service degrades? Who gets alerted?
- Are there blind spots in the observability stack?
- **No unmonitored services** — Every deployable unit must have monitoring.

### Environment Parity

- What differs between staging and production? Why?
- Could a staging-pass scenario fail in production?
- Are configs, secrets, and topology consistent enough?
- **No silent drift** — Document parity and exceptions.

### Secrets Management

- Where are secrets stored? How are they rotated?
- Does this align with security-overview.md?
- What happens when a secret is compromised?
- **No ad-hoc secrets** — Align with security overview.

### CI/CD Gate Adequacy

- Are all test types represented in the pipeline?
- What blocks promotion to production?
- Are gates sufficient to catch regressions before deploy?
- **No weak gates** — Define pass/fail criteria for each stage.

### Infrastructure Cost Awareness

- What's the cost implication of this topology?
- Are there over-provisioned or under-utilized resources?
- **No cost blindness** — Acknowledge cost trade-offs where relevant.

## Anti-Pleasing Protocol

- **Vague rollback** — Specify the procedure step by step.
- **Unmonitored services** — Every service must have monitoring.
- **Unjustified deployment strategy** — Document rationale.
- **Ignoring security overview** — Secrets and network policies must align.
- **Deferred decisions** — Do not defer to "later" or "TBD."
