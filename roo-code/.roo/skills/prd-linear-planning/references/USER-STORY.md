# User Story (Project) Reference

## Contents
- Purpose
- Contract gates
- Project template
- Decomposition rules
- Quality checklist

## Purpose
Use this format for Project-level user story groups derived from a PRD Initiative.

User stories in the PRD map directly to Linear Projects. Each Project groups a set of related user-facing capabilities that share a common actor, workflow, or feature area. They are NOT technical modules — they are user-outcome groupings.

HLD issues are derived from user story groups (see [references/HLD.md](references/HLD.md)).

## Contract gates
- REQUIRE parent Initiative linkage to an explicit PRD user story section.
- REQUIRE each Project to state boundaries that prevent sibling overlap.
- REQUIRE HLD issue decomposition plan as part of Project definition.
- DENY Projects that mix unrelated actors or user outcomes with no cohesion rationale.
- DENY Project updates without confirmed MCP state snapshot in current iteration.
- REQUIRE Project-level change communication via Project updates using the minimal contract in [`references/COMMUNICATION.md`](references/COMMUNICATION.md).
- ALLOW provisional local User Story draft only when clearly marked `PROVISIONAL - NOT SYNCED TO LINEAR`.

## Project template

### 1) User story group name
- A short, user-facing name describing the capability area (e.g., "Inventory Management", "Chat Interface").

### 2) Parent linkage
- Parent Initiative/PRD reference.
- Which PRD User Stories section(s) this Project covers.

### 3) Scope boundaries
- In-scope capabilities for this user story group.
- Explicit out-of-scope items and neighboring group boundaries.

### 4) User stories
Each story follows the format:
- **Story ID** (e.g., US-001)
- **As a** [actor], **I want** [action], **so that** [outcome].
- **Acceptance Criteria**: testable, observable conditions using Given/When/Then or explicit bullet checks.
- Error cases and edge behaviors included.

### 5) Technical approach (high-level)
- Key architecture decisions relevant to this story group.
- Dependencies on other Projects or external systems.
- Technology choices from PRD constraints that apply here.

### 6) HLD decomposition plan
- Candidate HLD Issues for implementing this user story group.
- Each HLD Issue should be scoped to one cohesive design unit implementable in one execution cycle.
- HLD Issues will be created in Linear as Issues under this Project.

### 7) Traceability and overlap control
- Map this Project to the parent Initiative objective anchors it delivers.
- List sibling Project boundaries and explicit non-overlap statements.

## Decomposition rules
- REQUIRE split by user actor or user-outcome grouping — not by technical layer.
- DENY Projects that mix fundamentally different user workflows with no cohesion.
- REQUIRE minimal number of Projects that keeps execution parallelizable.
- REQUIRE overlap check across sibling Projects before HLD issue creation.

## Quality checklist
- REQUIRE each Project objective is outcome-based (user value delivered), not a task list.
- REQUIRE scope is bounded and verifiable.
- REQUIRE user stories have testable acceptance criteria — no subjective terms.
- REQUIRE error cases and edge behaviors are covered in acceptance criteria.
- REQUIRE candidate HLD Issues are scoped small enough for one focused execution cycle.
- REQUIRE every HLD Issue traces to both the Project user story and the Initiative PRD.
- REQUIRE sibling Project non-overlap is explicit.
- REQUIRE each meaningful Project/User Story change has a traceable Project update entry or equivalent comment trail.
