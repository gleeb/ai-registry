# complete_examples

## example: create_project_mode_specific_skill

**scenario:** Create a new mode-specific project skill to standardize a workflow in one mode.

**workflow:**

- **step 1**
  - **description:** Confirm scope and name
  - **expected_outcome:** Target path is ./.roo/skills-<mode>/<skill-name>/SKILL.md and the name is spec-compliant
- **step 2**
  - **description:** Create folder and SKILL.md with required frontmatter and clear sections
  - **expected_outcome:** Skill is discoverable and has actionable instructions
- **step 3**
  - **description:** Validate name/description constraints and directory-name match
  - **expected_outcome:** Spec-compliant frontmatter

## example: create_multi_file_skill_with_references_and_scripts

**scenario:** Create a project skill that includes an entrypoint SKILL.md plus reference material and a validation script. The goal is progressive disclosure: only read references when needed, and execute scripts for deterministic checks.

**workflow:**

- **step 1**
  - **description:** Choose structure based on fragility and size
  - **expected_outcome:** Use SKILL.md as the entrypoint, references/ for long-lived guidance, and scripts/ for validation/automation.
- **step 2**
  - **description:** Draft SKILL.md as navigation (not a dumping ground)
  - **expected_outcome:** SKILL.md contains:
    - Frontmatter (name/description)
    - When to use / When NOT to use
    - A numbered workflow with explicit "read this file when..." pointers
    - A "Files" section that links one level deep:
      - references/SCHEMA.md (read when needing field definitions)
      - references/TROUBLESHOOTING.md (read when validation fails)
      - scripts/validate_input.(sh|js|py) (execute to validate intermediate outputs)
- **step 3**
  - **description:** Create references with table-of-contents style headings
  - **expected_outcome:** Each references/*.md file starts with a short contents list so the agent can jump to relevant sections.
- **step 4**
  - **description:** Make script intent explicit
  - **expected_outcome:** SKILL.md clearly states whether the script should be executed (preferred) or read as reference. The script produces verifiable output (e.g., JSON report or "OK"/error list) to support feedback loops.

## example: edit_global_skill_with_confirmation

**scenario:** Edit an existing global skill used across multiple projects.

**workflow:**

- **step 1**
  - **description:** Locate the global skill path and read SKILL.md
  - **expected_outcome:** Exact file to change is known
- **step 2**
  - **description:** Apply the minimal edit and re-check frontmatter constraints
  - **expected_outcome:** Global skill updated safely and remains spec-compliant
