# Canonical Plan Folder Structure

## Overview

All planning artifacts are stored in a `plan/` folder at the project root. This is the single source of truth for project planning. External SaaS systems (Linear, Jira, etc.) are optional sync targets.

## Folder Layout

```
plan/
├── prd.md                          # Product Requirements Document
├── system-architecture.md          # System Architecture specification
├── hld.md                          # High-Level Design document
├── security.md                     # Security plan and threat model
├── api-design.md                   # API contracts and specifications
├── data-architecture.md            # Data models and storage strategy
├── devops.md                       # CI/CD, deployment, infrastructure
├── testing-strategy.md             # Test approach, coverage, QA gates
├── user-stories/                   # User story decomposition
│   ├── US-001-scaffolding.md       # Always first: project setup
│   ├── US-002-[feature-a].md
│   ├── US-003-[feature-b].md
│   └── ...
├── design/                         # Design and UI/UX artifacts
│   ├── design-spec.md              # Visual direction, component patterns
│   ├── color-palette.md            # Color system definition
│   └── mockups/                    # HTML/CSS mockups
│       ├── index.html              # Gallery template site
│       ├── styles.css              # Gallery styles
│       ├── assets/                 # Shared images, icons, fonts
│       └── screens/                # Screen mockups by feature
│           ├── [feature-a]/
│           │   ├── screen-1.html
│           │   └── screen-2.html
│           └── [feature-b]/
│               └── ...
└── validation/                     # Validation outputs
    └── cross-validation-report.md  # Latest cross-plan validation
```

## File Naming Conventions

- Plan documents use kebab-case: `system-architecture.md`, `api-design.md`.
- User stories use the pattern: `US-NNN-[short-name].md` where NNN is zero-padded.
- Design screen mockups are organized by feature area in subdirectories.
- The first user story is always `US-001-scaffolding.md`.

## File Ownership

| File | Created By | Updated By |
|---|---|---|
| `prd.md` | PRD Agent | PRD Agent |
| `system-architecture.md` | System Architecture Agent | System Architecture Agent |
| `hld.md` | HLD Agent | HLD Agent |
| `security.md` | Security Agent | Security Agent |
| `api-design.md` | API Design Agent | API Design Agent |
| `data-architecture.md` | Data Architecture Agent | Data Architecture Agent |
| `devops.md` | DevOps Agent | DevOps Agent |
| `testing-strategy.md` | Testing Strategy Agent | Testing Strategy Agent |
| `user-stories/*.md` | HLD Agent | HLD Agent |
| `design/*` | Design/UI-UX Agent | Design/UI-UX Agent |
| `validation/*` | Plan Validator | Plan Validator |

## Initialization

When planning begins on a new project:
1. Create the `plan/` directory if it does not exist.
2. The hub determines which files already exist and which need creation.
3. Each agent creates its output file(s) during its planning phase.
4. The validator creates `validation/cross-validation-report.md` after each validation run.
