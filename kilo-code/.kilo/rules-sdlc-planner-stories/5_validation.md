# Validation

## Self-Validation Checks

Before submitting the decomposition to the Planning Hub, verify ALL of the following. EVERY check defaults to FAIL and must be explicitly confirmed.

### Coverage Check

- [ ] Every PRD section 7 user story group is addressed by at least one story.
- [ ] No PRD requirement is unaccounted for. Map each section to its covering story.
- [ ] Evidence: list the mapping (PRD section -> story ID).

### Architecture Alignment Check

- [ ] Every architecture component is referenced by at least one story.
- [ ] No story references a component that doesn't exist in the architecture.
- [ ] Story boundaries respect component boundaries — no story spans unrelated components.
- [ ] Evidence: list the mapping (component -> story IDs).

### Dependency Integrity Check

- [ ] Every story has a complete dependency manifest with all required fields.
- [ ] All `prd_sections` references point to existing PRD sections.
- [ ] All `architecture_components` references point to existing components.
- [ ] All `provides_contracts` have matching files in `plan/contracts/`.
- [ ] All `consumes_contracts` have matching files in `plan/contracts/`.
- [ ] All `depends_on_stories` reference existing story folders.
- [ ] No circular dependencies exist.
- [ ] Execution order is consistent with dependency graph.

### Contract Completeness Check

- [ ] Every shared interface between stories is documented as a contract.
- [ ] Every contract has exactly one owner story.
- [ ] Every contract has at least one consumer story (a contract with zero consumers is dead code).
- [ ] Contract definitions include invariants.

### Story Quality Check

- [ ] Every story has a clear scope statement quoting PRD text.
- [ ] Every story has testable acceptance criteria with PRD traceability.
- [ ] Every story has a "Files Affected" section with specific paths.
- [ ] Every story has an "Out of Scope" section.
- [ ] No story adds scope not in the PRD without `[ADDITION]` flag.
- [ ] US-001-scaffolding exists and has execution_order: 1.

### Sizing Check

- [ ] No story has more than 8 acceptance criteria.
- [ ] No story touches more than 3 architecture components (unless justified).
- [ ] Stories are right-sized for ~30-60 minutes of agent execution.

## Validation Report Format

After self-validation, produce a summary:

```
Stories: {count}
Contracts: {count}
PRD Coverage: {covered}/{total} sections
Architecture Coverage: {covered}/{total} components
Dependency Issues: {count}
Sizing Warnings: {count}
```
