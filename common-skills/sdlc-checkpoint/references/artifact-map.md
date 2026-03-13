# Artifact Map — Agent to Expected File Path

This mapping is used by `verify.sh` to determine whether a dispatched agent completed its work. Each planning agent produces a known artifact at a known path.

## Planning Phase Artifacts

| Phase | Agent | Expected Artifact |
|-------|-------|-------------------|
| 1 | PRD Agent | `plan/prd.md` |
| 2 | System Architecture Agent | `plan/system-architecture.md` |
| 2 | Story Decomposer | `plan/user-stories/US-NNN-name/story.md` |

## Per-Story Artifacts (Phase 3)

For a story at `plan/user-stories/{STORY}/`:

| Domain | Agent Slug | Expected Artifact |
|--------|-----------|-------------------|
| hld | `sdlc-planner-hld` | `plan/user-stories/{STORY}/hld.md` |
| api | `sdlc-planner-api` | `plan/user-stories/{STORY}/api.md` |
| data | `sdlc-planner-data` | `plan/user-stories/{STORY}/data.md` |
| security | `sdlc-planner-security` | `plan/user-stories/{STORY}/security.md` |
| design | `sdlc-planner-design` | `plan/user-stories/{STORY}/design/design.md` |

## Cross-Cutting Artifacts (Phase 4)

| Agent | Expected Artifact |
|-------|-------------------|
| Security (rollup) | `plan/cross-cutting/security-overview.md` |
| DevOps | `plan/cross-cutting/devops.md` |
| Testing Strategy | `plan/cross-cutting/testing-strategy.md` |

## Validation Artifacts (Phase 5)

| Phase Validated | Expected Artifact Pattern |
|-----------------|--------------------------|
| Phase 1 | `plan/validation/phase-1-prd-validation.md` |
| Phase 2 | `plan/validation/phase-2-stories-validation.md` |
| Per-Story | `plan/validation/US-NNN-validation.md` |
| Cross-Story | `plan/validation/cross-story-validation.md` |

## Execution Artifacts

Execution state is tracked in the staging document, not as separate artifact files. The staging doc task checklist (`- [x]` / `- [ ]`) is the source of truth for task completion.

| Phase | Indicator |
|-------|-----------|
| Phase 1 complete | Staging doc exists at `docs/staging/US-NNN-*.md` with task checklist |
| Task complete | Task marked `[x]` in staging doc |
| Phase 3 complete | All tasks marked `[x]` |
| Phase 4 complete | Acceptance report exists and verdict is COMPLETE |
| Phase 5 complete | Staging doc moved to `docs/archive/` or marked completed |
