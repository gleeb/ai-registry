# DevOps Plan Template

## Purpose

Use this format when drafting or refining a DevOps plan. The DevOps plan defines how the system is built, deployed, operated, and recovered. It must be complete, actionable, and aligned with architecture and security requirements before implementation begins.

## Contract Gates

- REQUIRE all sections to be substantive before the DevOps plan is considered complete.
- REQUIRE rollback procedure, monitoring plan, and disaster recovery to be documented.
- DENY placeholders such as "TBD" or "to be determined" — document the decision or mark as deferred with rationale.
- DENY secrets in code or unencrypted storage without explicit exception and mitigation.
- ALLOW provisional draft only when clearly marked `PROVISIONAL - NOT VALIDATED`.

---

## 1. Metadata

| Field | Value |
|-------|-------|
| Document Version | 0.1.0 |
| Last Updated | [date] |
| DevOps Owner | [name or team] |
| Status | Draft / Review / Approved |
| Related Plans | plan/prd.md, plan/system-architecture.md, plan/hld.md, plan/security.md |

---

## 2. DevOps Overview

### 2.1 Philosophy

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| Deployment philosophy | [e.g., Continuous deployment / Release on demand / Scheduled releases] | [Why this approach fits the project: team size, risk tolerance, compliance, etc.] |
| Infrastructure approach | [e.g., Infrastructure as Code / Managed PaaS / Hybrid] | [Why this approach was chosen] |
| Key principle | [e.g., "Everything in version control" / "Immutable infrastructure" / "Cattle not pets"] | [Guiding principle for operational decisions] |

### 2.2 Key Decisions Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Cloud provider | [AWS / GCP / Azure / Multi-cloud / On-prem] | [Why] |
| CI/CD tooling | [GitHub Actions / GitLab CI / Jenkins / CircleCI / Other] | [Why] |
| Deployment strategy | [Blue-green / Rolling / Canary / Recreate] | [Why] |
| Container orchestration | [Kubernetes / ECS / Cloud Run / Serverless / None] | [Why] |
| Secrets management | [Vault / Cloud native / Env vars with encryption] | [Why] |

---

## 3. CI/CD Pipeline

### 3.1 Pipeline Stages

| Stage | Purpose | Tool/Step | Duration Target |
|-------|---------|-----------|-----------------|
| Lint | Code style, static analysis | [e.g., ESLint, Ruff, golangci-lint] | < 2 min |
| Unit Test | Fast feedback on logic | [e.g., pytest, jest, go test] | < 5 min |
| Build | Produce deployable artifact | [e.g., Docker build, npm build] | < 10 min |
| Security Scan | Dependency and image scanning | [e.g., Snyk, Trivy, Dependabot] | < 5 min |
| Integration Test | Service integration, API tests | [e.g., pytest, Postman, custom] | < 15 min |
| Deploy to Dev | Automatic deployment to dev | [e.g., kubectl apply, terraform apply] | < 5 min |
| Deploy to Staging | Manual or automatic promotion | [e.g., approval gate + deploy] | < 10 min |
| Deploy to Production | Manual approval required | [e.g., approval gate + deploy] | < 15 min |

### 3.2 Triggers

| Trigger | Target Stage | Condition |
|---------|--------------|-----------|
| Push to main | Lint, Unit Test, Build, Security Scan, Deploy to Dev | On every push |
| Pull request | Lint, Unit Test, Build, Security Scan | On PR open/update |
| Tag (e.g., v1.2.3) | Full pipeline including Staging deploy | On tag push |
| Manual | Deploy to Production | Requires approval |
| Schedule | [e.g., nightly integration tests] | [Cron expression] |

### 3.3 Quality Gates

| Gate | Criteria | Failure Action |
|------|----------|----------------|
| Lint | Zero errors, configurable warnings | Block pipeline |
| Unit Test | All tests pass, coverage ≥ [X]% | Block pipeline |
| Security Scan | No critical/high vulnerabilities | Block pipeline (or require override) |
| Integration Test | All tests pass | Block promotion to staging |
| Staging smoke test | Health checks pass | Block promotion to production |

### 3.4 Build, Test, Deploy Steps

**Build:**
- [Step 1: e.g., Checkout code]
- [Step 2: e.g., Install dependencies]
- [Step 3: e.g., Run build command]
- [Step 4: e.g., Build Docker image, tag with commit SHA]
- [Step 5: e.g., Push to container registry]

**Test:**
- [Step 1: e.g., Run unit tests with coverage]
- [Step 2: e.g., Run integration tests against dev/staging]
- [Step 3: e.g., Run security scan on dependencies and image]

**Deploy:**
- [Step 1: e.g., Pull approved image from registry]
- [Step 2: e.g., Apply Kubernetes manifests / Run terraform]
- [Step 3: e.g., Run smoke tests / Health check]
- [Step 4: e.g., Notify team (Slack, email)]

### 3.5 Artifacts

| Artifact | Storage | Retention | Versioning |
|----------|---------|-----------|------------|
| Container images | [e.g., ECR, GCR, Docker Hub] | [e.g., 30 days for non-tagged, indefinite for tagged] | Tag: commit SHA, semver for releases |
| Build logs | [e.g., CI system, S3] | [e.g., 90 days] | By build ID |
| Test reports | [e.g., CI system, S3] | [e.g., 90 days] | By build ID |
| Deployment manifests | Git repository | Indefinite | Git tags, branches |

---

## 4. Deployment Strategy

### 4.1 Method

| Aspect | Specification |
|--------|---------------|
| Primary strategy | [Blue-green / Rolling / Canary / Recreate] |
| Rationale | [Why this strategy: zero-downtime requirement, rollback speed, risk tolerance] |
| Deployment flow | [Describe step-by-step: e.g., "New version deploys to green pool, health checks run, traffic switches, blue pool kept for rollback"] |
| Traffic shift | [Instant switch / Gradual (e.g., 10% → 50% → 100%) / Manual] |

### 4.2 Rollback Procedure

| Step | Action | Owner | Trigger |
|------|--------|-------|---------|
| 1 | Detect failure (health check, error rate, manual) | [Automated / On-call] | [Criteria: e.g., error rate > 5%, latency p99 > 2s] |
| 2 | Decide rollback | [Automated / On-call engineer] | [When automated vs manual] |
| 3 | Execute rollback | [e.g., Switch traffic back to previous version / kubectl rollout undo] | [Tool/command] |
| 4 | Verify rollback success | [Health checks, smoke test] | [Criteria] |
| 5 | Post-incident | [Document, root cause, improve] | [Process] |

**Rollback triggers:**
- [e.g., Health check failure for 3 consecutive checks]
- [e.g., Error rate exceeds 5% for 2 minutes]
- [e.g., Manual decision by on-call engineer]
- [e.g., Database migration failure]

**Database migration rollback:**
- [e.g., Migrations are backward-compatible; rollback = revert application only]
- [e.g., Migrations have down scripts; rollback = run down script then revert application]
- [e.g., No automatic rollback for DB; manual procedure documented in runbook]

### 4.3 Deployment Frequency Target

| Environment | Target Frequency | Approval |
|-------------|------------------|----------|
| Dev | Multiple times per day | None |
| Staging | Daily or on release | Optional |
| Production | [e.g., Weekly / On release / Continuous] | [Required: who approves] |

---

## 5. Environment Management

| Environment | Purpose | Characteristics | Access |
|-------------|---------|-----------------|--------|
| **Local** | Developer machine, rapid iteration | Same runtime as prod where possible; may use mocks for external services | All developers |
| **Dev** | Integration, feature testing | Mirrors prod topology; smaller scale; shared or per-developer | All developers |
| **Staging** | Pre-production validation, UAT | Production parity: same services, config pattern, data volume class | Developers, QA, product |
| **Production** | Live user traffic | Full scale, production data, strict change control | DevOps, on-call, limited developers |

### 5.1 Environment Parity

| Aspect | Dev | Staging | Production |
|--------|-----|---------|------------|
| Runtime/OS version | [Same as prod / Lighter] | Same as prod | — |
| Database version | [Same / Compatible] | Same as prod | — |
| External service mocks | [Allowed / Some real] | Real where possible | Real |
| Data volume | Synthetic / subset | Production-like volume | Full |
| Secrets | Dev/test secrets | Staging secrets | Production secrets |
| Configuration | Env-specific overrides | Staging config | Production config |

### 5.2 Configuration Management

| Aspect | Approach |
|--------|----------|
| Config storage | [e.g., Environment variables, config files in repo, external config service] |
| Secrets | [Never in config files; use secrets manager — see Section 8] |
| Feature flags | [e.g., LaunchDarkly, custom, env vars] |
| Environment-specific values | [e.g., Separate config files per env, single file with env overlay] |

---

## 6. Infrastructure Requirements

### 6.1 Cloud Provider and Services

| Component | Service | Region(s) | Rationale |
|-----------|---------|-----------|-----------|
| Compute | [e.g., EKS, ECS, EC2, Lambda] | [e.g., us-east-1, eu-west-1] | [Why] |
| Database | [e.g., RDS, Aurora, DynamoDB] | [Same as compute] | [Why] |
| Object storage | [e.g., S3, GCS] | [Same or multi-region] | [Why] |
| Networking | [e.g., VPC, Load Balancer, CDN] | [Per region] | [Why] |
| DNS | [e.g., Route53, Cloudflare] | Global | [Why] |
| [Other services] | [e.g., Redis, message queue] | [Region] | [Why] |

### 6.2 Regions

| Region | Purpose | Data residency |
|--------|---------|----------------|
| [e.g., us-east-1] | Primary production | [e.g., US] |
| [e.g., eu-west-1] | [Secondary / DR / EU users] | [e.g., EU] |

### 6.3 Scaling Approach

| Component | Scaling Type | Trigger | Limits |
|-----------|--------------|---------|--------|
| Compute | [Horizontal / Vertical / Auto] | [e.g., CPU > 70%, request count] | [Min/max instances] |
| Database | [Read replicas / Sharding / Managed scaling] | [e.g., Connection count, storage] | [Limits] |
| Storage | [Auto / Manual] | [e.g., Usage] | [Limits] |

---

## 7. Container Strategy

*If not using containers, document "Not applicable" with rationale (e.g., serverless, managed PaaS).*

### 7.1 Base Images

| Image | Base | Size | Updates |
|-------|------|------|----------|
| [e.g., app-runtime] | [e.g., alpine:3.19, distroless] | [e.g., < 100MB] | [e.g., Weekly security scan, rebuild on CVE] |

### 7.2 Registry

| Aspect | Specification |
|--------|---------------|
| Registry | [e.g., ECR, GCR, Docker Hub] |
| Naming | [e.g., {registry}/{org}/{service}:{tag}] |
| Access | [e.g., IAM, pull-only for deploy] |
| Scanning | [e.g., Trivy on push, block on critical] |

### 7.3 Orchestration

| Aspect | Specification |
|--------|---------------|
| Platform | [Kubernetes / ECS / Cloud Run / Serverless] |
| Deployment unit | [e.g., Deployment, Service, Ingress per microservice] |
| Resource limits | [e.g., CPU: 500m-1000m, Memory: 512Mi-1Gi per pod] |
| Health checks | [e.g., Liveness: /health, Readiness: /ready] |
| Service mesh | [e.g., None / Istio / Linkerd] — [Rationale] |

---

## 8. Secrets Management

### 8.1 Storage

| Secret Type | Storage | Encryption |
|-------------|---------|------------|
| API keys | [e.g., AWS Secrets Manager, Vault] | Encrypted at rest |
| Database credentials | [Same] | Encrypted at rest |
| TLS certificates | [e.g., ACM, cert-manager, Vault] | Managed by provider |
| Application secrets | [Same as API keys] | Encrypted at rest |

### 8.2 Rotation Policy

| Secret Type | Rotation Frequency | Process |
|-------------|-------------------|---------|
| Database credentials | [e.g., 90 days] | [e.g., Automated rotation, app picks up new creds] |
| API keys | [e.g., 90 days or on compromise] | [e.g., Manual rotation, update in secrets manager] |
| TLS certificates | [e.g., Auto-renew 30 days before expiry] | [e.g., cert-manager, ACM] |

### 8.3 Access Control

| Role | Access |
|------|--------|
| CI/CD pipeline | Read-only for deploy; no production secrets in pipeline logs |
| Application runtime | Read at startup or on-demand; least privilege |
| Developers | No production secrets; dev/staging only |
| DevOps/On-call | Read/write for emergency rotation |

### 8.4 Emergency Procedures

| Scenario | Action |
|----------|--------|
| Secret compromised | [1. Revoke/rotate immediately, 2. Audit access logs, 3. Notify security, 4. Rotate dependent secrets] |
| Unauthorized access suspected | [1. Rotate affected secrets, 2. Enable audit logging, 3. Investigate] |
| Lost secret | [1. Generate new secret, 2. Update all consumers, 3. Revoke old secret] |

---

## 9. Monitoring and Observability

### 9.1 Metrics

| Metric | Source | Aggregation | Alert Threshold |
|--------|--------|-------------|-----------------|
| Request rate | [e.g., Application, load balancer] | Rate per minute | [If applicable] |
| Error rate | [e.g., Application] | Percentage, 5m window | > 5% |
| Latency (p50, p95, p99) | [e.g., Application, APM] | Percentiles | p99 > [X]ms |
| CPU utilization | [e.g., Cloud provider] | Average | > 80% sustained |
| Memory utilization | [e.g., Cloud provider] | Average | > 85% |
| [Custom business metrics] | [e.g., Orders/sec, queue depth] | [As needed] | [As needed] |

### 9.2 Logs

| Aspect | Specification |
|--------|---------------|
| Log aggregation | [e.g., CloudWatch, Datadog, ELK, Loki] |
| Log format | [e.g., JSON with timestamp, level, message, request_id] |
| Retention | [e.g., 30 days hot, 90 days cold] |
| Search/indexing | [e.g., By service, level, request_id, timestamp] |

### 9.3 Traces

| Aspect | Specification |
|--------|---------------|
| Tracing system | [e.g., Jaeger, Zipkin, X-Ray, Datadog APM] |
| Trace propagation | [e.g., W3C Trace Context, OpenTelemetry] |
| Retention | [e.g., 7 days] |
| Sample rate | [e.g., 100% in staging, 10% in production] |

### 9.4 Dashboards

| Dashboard | Purpose | Key Panels |
|-----------|---------|------------|
| Service overview | Health at a glance | Request rate, error rate, latency, uptime |
| Infrastructure | Resource utilization | CPU, memory, disk, network |
| Business | Key business metrics | [e.g., Orders, signups, conversions] |
| [Custom] | [e.g., Database, cache] | [Relevant metrics] |

### 9.5 Alerting Rules

| Alert | Condition | Severity | Action |
|-------|-----------|----------|--------|
| High error rate | Error rate > 5% for 5 min | Critical | Page on-call |
| High latency | p99 > [X]ms for 5 min | Critical | Page on-call |
| Service down | Health check failure 3x | Critical | Page on-call |
| Disk space | > 85% used | Warning | Notify team |
| Certificate expiry | < 14 days | Warning | Notify team |
| [Custom] | [Condition] | [Severity] | [Action] |

### 9.6 On-Call and Escalation

| Aspect | Specification |
|--------|---------------|
| On-call rotation | [e.g., Weekly, PagerDuty, Opsgenie] |
| Escalation path | [e.g., L1 → L2 → L3] |
| Runbook | [Link to runbooks for each alert] |

---

## 10. Backup and Disaster Recovery

### 10.1 Backup Frequency and Retention

| Data Type | Frequency | Retention | Storage |
|-----------|-----------|-----------|---------|
| Database | [e.g., Daily, continuous] | [e.g., 30 days] | [e.g., S3, GCS] |
| Configuration | [e.g., On change] | [e.g., Indefinite in Git] | Git |
| Secrets | [e.g., No backup; recreate from vault] | N/A | Secrets manager |
| [Other] | [e.g., User uploads] | [e.g., 90 days] | [Storage] |

### 10.2 RTO and RPO Targets

| Recovery Scenario | RTO | RPO | Rationale |
|-------------------|-----|-----|------------|
| Database corruption | [e.g., 4 hours] | [e.g., 1 hour] | [Business impact] |
| Region failure | [e.g., 24 hours] | [e.g., 1 hour] | [DR failover] |
| Application bug | [e.g., 1 hour] | [e.g., 0] | [Rollback] |

### 10.3 Recovery Procedure

| Step | Action | Owner |
|------|--------|-------|
| 1 | Detect incident, declare disaster if needed | On-call |
| 2 | [e.g., Restore database from backup to new instance] | DevOps |
| 3 | [e.g., Deploy application to DR region or restore from last known good] | DevOps |
| 4 | [e.g., Update DNS to point to DR] | DevOps |
| 5 | Verify functionality, restore traffic | On-call |
| 6 | Post-incident review, update runbook | Team |

### 10.4 Disaster Recovery Drills

| Aspect | Specification |
|--------|---------------|
| Frequency | [e.g., Quarterly] |
| Scope | [e.g., Database restore, DR region failover] |
| Documentation | [e.g., Runbook: references/runbooks/DR-DRILL.md] |

---

## 11. Cost Management

### 11.1 Budget

| Category | Monthly Budget | Notes |
|----------|----------------|-------|
| Compute | [e.g., $X] | [e.g., Dev + staging + prod] |
| Database | [e.g., $X] | [e.g., RDS, Aurora] |
| Storage | [e.g., $X] | [e.g., S3, backups] |
| [Other] | [e.g., $X] | [e.g., Third-party services] |
| **Total** | [e.g., $X] | |

### 11.2 Cost Optimization Approach

| Strategy | Action |
|----------|--------|
| Right-sizing | [e.g., Review instance sizes quarterly, use metrics to downsize] |
| Reserved instances | [e.g., Use for predictable baseline; spot for batch] |
| Spot/Preemptible | [e.g., For non-critical workloads, batch jobs] |
| Cleanup | [e.g., Terminate unused resources, delete old snapshots] |
| Tagging | [e.g., Tag all resources for cost allocation by team/project] |

### 11.3 Billing Alerts

| Alert | Threshold | Action |
|-------|------------|--------|
| Budget warning | 80% of monthly budget | Notify team |
| Budget overrun | 100% of monthly budget | Notify team, escalate |
| Anomaly | [e.g., 20% increase week-over-week] | Notify team |

---

## 12. Runbook References

| Scenario | Runbook | Location |
|----------|---------|----------|
| Deployment failure | [e.g., Rollback procedure] | references/runbooks/ROLLBACK.md |
| Database restore | [e.g., Restore from backup] | references/runbooks/DB-RESTORE.md |
| Secret rotation | [e.g., Rotate API key] | references/runbooks/SECRET-ROTATION.md |
| High error rate | [e.g., Debug and mitigate] | references/runbooks/HIGH-ERROR-RATE.md |
| Certificate renewal | [e.g., Manual cert renewal] | references/runbooks/CERT-RENEWAL.md |
| [Region failover] | [e.g., DR failover] | references/runbooks/DR-FAILOVER.md |

*Create runbooks as separate documents; link to them here. Runbooks should include: prerequisites, step-by-step procedure, verification, rollback if applicable.*

---

## Quality Checklist

Before marking the DevOps plan complete, verify:

- [ ] CI/CD pipeline stages, triggers, and quality gates are documented
- [ ] Build, test, and deploy steps are specified for each environment
- [ ] Artifact storage and versioning are defined
- [ ] Deployment strategy (blue-green, rolling, canary) is chosen with rationale
- [ ] Rollback procedure is documented with triggers and steps
- [ ] All environments (dev, staging, production) are defined with purpose and characteristics
- [ ] Environment parity between staging and production is addressed
- [ ] Infrastructure requirements (cloud provider, services, regions) are specified
- [ ] Scaling approach is documented
- [ ] Container strategy is documented (or "Not applicable" with rationale)
- [ ] Secrets management: storage, rotation, access control, emergency procedures
- [ ] No secrets in code or unencrypted storage
- [ ] Monitoring: metrics, logs, traces, dashboards, alerting rules
- [ ] On-call and escalation path are defined
- [ ] Backup frequency, retention, and storage are documented
- [ ] RTO and RPO targets are defined
- [ ] Disaster recovery procedure is documented
- [ ] Cost management: budget, optimization approach, billing alerts
- [ ] Runbook references are listed for common operational scenarios
