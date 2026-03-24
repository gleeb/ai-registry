# Staging Document Template

Use this template when creating a staging document for a user story implementation. The architect scaffolds this during Phase 1; the implementer maintains it throughout the dev loop.

## Template

```markdown
# US-NNN – Story Title

## Overview
Brief description of what this story accomplishes and why it's needed.

## Plan References
- **Story**: `plan/user-stories/US-NNN-name/story.md`
- **HLD**: `plan/user-stories/US-NNN-name/hld.md`
- **API**: `plan/user-stories/US-NNN-name/api.md` (if applicable)
- **Data**: `plan/user-stories/US-NNN-name/data.md` (if applicable)
- **Security**: `plan/user-stories/US-NNN-name/security.md` (if applicable)
- **Design**: `plan/user-stories/US-NNN-name/design/` (if applicable)

## Acceptance Criteria
[Copied from story.md for traceability — each criterion will be verified]
1. [Criterion from story.md]
2. [Criterion from story.md]
3. ...

## Tech Stack & Loaded Skills
- [tech] — skill: `skills/[skill-name]/`
- [tech] — skill: `skills/[skill-name]/`

## Context Gathered

### Documentation Reviewed
- `docs/[domain]/[file].md` — [specific insight gained]
- `docs/staging/[related].md` — [lessons from related work]
[List ALL files read, with specific insights gained]

### Key Insights from Context
- [Pattern X is used because of Y]
- [Previous work on Z revealed that...]
- [Architecture constraint: ...]

## Implementation Progress

### Completed
- [x] [Task description]
  - Decision: [what was decided and why]
  - Files: `path/to/file.ext`

### In Progress
- [ ] [Task description]
  - Current status: [what's happening]
  - Blocker: [if any]

### Planned
- [ ] [Task description]

## Technical Decisions & Rationale

### Decision 1: [Title]
**Choice**: [What was chosen]
**Rationale**:
- [Why this choice was made]
- [What alternatives were considered]
- [Reference to docs/plan artifacts that informed the decision]

## Issues & Resolutions

| Issue | Root Cause | Resolution | Lesson for Future |
|-------|------------|------------|-------------------|
| [description] | [cause] | [fix] | [what to remember] |

## Implementation File References

### Created Files
- `path/to/new/file.ext` — [purpose]

### Modified Files
- `path/to/existing/file.ext` — [what changed and why]

## Lessons Learned
- [Key takeaway for future agents]

## Next Steps
- [What remains after this story, if anything]
```

## Scaffolding Instructions

When the architect creates this document:

1. Copy the template above into `docs/staging/US-NNN-story-name.md`.
2. Fill in Plan References from the story's plan folder.
3. Copy Acceptance Criteria verbatim from `story.md`.
4. Fill in Tech Stack from the story manifest's `tech_stack` field, mapping each to its skill path.
5. Leave Context Gathered, Implementation Progress, Technical Decisions, Issues, File References, and Lessons Learned for the implementer to fill during the dev loop.
