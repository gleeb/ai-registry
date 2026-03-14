# error_handling

## scenario: research_dispatch_failure

**Trigger:** sdlc-project-research agent fails to start, crashes, or returns an error.

**Required actions:**
- Report the failure to the user: which research was requested, what error occurred.
- Score technical_feasibility dimension as "medium" with note: "Research dispatch failed — manual verification recommended."
- Present probing questions for technical_feasibility to the user for manual resolution.
- Offer to retry research dispatch once, or proceed with user-provided evidence.

**Prohibited actions:**
- Do not guess or fabricate research findings.
- Do not score technical_feasibility as "high" without evidence.

## scenario: validation_gate_override

**Trigger:** User wants to proceed to completion despite one or more dimensions not at "high".

**Required actions:**
- Identify each non-high dimension and its specific risk.
- Present the risks explicitly: "If we proceed, [dimension X] at [low/medium] means [specific downstream impact]."
- Require explicit written acknowledgment for each non-high dimension before proceeding.
- Document the override and acknowledgments in the PRD metadata or completion summary.

**Prohibited actions:**
- Do not silently skip the gate.
- Do not proceed without per-dimension risk acknowledgment.

## scenario: stale_plan_artifacts

**Trigger:** Existing plan/prd.md exists but appears outdated or inconsistent with user's current intent.

**Required actions:**
- Present the existing PRD state to the user.
- Ask: "Is this PRD still accurate, or has the scope/requirements changed?"
- If incremental update: re-validate the entire PRD after changes, not just the modified sections.
- If full rewrite: treat as greenfield and run full context_and_sparring and prd_drafting.

## scenario: user_wants_to_skip_validation

**Trigger:** User asks to skip the 8-dimension validation cycle and proceed to completion.

**Required actions:**
- Explain that validation protects downstream planning from weak assumptions.
- Present the scorecard with current dimensions (low/medium/high) and key issues.
- Require explicit written acknowledgment of the specific risk for each non-high dimension.
- If user insists: proceed only after per-dimension acknowledgment.
- Document the override in the completion summary.

**Prohibited actions:**
- Do not silently skip validation.
- Do not proceed without per-dimension risk acknowledgment.

## scenario: technical_feasibility_blocked

**Trigger:** A validation dimension (especially technical_feasibility) is blocked because the planner lacks evidence.

**Required actions:**
- DENY guessing — do not fabricate or assume feasibility.
- Recommend dispatching sdlc-project-research for the specific technology or requirement.
- If research is not available: score the dimension as "medium" and present probing questions for user to provide evidence.

**Prohibited actions:**
- Do not score as "high" without evidence.

## scenario: incremental_update

**Trigger:** User wants to update an existing PRD rather than draft from scratch.

**Required actions:**
- Read existing plan/prd.md and identify what has changed.
- Re-run sparring for all affected sections; do not assume unchanged sections are still valid.
- Re-validate the entire PRD after updates, not just the changed sections.
- Cross-check consistency between changed and unchanged sections.
