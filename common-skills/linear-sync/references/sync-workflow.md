# Linear Sync Workflow

## Overview

Step-by-step workflow for synchronizing internal plan artifacts to Linear via MCP.

## Phase 1: MCP Discovery

1. Verify MCP Linear tools are available.
2. Fetch current state snapshot:
   - List all Initiatives in the workspace/team.
   - For the target Initiative: list all Projects and their Issues.
3. Record entity IDs, statuses, and last-modified timestamps.
4. If MCP is unavailable: STOP. Report blocker. Mark all work as `PROVISIONAL - NOT SYNCED TO LINEAR`.

## Phase 2: State Assessment

1. Compare `plan/` folder contents against Linear state:
   - Does an Initiative exist for this PRD? → Update or Create.
   - Do Projects exist for each user story? → Update, Create, or Archive.
   - Do Issues exist for each HLD section? → Update, Create, or Archive.
2. Identify conflicts:
   - Linear entities that don't match plan artifacts (stale).
   - Plan artifacts that have no Linear counterpart (new).
   - Scope overlaps between sibling entities.
3. Document the sync plan before applying.

## Phase 3: Apply Sequence

REQUIRE strict ordering:

### Step 1: Initiative
- Create or update the Initiative from `plan/prd.md`.
- Set status, description, objective anchors.
- Record the Initiative ID.

### Step 2: Projects
- For each `plan/user-stories/US-*.md`:
  - Create or update the Project under the Initiative.
  - Set parent link to the Initiative.
  - Record Project IDs.
- Verify no sibling Project overlap.

### Step 3: Issues
- For each HLD section targeting a specific Project:
  - Create or update the Issue under the correct Project.
  - Set parent link to the Project.
  - Set acceptance criteria from the HLD.
  - Record Issue IDs.
- Verify no sibling Issue overlap.

## Phase 4: Verification

1. Re-fetch state to confirm all writes landed.
2. Verify hierarchy integrity: every Issue → Project → Initiative chain is intact.
3. Report any write failures or partial syncs.

## Phase 5: Change Communication

For each entity created or updated, record per the communication contract:
1. What changed (scope, status, content).
2. Why it changed (plan update, conflict resolution).
3. Impact (parent/child links affected).
4. Next action (what comes next in the planning flow).

## Error Recovery

| Error | Action |
|---|---|
| MCP unavailable | Block all writes, report, offer provisional mode |
| Write fails for single entity | Report, skip, continue with remaining entities |
| Hierarchy conflict (duplicate Project names) | Ask user to disambiguate before write |
| Stale entity in Linear | Warn user, ask whether to overwrite or skip |
