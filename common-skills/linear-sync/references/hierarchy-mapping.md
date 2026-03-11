# Linear Hierarchy Mapping

## Overview

This reference defines how internal plan artifacts from the `plan/` folder map to Linear's entity hierarchy.

## Mapping Table

| Plan Artifact | Linear Entity | Linear Level | Notes |
|---|---|---|---|
| `plan/prd.md` | Initiative | Top | One Initiative per product/project PRD |
| `plan/user-stories/US-*.md` | Project | Middle | One Project per user story group |
| HLD sections in `plan/hld.md` | Issue (HLD) | Bottom | One Issue per HLD implementation unit |
| LLD (created by architect) | Sub-issue or Issue | Bottom | Created during execution, not planning |

## Hierarchy Rules

- **Initiative → Project → Issue** is the strict hierarchy.
- Every Project MUST link to its parent Initiative.
- Every Issue MUST link to its parent Project AND trace to the Initiative.
- Sibling Projects under the same Initiative must not overlap in scope.
- Sibling Issues under the same Project must not overlap in scope.

## Sync Direction

Internal plan artifacts are the source of truth. Linear is the sync target.

1. Read `plan/prd.md` → create or update Initiative.
2. Read `plan/user-stories/*.md` → create or update Projects under the Initiative.
3. Read HLD sections from `plan/hld.md` → create or update Issues under the appropriate Projects.

## Field Mapping

### Initiative (from PRD)
| PRD Section | Initiative Field |
|---|---|
| Executive Summary | Description (first paragraph) |
| Metadata.Status | Initiative status |
| Goals & Objectives | Initiative objective anchors |
| Full PRD content | Initiative description body |

### Project (from User Story)
| User Story Section | Project Field |
|---|---|
| User story group name | Project name |
| Parent linkage | Parent Initiative link |
| Scope boundaries | Project description |
| User stories | Project description body |
| HLD decomposition plan | Candidate Issues list |

### Issue (from HLD)
| HLD Section | Issue Field |
|---|---|
| Outcome statement | Issue title |
| Parent linkage | Parent Project link |
| High-level design | Issue description |
| Acceptance criteria | Issue acceptance criteria |
| Dependencies | Issue blockers/relations |

## First Project Rule
The first Project in every new Initiative MUST be "Project Scaffolding and Environment Setup" covering repository init, tooling, docs structure, and dev environment verification.
