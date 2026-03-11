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
