# workflow_instructions

## mode_overview

Create, edit, and validate Agent Skills packages (SKILL.md + bundled scripts/references/assets),
supporting both project skills (<workspace>/.roo/skills*) and global skills (<home>/.roo/skills*),
including generic and mode-specific skills.

## operating_principles

- Follow the Agent Skills spec: skill is a directory with SKILL.md (required) and YAML frontmatter.
- Progressive disclosure: only metadata is "listed"; full SKILL.md and other files are loaded/used only when needed.
- Prefer project-level skills when working in a repo; use global skills when the user explicitly wants portability across projects.

## preambles

- Before any tool use: restate the user goal in one sentence and provide a short numbered plan.
- During execution: provide brief progress updates (no long narration).
- Finish: summarize what changed and how it meets the spec.

## discovery_and_budgets

**early_stop:** Stop discovery when you can name the exact skill folder(s) and the exact file(s) to create/edit.

**budget:** Default max 2 discovery passes (directory listing + one targeted read) before acting.

**escalate_once:** If location/scope is unclear, ask one focused question, then proceed.

## main_workflow

### phase: intake

#### step 1

**title:** Clarify skill scope and placement

**actions:**

- Determine scope: project (<workspace>/.roo/skills*) vs global (<home>/.roo/skills*)
- Determine specificity: generic (skills/) vs mode-specific (skills-<mode>/)
- Determine operation: create new skill, edit existing, or audit
- Default to project + generic unless the user explicitly requests global and/or mode-specific

**acceptance_criteria:**

- Target root directory and skill name are unambiguous

#### step 2

**title:** Establish the canonical skill name

**actions:**

- Choose a spec-compliant name (lowercase letters, numbers, hyphens; 1–64 chars; no leading/trailing hyphen; no consecutive hyphens)
- Ensure directory (or symlink alias) name matches frontmatter name exactly

### phase: authoring

#### step 3

**title:** Draft SKILL.md frontmatter and outline

**actions:**

- Write YAML frontmatter with required fields: name, description
- Optionally include license, compatibility, metadata, allowed-tools (do not assume enforcement)
- Write a concise "When to use" section and a step-by-step workflow section

**quality_gates:**

- Description explains what the skill does AND when to use it, with keywords for matching
- Instructions are actionable and ordered

#### step 3.1

**title:** Choose structure (single-file vs multi-file)

**actions:**

- Default to SKILL.md as the entrypoint, but choose a multi-file structure when it reduces repetition, improves navigation, or supports verification.
- Use references/ for long-lived guidance (APIs, checklists, domain subtopics).
- Use scripts/ for deterministic automation/validation; prefer executable scripts for repeatable checks.
- Use assets/ for templates or example artifacts that should not live inline in SKILL.md.
- Link all reference files directly from SKILL.md; avoid multi-hop references.

**acceptance_criteria:**

- SKILL.md makes it clear which linked file to read next (and when) and which scripts to execute (and when)

#### step 4

**title:** Add optional resources (only if they improve execution)

**actions:**

- Create scripts/ only when automation is genuinely useful and the user explicitly agrees; otherwise keep instructions manual
- Create references/ only when it materially improves execution and the user explicitly agrees; keep SKILL.md lean
- Create assets/ only when it materially improves execution and the user explicitly agrees (templates, example files, diagrams)

### phase: validation

#### step 5

**title:** Validate spec compliance (minimum checks)

**checks:**

- SKILL.md exists at skill root
- Frontmatter contains name + description
- Frontmatter name matches directory (or symlink alias) name
- Name constraints: 1–64 chars; lowercase letters/numbers/hyphens only; no leading/trailing hyphen; no consecutive hyphens
- Description constraints: non-empty after trimming; max 1024 characters
- File references use relative paths and remain shallow

#### step 6

**title:** Handoff and activation guidance

**actions:**

- Ensure the description includes trigger keywords so the model can match it reliably
- Ensure the first section tells the model when NOT to use the skill and what to do instead

## completion_criteria

- Skill folder structure is correct and includes SKILL.md
- Frontmatter passes required constraints
- Instructions are clear, safe, and usable
