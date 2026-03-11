# Impact Analysis Specification

## Purpose

Impact analysis is a **read-only pre-planning step** that traces the dependency graph from a proposed change point and reports the blast radius. It answers: "If I change X, what else is affected?" before any re-planning begins.

## When to Use

The Plan Validator runs in impact analysis mode when:

1. The user proposes a change to any plan artifact.
2. The Planning Hub detects a validation failure that requires re-planning.
3. A contract change is detected that may cascade to consumer stories.

## Input

The Validator receives:

```markdown
CHANGE DESCRIPTION: {what is changing}
CHANGE LEVEL: PRD | Architecture | Story (internal) | Story (contract) | Cross-cutting
AFFECTED ARTIFACT: {file path of the artifact being changed}
PROPOSED CHANGE SUMMARY: {brief description of the change}
```

## Analysis Process

### Step 1: Read Dependency Graph

1. Read all `story.md` files and extract dependency manifests.
2. Read all contract files in `plan/contracts/` and extract owner/consumer relationships.
3. Build an in-memory dependency graph:
   - PRD sections -> stories (via `prd_sections` in manifests)
   - Architecture components -> stories (via `architecture_components` in manifests)
   - Contracts -> owner story + consumer stories (via `provides_contracts` / `consumes_contracts`)
   - Story -> story (via `depends_on_stories`)

### Step 2: Trace from Change Point

Starting from the changed artifact, follow edges in the dependency graph:

- **PRD section changed**: Find all stories whose `prd_sections` include the changed section. For each, find downstream contracts and their consumers.
- **Architecture component changed**: Find all stories whose `architecture_components` include the changed component. Check if component boundaries affect story boundaries.
- **Contract changed**: Find the owner story and all consumer stories. For each consumer, check if their HLD, API, or data artifacts reference the changed contract fields.
- **Story changed internally**: Check if the story provides contracts. If yes, check whether the internal change affects the contract definition.

### Step 3: Classify Impact

For each affected artifact, classify the impact:

| Classification | Meaning | Action Required |
|---------------|---------|-----------------|
| **Direct** | The artifact directly references the changed item | Re-validation required, likely re-planning |
| **Indirect** | The artifact depends on something that depends on the changed item | Re-validation required, re-planning only if validation fails |
| **Unaffected** | No dependency path to the changed item | No action |

### Step 4: Report Blast Radius

Produce a structured report:

```markdown
# Impact Analysis Report

## Change
- Description: {change description}
- Level: {change level}
- Artifact: {file path}

## Blast Radius

### Directly Affected Stories
| Story | Dependency Path | Impact |
|-------|----------------|--------|
| US-NNN | prd_sections includes 7.3 | Scope may change |
| US-NNN | consumes_contracts includes auth-model | API contract dependency |

### Directly Affected Contracts
| Contract | Impact |
|----------|--------|
| auth-model.md | Owner story changed, definition may update |

### Indirectly Affected Stories
| Story | Dependency Path | Impact |
|-------|----------------|--------|
| US-NNN | depends_on_stories includes US-002 (directly affected) | May need re-validation |

### Cross-Cutting Impact
| Concern | Impact |
|---------|--------|
| Security Overview | YES — per-story security controls affected |
| Testing Strategy | YES — acceptance criteria may change |
| DevOps | NO |

### Unaffected Stories
{List of stories confirmed unaffected}

## Recommended Re-Planning Scope
- Stories to re-plan: [US-NNN, US-NNN]
- Stories to re-validate only: [US-NNN]
- Contracts to update: [auth-model]
- Cross-cutting to re-validate: [security-overview, testing-strategy]
- Estimated effort: {number of agent dispatches}
```

## Constraints

- Impact analysis is READ-ONLY. Never modify plan artifacts during analysis.
- Report ALL affected items, even if the impact seems minor. Let the Hub and user decide scope.
- If the dependency graph has cycles, report them as a structural issue.
- If a story has no dependency manifest, flag it as an analysis gap.
