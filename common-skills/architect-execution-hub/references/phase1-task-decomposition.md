# Phase 1: Task Decomposition + Staging Doc

This is the existing Phase 0 (resume check) and Phase 1 (context gathering, architecture, LLD, staging doc creation). No changes to the core flow, with additions:

1. `checkpoint.sh execution --phase 1`
2. **Testing strategy consumption (REQUIRE)**: Read `plan/cross-cutting/testing-strategy.md`. Extract coverage thresholds (line, branch, function minimums), the AC-to-test-type traceability table, and negative testing requirements. These values are included in every implementer and QA dispatch for the story. When decomposing tasks, include expected test types, locations, and coverage expectations for each task based on the testing strategy (e.g., "unit tests for data layer at 80% line coverage", "integration tests for API endpoint including error paths").
3. **Staging doc scaffolding**: Use the staging doc template from `skills/project-documentation/references/staging-doc-template.md` to create the staging document. Pre-populate Plan References, Acceptance Criteria (from story.md), and Tech Stack sections.
4. **Copy Review Milestones** from `story.md` into the staging doc's `## Review Milestones` section. Add a Status column (pending / triggered / user-approved). If `story.md` has "None — fully autonomous execution," copy that. These milestones are the ONLY points where execution pauses for user input.
5. **Task sizing constraints (REQUIRE)**: When decomposing design units into tasks, enforce these limits:
   - **Max files per task**: 4 new/modified production files (excluding tests). If a design unit requires more, split into sub-tasks.
   - **Max integration points per task**: 3. If a task wires together more than 3 service/component boundaries, split into: (a) individual service tasks, (b) a separate wiring/integration task.
   - **Integration tasks must be separate**: When the story has a route/page/orchestrator that wires together multiple services, it MUST be split into: (a) service wiring tasks (one per service boundary), (b) a final thin integration task that only connects already-working pieces.
   - **External library integration**: Any task that integrates a new external library/SDK should be its own task, not combined with business logic tasks. This ensures the library API is working and tested before building on top of it.
6. **External library extraction**: For each task, extract all external libraries/SDKs/platform APIs from the HLD's design units and the story's tech stack. Record them in the staging document's task entry as `External libraries: [list]`. These feed the `EXTERNAL LIBRARIES` section in every implementer dispatch.
7. **Library cache file creation**: Create `docs/staging/<story-id>.lib-cache.md` with the story-level header (see `project-documentation/references/task-context-template.md` Hub Instructions). This file is the single shared library documentation cache for all tasks in the story. Initialize it empty. Always include `LIBRARY CACHE: docs/staging/<story-id>.lib-cache.md` in every implementer dispatch.
8. After staging doc is created: `checkpoint.sh execution --staging-doc "docs/staging/{filename}.md" --tasks-total {N}`
