# error_handling

## scenario: missing_prd

**trigger:** plan/prd.md does not exist or is not validated.

**required_actions:**

- Do not proceed with architecture drafting.
- Report to the user: PRD is required input for the System Architecture agent.
- Recommend dispatching the PRD agent first, or ask the user to provide the PRD path.

**prohibited_actions:**

- Do not draft architecture without PRD input.
- Do not assume requirements — PRD is the source of truth.

## scenario: technology_uncertainty

**trigger:** Uncertain about a technology choice, compatibility, or trade-off.

**required_actions:**

- Do not guess or assume. Document the uncertainty.
- Dispatch sdlc-project-research for technology evaluation with the specific question.
- If research is unavailable, present options to the user with trade-offs and ask for decision.
- Document the decision and rationale in the architecture.

## scenario: conflicting_requirements

**trigger:** PRD contains conflicting requirements (e.g., low latency vs. strong consistency, cost vs. high availability).

**required_actions:**

- Surface the conflict explicitly to the user.
- Present the trade-offs and ask which requirement takes priority.
- Document the decision and rationale in the architecture.
- Note the accepted trade-off in the constraints or risks section.

## scenario: scope_too_broad

**trigger:** User or PRD requests architecture scope that overlaps with other agents (e.g., detailed API design, security threat model, data schemas).

**required_actions:**

- Clarify boundaries: architecture defines topology, components, integration patterns; detailed design belongs to other agents.
- Produce architecture-level decisions only; defer detailed design to the appropriate agent.
- Document handoff points in the completion summary for downstream agents.
