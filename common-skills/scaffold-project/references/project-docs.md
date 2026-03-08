# Project Documentation Scaffolding

Every new project gets a `docs/` directory designed for AI agent consumption. The structure enables fast context gathering, progressive discovery, and continuous knowledge capture during development.

## When to Apply

Always. Create the `docs/` structure as part of every project scaffold, regardless of technology. Adapt the domain sections to the project type.

## Directory Structure

```
docs/
├── index.md                    # Root index — project overview + links to all sections
├── frontend/                   # Frontend domain (if applicable)
│   ├── index.md                # Frontend overview + links to topic files
│   ├── technology.md           # Stack, libraries, versions
│   ├── project-structure.md    # Directory layout, conventions
│   └── setup-and-deployment.md # Dev environment, build, deploy
├── backend/                    # Backend domain (if applicable)
│   ├── index.md
│   ├── technology.md
│   ├── project-structure.md
│   ├── api.md                  # API reference (endpoints, schemas)
│   └── database.md             # Schema, migrations, access patterns
├── infra/                      # Infrastructure / DevOps (if applicable)
│   ├── index.md
│   ├── environment-config.md   # Env management (dev/staging/prod)
│   └── deployment-guide.md     # Deployment steps
├── mobile/                     # Mobile domain (if applicable, instead of frontend/)
│   ├── index.md
│   ├── technology.md
│   └── project-structure.md
├── staging/                    # In-progress task documentation
│   ├── README.md               # Explains the staging workflow
│   └── .gitkeep
├── specs/                      # Design documents for larger features
│   └── .gitkeep
└── archive/                    # Deprecated/completed staging docs
    └── .gitkeep
```

## Domain Selection by Project Type

| Project type | Domains to create |
|-------------|-------------------|
| React / Next.js SPA | `frontend/` |
| Python API / CLI | `backend/` |
| React Native mobile | `mobile/` |
| Fullstack (web + API) | `frontend/`, `backend/`, `infra/` |
| Monorepo (multiple apps) | One domain folder per app/package, plus `infra/` |

For monorepos, name domain folders after the apps: `docs/web/`, `docs/api/`, `docs/mobile/`, `docs/shared/`.

## Templates

### docs/index.md

```markdown
# <Project Name> Documentation

## Overview

<1-2 paragraphs: what this project does and why it exists.>

### Core Components

<Numbered list of architectural layers, e.g.:>
1. **Frontend** — <brief description>
2. **Backend** — <brief description>
3. **Infrastructure** — <brief description>

## Documentation Structure

### [Frontend Documentation](./frontend/index.md)
- [Technology Stack](./frontend/technology.md)
- [Project Structure](./frontend/project-structure.md)
- [Setup & Deployment](./frontend/setup-and-deployment.md)

### [Backend Documentation](./backend/index.md)
- [Technology Stack](./backend/technology.md)
- [Project Structure](./backend/project-structure.md)
- [API Reference](./backend/api.md)
- [Database Design](./backend/database.md)

### [Infrastructure](./infra/index.md)
- [Environment Configuration](./infra/environment-config.md)
- [Deployment Guide](./infra/deployment-guide.md)

## Quick Start

### For Frontend Developers
1. Start with [Frontend Setup](./frontend/setup-and-deployment.md)
2. Review [Project Structure](./frontend/project-structure.md)

### For Backend Developers
1. Start with [Backend Technology](./backend/technology.md)
2. Review [API Reference](./backend/api.md)

## System Architecture

<Add a Mermaid diagram or text description of how components connect.>
```

### docs/frontend/index.md (or mobile/index.md)

```markdown
# Frontend Documentation

## Overview

<What the frontend does, who the users are.>

## Architecture Overview

<Directory tree showing the main folders and their purpose.>

## Core Technologies

- **Framework**: <e.g., React 19 with TypeScript>
- **Build Tool**: <e.g., Vite>
- **Styling**: <e.g., Tailwind CSS v4>
- **State Management**: <e.g., Zustand>
- **Routing**: <e.g., React Router v7 / Expo Router>

## Documentation Sections

- [Technology Stack](./technology.md) — Libraries, versions, and rationale
- [Project Structure](./project-structure.md) — Directory layout and conventions
- [Setup & Deployment](./setup-and-deployment.md) — Dev environment and build process

## Related Documentation

- [Backend API Reference](../backend/api.md)
- [Infrastructure](../infra/index.md)
```

### docs/backend/index.md

```markdown
# Backend Documentation

## Overview

<What the backend does, key services.>

## Architecture Overview

<Directory tree showing the main folders and their purpose.>

## Core Technologies

- **Runtime**: <e.g., Python 3.12>
- **Framework**: <e.g., FastAPI>
- **Database**: <e.g., PostgreSQL>
- **Package Manager**: <e.g., uv>

## Documentation Sections

- [Technology Stack](./technology.md) — Libraries, versions, and rationale
- [Project Structure](./project-structure.md) — Directory layout and conventions
- [API Reference](./api.md) — Endpoints, request/response formats
- [Database Design](./database.md) — Schema, migrations, access patterns

## Related Documentation

- [Frontend Documentation](../frontend/index.md)
- [Infrastructure](../infra/index.md)
```

### docs/staging/README.md

```markdown
# Staging Documentation

This directory holds documentation created during active development that has not yet been integrated into the main documentation structure.

## Naming Convention

Use task/ticket IDs: `T-###-short-description.md` (e.g., `T-001-user-auth.md`).

## Required Document Structure

Every staging document must include:

- **Overview** — What and why
- **Context Gathered** — Documentation files reviewed and key insights
- **Implementation Progress** — Completed / In Progress / Planned checklists
- **Technical Decisions & Rationale** — Choices made and why
- **Issues & Resolutions** — Problems hit, root cause, fix, lesson
- **File References** — Created and modified files
- **Lessons Learned** — Takeaways for future work

## Lifecycle

1. Created before first code change for a task
2. Updated continuously during implementation
3. Integrated into main docs when task completes (distribute to relevant domain docs)
4. Moved to `../archive/` after integration is verified
```

### Topic file starter (technology.md, project-structure.md, etc.)

Each topic file follows this pattern:

```markdown
# <Topic Title>

## Overview

<1-2 sentences on what this document covers.>

## <Main content sections>

<Detailed information. Include:>
- File paths referencing actual code
- Rationale for decisions (WHY, not just WHAT)
- Configuration snippets
- Gotchas and lessons learned

## Related Documentation

- [Link to related doc](./related.md)
```

## Scaffolding Procedure

1. Create the `docs/` directory tree based on project type (see domain selection table).
2. Write `docs/index.md` with the project overview — fill in project name, component descriptions, and adjust the documentation structure links to match the domains created.
3. Write each domain `index.md` — fill in the overview, core technologies chosen during scaffolding, and link to the topic file stubs.
4. Create topic file stubs (`technology.md`, `project-structure.md`, `setup-and-deployment.md`, etc.) with the topic file starter template. Fill in what is known from the scaffold (e.g., the tech stack, folder structure).
5. Create `docs/staging/README.md` from the template above.
6. Create `docs/specs/.gitkeep` and `docs/archive/.gitkeep`.

Fill in as much as possible from the scaffolding context — the technology choices, folder structure, and setup commands are all known at scaffold time. Leave `<placeholders>` only for information that genuinely isn't available yet.
