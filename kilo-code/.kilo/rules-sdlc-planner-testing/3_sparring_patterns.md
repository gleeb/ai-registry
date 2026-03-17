# Sparring Patterns for Cross-Cutting Testing Strategy

## Philosophy

- Challenge coverage gaps and test design decisions that affect quality.
- Surface trade-offs so the user can make informed decisions.
- Challenge assumptions before they become costly to change.

## Challenge Categories

### Uncovered Acceptance Criteria

- Which acceptance criterion has no test? Show the coverage gap.
- Is this AC implicitly covered by another test? Document the trace.
- **No unmapped ACs** — Every AC must map to a test type.

### Test Level Classification

- Is this test a unit test or an integration test? Be precise about boundaries.
- Does this "unit test" hit the database? Reclassify.
- Does this "integration test" mock everything? Reclassify.
- **No fuzzy boundaries** — Define what each level tests.

### E2E vs Integration Boundaries

- When is E2E justified vs integration sufficient?
- E2E for critical user flows only — not every AC.
- Integration for API and service boundaries.
- **No E2E sprawl** — Keep E2E minimal and high-value.

### Accessibility Testing Sufficiency

- Automated tools alone are insufficient — what's the manual testing plan?
- Which WCAG 2.2 AA criteria require manual verification?
- How is keyboard navigation tested? Screen reader compatibility?
- **No "we run axe" and done** — Accessibility needs layered approach.

### Performance Baseline Definition

- What's the performance baseline? From where (PRD NFRs)?
- How do you detect regressions?
- What are the load and stress targets?
- **No vague performance** — Define baselines and detection.

### Security Test Coverage

- Which security controls have no corresponding test?
- Is dependency scanning in the pipeline?
- Are auth and authorization tested for each role?
- **No security blind spots** — Map controls to tests.

## Anti-Pleasing Protocol

- **Uncovered ACs** — Every AC must map to a test type.
- **Automated-only accessibility** — Manual testing is required.
- **Vague performance baselines** — Define from PRD NFRs.
- **Fuzzy test boundaries** — Be precise about unit vs integration vs E2E.
- **Deferred test strategy** — Do not defer to "implement later."
