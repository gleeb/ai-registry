# Testing Strategy Agent Dispatch Template

Use this template when dispatching `sdlc-planner-testing` via `new_task` for Phase 4 cross-cutting testing strategy.

## Required Message Structure

```
PLAN: Cross-Cutting Testing Strategy

CONTEXT:
- All per-story planning is complete and validated
- plan/prd.md: REQUIRED (NFRs, acceptance criteria overview)
- plan/system-architecture.md: REQUIRED (component boundaries, integration points)
- plan/user-stories/*/story.md: REQUIRED (all stories with acceptance criteria)
- plan/user-stories/*/api.md: [list available — for API test planning]
- plan/user-stories/*/security.md: [list available — for security test planning]
- plan/cross-cutting/security-overview.md: [exists / does not exist]

SCOPE:
- IN SCOPE: Testing strategy spanning all stories — test pyramid, coverage mapping from acceptance criteria, integration test plan, E2E test scenarios, accessibility testing plan, performance test plan, CI/CD test gates
- OUT OF SCOPE: Writing actual test code, per-story implementation details

EXISTING PLAN ARTIFACTS:
- plan/cross-cutting/testing-strategy.md: [exists / does not exist]
- [List all existing per-story artifacts for reference]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- Acceptance criteria from ALL story.md files
- API endpoints from ALL api.md files
- Security controls from ALL security.md files
- Architecture integration points for integration testing
- PRD NFRs for performance and reliability testing

SHARED SPARRING RULES:
Read and apply common-skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- Write testing strategy to plan/cross-cutting/testing-strategy.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that plan/cross-cutting/testing-strategy.md has been written
2. Coverage mapping: each story's acceptance criteria → test type and approach
3. Test pyramid distribution (unit, integration, E2E)
4. Accessibility testing approach (WCAG 2.2 AA)
5. Performance testing approach (based on PRD NFRs)
6. CI/CD test gate recommendations
7. Unresolved testing questions or gaps

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
