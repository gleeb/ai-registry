# Story Outline Template

Use this template for every `story.md` file in `plan/user-stories/US-NNN-name/`.

---

```markdown
# US-NNN: {Story Name}

## Dependencies
- prd_sections: [{list of PRD section numbers}]
- architecture_components: [{list of component names}]
- provides_contracts: [{list of contract names, or empty}]
- consumes_contracts: [{list of contract names, or empty}]
- depends_on_stories: [{list of story IDs, or empty}]
- execution_order: {positive integer}
- candidate_domains: [{subset of: hld, api, data, security, design}]

## Scope

{One paragraph describing what this story delivers. MUST quote exact PRD text with section numbers.}

Per PRD {section}: "{verbatim excerpt from PRD}"

## Acceptance Criteria

{Numbered list of testable conditions. Each criterion MUST trace to a PRD section.}

1. **AC-1**: {Criterion description} (PRD {section})
2. **AC-2**: {Criterion description} (PRD {section})
3. **AC-3**: {Criterion description} (PRD {section})

## Files Affected

{List of files the execution agent will create or modify. Be specific.}

| Action | File Path | Description |
|--------|-----------|-------------|
| CREATE | src/{path} | {what this file does} |
| CREATE | src/{path} | {what this file does} |
| MODIFY | src/{path} | {what changes} |

## Out of Scope

{Explicitly list what this story does NOT cover to prevent scope creep.}

- {Item 1}
- {Item 2}

## Notes

{Any additional context, open questions, or constraints for the execution agent.}
```

---

## Template Rules

1. **Dependencies section** is the machine-readable manifest. Format MUST match [`DEPENDENCY-MANIFEST.md`](DEPENDENCY-MANIFEST.md) exactly.
2. **Scope** MUST quote PRD text verbatim with section numbers. No paraphrasing.
3. **Acceptance criteria** MUST be testable (an assertion can be written for each one).
4. **Files Affected** MUST list concrete file paths, not vague descriptions like "authentication files".
5. **Out of Scope** prevents gold-plating by making boundaries explicit.
6. **candidate_domains** MUST always include `hld`. Include others only when the story requires them.
