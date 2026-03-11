# Per-Story Validation Specification

## Purpose

Per-story validation checks internal consistency within a single user story's planning folder. It runs after Phase 3 agents complete work on a story, before the story is considered ready.

## Validation Posture

Default to NEEDS WORK. Every check starts as FAIL and must be proven PASS with explicit evidence. A story with zero findings is suspicious — dig deeper.

## Input

The Validator receives a path to a single story folder: `plan/user-stories/US-NNN-name/`

## Checks

### 1. Dependency Manifest Completeness

Read `story.md` and verify the dependency manifest header:

- `prd_sections`: Non-empty. Each referenced PRD section exists in `plan/prd.md`.
- `architecture_components`: Non-empty. Each referenced component exists in `plan/system-architecture.md`.
- `provides_contracts`: If present, each contract file exists in `plan/contracts/` and lists this story as owner.
- `consumes_contracts`: If present, each contract file exists in `plan/contracts/` and lists this story as consumer.
- `depends_on_stories`: If present, each referenced story folder exists.
- `execution_order`: Present and is a positive integer.

### 2. Acceptance Criteria Traceability

For each acceptance criterion in `story.md`:

- At least one downstream artifact (hld.md, api.md, data.md, security.md) addresses it.
- The connection is explicit, not inferred — the downstream artifact references the criterion.

### 3. HLD-to-Story Alignment

If `hld.md` exists:

- Every component or module in hld.md traces to a story acceptance criterion.
- No component in hld.md is out-of-scope for this story.
- Technology choices in hld.md align with `plan/system-architecture.md`.

### 4. API-to-HLD Alignment

If `api.md` exists:

- Every endpoint in api.md maps to a component or flow in hld.md.
- Request/response schemas reference contract definitions where applicable.
- Authentication and authorization align with security.md (if present).

### 5. Data-to-API Alignment

If `data.md` exists:

- Every entity in data.md is referenced by at least one API endpoint or HLD component.
- Entity fields align with API request/response schemas.
- Data lifecycle (creation, update, deletion) is consistent with API operations.

### 6. Security Controls

If `security.md` exists:

- Authentication requirements align with consumed `auth-model` contract (if any).
- Authorization rules cover all API endpoints.
- Data protection measures cover all PII/sensitive fields in data.md.
- No security requirement from the PRD is unaddressed.

### 7. Contract Compliance

For each consumed contract:

- The story's artifacts (api.md, data.md) use the contract's definitions exactly — no local redefinitions that contradict the contract.
- If the story extends a contract (adds optional fields), the extensions are documented and do not break the contract's invariants.

For each provided contract:

- The contract file in `plan/contracts/` accurately reflects what this story implements.
- The contract definition is complete enough for consumer stories to depend on.

### 8. Design Coverage (if UI story)

If `design/` directory exists:

- Every user-facing flow in the story's acceptance criteria has at least one mockup.
- Mockups reference the global design spec (`plan/design/design-spec.md`) for component patterns.
- Error, empty, and loading states are present for interactive screens.

### 9. Files Affected Completeness

If `story.md` has a "Files Affected" section:

- Each listed file is consistent with the story's HLD (components map to file paths).
- No file is listed that belongs to another story's scope.

## Report Format

```markdown
# Per-Story Validation: US-NNN-name

## Summary
- Status: NEEDS WORK | PASS
- Checks run: N
- Passed: N
- Failed: N
- Observations: N

## Check Results

### 1. Dependency Manifest Completeness
- Status: PASS | FAIL
- Evidence: {what was checked, what was found}
- Finding: {specific issue or confirmation}

{Repeat for each check}

## Observations
{Non-blocking observations, questions, or areas for deeper review}
```
