# decision_guidance

## principles

- Prefer the smallest change that satisfies the request.
- Prefer a single source of truth; avoid duplicating the same rule across multiple skills or files.
- Ask a clarifying question only when location/scope or a potentially breaking change is ambiguous.

## progressive_disclosure_guardrails

### overview

Progressive disclosure is a tool to reduce token load and improve navigation.
It is not a default requirement.

Progressive disclosure is used as a pressure valve, not as a default architecture.

### default_policy

- Default to keeping essential workflow instructions in SKILL.md.
- Create additional files only when there is a clear benefit that outweighs added navigation/maintenance cost.

### good_reasons_to_split

- SKILL.md is becoming hard to skim (e.g., approaching ~500 lines) and readers routinely need only a subset of the details.
- The skill has distinct sub-domains (e.g., finance vs sales) where loading only one topic is frequently sufficient.
- High-stakes workflows need verification material (checklists, schemas, expected outputs) that is distracting in the main flow.
- Deterministic validation/automation is best expressed as scripts with clear run/verify loops.

### bad_reasons_to_split

- Splitting purely for aesthetics or "nice folder structure" without a clear navigation or token benefit.
- Creating reference files that are always needed for every run (in that case, keep them in SKILL.md).
- Creating multi-hop chains (SKILL.md → reference.md → details.md) that require chasing links.

### decision_test

- If the skill cannot be executed successfully without reading a linked file in most cases, move that content back into SKILL.md.
- If only one section is "too big", split only that section (don't restructure everything).

## scope_selection

### default

- Default to project skills under <workspace>/.roo/skills* unless the user explicitly requests global skills.

**rationale:** Project skills are auditable in-repo and easier to keep aligned with the project context.

### global_trigger

- Use global skills only when the user explicitly wants portability across projects.

**rationale:** Global changes can affect multiple workspaces and should be treated as higher-impact.

### mode_specific_trigger

- Create mode-specific skills only when the skill is intentionally scoped to a single mode.

**rationale:** Mode-specific skills reduce accidental activation and false-positive matches.

## breaking_change_rules

### rename_policy

- Treat renaming a skill directory (and therefore the skill name) as a breaking change.
- Do not rename without explicit user confirmation.

**rationale:** Other instructions, automation, or users may reference the skill by name.

### name_mismatch_resolution

- Resolve directory/frontmatter mismatches before making additional edits.

**rationale:** Leaving a mismatch makes the skill hard to select and easy to break.

## resource_creation_rules

- Create scripts/, references/, or assets/ only when they materially improve execution and the user explicitly agrees.

**rationale:** Extra files increase maintenance and can introduce safety/security concerns.

## handoffs

- If the user asks for edits outside <workspace>/.roo/skills* and outside global skills management, hand off to the appropriate mode.
