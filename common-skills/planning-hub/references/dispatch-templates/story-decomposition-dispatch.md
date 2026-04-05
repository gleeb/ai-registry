# Story Decomposition Agent Dispatch Template

**DISPATCH TO**: `sdlc-planner-stories`

Use this template when dispatching `sdlc-planner-stories` via the Task tool.

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
Read and apply skills/planning-hub/references/shared-sparring-rules.md for all interactions.

OUTPUT:
- plan/user-stories/US-NNN-name/story.md — one per story
- plan/contracts/*.md — shared contract definitions

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Story inventory: ID, name, execution_order, candidate_domains, depends_on
2. Contract inventory: name, owner story, consumer stories
3. PRD coverage: sections covered / total sections
4. Architecture coverage: components covered / total components
5. Sizing summary: count of stories, any sizing warnings
6. Unresolved questions or risks

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Re-dispatch (after validation feedback)

When re-dispatching after Plan Validator returns NEEDS WORK, add:

```
VALIDATOR GUIDANCE (from Plan Validator):

REASONED CORRECTIONS:
[Paste the corrections section from the Plan Validator's guidance package.
Each correction includes what's wrong, what the better artifact looks like,
and the reasoning chain explaining why.]

DOCUMENTATION:
[Paste any fetched documentation excerpts from the guidance package.]
[Paste any documentation fetch instructions — if included, use context7 MCP
to retrieve the specified docs before revising. Search for the exact terms,
library, and sections specified.]

IMPROVEMENT INSTRUCTIONS:
[Paste the consolidated improvement instructions from the guidance package.
These are specific, actionable steps to follow.]

Apply the corrections and follow the improvement instructions. If documentation
fetch instructions are included, retrieve the docs via context7 first — they
contain the context needed to produce the correct artifact.
```
