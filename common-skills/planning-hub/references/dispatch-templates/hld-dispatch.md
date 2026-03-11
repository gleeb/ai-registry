# HLD Agent Dispatch Template

Use this template when dispatching `sdlc-planner-hld` via `new_task`.

## Required Message Structure

```
PLAN: High-Level Design and User Story Decomposition

CONTEXT:
- [Reference to plan/prd.md — PRD must exist and be validated]
- [Reference to plan/system-architecture.md — architecture must exist]
- [Whether this is full decomposition or targeted update]

SCOPE:
- IN SCOPE: HLD per component/feature area, user story decomposition, acceptance criteria, traceability
- OUT OF SCOPE: LLD (created by architect during execution), implementation code, detailed API specs (API Design agent)

EXISTING PLAN ARTIFACTS:
- plan/prd.md: [REQUIRED]
- plan/system-architecture.md: [REQUIRED]
- plan/hld.md: [exists / does not exist]
- plan/user-stories/: [exists / does not exist]
- [List any other relevant existing plan files]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- [User story groups from PRD section 7]
- [Architecture components and boundaries from system-architecture.md]
- [Technology decisions that constrain the HLD]
- [Security requirements that affect design]

OUTPUT:
- Write the HLD to plan/hld.md
- Write user stories to plan/user-stories/US-NNN-[name].md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that plan/hld.md and user stories have been written
2. Traceability summary: PRD → User Story → HLD section mapping
3. Component-level design decisions
4. User story inventory with acceptance criteria summary
5. Sibling overlap check results
6. Unresolved questions or blockers

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
