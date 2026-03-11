# Testing Strategy Template

## Purpose

Use this format when drafting or refining a Testing Strategy specification. The testing strategy document is the single source of truth for test approach, coverage requirements, test data, environments, QA gates, and traceability from acceptance criteria to tests. It must be validated before implementation proceeds.

## Contract gates

- REQUIRE all 13 sections to be substantive before the testing strategy is considered complete.
- REQUIRE every acceptance criterion to map to at least one test type — no orphaned criteria.
- REQUIRE coverage targets to include rationale — no arbitrary 100% without justification.
- REQUIRE test data strategy to address fixtures, factories, seeding, cleanup, and sensitive data.
- REQUIRE QA gates to align with deployment workflow (PR, merge, pre-deploy).
- DENY proceeding to implementation before user validates the testing strategy.
- ALLOW provisional draft only when clearly marked `PROVISIONAL - NOT VALIDATED`.

---

## Template

### 1) Metadata

| Field | Value |
|-------|-------|
| Document Version | 0.1.0 |
| Last Updated | [date] |
| Author | [name] |
| Status | Draft / Review / Approved |
| PRD Reference | plan/prd.md (version/date) |
| HLD Reference | plan/hld.md (version/date) |
| System Architecture Reference | plan/system-architecture.md (version/date) |
| Security Plan Reference | plan/security.md (version/date) — for security testing alignment |

---

### 2) Testing Philosophy

**Approach**

- [Primary testing philosophy: test pyramid, testing trophy, risk-based, etc.]
- [Balance between speed and confidence: fast feedback vs. comprehensive coverage]
- [Shift-left vs. shift-right: where does testing happen in the pipeline?]

**Priorities**

- [Top 3 testing priorities for this project, e.g., critical user flows, API contract stability, performance NFRs]
- [What must never regress without detection?]
- [What can be tested manually or deferred?]

**Trade-offs**

- [Explicit trade-offs: e.g., "We favor integration tests over unit tests at boundaries to catch contract breaks"]
- [What we are NOT testing and why]
- [Acceptable risk areas with justification]

---

### 3) Test Levels

| Level | Scope | Tools | Coverage Target | Rationale | Execution Frequency |
|-------|-------|-------|-----------------|-----------|----------------------|
| Unit | [Functions, classes, modules in isolation] | [e.g., Jest, pytest, JUnit] | [e.g., 70% line, 80% branch] | [Why this target] | [Every commit / PR] |
| Integration | [Component boundaries, DB, APIs, message queues] | [e.g., pytest + testcontainers, Supertest] | [e.g., 100% of public APIs] | [Why this target] | [Every PR / merge] |
| E2E | [Critical user flows, full stack] | [e.g., Playwright, Cypress] | [100% of critical flows] | [List critical flows] | [Every PR / nightly] |
| Performance | [Load, stress, soak] | [e.g., k6, Locust, Artillery] | [NFR thresholds met] | [From PRD] | [Pre-release / weekly] |
| Security | [SAST, DAST, dependency scan] | [From security plan] | [No high/critical vulns] | [From security plan] | [Every PR / nightly] |
| Accessibility | [WCAG compliance] | [e.g., axe, Lighthouse] | [WCAG 2.1 AA] | [From PRD/design] | [Every PR / pre-release] |

**Notes**

- [Any level-specific clarifications, e.g., "Unit tests exclude generated code and third-party libraries"]
- [Flaky test policy: how to handle, when to quarantine]

---

### 4) Test Framework and Tooling

| Level | Tool | Version | Rationale |
|-------|------|---------|-----------|
| Unit | [Tool name] | [version] | [Why chosen: ecosystem fit, speed, mocking support, etc.] |
| Integration | [Tool name] | [version] | [Why chosen: container support, DB fixtures, etc.] |
| E2E | [Tool name] | [version] | [Why chosen: browser support, CI compatibility, etc.] |
| Performance | [Tool name] | [version] | [Why chosen: scripting, reporting, etc.] |
| Security | [Tool name] | [version] | [From security plan; cross-ref] |
| Accessibility | [Tool name] | [version] | [Why chosen: WCAG rules, integration] |
| Test runner / orchestration | [Tool name] | [version] | [How tests are invoked, parallelization] |
| Coverage reporting | [Tool name] | [version] | [How coverage is measured and reported] |

**Tooling Constraints**

- [CI environment constraints: memory, CPU, timeout limits]
- [Local vs. CI: any tools that run only locally or only in CI]

---

### 5) Test Data Strategy

**Approach**

- [Primary approach: fixtures, factories, seeding, or combination]
- [When to use each: unit tests use mocks/fixtures; integration tests use seeded DB; e2e may use staging data]

**Fixtures**

- [Location: e.g., `tests/fixtures/`]
- [Format: JSON, YAML, SQL dumps]
- [Maintenance: who updates, when]
- [Scope: which tests use which fixtures]

**Factories**

- [Library: e.g., FactoryBot, Faker, hypothesis]
- [Where factories live]
- [How to generate realistic but anonymized data]
- [Relationship handling: nested objects, foreign keys]

**Seeding**

- [How integration/e2e tests seed the database]
- [Seed scripts location and invocation]
- [Idempotency: can seeds run multiple times?]
- [Order dependencies: migration order, seed order]

**Cleanup**

- [Per-test cleanup: transactional rollback, truncate, drop/recreate]
- [Parallel test isolation: separate DBs, schemas, or containers]
- [Orphaned data policy: how to prevent and detect]
- [CI cleanup: disk space, container teardown]

**Sensitive Data Handling**

- [No real PII, credentials, or payment data in tests]
- [Anonymization approach: hashing, masking, synthetic generation]
- [Secrets in test env: how injected, never committed]
- [Compliance: GDPR, PCI test data requirements]

---

### 6) Test Environment Requirements

| Level | Environment | Characteristics | Data |
|-------|-------------|-----------------|------|
| Unit | [Local / CI] | [No external deps; mocks only] | [In-memory or fixtures] |
| Integration | [CI containers / local Docker] | [Real DB, testcontainers, or embedded] | [Seeded from fixtures/factories] |
| E2E | [CI / staging] | [Full stack; browser or headless] | [Seeded or staging snapshot] |
| Performance | [Staging / dedicated perf env] | [Production-like; isolated] | [Synthetic or anonymized prod-like] |
| Security | [CI / dedicated scan env] | [As per security plan] | [N/A or test targets] |
| Accessibility | [CI / local] | [Same as E2E or unit for components] | [Same as E2E] |

**Environment Parity**

- [How CI differs from local: document known differences]
- [Staging vs. production: what is different, what must match]
- [Environment variables: required for each level, where defined]

---

### 7) QA Gates

| Gate | Stage | Criteria | Blocking? |
|------|-------|----------|-----------|
| Lint | PR | [Linter passes] | Yes |
| Unit tests | PR | [All pass; coverage ≥ target] | Yes |
| Integration tests | PR / Merge | [All pass; no flaky failures] | Yes |
| E2E smoke | PR / Merge | [Critical flows pass] | Yes |
| Security scan | PR / Nightly | [No high/critical vulns] | [Yes/No — specify] |
| Performance baseline | Pre-release | [NFR thresholds met] | Yes |
| Accessibility | PR / Pre-release | [Automated checks pass] | [Yes/No — specify] |
| Manual QA | Pre-release | [Checklist completed] | [Yes/No — specify] |

**Gate Failure Handling**

- [Who is notified on gate failure]
- [Flaky test policy: retry count, quarantine process]
- [Override process: when and how gates can be bypassed (e.g., emergency hotfix)]

---

### 8) Acceptance Criteria Traceability

| User Story | Acceptance Criterion | Test Type | Test Location |
|------------|----------------------|-----------|---------------|
| US-001 | AC-1.1: [criterion] | Unit | [path or suite] |
| US-001 | AC-1.2: [criterion] | Integration | [path or suite] |
| US-002 | AC-2.1: [criterion] | E2E | [path or suite] |
| ... | ... | ... | ... |

**Traceability Rules**

- [Every acceptance criterion must map to at least one test type]
- [Critical flows must have E2E coverage]
- [API contracts must have integration tests]
- [Orphaned criteria: flag and resolve before completion]

---

### 9) Performance Testing

**Approach**

- [When performance tests run: pre-release, weekly, on-demand]
- [What is tested: APIs, critical user flows, batch jobs]
- [Baseline establishment: how baselines are set and updated]

**Tools**

- [Primary tool, e.g., k6, Locust, Artillery]
- [How tests are scripted and versioned]
- [Reporting: where results go, how to compare]

**Scenarios**

| Scenario | Type | Target | Threshold |
|----------|------|--------|-----------|
| [e.g., API health check] | Load | [RPS] | [p95 < 200ms] |
| [e.g., checkout flow] | Load | [concurrent users] | [p99 < 2s] |
| [e.g., spike test] | Stress | [ramp-up] | [no errors until X RPS] |
| [e.g., 24h run] | Soak | [duration] | [no memory leak, error rate < 0.1%] |

**Frequency**

- [Load tests: every release / weekly]
- [Stress/soak: quarterly / on major changes]
- [Baseline updates: when and who approves]

---

### 10) Security Testing

**Cross-Reference**

- Primary security testing requirements are defined in `plan/security.md`. This section summarizes testing implementation.

**SAST (Static Application Security Testing)**

- [Tool, e.g., Semgrep, SonarQube, CodeQL]
- [When it runs: every PR]
- [What is scanned: codebase, config files]
- [Failure criteria: high/critical findings block merge]

**DAST (Dynamic Application Security Testing)**

- [Tool, e.g., OWASP ZAP, Burp]
- [When it runs: nightly / pre-release]
- [Target: staging or dedicated scan environment]
- [Scope: which endpoints, which auth flows]

**Dependency Scanning**

- [Tool, e.g., Dependabot, Snyk, Renovate]
- [When it runs: every PR / daily]
- [Failure criteria: known vulns in direct deps block merge]
- [Indirect deps: policy (fail or warn)]

**Additional**

- [Penetration testing: frequency, scope — from security plan]
- [Secrets scanning: pre-commit hook, CI]
- [Container image scanning: if applicable]

---

### 11) Accessibility Testing

**Target**

- [WCAG level: 2.1 AA recommended; 2.1 AAA if required by PRD]
- [Scope: all user-facing UI, or specific flows]

**Automated Tools**

- [Tool, e.g., axe-core, Pa11y, Lighthouse]
- [Integration: CI, pre-commit, or both]
- [What is scanned: full pages, components, or both]
- [Failure criteria: which rules block merge]

**Manual Checks**

- [Keyboard navigation: tab order, focus indicators, no traps]
- [Screen reader: NVDA, VoiceOver, or both; which flows]
- [Color contrast: manual verification or tool]
- [Responsive and zoom: 200% zoom, mobile viewports]
- [Frequency: every release, for new features, or audit schedule]

**Responsibility**

- [Who performs manual checks: developer, QA, dedicated a11y specialist]
- [Documentation: checklist location, how to run]

---

### 12) Regression Testing

**Strategy**

- [Full regression: when and what scope]
- [Smoke regression: subset for fast feedback]
- [Critical path: minimal set that must always pass]

**Scope**

- [What is included: all automated tests, or subset]
- [What is excluded: deprecated features, known flaky]
- [How scope is maintained: tagged tests, test suites]

**Frequency**

- [Every PR: unit, integration, smoke e2e]
- [Nightly: full e2e, security, performance]
- [Pre-release: full regression + manual checklist]

**Automation Level**

- [Percentage automated vs. manual]
- [Manual regression: checklist, owner, when run]
- [Automation growth plan: target to increase automated coverage]

---

### 13) Test Reporting

**Metrics**

- [Coverage: line, branch, function — per level]
- [Pass rate: trend over time]
- [Flakiness: flaky test count, quarantine count]
- [Execution time: per suite, trend]
- [Defect escape: bugs found in prod that tests should have caught]

**Dashboards**

- [Where metrics are displayed: CI UI, Grafana, custom]
- [Who views them: developers, QA, leads]
- [Refresh frequency]

**Failure Handling**

- [Notification: Slack, email, etc.]
- [Triage: who investigates, SLA]
- [Blame assignment: last commit, flaky test owner]
- [Quarantine process: how tests are quarantined, who can do it]

---

## Quality Checklist

Before marking the testing strategy as complete, verify:

- [ ] All 13 sections are substantive with no placeholders.
- [ ] Every acceptance criterion maps to at least one test type.
- [ ] Coverage targets have rationale; no 100% without justification.
- [ ] Test data strategy covers fixtures, factories, seeding, cleanup, and sensitive data.
- [ ] QA gates are defined and align with deployment workflow.
- [ ] Test environment requirements are documented per level.
- [ ] Performance testing approach includes load, stress, and soak scenarios with thresholds.
- [ ] Security testing cross-references `plan/security.md` and specifies SAST, DAST, dependency scanning.
- [ ] Accessibility testing specifies tools, WCAG level, and manual checks.
- [ ] Regression testing strategy defines scope, frequency, and automation level.
- [ ] Test framework and tooling choices include rationale.
- [ ] CI vs. local environment parity (or known differences) is documented.
- [ ] User has reviewed and approved the strategy.
