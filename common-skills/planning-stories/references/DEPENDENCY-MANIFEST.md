# Dependency Manifest Specification

## Purpose

Every `story.md` file includes a machine-readable dependency manifest header that declares what the story depends on and what it provides. This enables mechanical impact analysis — when something changes, follow the graph.

## Format

The dependency manifest is a level-2 heading in `story.md` with YAML-like key-value pairs using Markdown list syntax:

```markdown
## Dependencies
- prd_sections: [7.3, 9.1]
- architecture_components: [inventory-service, api-gateway]
- provides_contracts: [product-entity]
- consumes_contracts: [auth-model]
- depends_on_stories: [US-002]
- execution_order: 3
- candidate_domains: [hld, api, data, security, design]
- integration_dependencies: [sqlite:mock, inventory-api:real]
```

## Fields

### prd_sections (required)

List of PRD section numbers this story addresses. Used for upward traceability.

- Format: List of section numbers (e.g., `[7.3, 9.1, 10.2]`)
- Validation: Each section must exist in `plan/prd.md`
- Empty list is DENIED — every story must trace to at least one PRD section

### architecture_components (required)

List of system architecture components this story touches. Used for architecture-to-story traceability.

- Format: List of component names matching `plan/system-architecture.md` component inventory
- Validation: Each component must exist in the architecture document
- Empty list is DENIED — every story must map to at least one component

### provides_contracts (optional)

List of shared contracts this story defines and owns.

- Format: List of contract names matching files in `plan/contracts/`
- If present, the story is responsible for the contract's accuracy
- The contract file must list this story as owner

### consumes_contracts (optional)

List of shared contracts this story depends on but does not own.

- Format: List of contract names matching files in `plan/contracts/`
- If present, the story's artifacts must use these contract definitions as authoritative
- The contract file must list this story as consumer

### depends_on_stories (optional)

List of stories that must be planned (and ideally executed) before this one.

- Format: List of story IDs (e.g., `[US-001, US-002]`)
- Creates an execution ordering constraint
- Circular dependencies are a structural error — flag immediately

### execution_order (required)

Suggested execution order for this story. Lower numbers execute first.

- Format: Positive integer
- Stories with the same order can be executed in parallel
- Must be consistent with `depends_on_stories` — a story cannot have a lower order than its dependencies

### candidate_domains (required)

List of Phase 3 planning domains needed for this story. The Hub uses this to know which agents to dispatch.

- Format: List from `[hld, api, data, security, design]`
- `hld` is always required
- `design` is only needed for stories with user-facing UI
- `security` is needed when the story handles auth, PII, or sensitive operations
- `api` is needed when the story exposes or consumes API endpoints
- `data` is needed when the story creates or modifies data entities

### story_type (optional)

Classifies the story's execution model. The Engineering Hub uses this to route the story to the correct executor.

- Format: One of `scaffolding | feature | integration | infrastructure` (default: `feature` when absent)
- `scaffolding` — MUST be set on US-001-scaffolding. Signals the Engineering Hub to fast-path the entire story to `@sdlc-engineering-scaffolder` with no task decomposition. The scaffolder owns the full story lifecycle including self-validation against story.md ACs and Files Affected.
- `feature` — standard story executed via Phase 1/2/3 in the Engineering Hub.
- `integration` — story that primarily wires together existing components; treated as `feature` by the hub.
- `infrastructure` — devops/config-only story with no implementation tasks; treated as `feature` by the hub.
- Absence of this field defaults to `feature`.

### tech_stack (required)

List of technologies and frameworks used by this story. The Implementation Hub uses this to load the appropriate technology skills during execution.

- Format: List of technology identifiers (e.g., `[react-native, typescript, expo]`)
- Each entry should match a skill name in `skills/` when a skill exists
- If no matching skill exists, the entry is noted as a gap but does not block execution
- Common values: `react-native`, `typescript`, `expo`, `node`, `python`, `aws-cdk`, `terraform`

### integration_dependencies (required)

List of external dependencies and their realization level for this story. Enables the validator to check that every mocked dependency has a corresponding realization story.

- Format: List of `name:level` pairs (e.g., `[sqlite:mock, stripe-api:real, redis:realize]`)
- Valid levels: `mock`, `interface-only`, `real`, `realize`
- `mock` — in-memory fake or hardcoded data; a future story replaces it with a real connection
- `interface-only` — defines the adapter interface; consumers use a mock adapter until the real implementation
- `real` — connects to actual infrastructure that must be provisioned before implementation
- `realize` — replaces a mock/interface from a prior story with a real connection
- Empty list is allowed for stories with no external dependencies (e.g., pure UI, scaffolding)
- Each entry must have a corresponding row in the story's `## Integration Strategy` table with full details (realized_by, mock_approach, notes)

## Example

```markdown
## Dependencies
- prd_sections: [7.2, 9.1, 9.3]
- architecture_components: [auth-service, api-gateway, user-database]
- provides_contracts: [auth-model, user-profile]
- consumes_contracts: []
- depends_on_stories: [US-001]
- execution_order: 2
- candidate_domains: [hld, api, data, security]
- tech_stack: [react-native, typescript, expo]
- integration_dependencies: [postgresql:mock, auth0:interface-only]
```

Scaffolding story example:

```markdown
## Dependencies
- story_type: scaffolding
- prd_sections: [5, 7, 8, 9]
- architecture_components: [App Shell & Navigation, Service Worker Layer]
- provides_contracts: []
- consumes_contracts: []
- depends_on_stories: []
- execution_order: 1
- candidate_domains: [hld]
- tech_stack: [typescript, react, vite, vite-plugin-pwa]
- integration_dependencies: []
```

## Validation Rules

The Plan Validator checks:

1. All referenced PRD sections exist in `plan/prd.md`.
2. All referenced architecture components exist in `plan/system-architecture.md`.
3. All provided contracts have matching files in `plan/contracts/` with correct ownership.
4. All consumed contracts have matching files in `plan/contracts/`.
5. All story dependencies reference existing story folders.
6. Execution order is consistent with dependency graph (no story ordered before its dependencies).
7. No circular dependencies in `depends_on_stories`.
8. `candidate_domains` always includes `hld`.
9. `tech_stack` is present and non-empty.
10. `integration_dependencies` is present (empty list allowed for stories with no external deps).
11. Every `mock` dependency has a corresponding `realize` entry in another story (or an explicit "deferred — out of project scope" note in the Integration Strategy table).
12. Every `realize` dependency has a prior `mock` or `interface-only` entry in an earlier story.
13. The realizing story's `execution_order` is higher than the mocking story's `execution_order`.
14. Every `real` or `realize` dependency has corresponding infrastructure in `plan/cross-cutting/devops.md`.
15. If `story_type: scaffolding` is present, the story is US-001-scaffolding and has `execution_order: 1`. No other story may declare `story_type: scaffolding`.
