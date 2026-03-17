# Decision Guidance for Cross-Cutting Testing Strategy

## Test Framework Selection

- Choose frameworks consistent with tech stack and team expertise.
- Unit: Jest, pytest, JUnit, etc. — match language and ecosystem.
- Integration: Supertest, requests, RestAssured — match API style.
- E2E: Playwright, Cypress, Selenium — consider speed, reliability, CI fit.
- Document the choice and rationale.

## When to Use E2E vs Integration

- **E2E**: Critical user flows that span multiple services or systems. Few, slow, high confidence.
- **Integration**: API contracts, database interactions, service boundaries. Many, faster, good coverage.
- Prefer integration over E2E when the same behavior can be verified at the integration boundary.
- Avoid E2E for logic that integration tests can cover.

## Accessibility Testing Tool Selection

- **Automated**: axe-core, Pa11y, Lighthouse — for regression and quick checks.
- **Manual**: Keyboard navigation, screen reader testing (NVDA, VoiceOver, JAWS).
- Combine both — automated catches many issues; manual catches interaction and context.
- Target WCAG 2.2 AA. Document which criteria need manual verification.

## Performance Testing Approach

- **Load testing**: Simulate expected load, verify response times and throughput.
- **Stress testing**: Find breaking point, understand degradation.
- **Benchmarks**: Establish baselines from PRD NFRs.
- Choose tools (k6, Gatling, JMeter, Artillery) based on stack and CI integration.
- Define when performance tests run (every PR vs nightly vs pre-release).

## Test Data Management

- **Fixtures**: Static data for deterministic tests.
- **Factories**: Generated data for variety and isolation.
- **Anonymized production**: When realistic data is needed — ensure no PII.
- Define isolation strategy — tests must not interfere with each other.
- Document sensitive data handling.

## Boundaries

- **ALLOW**: Test pyramid design, coverage mapping, test type selection, CI/CD gate definition, accessibility plan, performance plan, security test plan.
- **DENY**: Writing actual test code, per-story implementation details, scope beyond testing strategy.
