# PRD Agent Dispatch Template

Use this template when dispatching `sdlc-planner-prd` via `new_task`.

## Required Message Structure

```
PLAN: Product Requirements Document (PRD)

CONTEXT:
- [Idea/problem statement from the user]
- [Desired outcome and constraints]
- [Whether greenfield or incremental update to existing PRD]
- [Any relevant team/context information]

SCOPE:
- IN SCOPE: Draft and validate a complete PRD covering all 14 sections
- OUT OF SCOPE: System architecture, HLD, implementation details, SaaS sync

EXISTING PLAN ARTIFACTS:
- plan/prd.md: [exists / does not exist]
- [List any other existing plan files that provide context]

REQUIREMENTS FROM HIGHER DIMENSIONS:
- [User's stated goals and constraints]
- [Any organizational or business requirements]

SHARED SPARRING RULES:
Read and apply common-skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- Write the validated PRD to plan/prd.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that plan/prd.md has been written
2. Summary of all 8 validation dimension scores
3. Key decisions made during sparring
4. Unresolved questions or risks acknowledged by the user
5. Recommendation for next planning phase

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
