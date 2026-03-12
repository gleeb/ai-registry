# Documentation Structure

## Purpose

The `docs/` folder is the project's **technical reference for AI agents**. It captures how the system works today, how it was built, and what future agents need to know. It is NOT a project board — planning and tracking live in `plan/`.

## Folder Layout

```
docs/
├── index.md                    # Master index — project overview, links to all domains
├── frontend/                   # Frontend domain documentation
│   ├── index.md                # Frontend overview and links
│   ├── technology.md           # Tech stack, frameworks, versions
│   ├── project-structure.md    # Directory organization and conventions
│   ├── setup-and-deployment.md # Dev environment, build, deploy
│   └── [topic].md              # Additional topic files as needed
│
├── backend/                    # Backend domain documentation
│   ├── index.md
│   ├── technology.md
│   ├── project-structure.md
│   ├── api.md                  # API reference and endpoints
│   ├── database.md             # Schema, migrations, data access
│   └── [topic].md
│
├── infrastructure/             # Infrastructure and DevOps
│   ├── index.md
│   └── [topic].md
│
├── staging/                    # In-progress implementation journals
│   ├── README.md               # Staging workflow conventions
│   ├── US-NNN-story-name.md    # One per active user story
│   └── [other-staging].md      # Developer notes, issue trackers
│
├── archive/                    # Completed staging docs (reference only)
│   └── US-NNN-story-name.md
│
└── specs/                      # Design documents and task plans
    └── [feature-name]/
        ├── design.md
        └── tasks.md
```

## Boundary with `plan/`

| Folder | Contains | Authoritative For |
|--------|----------|-------------------|
| `plan/` | Planning artifacts (PRD, architecture, stories, HLD, API, data, security, design) | What to build and why |
| `docs/` | Technical reference (how the system works, how it was built, troubleshooting) | How it works today |
| `docs/staging/` | Implementation journals (decisions, issues, progress during dev) | How it was built (in-progress) |
| `docs/archive/` | Completed staging docs | How it was built (historical) |

## Domain Index Files

Each domain index (`docs/frontend/index.md`, etc.) should contain:

- Brief overview of the domain
- Tech stack summary
- Links to all topic files in the domain
- Quick-start guide for agents working in this domain

## When to Create New Documentation

- New domain docs: when a story adds a new architectural layer (e.g., mobile app)
- New topic files: when a staging doc reveals reusable patterns or significant knowledge
- Update existing docs: when a staging doc's decisions or lessons apply to existing topics
