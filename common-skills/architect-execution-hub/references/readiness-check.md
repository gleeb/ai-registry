# Implementation Readiness Check

Phase 0 protocol — verify all prerequisites before starting implementation.

## Steps

### 1. Locate Plan Artifacts

Read `plan/user-stories/US-NNN-name/story.md` and extract the dependency manifest:

```yaml
prd_sections: [...]
architecture_components: [...]
provides_contracts: [...]
consumes_contracts: [...]
depends_on_stories: [...]
execution_order: N
candidate_domains: [api, data, security, design, ...]
tech_stack: [react-native, typescript, expo, ...]
```

### 2. Verify Artifact Completeness

Based on `candidate_domains`, verify these artifacts exist:

| Domain | Required Artifact |
|--------|------------------|
| (always) | `story.md`, `hld.md` |
| `api` | `api.md` |
| `data` | `data.md` |
| `security` | `security.md` |
| `design` | `design/` directory with design artifacts |

**If any expected artifact is missing**: HALT. Escalate to coordinator — the planning phase may be incomplete.

### 3. Check Dependency Stories

For each story ID in `depends_on_stories`:

1. Locate the story's staging doc or completion marker.
2. Verify it is marked as completed (Phase 6 passed).

**If any dependency story is incomplete**: HALT. Escalate to coordinator — execution order may need adjustment.

### 4. Determine and Load Tech Skills

Follow [`skill-loading-protocol.md`](skill-loading-protocol.md) to map `tech_stack` entries to available skills.

### 5. Load Documentation Skill

Load `common-skills/project-documentation/` to prepare staging doc templates for Phase 1.

### 6. Check Cross-Cutting Testing Strategy (Soft Gate)

Check if `plan/cross-cutting/testing-strategy.md` exists. If it does:
- Note it as available for Phase 1 task decomposition (include per-task testing requirements from the AC traceability table).
- The architect should read it during Phase 1 and use it to inform testing expectations per task.

If it does not exist: log a warning but do not block. Testing obligations still apply via agent rules (implementer must write tests, reviewer gates on test existence, QA verifies adequacy).

## Gate Criteria

All of the following must be true to proceed:

- [ ] `story.md` exists and has valid dependency manifest
- [ ] All expected plan artifacts exist based on `candidate_domains`
- [ ] All `depends_on_stories` are completed
- [ ] Tech skills identified (missing skills noted but not blocking)
- [ ] Documentation skill loaded
- [ ] Cross-cutting testing strategy noted if available (soft — does not block)

## On Failure

If the gate fails, return to coordinator with:

```
READINESS CHECK FAILED — US-NNN

Missing artifacts: [list]
Incomplete dependencies: [list]
Missing skills: [list]

Action required: [what needs to happen before this story can proceed]
```
