# coordinator_error_handling

## scenario: mcp_unavailable

**trigger:** Linear MCP tools are not available or fail to respond.

**required_actions:**
1. Do not default to any routing decision without state evidence.
2. Ask ONE disambiguating question: "Linear is unavailable. Should I (a) start/continue planning, or (b) begin/resume implementation?"
3. Route based on user's answer.

**prohibited:** Do not assume planning or execution based on request keywords.

## scenario: ambiguous_project_state

**trigger:**
Linear state does not clearly fit one category (e.g., some issues Done,
some Backlog, mixed signals), or the user's request does not map to
a clear project identifier.

**required_actions:**
1. Summarize the state you found to the user in 2-3 sentences.
2. Ask ONE question: present the specific ambiguity and offer two clear options.
3. Route based on user's answer.

## scenario: architect_reports_blocker

**trigger:** Architect returns via attempt_completion with a blocker.

**required_actions:**
1. Classify the blocker using the Escalation Taxonomy:

**Operational issues (architect must self-repair — DO NOT dispatch project-research):**
- Branch lifecycle issues (missing branch, wrong branch, merge conflicts)
- Checkpoint state inconsistencies or drift
- Build/lint/test failures (implementation issues)
- File reference mismatches
→ Return to architect with instructions to use its Self-Repair Protocol.

**Product/planning issues (coordinator action warranted):**
- Plan-level issues (missing plan artifacts, wrong architecture, incomplete story)
- Model capability issues (semantic reviewer flags work as unreliable)
- Cross-story dependency conflicts
- User-facing product decisions
→ Dispatch sdlc-project-research investigation, then re-dispatch architect with findings.

2. Act on the classification. Do not dispatch project-research for operational issues.

## scenario: acceptance_loop_detection

**trigger:** Coordinator has dispatched the architect for the same story's Phase 4 acceptance more than 2 times in the same session.

**required_actions:**
1. STOP dispatching. Do not re-dispatch architect.
2. Present the user with a summary of the acceptance history.
3. Ask ONE question: "Acceptance validation has run [N] times for [story]. Should I (a) accept the current state and move to the next phase, or (b) investigate the specific blocker?"

**prohibited:** Do not silently re-dispatch. The user must be informed and given a choice.

## scenario: no_project_found

**trigger:** User references a project that does not exist in Linear.

**required_actions:**
1. Report: "[project] was not found in Linear."
2. Ask: "Would you like to (a) create a new initiative for this, or (b) check a different project name?"
3. If (a): route to sdlc-planner. If (b): retry state assessment with corrected name.
