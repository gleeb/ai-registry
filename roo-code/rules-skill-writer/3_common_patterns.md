# common_patterns

## skill_folder_patterns

### pattern: project_generic

**description:** Project skill available across all modes in this repo

**path:** ./.roo/skills/<skill-name>/SKILL.md

### pattern: project_mode_specific

**description:** Project skill available only in a specific mode

**path:** ./.roo/skills-<mode>/<skill-name>/SKILL.md

### pattern: global_generic

**description:** Global skill available across all workspaces

**path:** <home>/.roo/skills/<skill-name>/SKILL.md

### pattern: global_mode_specific

**description:** Global skill available only in a specific mode

**path:** <home>/.roo/skills-<mode>/<skill-name>/SKILL.md

## skill_structure_guidance

### default

- Default to keeping essential workflow instructions in SKILL.md.
- Add additional files only when they materially improve navigation, reuse, or verification.

### optional_folders

#### folder: references

**use_for:** Optional deep dives (APIs, schemas, checklists, edge cases)

- Link directly from SKILL.md; avoid multi-hop references.

#### folder: scripts

**use_for:** Deterministic validation or automation (prefer execute-first workflows)

- SKILL.md must state whether to execute the script or read it as reference.

#### folder: assets

**use_for:** Reusable templates and example artifacts

## linked_file_handling

- Do not assume linked file contents unless they have been explicitly read.
- Prefer reading the minimum necessary linked file(s) for the current task.

## path_conventions

- Use forward slashes in paths (e.g., references/guide.md) for cross-platform compatibility.

## override_priority

**note:** When the same skill name exists in multiple locations, prefer the highest-precedence one.

**order:**

- Project mode-specific: ./.roo/skills-<mode>/<skill-name>/
- Project generic: ./.roo/skills/<skill-name>/
- Global mode-specific: <home>/.roo/skills-<mode>/<skill-name>/
- Global generic: <home>/.roo/skills/<skill-name>/

## skill_md_minimum_format

**note:** SKILL.md must start with YAML frontmatter including name and description.

**frontmatter_example:**

```
--- name: your-skill-name description: When to use this skill and what it does (include matching keywords) ---
# When to use
# When NOT to use
# Inputs required
# Workflow 1) ... 2) ...
# Examples
# Troubleshooting
```

## recommended_skill_md_sections

- Title (matches intent; human-readable)
- When to use this skill
- When NOT to use this skill
- Inputs required from the user
- Workflow (numbered)
- Examples (minimal, realistic)
- Troubleshooting / edge cases

## validation_rules

### name_constraints

- 1–64 characters
- Lowercase letters, numbers, and hyphens only
- No leading or trailing hyphen
- No consecutive hyphens
- Must match the directory name exactly

### description_constraints

- Non-empty after trimming
- Max 1024 characters
