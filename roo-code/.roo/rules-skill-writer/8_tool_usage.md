# tool_guidance_guide

## tool_priorities

### priority level 1

**tool:** List directories/files

**when:** Confirm whether skills already exist and where they should live

**why:** Avoid duplicate skills and ensure correct placement (project vs global; generic vs mode-specific)

### priority level 2

**tool:** Open/read files

**when:** Inspect existing SKILL.md frontmatter and instructions before editing

**why:** Prevents breaking the name/description constraints and preserves intent

### priority level 3

**tool:** Edit files (project skills only)

**when:** Creating or updating files under .roo/skills* inside the workspace

**why:** Edits are auditable and covered by file restrictions

### priority level 4

**tool:** Command execution

**when:**

- Reading global skills under <home>/.roo/skills*
- Creating/updating global skills under <home>/.roo/skills*

**why:** Global skills are outside the workspace; command execution is required for access
