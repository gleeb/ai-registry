# User Story Template

## Contents
- Purpose
- Contract gates
- Story template
- Decomposition rules
- Quality checklist

## Purpose
Use this format for user story files in `plan/user-stories/`.

User stories group related user-facing capabilities that share a common actor, workflow, or feature area. They are NOT technical modules — they are user-outcome groupings.

HLD sections are derived from user stories (see [HLD.md](HLD.md)).

## Contract gates
- REQUIRE parent PRD linkage to an explicit user story section.
- REQUIRE each user story to state boundaries that prevent sibling overlap.
- REQUIRE HLD decomposition plan as part of user story definition.
- DENY user stories that mix unrelated actors or user outcomes with no cohesion rationale.

## Story template

### 1) User story group name
- A short, user-facing name describing the capability area (e.g., "Inventory Management", "Chat Interface").

### 2) Parent linkage
- Parent PRD reference.
- Which PRD User Stories section(s) this story covers.

### 3) Scope boundaries
- In-scope capabilities for this user story group.
- Explicit out-of-scope items and neighboring story boundaries.

### 4) User stories
Each story follows the format:
- **Story ID** (e.g., US-001)
- **As a** [actor], **I want** [action], **so that** [outcome].
- **Acceptance Criteria**: testable, observable conditions using Given/When/Then or explicit bullet checks.
- Error cases and edge behaviors included.

### 5) Technical approach (high-level)
- Key architecture decisions relevant to this story group.
- Dependencies on other user stories or external systems.
- Technology choices from PRD constraints that apply here.

### 6) HLD decomposition plan
- Candidate HLD sections for implementing this user story group.
- Each HLD section should be scoped to one cohesive design unit implementable in one execution cycle.

### 7) Traceability and overlap control
- Map this user story to the parent PRD objective anchors it delivers.
- List sibling user story boundaries and explicit non-overlap statements.

## Decomposition rules
- REQUIRE a "Project Scaffolding and Environment Setup" user story as the first story (US-001) in every new product decomposition. This covers repository init, package manager setup, linting/formatting/CI, docs/ tree, and dev environment verification. It is a prerequisite for all other stories and must be first in execution order.
- REQUIRE split by user actor or user-outcome grouping — not by technical layer.
- DENY user stories that mix fundamentally different user workflows with no cohesion.
- REQUIRE minimal number of user stories that keeps execution parallelizable.
- REQUIRE overlap check across sibling user stories before HLD section creation.

## Quality checklist
- REQUIRE each user story objective is outcome-based (user value delivered), not a task list.
- REQUIRE scope is bounded and verifiable.
- REQUIRE user stories have testable acceptance criteria — no subjective terms.
- REQUIRE error cases and edge behaviors are covered in acceptance criteria.
- REQUIRE candidate HLD sections are scoped small enough for one focused execution cycle.
- REQUIRE every HLD section traces to both the user story and the PRD.
- REQUIRE sibling user story non-overlap is explicit.
