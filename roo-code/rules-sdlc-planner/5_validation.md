# Planning Hub Validation Gates

## Overview

The Planning Hub dispatches the Plan Validator (sdlc-plan-validator) after each phase.
Validation is a **blocking gate** — the hub does NOT proceed to the next phase until validation passes.

## Phase Validation Schedule

### Phase 1: Requirements

- **Trigger**: PRD agent completes `plan/prd.md`.
- **Validator mode**: Phase validation.
- **Checks**:
  - PRD passes all internal validation dimensions at "high".
  - PRD has all required sections with substantive content.
  - User stories are grouped by feature area.
- **Gate**: ALL checks must pass before dispatching Phase 2 agents.

### Phase 2: Architecture + Story Decomposition

- **Trigger 1**: Architecture agent completes `plan/system-architecture.md`.
- **Checks**:
  - Architecture covers all PRD components and capabilities.
  - Technology stack decisions are consistent and justified.
- **Gate**: Architecture must pass before dispatching Story Decomposer.

- **Trigger 2**: Story Decomposer completes story folders and contract identification.
- **Checks**:
  - Every PRD requirement traces to at least one user story.
  - Dependency manifests are complete and acyclic.
  - Shared contracts are identified with clear ownership.
  - Stories are right-sized (30–60 min execution estimate).
- **Gate**: No CRITICAL findings before dispatching Phase 3 agents.

### Phase 3: Per-Story Planning (loop)

- **Trigger**: All dispatched agents complete for a given story.
- **Validator mode**: Per-story validation.
- **Checks**:
  - HLD covers all story acceptance criteria.
  - API design matches HLD integration points.
  - Data architecture supports HLD data entities.
  - Security controls address identified threats.
  - Contract compliance — consumed contracts used correctly, provided contracts defined.
  - Design mockups cover all UI-facing acceptance criteria (if applicable).
  - Files Affected section is complete and realistic.
- **Gate**: Do not proceed to next story until per-story validation passes.

### Phase 4: Cross-Cutting

- **Trigger**: Security rollup, DevOps, and Testing Strategy agents complete.
- **Validator mode**: Cross-story validation.
- **Checks**:
  - Security overview is consistent across all per-story security files.
  - DevOps supports architecture and security requirements.
  - Testing strategy covers all acceptance criteria across all stories.
  - No cross-story conflicts in technology, data models, auth, or terminology.
- **Gate**: No CRITICAL findings before declaring execution readiness.

### Phase 5: Execution Readiness

- **Validator mode**: Full-chain validation.
- **Checks**:
  - Full-chain traceability: PRD → Architecture → Stories → Per-Story Artifacts → Tests.
  - All contracts have consumers.
  - Execution order respects dependency graph.
- **Gate**: All planning complete when full-chain validation passes.

## Validation Failure Handling

1. If validator returns FAIL with CRITICAL findings, do NOT proceed to next phase.
2. Identify which agents produced the conflicting or incomplete artifacts.
3. Re-dispatch the **minimum set of agents** needed to resolve the issues.
4. Include the validator's specific findings in the re-dispatch message.
5. After agents resolve, re-run validation.
6. If validation fails **3 times** on the same finding, escalate to the user for a decision.
