# Testing Strategy Agent Dispatch Template

Use this template when dispatching `sdlc-planner-testing` via `new_task`.

## Required Message Structure

```
PLAN: Testing Strategy

CONTEXT:
- [Reference to plan/prd.md — acceptance criteria and NFRs]
- [Reference to plan/hld.md — component design and user stories]
- [Reference to plan/api-design.md — API contracts to test]
- [Reference to plan/security.md — security testing requirements]
- [Whether greenfield or extending existing test suite]

SCOPE:
- IN SCOPE: Test approach (unit/integration/e2e), coverage requirements, test data strategy, QA gates, test environment needs, performance testing approach, security testing approach, accessibility testing
- OUT OF SCOPE: Writing actual test code (execution phase), CI/CD pipeline config (DevOps agent)

EXISTING PLAN ARTIFACTS:
- plan/prd.md: [REQUIRED]
- plan/hld.md: [REQUIRED]
- plan/system-architecture.md: [REQUIRED]
- plan/api-design.md: [if exists]
- plan/security.md: [if exists]
- plan/testing-strategy.md: [exists / does not exist]
- [List any other relevant existing plan files]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- [Acceptance criteria from user stories]
- [Performance thresholds from PRD NFRs]
- [Security testing requirements from security plan]
- [API contract validation needs from API design]
- [Accessibility requirements from PRD/design]

OUTPUT:
- Write the testing strategy to plan/testing-strategy.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that plan/testing-strategy.md has been written
2. Test level breakdown (unit, integration, e2e, performance, security)
3. Coverage targets per level
4. Test data strategy
5. QA gate definitions (what blocks deployment)
6. Test environment requirements
7. Traceability: which acceptance criteria are covered by which test types
8. Unresolved questions or deferred decisions

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
