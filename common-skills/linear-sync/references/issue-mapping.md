# LLD Issue Mapping (Linear)

## Purpose
Defines how execution-level LLD Issues are represented in Linear. LLDs are created by the sdlc-architect during execution, not during planning. This reference is used by the sync layer when the architect needs to create Issues in Linear.

## Contract gates
- REQUIRE parent Project linkage and parent Initiative objective trace.
- REQUIRE explicit acceptance criteria before creating the Issue in Linear.
- REQUIRE overlap check against sibling Issues in the same Project.
- DENY Issue writes when MCP state snapshot is missing for current iteration.
- DENY closing conditions that are not observable/testable.
- REQUIRE Issue-level change communication through comments using the minimal contract in [`communication.md`](communication.md).
- ALLOW provisional local LLD draft only when clearly marked `PROVISIONAL - NOT SYNCED TO LINEAR`.

## Issue template (Linear fields)

### 1) Title
- Concise outcome statement describing the user/system outcome.

### 2) Description
- Parent linkage: parent Project reference and Initiative objective trace.
- Scope: what this Issue includes and explicitly excludes.
- Acceptance criteria: testable, observable conditions (Given/When/Then or bullet checks).
- Dependencies and blockers: upstream Issues, external dependencies, known blockers.

### 3) Labels/metadata
- Type: LLD / Implementation
- Priority: per project conventions
- Assignee: sdlc-architect or sdlc-implementer

### 4) Verification notes
- How completion will be validated (tests, metrics, review artifact).

### 5) Done definition
- Explicit criteria for closing in Linear.

## Traceability
- Parent Project ID/reference and parent Initiative anchor are REQUIRED.
- Sibling Issue non-overlap statement in description.
- Each meaningful Issue change has a traceable comment/update trail with rationale and impact.
