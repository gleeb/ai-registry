# Documentation Integration Protocol

Phase 5 — merge staging document insights into permanent project documentation.

## Prerequisites

- Story has passed acceptance validation (Phase 4)
- Staging document is fully populated
- `common-skills/project-documentation/` skill is loaded

## Steps

### 1. Load Integration Checklist

Read `common-skills/project-documentation/references/integration-checklist.md` for the full verification checklist.

### 2. Categorize Staging Doc Content

Read the staging document and identify content to distribute:

| Content Type | Source Section | Destination |
|-------------|---------------|-------------|
| Technical decisions | Technical Decisions & Rationale | Domain docs (e.g., `docs/backend/technology.md`) |
| Issues & fixes | Issues & Resolutions | Domain troubleshooting guides |
| Lessons learned | Lessons Learned | Relevant domain docs or developer notes |
| Implementation patterns | Throughout staging doc | Domain pattern guides |
| API changes | File References + decisions | `docs/backend/api.md` or similar |
| New components | File References | Domain project structure docs |

### 3. Update Domain Documentation

For each domain affected:

1. Update existing topic files with new knowledge from the staging doc.
2. Create new topic files if the staging doc reveals significant new areas.
3. Update the domain's `index.md` if new files were added.

### 4. Update Master Index

If new domains were created (e.g., first mobile story adds `docs/mobile/`):

1. Create the domain directory with `index.md`.
2. Add the domain to `docs/index.md`.

### 5. Verify File References

All file references in the updated documentation must point to files that actually exist. Run a verification pass:

- Check every `path/to/file.ext` reference in the staging doc
- Check every file reference in newly updated domain docs
- Flag and fix any broken references

### 6. Archive Staging Document

After verification:

1. Add a completion header to the staging doc: `<!-- COMPLETED: integrated into permanent docs -->`
2. Move the staging doc to `docs/archive/US-NNN-name.md`
3. Or keep it in `docs/staging/` with the completion marker if archiving is not desired

## Quality Check

Before marking Phase 5 complete, verify:

- [ ] All technical decisions from staging doc are in permanent docs
- [ ] Issues and resolutions are preserved
- [ ] Lessons learned are distributed
- [ ] File references are valid
- [ ] Domain indexes are updated
- [ ] No valuable context was lost
