---
name: planning-testing-strategy
description: Cross-cutting Testing Strategy specialist. Use when the Planning Hub dispatches testing strategy work in Phase 4 after all per-story planning is complete. Reads all per-story acceptance criteria, API specs, and security controls. Defines test pyramid, coverage mapping, integration test plan, E2E scenarios, accessibility testing plan, and CI/CD test gates. Writes to plan/cross-cutting/testing-strategy.md.
---

# Planning Testing Strategy (Cross-Cutting, Phase 4)

## When to use
- Use when the Planning Hub dispatches Testing Strategy work (`sdlc-planner-testing`).
- Use when all per-story planning (Phase 3) is complete and validated.
- Use when updating or revising existing testing strategy.

## When NOT to use
- DENY use for writing actual test code — testing strategy is planning only.
- DENY use before Phase 3 is complete (testing needs all story artifacts).
- DENY use for per-story test details — focus on cross-cutting strategy.

## Inputs required
1. All `plan/user-stories/*/story.md` — acceptance criteria for coverage mapping.
2. All `plan/user-stories/*/api.md` — API endpoints for API test planning.
3. All `plan/user-stories/*/security.md` — security controls for security testing.
4. `plan/cross-cutting/security-overview.md` — aggregate security testing needs.
5. `plan/system-architecture.md` — integration points for integration test planning.
6. `plan/prd.md` — NFRs for performance and reliability testing.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

### Phase 1: Acceptance Criteria Inventory

1. Read all story.md files and extract all acceptance criteria.
2. Categorize each AC by test type: unit, integration, E2E, manual.
3. Map each AC to the story and story artifacts it traces to.
4. Identify acceptance criteria that span multiple stories.

### Phase 2: Test Pyramid Design

1. Define the test pyramid distribution (unit, integration, E2E ratios).
2. For each test level, define what gets tested:
   - **Unit**: individual functions, business logic, data transformations.
   - **Integration**: API endpoints, database queries, service-to-service calls.
   - **E2E**: complete user flows, cross-service scenarios.
3. Define mock/stub strategy for isolation.

### Phase 3: Specialized Testing Plans

1. **API Testing**: Based on all api.md files — endpoint coverage, error scenarios, auth testing.
2. **Security Testing**: Based on security controls — penetration testing scope, SAST/DAST tools, dependency scanning.
3. **Accessibility Testing**: Based on design artifacts — WCAG 2.2 AA compliance testing approach. See [`references/ACCESSIBILITY-TESTING.md`](references/ACCESSIBILITY-TESTING.md).
4. **Performance Testing**: Based on PRD NFRs — load testing, stress testing, benchmarks.

### Phase 4: CI/CD Test Gates

1. Define which tests run at each CI/CD stage.
2. Define pass/fail criteria for each gate.
3. Define test environment requirements.
4. Define test data strategy.

### Phase 5: Review and Completion

1. Present testing strategy with coverage mapping.
2. Apply sparring — challenge coverage gaps, test isolation, CI/CD gates.
3. Write to `plan/cross-cutting/testing-strategy.md`.

## Sparring Protocol

- "Which acceptance criterion has no test? Show me the coverage gap."
- "Is this test an integration test or a unit test? Be precise about boundaries."
- "What happens when this E2E test fails in CI? How do you diagnose it?"
- "Have you covered error scenarios for all API endpoints?"
- "How do you test accessibility? Automated tools alone aren't sufficient."
- "What's the performance baseline? How do you detect regressions?"

## Output

- `plan/cross-cutting/testing-strategy.md` — the cross-cutting testing strategy.

## Files

- [`references/TESTING-STRATEGY.md`](references/TESTING-STRATEGY.md): Testing strategy template and quality checklist.
- [`references/ACCESSIBILITY-TESTING.md`](references/ACCESSIBILITY-TESTING.md): WCAG 2.2 AA testing protocol.

## Troubleshooting

- If per-story artifacts are incomplete, flag which stories need completion.
- If acceptance criteria are vague, flag for the Hub to re-dispatch story clarification.
- If security testing requirements conflict with DevOps constraints, reconcile.
