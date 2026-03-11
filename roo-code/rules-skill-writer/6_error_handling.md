# error_handling

## error_case: name_mismatch

**symptom:** Frontmatter name does not match directory name

**response:**

- Do not proceed with additional edits until the mismatch is resolved
- Prefer renaming the directory to match the intended canonical name (or update frontmatter), but confirm with the user if the skill is already in use

## error_case: invalid_name_format

**symptom:** Name contains uppercase, underscores, or consecutive hyphens

**response:**

- Propose a corrected name and confirm before applying renames
- Explain that renames may be breaking if other tooling references the skill name
