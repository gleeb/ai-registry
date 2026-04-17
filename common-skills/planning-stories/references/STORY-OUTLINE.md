# Story Outline Template

Use this template for every `story.md` file in `plan/user-stories/US-NNN-name/`.

---

```markdown
# US-NNN: {Story Name}

## Dependencies
- story_type: {scaffolding | feature | integration | infrastructure — omit for feature stories}
- prd_sections: [{list of PRD section numbers}]
- architecture_components: [{list of component names}]
- provides_contracts: [{list of contract names, or empty}]
- consumes_contracts: [{list of contract names, or empty}]
- depends_on_stories: [{list of story IDs, or empty}]
- execution_order: {positive integer}
- candidate_domains: [{subset of: hld, api, data, security, design}]
- integration_dependencies: [{list of name:level pairs, e.g., "sqlite:mock", "redis:real", or empty}]

## Integration Strategy

{For each external dependency this story touches (database, external API, message queue,
cache, auth provider, file storage, etc.), declare the realization level. If this story
has no external dependencies, write "No external dependencies."}

| Dependency | Level | Realized By | Mock Approach | Notes |
|------------|-------|-------------|---------------|-------|
| {e.g., "SQLite database"} | {mock / interface-only / real / realize} | {story ID that connects the real thing, or "this story" if level is real/realize} | {if mocked: "in-memory array", "JSON fixture", etc. Otherwise "—"} | {optional context} |

{Levels:
- **mock** — in-memory fake or hardcoded data; a future story replaces it with a real connection.
- **interface-only** — defines the adapter interface with no real implementation; consumers use a mock adapter.
- **real** — connects to actual infrastructure (must be provisioned before implementation).
- **realize** — replaces a mock/interface from a prior story with a real connection.}

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

## Review Milestones

{Optional. Define specific points where the execution agent should pause and present
results for user inspection. Outside of these milestones, the story runs fully
autonomously with no user interaction. If no milestones are needed, write
"None — fully autonomous execution."}

| ID | Trigger | Action | Verify |
|----|---------|--------|--------|
| RM-1 | {After task N, after phase N, or "after all tasks"} | {Command to run or artifact to present} | {What the user checks} |

## Notes

{Any additional context, open questions, or constraints for the execution agent.}
```

---

## Template Rules

1. **Dependencies section** is the machine-readable manifest. Format MUST match [`DEPENDENCY-MANIFEST.md`](DEPENDENCY-MANIFEST.md) exactly. For US-001-scaffolding, `story_type: scaffolding` MUST be the first line of the manifest. For all other stories, omit `story_type` (it defaults to `feature`).
2. **Integration Strategy** MUST list every external dependency the story touches with its realization level. Every `mock` dependency MUST name the story that will realize it. Every `realize` dependency MUST name the prior story it replaces. Stories with no external dependencies MUST state "No external dependencies."
3. **Scope** MUST quote PRD text verbatim with section numbers. No paraphrasing.
4. **Acceptance criteria** MUST be testable (an assertion can be written for each one).
5. **Files Affected** MUST list concrete file paths, not vague descriptions like "authentication files".
6. **Out of Scope** prevents gold-plating by making boundaries explicit.
7. **Review Milestones** are user-defined pause points. If none are specified, the execution agent runs the entire story autonomously with no user interaction. Milestones are the ONLY mechanism for requesting user review during execution.
8. **candidate_domains** MUST always include `hld`. Include others only when the story requires them.
