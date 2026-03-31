# Cross-Cutting Testing Strategy Workflow (Phase 4)

## Overview

Testing Strategy Agent produces the cross-cutting testing strategy. It writes to `plan/cross-cutting/testing-strategy.md`. The agent focuses on inventorying acceptance criteria, designing the test pyramid, planning specialized testing (API, security, accessibility, performance), and defining CI/CD test gates — synthesizing inputs from all per-story artifacts.

## Initialization

1. **Load planning-testing-strategy skill** — Use the skill for templates, patterns, and testing reference.
2. **Verify required inputs exist**:
   - All `plan/user-stories/*/story.md` (acceptance criteria)
   - All `plan/user-stories/*/api.md` (API endpoints for API testing)
   - All `plan/user-stories/*/security.md` (security controls for security testing)
   - `plan/cross-cutting/security-overview.md`
   - `plan/system-architecture.md` (integration points)
   - `plan/prd.md` (NFRs for performance)

   If any are missing, report the gap and request them before proceeding.

## Main Workflow

### Phase 1: Acceptance Criteria Inventory

- Read all `story.md` files — extract every acceptance criterion.
- Categorize each AC by test type: unit, integration, E2E, manual.
- Map each AC to its story and story artifacts.
- Identify acceptance criteria that span multiple stories.

### Phase 2: Test Pyramid Design

- Define test pyramid distribution (unit, integration, E2E ratios).
- For each level, define what gets tested and boundaries.
- Define mock/stub strategy for isolation.

### Phase 3: Specialized Testing Plans

- **API Testing**: From all `api.md` — endpoint coverage, error scenarios, auth testing.
- **Security Testing**: From `security.md` and security-overview — SAST/DAST, penetration scope, dependency scanning.
- **Accessibility Testing**: WCAG 2.2 AA compliance — automated and manual approach. See `references/ACCESSIBILITY-TESTING.md`.
- **Performance Testing**: From PRD NFRs — load, stress, baselines.

### Phase 4: CI/CD Test Gates

- Define which tests run at each CI/CD stage.
- Define pass/fail criteria for each gate.
- Define test environment and test data requirements.

### Phase 5: Review with User

- Present testing strategy with coverage mapping.
- Apply sparring protocol — challenge uncovered ACs, test boundaries, accessibility sufficiency.
- Iterate until user approves.

### Phase 6: Completion

- Run self-validation (see `5_validation.md`).
- Write to `plan/cross-cutting/testing-strategy.md`.
- Report completion to the Planning Hub.

## Completion Criteria

- [ ] `testing-strategy.md` written to `plan/cross-cutting/`
- [ ] Every acceptance criterion mapped to a test type
- [ ] Test pyramid defined with ratios
- [ ] Accessibility plan exists (WCAG 2.2 AA)
- [ ] Performance plan exists (from PRD NFRs)
- [ ] Security testing plan exists
- [ ] CI/CD gates defined
- [ ] Self-validation passed before write
