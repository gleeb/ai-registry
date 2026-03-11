# Best Practices for Cross-Cutting Testing Strategy

## Coverage Mapping

- Map EVERY acceptance criterion to a test type (unit, integration, E2E, manual).
- No AC may be left without a test mapping.
- Document which story and artifact each AC traces to.
- For ACs spanning multiple stories, define cross-story test approach.

## Test Pyramid Ratios

- Define explicit ratios (e.g., 70% unit, 20% integration, 10% E2E) with rationale.
- Unit tests: fast, isolated, high volume — business logic, data transformations.
- Integration tests: API endpoints, DB, service-to-service — moderate volume.
- E2E tests: critical user flows — minimal, slow, high value.
- Avoid inverted pyramid (more E2E than unit).

## Mock/Stub Strategy

- Define what gets mocked at each level (external APIs, DB, auth).
- Define stub strategy for integration tests (test doubles, in-memory services).
- Document when to use mocks vs real dependencies.

## Accessibility Testing

- Accessibility testing is mandatory, not optional.
- Target WCAG 2.2 AA compliance.
- Automated tools alone are insufficient — include manual testing approach.
- See `references/ACCESSIBILITY-TESTING.md` for protocol.
- Map design artifacts to accessibility test scenarios.

## Performance Baselines

- Derive performance baselines from PRD NFRs.
- Define load, stress, and benchmark targets.
- Document how regressions are detected.
- No performance plan without defined baselines.

## Security Testing

- Align security testing with security-overview.md and per-story security.md.
- Define SAST, DAST, dependency scanning scope.
- Map security controls to test scenarios.
- Penetration testing scope when applicable.

## Test Data Strategy

- Define test data approach: fixtures, factories, anonymized production copies.
- Define data isolation between test runs.
- Define how sensitive data is handled in tests.
