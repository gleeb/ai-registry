# Error Handling

## Missing PRD Story Groups

**Symptom**: `plan/prd.md` section 7 is empty or missing.

**Action**: Stop decomposition. Report to the Planning Hub that the PRD needs section 7 (User Story Groups) before story decomposition can proceed. Do NOT invent story groups.

## Missing Architecture Component Inventory

**Symptom**: `plan/system-architecture.md` lacks a component inventory or has vague component definitions.

**Action**: Stop decomposition. Report to the Planning Hub that the architecture needs a concrete component inventory with defined boundaries before story decomposition can proceed.

## Circular Dependencies

**Symptom**: Story A depends on Story B, and Story B depends on Story A (directly or transitively).

**Action**:
1. Identify the circular chain.
2. Determine if the stories should be merged (both are needed to deliver value).
3. Determine if a shared contract is missing (extract the shared interface).
4. Determine if the dependency is one-directional (fix the manifest).
5. Present all three options to the user with trade-offs.

## Orphaned Architecture Components

**Symptom**: An architecture component exists but no story references it.

**Action**:
1. Check if the component is a cross-cutting concern (handled in Phase 4, not per-story).
2. Check if the component is infrastructure that the scaffolding story covers.
3. If neither, flag it as potentially missing a story and ask the user.

## PRD Requirements Without Stories

**Symptom**: A PRD section 7 requirement exists but no story covers it.

**Action**:
1. Check if the requirement is captured by an existing story's acceptance criteria (mapping may be incomplete).
2. If genuinely uncovered, create a new story to address it.
3. If the requirement is unclear, ask the user for clarification before creating a story.

## Oversized Stories

**Symptom**: A story exceeds the sizing guidelines (>8 acceptance criteria, >3 components).

**Action**:
1. Propose a split to the user with specific boundary suggestions.
2. Identify which acceptance criteria go to which sub-story.
3. Determine if new contracts are needed between the sub-stories.
4. Re-assign dependencies and execution order.

## Undersized Stories

**Symptom**: A story has only 1 acceptance criterion and minimal scope.

**Action**:
1. Check if it can be merged with a related story.
2. If the story is genuinely minimal (e.g., a configuration change), keep it but add a note explaining why it's small.
3. Do NOT merge stories that touch different components just to satisfy sizing.

## Contract Ownership Disputes

**Symptom**: Two stories both claim to define the same interface.

**Action**:
1. Determine which story first creates the interface (lower execution_order).
2. Assign ownership to that story.
3. The later story becomes a consumer.
4. If the later story needs to extend the interface, document the extension in the contract with the owner's awareness.

## Incremental Mode Conflicts

**Symptom**: A brownfield change affects stories that have already been planned in Phase 3.

**Action**:
1. Do NOT modify Phase 3 artifacts directly.
2. Update the story outlines and dependency manifests.
3. Flag affected stories for re-planning by the Hub.
4. The Hub will re-dispatch Phase 3 agents for affected stories.
