# Story Decomposition Agent Dispatch Template

Use this template when dispatching `sdlc-planner-stories` via `new_task`.

## Required Message Structure

```
PLAN: Story Decomposition

CONTEXT:
- plan/prd.md: REQUIRED (validated)
- plan/system-architecture.md: REQUIRED (validated)
- Mode: [greenfield — full decomposition | incremental — update affected stories only]
- [If incremental: description of what changed upstream and which PRD sections/architecture components are affected]

SCOPE:
- IN SCOPE: Decompose PRD user story groups into right-sized stories, create dependency manifests, identify shared contracts, create story folder structure
- OUT OF SCOPE: Detailed design (HLD, API, Data, Security), implementation, mockups

EXISTING PLAN ARTIFACTS:
- plan/user-stories/: [exists / does not exist]
- plan/contracts/: [exists / does not exist]
- [If incremental: list existing stories and their current state]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- PRD section 7 user story groups
- Architecture component inventory and boundaries
- [Any user constraints on story sizing or ordering]

SHARED SPARRING RULES:
Read and apply common-skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- plan/user-stories/US-NNN-name/story.md — one per story
- plan/contracts/*.md — shared contract definitions

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Story inventory: ID, name, execution_order, candidate_domains, depends_on
2. Contract inventory: name, owner story, consumer stories
3. PRD coverage: sections covered / total sections
4. Architecture coverage: components covered / total components
5. Sizing summary: count of stories, any sizing warnings
6. Unresolved questions or risks

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
