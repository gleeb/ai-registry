# coordinator_best_practices

## principles

### principle: state_driven_routing (priority="HIGH")

**description:**
Always check project state via Linear MCP before routing. Never route
based on keyword matching alone. "Let's work on project-x" could mean
planning or implementing — the state determines which.

**rationale:**
Keyword-based routing caused incorrect routing to planner when issues
already existed. State-driven routing ensures the correct phase is selected.

**bad_example:** User says "let's start on project-x" → route to planner because "start" sounds like planning.

**good_example:** User says "let's start on project-x" → check Linear → issues exist in Backlog → route to architect.

### principle: minimal_coordinator_context (priority="HIGH")

**description:**
Coordinator passes context through staging documents and Linear state,
not through its own memory or verbose dispatch messages.
Keep dispatch messages focused on scope, boundaries, and contracts.

**rationale:**
Staging documents persist across sessions. Coordinator memory does not.
Using staging docs as the context bus ensures resumability.

### principle: single_question_disambiguation (priority="MEDIUM")

**description:**
When state is ambiguous or MCP is unavailable, ask exactly ONE
disambiguating question. Do not ask multiple questions or present
lengthy menus.

**rationale:**
Multiple questions slow down the user. One focused question resolves
the routing decision efficiently.

## common_pitfalls

### pitfall: routing_to_planner_when_issues_exist

**why_problematic:**
Sends the user back to planning when they want to implement, wasting
time and causing frustration.

**correct_approach:**
Check Linear for issues. If issues exist, route to architect for execution.

### pitfall: direct_implementer_dispatch

**why_problematic:**
Coordinator should not dispatch directly to implementer. The architect
manages the full execution cycle (implement, review, QA).

**correct_approach:**
Always dispatch to sdlc-architect for execution work. Architect handles
sub-mode dispatch internally.

### pitfall: skipping_state_check

**why_problematic:**
Without state check, routing defaults to pattern matching which is unreliable.

**correct_approach:**
Always attempt Linear MCP state check first. Only fall back to
disambiguation question if MCP is unavailable.

## quality_checklist

- Linear MCP was queried before routing decision.
- State classification (NONE/PLANNED/READY/IN_PROGRESS/DONE) is explicit.
- Dispatch message follows mandatory delegation contract.
- No direct dispatch to sdlc-implementer, sdlc-code-reviewer, or sdlc-qa.
