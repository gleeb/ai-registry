# Staging Document Template

Use this template when creating an execution journal for a user story implementation. The staging document references plan artifacts by section and line range — it does NOT copy plan content. Plan artifacts (story.md, hld.md, api.md, data.md, security.md) are the source of truth; the staging document tracks execution state, task decomposition, and runtime decisions.

## Template

```markdown
# US-NNN -- Story Title

## Plan Artifact Paths
- **Story**: `plan/user-stories/US-NNN-name/story.md` (acceptance criteria at lines X-Y)
- **HLD**: `plan/user-stories/US-NNN-name/hld.md`
- **API**: `plan/user-stories/US-NNN-name/api.md` (if applicable)
- **Data**: `plan/user-stories/US-NNN-name/data.md` (if applicable)
- **Security**: `plan/user-stories/US-NNN-name/security.md` (if applicable)
- **Design**: `plan/user-stories/US-NNN-name/design/` (if applicable)
- **Contracts**: `plan/contracts/CON-NNN-name.md` (consumed/provided, if applicable)

## Tech Stack & Loaded Skills
- [tech] — skill: `skills/[skill-name]/`

## Review Milestones
[Copied from story.md — the ONLY points where the agent pauses for user input]
| ID | Trigger | Action | Verify | Status |
|----|---------|--------|--------|--------|
[If story.md has "None — fully autonomous execution", copy that line here instead of the table]

## Browser Verification Classification
- **Classification**: mandatory | per-task
- **Rationale**: [why]

## Task Decomposition
[Maps plan DUs/IUs to executable tasks with plan-artifact references]

### Task 1: [Name]
- **Plan refs:**
  - hld.md [DU/IU reference] (lines N-M): [what to read for spec]
  - api.md [section] (lines N-M): [what to read for contract]
  - security.md [section] (lines N-M): [what to read for controls]
- **Files:** CREATE/MODIFY path/to/file.ext
- **Status:** pending | Review: 0 | QA: 0

### Task 2: [Name]
- **Plan refs:**
  - hld.md [DU/IU reference] (lines N-M): [what to read for spec]
- **Files:** CREATE/MODIFY path/to/file.ext
- **Status:** pending | Review: 0 | QA: 0

## Execution Log

### Technical Decisions (execution-time)
| Decision | Choice | Rationale | Plan deviation? |
|----------|--------|-----------|-----------------|

### Issues and Resolutions
| Issue | Root Cause | Resolution | Lesson |
|-------|------------|------------|--------|

### Implementation File References
**Created:** (filled during execution)
**Modified:** (filled during execution)

### Lessons Learned
(filled during execution)
```

## Scaffolding Instructions

When the architect creates this document:

1. Copy the template above into `docs/staging/US-NNN-story-name.md`.
2. Fill in **Plan Artifact Paths** from the story's plan folder. For key sections (acceptance criteria, design units, API contracts), record the line ranges so subagents can read specific sections without scanning entire files.
3. Fill in **Tech Stack** from the story manifest's `tech_stack` field, mapping each to its skill path.
4. Copy **Review Milestones** from `story.md` into the staging doc, adding a Status column (pending / triggered / user-approved). If the story has no milestones, write "None — fully autonomous execution."
5. Determine and record **Browser Verification Classification**.
6. Build the **Task Decomposition** by breaking HLD design units / implementation units into execution tasks. For each task, record which DU/IU/API/security sections to reference (with line ranges). Do NOT re-write signatures, boundaries, or acceptance signals into the staging doc — the task's plan refs point to where that detail lives.
7. Leave the **Execution Log** sections empty — they are filled during the dev loop.

## What the staging doc does NOT do

- Do NOT copy acceptance criteria from story.md (reference it by path and line range).
- Do NOT re-write HLD design units, implementation unit signatures, or boundaries.
- Do NOT re-state API validation rules, error shapes, or contract details.
- Do NOT re-state security constraints or data architecture details.
- All of the above live in the plan artifacts and are referenced by path + line range.
