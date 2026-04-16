# Staging Document Template

Use this template when creating an execution journal for a user story implementation. The staging document is an **execution journal** — it tracks state, task decomposition, and runtime decisions. It does NOT copy plan content; that is the job of per-task context documents (see `references/task-context-template.md`).

**Role boundary:**
- **Staging document** (`docs/staging/US-NNN-name.md`): execution journal — plan artifact paths as master index, task status, technical decisions, issues, file references.
- **Task context documents** (`docs/staging/US-NNN-name.task-N.context.md`): verbatim plan excerpts + current source files for one task — what subagents read before implementation/review.

Plan artifacts (story.md, hld.md, api.md, data.md, security.md) remain the authoritative source of truth. Context documents are a verbatim extraction cache; the staging document is the execution index.

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
- **Testing Strategy**: `plan/cross-cutting/testing-strategy.md` (if applicable)

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
[Maps plan DUs/IUs to executable tasks. Each task has an associated context document.]

### Task 1: [Name]
- **Context doc:** `docs/staging/US-NNN-name.task-1.context.md` (hub-managed — read this before implementation)
- **Plan refs** (for hub extraction into context doc):
  - hld.md [DU/IU reference] (lines N-M): [what to read for spec]
  - api.md [section] (lines N-M): [what to read for contract]
  - security.md [section] (lines N-M): [what to read for controls]
  - design/[file] (lines N-M or full file): [what design artifact is relevant]
- **Files:** CREATE/MODIFY path/to/file.ext
- **External libraries:** [list, for hub to populate EXTERNAL LIBRARIES in dispatch]
- **Status:** pending | Review: 0 | QA: 0
- **Context doc size:** [N lines — logged by hub for threshold monitoring]

### Task 2: [Name]
- **Context doc:** `docs/staging/US-NNN-name.task-2.context.md`
- **Plan refs** (for hub extraction into context doc):
  - hld.md [DU/IU reference] (lines N-M): [what to read for spec]
- **Files:** CREATE/MODIFY path/to/file.ext
- **External libraries:** [list]
- **Status:** pending | Review: 0 | QA: 0
- **Context doc size:** [N lines]

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
2. Fill in **Plan Artifact Paths** from the story's plan folder. For key sections (acceptance criteria, design units, API contracts), record the line ranges. These line ranges are used by the hub to extract verbatim content into context documents — they are the hub's extraction guide, not reading instructions for subagents.
3. Fill in **Tech Stack** from the story manifest's `tech_stack` field, mapping each to its skill path.
4. Copy **Review Milestones** from `story.md` into the staging doc, adding a Status column (pending / triggered / user-approved). If the story has no milestones, write "None — fully autonomous execution."
5. Determine and record **Browser Verification Classification**.
6. Build the **Task Decomposition** by breaking HLD design units / implementation units into execution tasks. For each task, record:
   - The context doc path (`docs/staging/US-NNN-name.task-N.context.md`) — the hub creates this file.
   - Which DU/IU/API/security/design sections to extract (with line ranges) — these guide hub extraction.
   - Files to create or modify.
   - External libraries required.
7. After completing the staging doc, create per-task context documents for each task using `references/task-context-template.md`. Apply the **task-size gate** (see that template's Hub Instructions).
8. Leave the **Execution Log** sections empty — they are filled during the dev loop.
9. Record the context doc line count in each task's `Context doc size` field after creation.

## What the staging doc does NOT do

- Does NOT contain plan content (acceptance criteria, HLD design units, API rules, security constraints) — that lives in context documents.
- Does NOT instruct subagents to follow plan references — subagents read context documents instead.
- Does NOT replace or duplicate the context documents — they are separate hub-managed artifacts.
