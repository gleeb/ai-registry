# Plan Folder Structure (Per-Story Architecture)

## Overview

All planning artifacts are stored in a `plan/` folder at the project root. The primary organizing unit is the **user story folder** — each story gets a self-contained package of all artifacts an execution agent needs.

## Folder Layout

```
plan/
  prd.md                              # Product Requirements Document
  system-architecture.md              # System Architecture specification
  contracts/                          # Shared contracts registry
    auth-model.md                     # Example: authentication/authorization model
    product-entity.md                 # Example: shared product data shape
    api-error-format.md               # Example: standardized error responses
  user-stories/                       # Per-story execution packages
    US-001-scaffolding/
      story.md                        # Scope, acceptance criteria, dependency manifest
      hld.md                          # High-level design for this story
    US-002-user-auth/
      story.md
      hld.md
      api.md                          # API design for this story
      data.md                         # Data architecture for this story
      security.md                     # Security controls for this story
      design/                         # UI mockups for this story
        login-screen.html
        register-screen.html
    US-003-product-catalog/
      story.md
      hld.md
      api.md
      data.md
      security.md
      design/
        catalog-list.html
        product-detail.html
  cross-cutting/                      # Concerns that span all stories
    security-overview.md              # Aggregated security posture
    devops.md                         # CI/CD, deployment, infrastructure
    testing-strategy.md               # Test approach, coverage, QA gates
  design/                             # Global design artifacts
    design-spec.md                    # Visual direction, component patterns
    color-palette.md                  # Color system definition
    mockups/                          # Gallery for browsing all mockups
      index.html                      # Gallery template site
      styles.css                      # Gallery styles
      assets/                         # Shared images, icons, fonts
  validation/                         # Validation outputs
    cross-validation-report.md        # Latest cross-plan validation
    impact-analysis-report.md         # Latest impact analysis (brownfield)
    change-log.md                     # Append-only change history
```

## File Naming Conventions

- Plan-level documents use kebab-case: `system-architecture.md`, `prd.md`.
- Story folders use the pattern: `US-NNN-short-name/` where NNN is zero-padded.
- Contract files use kebab-case matching the shared interface: `auth-model.md`, `product-entity.md`.
- Per-story artifacts use fixed names: `story.md`, `hld.md`, `api.md`, `data.md`, `security.md`.
- Design mockup files within stories use descriptive kebab-case: `login-screen.html`.
- The first user story is always `US-001-scaffolding/`.

## File Ownership

| File | Created By | Phase |
|---|---|---|
| `prd.md` | PRD Agent | Phase 1 |
| `system-architecture.md` | System Architecture Agent | Phase 2 |
| `contracts/*.md` | Story Decomposer Agent | Phase 2 |
| `user-stories/US-NNN/story.md` | Story Decomposer Agent | Phase 2 |
| `user-stories/US-NNN/hld.md` | HLD Agent | Phase 3 |
| `user-stories/US-NNN/api.md` | API Design Agent | Phase 3 |
| `user-stories/US-NNN/data.md` | Data Architecture Agent | Phase 3 |
| `user-stories/US-NNN/security.md` | Security Agent | Phase 3 |
| `user-stories/US-NNN/design/*.html` | Design/UI-UX Agent | Phase 3 |
| `cross-cutting/security-overview.md` | Security Agent (rollup mode) | Phase 4 |
| `cross-cutting/devops.md` | DevOps Agent | Phase 4 |
| `cross-cutting/testing-strategy.md` | Testing Strategy Agent | Phase 4 |
| `design/design-spec.md` | Design/UI-UX Agent | Phase 3 (first story with design) |
| `design/color-palette.md` | Design/UI-UX Agent | Phase 3 (first story with design) |
| `design/mockups/index.html` | Design/UI-UX Agent | Phase 3 (first story with design) |
| `validation/*` | Plan Validator | After each phase |

## Initialization

When planning begins on a new project:

1. Create the `plan/` directory if it does not exist.
2. The Hub determines which files already exist and which need creation.
3. Create `plan/contracts/`, `plan/user-stories/`, `plan/cross-cutting/`, `plan/design/`, and `plan/validation/` directories.
4. Each agent creates its output file(s) during its planning phase.
5. The Story Decomposer creates the `US-NNN-name/` folder structure.
6. Phase 3 agents populate per-story folders.
7. Phase 4 agents populate the `cross-cutting/` folder.

## Per-Story Folder Contents

Each story folder contains ONLY the artifacts relevant to that story's `candidate_domains`:

| Domain | File | When Present |
|---|---|---|
| hld | `hld.md` | Always (every story gets HLD) |
| api | `api.md` | When story exposes/consumes API endpoints |
| data | `data.md` | When story creates/modifies data entities |
| security | `security.md` | When story handles auth, PII, or sensitive ops |
| design | `design/` | When story has user-facing UI |
