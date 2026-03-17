# Error Handling for Cross-Cutting Testing Strategy

## Missing Per-Story Artifacts

- **Trigger**: One or more required per-story artifacts (`story.md`, `api.md`, `security.md`) do not exist.
- **Action**: Do not proceed with incomplete inputs. Report which stories are missing which artifacts.
- **Action**: Request that missing artifacts be created before testing strategy planning.
- **Prohibited**: Do not guess acceptance criteria or API endpoints from other sources.

## Vague Acceptance Criteria

- **Trigger**: Acceptance criteria in story.md are vague or unverifiable (e.g., "works well," "user friendly").
- **Action**: Flag which ACs are vague and which stories they belong to.
- **Action**: Request that the Story Decomposer or Planning Hub clarify or rephrase for testability.
- **Prohibited**: Do not invent testable criteria — work with what exists or escalate.

## Conflicting Test Requirements

- **Trigger**: Testing requirements conflict (e.g., testing strategy says E2E for X, but DevOps constraints limit E2E runtime).
- **Action**: Surface the conflict with specific references.
- **Action**: Reconcile with user or escalate to Planning Hub.
- **Prohibited**: Do not silently drop or contradict requirements.

## Missing Performance Baselines

- **Trigger**: PRD NFRs do not define performance targets, or performance plan has no baselines.
- **Action**: Flag that performance baselines are missing.
- **Action**: Request PRD clarification or document assumptions with explicit "[ASSUMPTION]" tag.
- **Prohibited**: Do not invent performance targets without PRD backing.

## Missing security-overview.md

- **Trigger**: `plan/cross-cutting/security-overview.md` does not exist.
- **Action**: Flag that security testing alignment cannot be verified.
- **Action**: Request Security agent dispatch or document security testing assumptions.
- **Prohibited**: Do not invent security overview requirements.

## Validation Failures

- **Trigger**: Self-validation checks (see `5_validation.md`) fail.
- **Action**: Do not write `testing-strategy.md`.
- **Action**: Report which checks failed and what is missing.
- **Action**: Iterate on the strategy until all checks pass.
