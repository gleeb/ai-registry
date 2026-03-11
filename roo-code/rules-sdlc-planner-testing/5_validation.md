# Self-Validation for Cross-Cutting Testing Strategy

## Posture

**Default FAIL** — Do not write `testing-strategy.md` until all checks pass. If any check fails, iterate on the strategy before writing.

## Validation Checks

### Every AC Mapped to Test Type

- Each acceptance criterion from all story.md files has a test type mapping.
- No AC is left unmapped or "TBD."
- Coverage mapping is explicit and traceable.

### Test Pyramid Defined

- Test pyramid distribution (unit, integration, E2E ratios) is documented.
- Boundaries between levels are clear.
- Rationale for the distribution is stated.

### Accessibility Plan Exists

- Accessibility testing approach is documented.
- WCAG 2.2 AA is the target.
- Both automated and manual testing are addressed.
- No "accessibility is optional" or deferred.

### Performance Plan Exists

- Performance testing approach is documented.
- Baselines are derived from PRD NFRs.
- Load, stress, or benchmark strategy is defined.
- Regression detection is addressed.

### Security Testing Plan Exists

- Security testing aligns with security-overview.md and per-story security.md.
- SAST, DAST, dependency scanning, or penetration scope is defined.
- Security controls are mapped to test scenarios.

### CI/CD Gates Defined

- Which tests run at each CI/CD stage is documented.
- Pass/fail criteria for each gate are defined.
- No undefined or vague gates.

## Validation Flow

1. Run all checks after specialized testing plans and CI/CD gates phase.
2. If any check fails — iterate, do not write.
3. Do not write `testing-strategy.md` until all checks pass.
4. Report validation status to the user upon completion.
