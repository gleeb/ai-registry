# Phase 1: Task Decomposition + Staging Doc

This is the existing Phase 0 (resume check) and Phase 1 (context gathering, architecture, LLD, staging doc creation). No changes to the core flow, with additions:

1. `checkpoint.sh execution --phase 1`
2. **Testing strategy consumption (REQUIRE)**: Read `plan/cross-cutting/testing-strategy.md`. Extract coverage thresholds (line, branch, function minimums), the AC-to-test-type traceability table, and negative testing requirements. These values are included in every implementer and QA dispatch for the story. When decomposing tasks, include expected test types, locations, and coverage expectations for each task based on the testing strategy (e.g., "unit tests for data layer at 80% line coverage", "integration tests for API endpoint including error paths").
3. **Staging doc scaffolding**: Use the staging doc template from `skills/project-documentation/references/staging-doc-template.md` to create the staging document. Pre-populate Plan References, Acceptance Criteria (from story.md), and Tech Stack sections.
4. **Copy Review Milestones** from `story.md` into the staging doc's `## Review Milestones` section. Add a Status column (pending / triggered / user-approved). If `story.md` has "None — fully autonomous execution," copy that. These milestones are the ONLY points where execution pauses for user input.
5. After staging doc is created: `checkpoint.sh execution --staging-doc "docs/staging/{filename}.md" --tasks-total {N}`
