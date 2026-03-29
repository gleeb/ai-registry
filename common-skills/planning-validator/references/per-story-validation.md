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

### 10. Semantic Spot-Check

See [`references/semantic-spot-checks.md`](references/semantic-spot-checks.md) for the full procedure.

Select 2-3 acceptance criteria and verify they correctly interpret the PRD requirement they reference — by meaning, not just section number.

- Read the AC text and the referenced PRD section.
- Verify the AC captures the PRD's intent (not a broadened, narrowed, or misinterpreted version).
- On failure: produce a reasoned correction explaining what the PRD actually means and what the corrected AC should say.

### 11. Terminology Consistency

See [`references/terminology-enforcement.md`](references/terminology-enforcement.md) for the full procedure.

Build a term registry from contracts and architecture, then check this story's artifacts for naming drift.

- Extract canonical terms from `plan/contracts/` and `plan/system-architecture.md`.
- Search the story's artifacts (story.md, hld.md, api.md, data.md, security.md) for divergent terms.
- Flag Important and Critical drift as NEEDS WORK (not deferred DRIFT).
- On failure: provide the canonical term, its source, and why consistency matters for downstream implementation.

### 12. Story Testability Assessment

Verify the story's HLD includes a testability section and that acceptance criteria have concrete test approaches:

- The story's `hld.md` must include a **Testability** section (or equivalent) specifying the test approach per AC.
- Each AC must have an explicit test type assigned: unit, integration, E2E, or manual.
- At least one AC per story must have an integration or E2E test type — stories with only unit tests are insufficient for confidence.
- If the story has UI-facing ACs (user interactions, screens, forms), at least one E2E test scenario must be specified.
- ACs involving validation, error handling, or conditional logic must specify negative/error-path test coverage (not just happy path).
- ACs with input handling must specify boundary condition testing (min/max, empty, null/undefined).

## Guidance Production (on NEEDS WORK)

When the overall verdict is NEEDS WORK, produce a guidance package using the format from [`references/planning-guidance-format.md`](references/planning-guidance-format.md):

1. For each failing check, include a **reasoned correction** — what the better artifact looks like and why.
2. Identify **knowledge gaps** — what the local planning model seems to misunderstand.
3. Provide **documentation guidance** for identified knowledge gaps — either fetch relevant docs via context7 MCP directly, or provide specific fetch instructions (search terms, library, section) for the local model to retrieve via context7 itself.
4. Produce consolidated **improvement instructions** structured for direct inclusion in a re-dispatch.

The Planning Hub extracts this guidance and includes it in the `VALIDATOR GUIDANCE` section of re-dispatches to local planning agents.

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

{Repeat for checks 2-11}

### 12. Story Testability Assessment
- Status: PASS | FAIL
- Evidence: {ACs checked, test types found in HLD testability section}
- Finding: {specific issue or confirmation}

## Observations
{Non-blocking observations, questions, or areas for deeper review}
```
