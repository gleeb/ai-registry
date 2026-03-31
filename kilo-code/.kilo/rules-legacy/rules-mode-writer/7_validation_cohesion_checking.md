# validation_cohesion_checking

## overview

Guidelines for thoroughly validating mode changes to ensure cohesion,
consistency, and prevent contradictions across all mode components.

## validation_principles

### principle: comprehensive_review

**Description:** Every change must be reviewed in context of the entire mode

**Checklist:**
- Read all existing XML instruction files
- Verify new changes align with existing patterns
- Check for duplicate or conflicting instructions
- Ensure terminology is consistent throughout

### principle: focused_questioning

**Description:** Ask focused clarifying questions only when needed to de-risk the work

**When to ask:**
- Critical details are missing (cannot proceed safely)
- Multiple valid approaches exist and the tradeoffs matter
- Proposed changes are risky/irreversible (permissions, deletions, broad refactors)
- A change may require widening permissions or fileRegex patterns

**Example:** In practice: ask a focused question with 2–4 actionable options.
- Question: "This change may affect file permissions. Should we also update the fileRegex patterns?"
- Options:
  1) "Yes, include the new file types in the regex"
  2) "No, keep current restrictions"
  3) "I need to list the file types I'll work with"
  4) "Show me the current restrictions first"

### principle: contradiction_detection

**Description:** Actively search for and resolve contradictions

**Common contradictions:**
- **Permission Mismatch:** Instructions reference permissions the mode doesn't have — Resolution: Either grant the permission or update the instructions
- **Workflow Conflicts:** Different XML files describe conflicting workflows — Resolution: Consolidate workflows and ensure single source of truth
- **Role Confusion:** Mode's roleDefinition doesn't match its actual scope/permissions — Resolution: Update roleDefinition to accurately reflect the mode's purpose

### principle: explicit_instruction_wording

**Description:** Avoid interpretation-dependent phrasing in mode instructions

**Guidelines:**
- Write directives as explicit allow/deny/require rules instead of phrases like "should be interpreted as"
- State exactly what is allowed, what is prohibited, and what is mandatory for completion
- When boundaries are strict, explicitly allow only the minimal supporting actions needed to complete scoped work

## validation_workflow

### phase: pre_change_analysis

**Description:** Before making any changes

**Steps:**
1. Read and understand all existing mode files
2. Create a mental model of current mode behavior
3. Identify potential impact areas
4. Ask clarifying questions about intended changes

### phase: change_implementation

**Description:** While making changes

**Steps:**
1. Document each change and its rationale
2. Cross-reference with other files after each change
3. Verify examples still work with new changes
4. Update related documentation immediately

### phase: post_change_validation

**Description:** After changes are complete

**Validation checklist:**
- **structural_validation:** All XML files are well-formed and valid; File naming follows established patterns; Tag names are consistent across files; No orphaned or unused instructions
- **content_validation:** roleDefinition accurately describes the mode; whenToUse is clear and distinguishable; Permissions match instruction requirements; File restrictions align with mode purpose; Examples are accurate and functional
- **integration_validation:** Mode boundaries are well-defined; Handoff points to other modes are clear; No overlap with other modes' responsibilities; Orchestrator can correctly route to this mode

## cohesion_patterns

### pattern: consistent_voice

**Description:** Maintain consistent tone and terminology

**Guidelines:**
- Use the same terms for the same concepts throughout
- Keep instruction style consistent across files
- Maintain the same level of detail in similar sections

### pattern: logical_flow

**Description:** Ensure instructions flow logically

**Guidelines:**
- Prerequisites come before dependent steps
- Complex concepts build on simpler ones
- Examples follow the explained patterns

### pattern: complete_coverage

**Description:** Ensure all aspects are covered without gaps

**Guidelines:**
- Every mentioned concept has decision guidance (what/when) without runtime implementation details
- All workflows have complete examples
- Error scenarios are addressed

## validation_questions

### question_set: before_changes

**Prompt:** Before we proceed with changes, ensure the main goal is clear. Suggested options:
- Add new functionality while keeping existing features
- Fix issues with current implementation
- Refactor for better organization
- Expand the mode's scope into new areas

### question_set: during_changes

**Prompt:** This change might affect other parts of the mode. Choose an approach:
- Update all affected areas to maintain consistency
- Keep the existing behavior for backward compatibility
- Create a migration path from old to new behavior
- Review the impact first

### question_set: after_changes

**Prompt:** Post-change testing focus areas:
- Test the new workflow end-to-end
- Verify file permissions work correctly
- Check integration with other modes
- Review all changes one more time

## red_flags

- **priority: high** — Instructions reference permissions not in the mode's groups — Action: Either add the permission group or remove/update the instruction
- **priority: high** — File regex doesn't match described file types — Action: Update regex pattern to match intended files
- **priority: medium** — Examples don't follow stated best practices — Action: Update examples to demonstrate best practices
- **priority: medium** — Duplicate instructions in different files — Action: Consolidate to single location and reference
