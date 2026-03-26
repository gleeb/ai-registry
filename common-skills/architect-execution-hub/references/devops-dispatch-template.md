# DevOps Dispatch Template

Use this template when dispatching `sdlc-devops` via the Task tool to provision infrastructure before an implementer task.

**Architect**: Before sending this dispatch, log it via `checkpoint.sh dispatch-log --event dispatch`. After the DevOps agent returns, log the response via `checkpoint.sh dispatch-log --event response`.

## When to Dispatch

Dispatch `sdlc-devops` when the current task has dependencies with `level: real` or `level: realize` in the story's Integration Strategy. Check before every implementer dispatch in Phase 2.

Do NOT dispatch for `level: mock` or `level: interface-only` — those require no infrastructure.

## Required Message Structure

```
TASK: [Task ID] — Infrastructure for [Task Name]

INFRASTRUCTURE NEEDED:
- [Resource 1]: [type, e.g., "PostgreSQL database"] — [purpose, e.g., "inventory storage"]
  level: [real | realize]
  prior_mock: [if realize — describe what mock approach was used before and in which story,
               e.g., "US-003 used in-memory array via InventoryRepository adapter"]
- [Resource 2]: [type] — [purpose]
  level: [real | realize]
  prior_mock: [if applicable]
[List every dependency that needs infrastructure for this task.]

TECHNOLOGY DECISIONS (from devops.md):
- [Relevant excerpts from plan/cross-cutting/devops.md Section 13 — provisioning
  recipe, container strategy, image versions, ports, env var names]
- [If Section 13 doesn't cover this resource, include relevant decisions from
  Sections 2 (philosophy), 5 (environments), 7 (containers), or 8 (secrets)]

STORY CONTEXT:
- Story: [US-NNN]
- HLD reference: [exact path to plan/user-stories/US-NNN-name/hld.md]
  Relevant section: [section name/number with integration realization details]
- Integration Strategy: [paste the relevant rows from story.md Integration Strategy table]

ENVIRONMENT TARGET:
- [local | dev | staging — which environment to provision for]
- [Any specific constraints: ports to avoid, existing services to not conflict with]

STAGING DOCUMENT: [exact path to docs/staging/US-NNN-*.md]
- Update "Technical Decisions & Rationale" with provisioning decisions.

COMPLETION CONTRACT:
Return infrastructure manifest with:
1. Every provisioned resource with type, status, connection string, and health check evidence.
2. Environment configuration applied (.env path, env var names set).
3. Teardown commands for every provisioned resource.
4. Staging doc sections updated.
5. Any warnings or notes for the implementer.
Do NOT write application code. Do NOT create summary files.
After returning the manifest, STOP.

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Re-dispatch (after provisioning failure)

When re-dispatching after a provisioning failure:

```
RETRY: [Task ID] — Infrastructure for [Task Name]

PREVIOUS FAILURE:
[Paste the DevOps agent's error output and diagnostic information verbatim.]

RESOLUTION GUIDANCE:
[Architect's analysis of the failure and suggested fix, e.g.,
"Port 5432 was in use. Try port 5433 and update DATABASE_URL accordingly."
"Docker daemon was not running. Start it first, then provision."]

[Include the full INFRASTRUCTURE NEEDED section from the original dispatch.]

COMPLETION CONTRACT:
[Same as above.]
```
