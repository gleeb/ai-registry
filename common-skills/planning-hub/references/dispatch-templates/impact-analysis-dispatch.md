# Impact Analysis Dispatch Template

Use this template when dispatching `sdlc-plan-validator` in impact analysis mode for brownfield changes.

## Required Message Structure

```
VALIDATE: Impact Analysis

CONTEXT:
- Mode: IMPACT ANALYSIS (brownfield change assessment, NOT standard validation)
- A change has been proposed to the existing plan

CHANGE DESCRIPTION:
- [What is changing — be specific]
- Change level: [PRD | Architecture | Story (internal) | Story (contract) | Cross-cutting]
- Affected artifact: [file path of the artifact being changed]
- Proposed change summary: [brief description]

ARTIFACTS TO ANALYZE:
- [List ALL plan artifacts that exist — the validator needs the full dependency graph]
- plan/prd.md
- plan/system-architecture.md
- plan/contracts/*.md
- plan/user-stories/*/story.md (all stories with dependency manifests)
- plan/cross-cutting/*.md

ANALYSIS SCOPE:
- Trace the dependency graph from the change point
- Identify directly affected stories (dependency path exists)
- Identify indirectly affected stories (transitive dependencies)
- Identify affected contracts
- Identify cross-cutting concerns that need re-validation
- Report the blast radius with recommended re-planning scope

OUTPUT:
- Write impact analysis report to plan/validation/impact-analysis-report.md

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Confirmation that plan/validation/impact-analysis-report.md has been written
2. Blast radius summary: N stories directly affected, N indirectly, N contracts, N cross-cutting
3. Recommended re-planning scope (minimum set of agents to re-dispatch)
4. Estimated effort (number of agent dispatches needed)
5. Any dependency graph issues discovered (cycles, missing manifests)

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
