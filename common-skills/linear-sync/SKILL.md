---
name: linear-sync
description: SaaS translation skill for synchronizing internal plan artifacts to Linear. Maps plan/ folder documents to Linear's Initiative/Project/Issue hierarchy. Handles MCP discovery, state assessment, apply sequences, and change tracking. Does NOT define planning methodology — that belongs to planning-* skills.
---

# Linear Sync

## When to use
- Use when the project uses Linear as its planning/ticketing system.
- Use to translate internal plan artifacts (from `plan/`) into Linear entities.
- REQUIRE MCP state discovery before any sync operation.

## When NOT to use
- DENY use for creating or editing plan content — use the appropriate planning-* skill instead.
- DENY use when MCP state cannot be confirmed — mark artifacts as `PROVISIONAL - NOT SYNCED TO LINEAR`.
- DENY use as a standalone planning tool — this is a translation layer only.

## Hierarchy Mapping
- **Initiative** = PRD (`plan/prd.md`)
- **Project** = User Story (`plan/user-stories/*.md`)
- **Issue** = HLD (`plan/hld.md` sections)

See [`references/hierarchy-mapping.md`](references/hierarchy-mapping.md) for the full mapping specification.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

1. **MCP discovery gate (REQUIRE before any sync)**
   - REQUIRE fresh MCP state snapshot for Initiative/Project/Issue scope.
   - DENY proposing or applying updates before this snapshot is captured.

2. **State assessment**
   - REQUIRE summary of current Linear state: existing entities, gaps, conflicts, stale items.
   - Cross-reference with `plan/` folder contents to determine what needs syncing.

3. **Sync plan**
   - Map each plan artifact to its Linear entity type per [`references/hierarchy-mapping.md`](references/hierarchy-mapping.md).
   - Identify: new entities to create, existing entities to update, conflicts to resolve.

4. **Apply sequence**
   - REQUIRE apply order: Initiative → Project → Issue.
   - DENY out-of-order writes unless parent links already exist and are verified.
   - Follow the sync workflow in [`references/sync-workflow.md`](references/sync-workflow.md).

5. **Change tracking**
   - REQUIRE each sync operation to be tracked per [`references/communication.md`](references/communication.md).
   - REQUIRE the minimal contract: what changed, why, impact, next action.

6. **MCP unavailable behavior**
   - DENY writes when MCP is unavailable or state fetch fails.
   - REQUIRE explicit blocker report with missing capability and impact.
   - ALLOW provisional local draft only when clearly marked `PROVISIONAL - NOT SYNCED TO LINEAR`.

## Output per sync cycle
1. **State snapshot**: Linear entities read + key IDs/statuses.
2. **Sync plan**: planned entity creates/updates and rationale.
3. **Applied changes**: confirmed writes (or explicit `none` when blocked).
4. **Communication trail**: update/comment references recorded.
5. **Remaining gaps**: entities not yet synced and reason.

## Files
- [`references/hierarchy-mapping.md`](references/hierarchy-mapping.md): How plan artifacts map to Linear entities.
- [`references/sync-workflow.md`](references/sync-workflow.md): MCP discovery, state assessment, apply sequence.
- [`references/communication.md`](references/communication.md): Change tracking protocol in Linear.
- [`references/issue-mapping.md`](references/issue-mapping.md): LLD/execution issue format for Linear.

## Troubleshooting
- If state is stale/incomplete, REQUIRE re-fetch before any sync operation.
- If MCP is unavailable, DENY writes and emit blocker + optional provisional label.
- If hierarchy conflicts exist, REQUIRE resolution before applying writes.
- If plan artifacts are missing or incomplete, DENY sync and report which artifacts are needed.
