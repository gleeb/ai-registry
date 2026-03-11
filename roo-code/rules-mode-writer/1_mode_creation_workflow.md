# Mode Management Workflow

## Overview

This workflow guides you through creating new custom modes or editing existing ones
for the Roo Code Software, ensuring comprehensive understanding and cohesive implementation.

## Mode Scope

### Workspace Modes

- **Location:** .roomodes in the workspace root directory
- **Notes:** Workspace modes are the default target for project-specific modes and for overrides.

### Global Modes

- **Location:** VS Code globalStorage custom modes settings file (location is environment-specific; open it via the product UI)
- **Notes:** Global modes are used system-wide and are created automatically on Roo Code startup.

### Precedence

- If the same slug exists in both global modes and workspace modes, the workspace (.roomodes) entry wins.

### Schema

- Both files use the same YAML schema: a top-level `customModes:` list of mode objects.

**Format notes:**

- Mode definitions are YAML objects within `customModes:`. Use YAML block scalars (e.g., `>-`) for multi-line text fields when helpful.
- If you must embed explicit newlines in a quoted string, use `\n` for newlines and `\n\n` for blank lines.
- `groups` is required and is a YAML array. It may be empty when a mode should not have access to optional permissions.
- Each `groups` entry may be:
  - a simple string (unrestricted permission group), or
  - a structured entry that restricts the permission to a subset of files (e.g., `fileRegex` + `description` for edit restrictions).

**Required fields:**

- slug
- name
- roleDefinition
- groups

**Recommended fields:**

- description
- whenToUse

**Optional fields:**

- customInstructions

**Example:**

Canonical YAML skeleton (illustrative; keep instructions/tooling details in .roo/rules-[slug]/)

```
customModes:
  - slug: example-mode
    name: Example Mode
    description: Short five-word summary
    roleDefinition: >-
      You are Roo Code, a [specialist type] who...

      Key areas:
      - Area one
      - Area two
    whenToUse: >-
      Use this mode when...
    groups:
      - read
      - - edit
        - fileRegex: \\.(md|mdx)$
          description: Documentation files only
    customInstructions: >-
      Optional brief glue text.
```

## Initial Determination

### Step 1: Determine User Intent

Identify whether the user wants to create a new mode or edit an existing one

**Detection patterns:**

**Pattern (edit_existing):**

- User mentions a specific mode by name or slug
- User references a mode directory path (e.g., .roo/rules-[mode-slug])
- User asks to modify, update, enhance, or fix an existing mode
- User says "edit this mode" or "change this mode"

**Pattern (create_new):**

- User asks to create a new mode
- User describes a new responsibility not covered by existing modes
- User says "make a mode for" or "create a mode that"

**Clarification question:**

- I want to make sure I understand correctly. Are you looking to create a brand new mode or modify an existing one?
- **Follow-up suggestions:**
  - Create a new mode for a specific purpose
  - Edit an existing mode to add new responsibilities
  - Fix issues in an existing mode
  - Enhance an existing mode with better workflows

### Step 2a: Resolve Mode Source (Workspace vs Global)

When the user asks about a specific mode by name/slug (including phrases like "global mode"), resolve where that mode is defined
before doing broad repository searches.

**Resolution order:**

1. Check the workspace override first by reading `.roomodes`.
2. If not present (or the user explicitly requests global scope), inspect the global custom modes settings file.
   Note: its exact path is determined by the extension at runtime (do not hardcode a machine-specific path).
3. If the mode is workspace-scoped, read its instruction directory `.roo/rules-[mode-slug]/`.

**Early stop:**

If the mode entry is found in either `.roomodes` or the global file, proceed directly to analysis/edits without additional discovery.

## Workflow Branches

### Branch: Create New Mode

#### Step 3.1: Gather Requirements for New Mode

Understand what the user wants the new mode to accomplish

**Actions:**

- Ask about the mode's primary purpose and use cases
- Identify what types of tasks the mode should handle
- Determine what repository access and permissions the mode needs
- Clarify any special behaviors or restrictions

**Example question:**

- What is the primary purpose of this new mode? What types of tasks should it handle?
- **Follow-up suggestions:**
  - A mode for writing and maintaining documentation
  - A mode for database schema design and migrations
  - A mode for API endpoint development and testing
  - A mode for performance optimization and profiling

#### Step 3.2: Design Mode Configuration

Create the mode definition with all required fields

**Scope selection:**

- Default to workspace-scoped modes unless the user explicitly requests a global mode.
- **Global mode trigger:** User asks for a mode to be available across all workspaces, or explicitly mentions the global modes file.
- **Workspace mode trigger:** User asks for a mode for this repo/project only, or wants to commit/share the mode with the repository.

**Required fields:**

- **slug:** Unique identifier (lowercase, hyphens allowed). Best practice: Keep it short and descriptive (e.g., "api-dev", "docs-writer")
- **name:** Display name with optional emoji. Best practice: Use an emoji that represents the mode's purpose
- **roleDefinition:** Detailed description of the mode's role and expertise. Best practice: Start with "You are Roo Code, a [specialist type]..."; List specific areas of expertise; Mention key technologies or methodologies
- **groups:** Permission groups the mode can access. Note: The concrete group names and any nesting structure are runtime-defined and may evolve. Treat these as conceptual categories and map them to the closest available equivalents.
  - **Options:** read (File reading and searching), edit (File editing - can be restricted by regex), command (Command execution), browser (Browser interaction), mcp (MCP servers)

**Recommended fields:**

- **description:** Short human-readable summary (aim ~5 words). Best practice: Keep it scannable and concrete
- **whenToUse:** Clear description for the Orchestrator. Best practice: Explain specific scenarios and task types

**Important note:**

Prefer keeping substantial mode guidance in XML files within `.roo/rules-[mode-slug]/`.
The underlying mode system supports `customInstructions`, but large instruction blocks there are easier to duplicate/drift.
Use `customInstructions` only for brief "glue" text when needed.

Note: the underlying mode system supports a `customInstructions` field,
but this repository intentionally keeps detailed instructions in
`.roo/rules-[mode-slug]/` XML files to avoid duplication and drift.

#### Step 3.3: Implement File Restrictions

Configure appropriate file access permissions

**Example (Restrict edit access to specific file types):**

```
groups:
  - read
  - - edit
    - fileRegex: \.(md|txt|rst)$
      description: Documentation files only
  - command
```

**Guidelines:**

- Use regex patterns to limit file editing scope
- Provide clear descriptions for restrictions
- Consider the principle of least privilege

#### Step 3.4: Create XML Instruction Files

Design structured instruction files in .roo/rules-[mode-slug]/

**File structure:**

- 1_workflow.xml: Main workflow and step-by-step processes
- 2_best_practices.xml: Guidelines and conventions
- 3_common_patterns.xml: Reusable code patterns and examples
- 4_decision_guidance.xml: Decision criteria and guardrails
- 5_examples.xml: Complete workflow examples

**XML best practices:**

- Use semantic tag names that describe content
- Nest tags hierarchically for better organization
- Include code examples in CDATA sections when needed
- Add comments to explain complex sections

### Branch: Edit Existing Mode

#### Step 4.1: Immerse in Existing Mode

Fully understand the existing mode before making any changes

**Actions:**

- Locate and read the mode configuration in .roomodes
- When global scope is relevant, locate and read the global custom modes settings file and compare slugs for precedence
- Read all XML instruction files in .roo/rules-[mode-slug]/
- Analyze the mode's current scope, permissions, and limitations
- Understand the mode's role in the broader ecosystem

**Questions to ask:**

- What specific aspects of the mode would you like to change or enhance?
- **Follow-up suggestions:**
  - Adjust permissions or restrictions
  - Fix issues with current workflows or instructions
  - Improve the mode's roleDefinition or whenToUse description
  - Enhance XML instructions for better clarity

#### Step 4.2: Analyze Change Impact

Understand how proposed changes will affect the mode

**Analysis areas:**

- Compatibility with existing workflows
- Impact on file permissions and capability access
- Consistency with mode's core purpose
- Integration with other modes

**Review cleanup checklist:**

- Role and scope: roleDefinition matches actual scope and permissions; remove scope creep
- Orchestrator routing: whenToUse/whenNotToUse are explicit and distinct from other modes
- Permissions: groups and fileRegex follow least-privilege and match instructions
- Instructions hygiene: no contradictions or duplicates across XML files
- Naming consistency: tag names and terminology are consistent
- Deprecated content: remove legacy fields (e.g., customInstructions in .roomodes)
- Boundaries: clear handoffs to other modes; no overlapping responsibilities

**Duplication and contradiction scan:**

- Search for repeated guidance and conflicting directives across files

**Validation questions:**

- I've analyzed the existing mode. Here's what I understand about your requested changes. Is this correct?
- **Follow-up suggestions:**
  - Yes, that's exactly what I want to change
  - Mostly correct, but let me clarify some details
  - No, I meant something different
  - I'd like to add additional changes

#### Step 4.3: Plan Modifications

Create a detailed plan for modifying the mode

**Planning steps:**

1. Identify which files need to be modified
2. Determine if new XML instruction files are needed
3. Check for potential conflicts or contradictions
4. Plan the order of changes for minimal disruption

**Refactor strategy:**

**Normalize:**

- Consolidate overlapping instructions into a single source of truth
- Align with XML best practices (semantic tags, hierarchical nesting)
- Standardize whenToUse/whenNotToUse language and boundaries
- Centralize preamble rules and autonomy calibration

**Permissions:**

- Tighten fileRegex to least-privilege; add clear descriptions
- Ensure instructions match configured permissions

**Structure:**

- Split overly long files; ensure 6_error_handling and 7_communication are present or updated

**Examples and tests:**

- Update 5_examples.xml to reflect new workflows and refactors
- Include before/after diffs where helpful

**Artifacts to update:**

- .roomodes: roleDefinition and whenToUse
- .roo/rules-[slug]/ XML instruction files
- Examples and quick_reference sections

#### Step 4.4: Silent Self-Reflection Rubric

Privately evaluate the planned changes against a 5–7 category rubric before implementation

**Rubric categories:**

- Cohesion across files
- Permissions and file restrictions (least privilege)
- Orchestrator fit (whenToUse/whenNotToUse clarity)
- XML structure and naming consistency
- Mode boundaries and handoff points
- Examples and testability

**Instruction:** Iterate on the plan until it passes the rubric; do not expose the rubric to the user

#### Step 4.5: Implement Changes

Apply the planned modifications to the mode

**Implementation order:**

- Update .roomodes configuration if needed
- Modify existing XML instruction files
- Create new XML instruction files if required
- Update examples and documentation

**Cleanup tasks:**

- Remove duplicate or contradictory instruction blocks across XML files
- Delete or migrate deprecated fields (e.g., customInstructions in .roomodes)
- Tighten fileRegex patterns and add clear descriptions
- Normalize tag names, terminology, and structure
- Ensure whenToUse/whenNotToUse and handoff rules are explicit

**Verification steps:**

1. Validate file restriction patterns against the intended file sets
2. Confirm permissions match instruction expectations
3. Re-run validation (section 5) and testing (section 6)
4. Scan the repository for legacy references and remove/modernize as needed

## Validation And Cohesion

### Step 5: Validate Cohesion and Consistency

Ensure all changes are cohesive and don't contradict each other

**Validation checks:**

**Configuration:**

- Mode slug follows naming conventions
- File restrictions align with mode purpose (least privilege)
- Permissions are appropriate
- whenToUse clearly differentiates from other modes

**Instructions:**

- All XML files follow consistent structure
- No contradicting instructions between files; contradiction hierarchy and resolutions documented
- Examples align with stated workflows
- Instructions match granted permissions and file restrictions

**Integration:**

- Mode integrates well with Orchestrator
- Clear boundaries with other modes
- Handoff points are well-defined

**Cohesion questions:**

- I've completed the validation checks. Would you like me to review any specific aspect in more detail?
- **Follow-up suggestions:**
  - Review the file permission patterns
  - Check for workflow contradictions
  - Verify integration with other modes
  - Everything looks good, proceed to testing

### Step 6: Test and Refine

Verify the mode works as intended

**Checklist:**

- Mode appears in the mode list
- File restrictions work correctly
- Instructions are clear and actionable
- Mode integrates well with Orchestrator
- All examples are accurate and helpful
- Changes don't break existing functionality (for edits)
- New behavior works as expected

## Quick Reference

- Create mode in .roomodes for project-specific modes
- Create mode in the global custom modes settings file for system-wide modes (path is environment-specific)
- Verify the .roo folder structure contains expected rule directories and XML files
- Validate file regex patterns against the intended file sets (avoid overbroad matches)
- Find existing mode implementations and patterns to reuse
- Read all XML files in a mode directory to understand its structure
- Always validate changes for cohesion and consistency
