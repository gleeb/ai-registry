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

Load `skills/project-documentation/` to prepare staging doc templates for Phase 1.

### 6. Check Cross-Cutting Testing Strategy (Soft Gate)

Check if `plan/cross-cutting/testing-strategy.md` exists. If it does:
- Note it as available for Phase 1 task decomposition (include per-task testing requirements from the AC traceability table).
- The architect should read it during Phase 1 and use it to inform testing expectations per task.

If it does not exist: log a warning but do not block. Testing obligations still apply via agent rules (implementer must write tests, reviewer gates on test existence, QA verifies adequacy).

### 7. Verify Required Environment Variables

Every story declares its external-service credentials and configuration as `required_env` entries in `api.md`. Phase 0a is the single choke point where the hub checks that those variables are actually set in the shell environment before dispatching any agent.

Procedure:

1. Read `required_env` from `plan/user-stories/US-NNN-name/api.md`.
2. If `plan/cross-cutting/required-env.md` exists, additionally read it to pick up variables introduced by prior stories that this story's runtime or tests also consume.
3. Filter to entries whose `scope` includes any of: `runtime`, `integration-test`. Variables scoped only `unit-test-placeholder` are NOT blocking — placeholder values in fixtures are expected for those.
4. For each filtered entry, check whether the variable is set in the shell (non-empty). Use a presence check like `printenv <NAME>` or `[ -n "${<NAME>}" ]`. Do NOT read or write `.env`. Do NOT echo or log the variable's value.
5. Collect all missing variables.

**If the missing set is non-empty**: HALT with a `MISSING_CREDENTIALS` blocker. Do not proceed to Phase 0b. Return the blocker to the engineering hub, which forwards it to the coordinator. The blocker message format:

```
BLOCKER: MISSING_CREDENTIALS — US-NNN
Missing variables:
- <NAME> — <purpose> (reference: <url or "none">)
- <NAME> — <purpose> (reference: <url or "none">)

Action required: user sets each variable in .env (or shell environment) and re-invokes the coordinator.
```

**Do NOT attempt to work around missing credentials** by generating placeholder values, by downgrading the scope to `unit-test-placeholder`, or by modifying `required_env`. The plan declares what is needed; the hub's job is to gate on it, not to relax it.

## Gate Criteria

All of the following must be true to proceed:

- [ ] `story.md` exists and has valid dependency manifest
- [ ] All expected plan artifacts exist based on `candidate_domains`
- [ ] All `depends_on_stories` are completed
- [ ] Tech skills identified (missing skills noted but not blocking)
- [ ] Documentation skill loaded
- [ ] Cross-cutting testing strategy noted if available (soft — does not block)
- [ ] Every `required_env` entry with `scope` including `runtime` or `integration-test` is set in the shell environment (hard gate)

## On Failure

If the gate fails, return to coordinator with:

```
READINESS CHECK FAILED — US-NNN

Missing artifacts: [list]
Incomplete dependencies: [list]
Missing skills: [list]
Missing credentials: [list of env-var names with purpose and reference]

Action required: [what needs to happen before this story can proceed]
```

Missing credentials are reported under their own `MISSING_CREDENTIALS` blocker (see Step 7 above) so the coordinator can route them to the correct escalation path — not conflated with missing artifacts or missing skills.
