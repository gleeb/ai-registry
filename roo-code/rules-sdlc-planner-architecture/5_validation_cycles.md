# validation_cycles

## overview

The System Architecture agent performs self-validation before presenting the draft to the user and before completing.
Validation ensures completeness, consistency, and quality of the architecture specification.

## self_validation_checks

### check: component_coverage

**description:** All PRD capabilities mapped to components

**criteria:**

- Every capability in the PRD has at least one component responsible for it.
- No PRD capability is orphaned or unassigned.

### check: technology_justification

**description:** Every technology choice justified

**criteria:**

- Every technology in the stack has a documented rationale.
- Trade-offs are documented.
- No "industry standard" without project-specific justification.

### check: integration_completeness

**description:** All integration points defined

**criteria:**

- Every component-to-component communication has an integration pattern (sync/async, protocol, failure handling).
- External integrations are documented.
- Integration failure modes are addressed.

### check: failure_mode_coverage

**description:** Failure modes addressed

**criteria:**

- Every component has failure detection and handling.
- Every integration has timeout, retry, or circuit breaker strategy.
- Single points of failure are identified and mitigated or documented as accepted risk.

### check: scalability_rationale

**description:** Scalability grounded in evidence

**criteria:**

- Scalability strategy references PRD projections or explicit constraints.
- Quantified targets exist (load, users, data volume).
- No vague "we can scale" without strategy.

## validation_schedule

### validation (phase: before_draft_presentation)

**trigger:** Draft complete, before presenting to user

**checks:**

- component_coverage
- technology_justification
- integration_completeness
- failure_mode_coverage
- scalability_rationale

### validation (phase: before_completion)

**trigger:** User confirmed architecture, before writing final artifact

**checks:**

- All sparring challenges resolved or explicitly accepted.
- No placeholder content.
- plan/system-architecture.md is ready for downstream agents.

## validation_failure_handling

- If any check fails, address the gap before proceeding.
- For component_coverage: add missing components or map to existing ones.
- For technology_justification: add rationale or dispatch research.
- For failure_mode_coverage: document failure handling for each component and integration.
