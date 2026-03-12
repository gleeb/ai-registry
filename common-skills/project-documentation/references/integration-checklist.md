# Documentation Integration Checklist

Use this checklist when integrating a staging document into permanent documentation (Phase 5 of the implementation hub).

## When to Integrate

- After a user story passes acceptance validation (Phase 4)
- Before starting a dependent story (so the next agent has up-to-date permanent docs)

## Integration Steps

### 1. Identify What to Distribute

Read the staging document and categorize its content:

| Staging Section | Destination | Action |
|-----------------|-------------|--------|
| Technical Decisions | Domain docs (e.g., `docs/backend/technology.md`) | Add decision and rationale |
| Issues & Resolutions | Domain troubleshooting guides | Add as known issues with solutions |
| Lessons Learned | Relevant domain docs or `docs/staging/developer_notes.md` | Distribute to appropriate locations |
| Implementation Patterns | Domain docs (e.g., `docs/frontend/project-structure.md`) | Document reusable patterns |
| File References | Domain docs as cross-references | Verify paths are still valid |

### 2. Update Domain Documentation

For each domain affected by the story:

- Update the domain's topic files with new patterns, decisions, and knowledge
- Add new topic files if the staging doc revealed significant new areas
- Update the domain's `index.md` if new topic files were created

### 3. Update Master Index

If new domains or significant new topics were added:
- Update `docs/index.md` with links to new content

### 4. Verify Cross-References

- All file paths in updated docs point to files that exist
- Cross-references between documents are bidirectional where appropriate
- No orphaned references from the staging doc

### 5. Archive the Staging Document

- Move the staging document to `docs/archive/`
- Or mark it as completed with a header note: `<!-- COMPLETED: integrated into permanent docs on [date] -->`

## Verification Checklist

- [ ] All technical decisions from staging doc are preserved in appropriate domain docs
- [ ] Issues and resolutions are added to troubleshooting guides
- [ ] Lessons learned are distributed to relevant documentation
- [ ] Implementation patterns are documented for reuse
- [ ] File references are verified (files exist on disk)
- [ ] Cross-references between documents are updated
- [ ] Domain index files are updated if new topics were added
- [ ] Master `docs/index.md` is updated if new domains were added
- [ ] No valuable context was lost during integration
- [ ] Staging document is archived or marked as completed

## Critical Rule

**Never lose context when merging documentation.** If in doubt about whether to preserve something, preserve it. It is better to have slightly redundant documentation than to lose a decision rationale or lesson learned that a future agent will need.
