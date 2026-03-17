# Error Handling for Planning Hub

## Sub-Agent Fails to Complete

- **Trigger**: A dispatched agent does not complete (timeout, error, no output).
- **Action**: Retry once with the same template. If retry fails, escalate to user.
- **Action**: Report which agent failed, what inputs were provided, and what error occurred.
- **Options for user**: (a) Retry with different parameters, (b) Skip this agent with acknowledgment and document gap, (c) Manually provide the artifact and continue.
- **Prohibited**: Do not silently skip or proceed as if the agent succeeded.

## Validation Gate Fails Repeatedly

- **Trigger**: Same validation gate fails 2–3 times after re-dispatch with feedback.
- **Action**: Escalate to user. Present: what is failing, what has been tried, and options.
- **Options**: (a) Iterate with more specific user guidance, (b) Accept partial output with documented gaps, (c) Skip this artifact with explicit acknowledgment.
- **Action**: If user chooses (b) or (c), document in change-log.md and mark artifact as `PARTIAL` or `SKIPPED` in validation report.
- **Prohibited**: Do not bypass the gate without user acknowledgment.

## User Wants to Skip Phases

- **Trigger**: User requests to skip one or more phases (e.g., "skip testing strategy").
- **Action**: Surface consequences: what will be missing, what downstream phases cannot verify, what risks exist.
- **Action**: Require explicit user acknowledgment before proceeding.
- **Action**: Mark skipped phase outputs as `NOT PLANNED` in validation report.
- **Action**: Document skip in change-log.md.
- **Prohibited**: Do not skip without user confirmation.

## Brownfield Impact Analysis Reveals Large Blast Radius

- **Trigger**: Impact analysis shows many stories, contracts, or cross-cutting concerns affected.
- **Action**: Present blast radius clearly to user — which artifacts, estimated re-planning scope.
- **Action**: Offer options: (a) Proceed with full re-planning, (b) User narrows scope (e.g., "only re-plan stories X, Y, Z"), (c) Defer change.
- **Action**: Do not proceed with re-planning until user confirms scope.
- **Prohibited**: Do not assume user wants full re-planning without confirmation.

## Circular Dependencies in Story Execution

- **Trigger**: Validator or dependency manifest reveals circular dependencies in execution_order.
- **Action**: Report the cycle (which stories reference each other).
- **Action**: Escalate to user — execution order cannot be resolved automatically.
- **Action**: Request user to break the cycle (e.g., split a story, reorder dependencies).
- **Prohibited**: Do not proceed with Phase 3 until the cycle is resolved.

## Missing Skills or Modes

- **Trigger**: A required agent skill or mode is not available (e.g., planning-hld skill missing, validator in IMPACT ANALYSIS mode not found).
- **Action**: Report which skill or mode is missing and what phase/agent requires it.
- **Action**: Escalate to user — planning cannot complete without the missing capability.
- **Options**: (a) Install/configure the missing skill, (b) Skip the dependent phase with acknowledgment, (c) Use a fallback if one exists (document the substitution).
- **Prohibited**: Do not pretend the skill exists or produce placeholder outputs.
