---
name: project-documentation
description: >
  Provides templates and standards for implementation-time project documentation.
  Use when the sdlc-architect creates staging documents for a user story, when
  the implementer needs the staging doc template, when integrating staging docs
  into permanent documentation after story completion, or when scaffolding a new
  project's docs/ directory structure.
---

# Project Documentation

## Overview

All project documentation is designed for AI agent consumption. The goal is to enable any agent to quickly understand the codebase, make informed decisions, and avoid repeating past mistakes.

**Core principle:** `docs/` is the project's technical reference for agents. It is NOT a project board. Planning artifacts live in `plan/`. Documentation captures how the system works and how it was built.

## When to Use

- Architect creating a staging document for a new user story (Phase 1)
- Implementer needing the staging doc template for updates
- Architect integrating staging docs into permanent docs (Phase 5)
- Scaffolding a new project's `docs/` directory

## Bootstrapping

For new projects, the `docs/` directory is created during scaffolding (Task 0) using the `scaffold-project` skill. See [`scaffold-project/references/project-docs.md`](../scaffold-project/references/project-docs.md) for the full directory structure, domain selection by project type, and file templates. The architect-execution-hub gates Phase 1 on `docs/index.md` existing.

## Workflow

### 1. Create Staging Document

Load [`references/staging-doc-template.md`](references/staging-doc-template.md) and scaffold a staging document at `docs/staging/US-NNN-story-name.md`. Pre-populate:

- Plan References from the story's plan artifacts
- Acceptance Criteria copied from `story.md`
- Tech stack from the story manifest's `tech_stack` field

### 2. Continuous Updates (During Implementation)

The implementer updates the staging document throughout the dev loop:

- Progress section after each significant code change
- Technical Decisions with rationale when making choices
- Issues & Resolutions table when encountering and fixing problems
- File References for all created and modified files

### 3. Integrate Into Permanent Docs (After Acceptance)

Load [`references/integration-checklist.md`](references/integration-checklist.md) and merge staging doc insights into permanent documentation:

- Distribute decisions, patterns, and lessons across domain docs
- Update `docs/index.md` if new domains were added
- Archive the staging document after verification

## References

- [`references/staging-doc-template.md`](references/staging-doc-template.md) — Staging document template with plan traceability
- [`references/documentation-structure.md`](references/documentation-structure.md) — `docs/` folder layout and domain organization
- [`references/integration-checklist.md`](references/integration-checklist.md) — How to merge staging docs into permanent docs
- [`references/quality-standards.md`](references/quality-standards.md) — Writing guidelines for AI-consumable documentation
