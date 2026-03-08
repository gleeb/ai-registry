# LLD (Issue) Reference

## Contents
- Purpose
- Contract gates
- Issue template
- Acceptance criteria patterns
- Sizing and readiness checks

## Purpose
Use this format for execution-level Issues under an HLD Project.

## Contract gates
- REQUIRE parent Project linkage and parent Initiative objective trace.
- REQUIRE explicit acceptance criteria before proposing write actions.
- REQUIRE overlap check against sibling Issues in the same Project.
- DENY Issue writes when MCP state snapshot is missing for current iteration.
- DENY closing conditions that are not observable/testable.
- REQUIRE Issue-level change communication through comments using the minimal contract in [`references/COMMUNICATION.md`](references/COMMUNICATION.md).
- ALLOW provisional local LLD draft only when clearly marked `PROVISIONAL - NOT SYNCED TO LINEAR`.

## Issue template
### 1) Outcome statement
- Describe the user/system outcome in one sentence.

### 2) Parent linkage
- Parent Project reference.
- Trace to Initiative objective.

### 3) Scope
- What this Issue includes.
- What this Issue does not include.

### 4) Acceptance criteria
- Use testable, observable conditions.
- Prefer Given/When/Then or bullet checks.

### 5) Dependencies and blockers
- Upstream dependencies.
- External blockers and owner.

### 6) Verification notes
- How completion will be validated (tests, metrics, review artifact).

### 7) Done definition
- Explicit criteria for closing in Linear.

### 8) Traceability and overlap control
- Parent Project ID/reference and parent Initiative anchor.
- Sibling Issue non-overlap statement.

## Acceptance criteria patterns
- REQUIRE functional behavior is observable in the target environment.
- REQUIRE error cases and boundary cases are included.
- REQUIRE non-functional expectations (performance/reliability/security) when relevant.
- REQUIRE evidence format for closure (test result, metric, or artifact).

## Sizing and readiness checks
- REQUIRE Issue is small enough for one focused implementation cycle.
- REQUIRE requirements are unambiguous.
- REQUIRE dependencies are known or explicitly tracked.
- REQUIRE closing evidence is clear before starting.
- REQUIRE trace link back to Project objective and Initiative objective anchor.
- REQUIRE each meaningful Issue change has a traceable comment/update trail with rationale and impact.
