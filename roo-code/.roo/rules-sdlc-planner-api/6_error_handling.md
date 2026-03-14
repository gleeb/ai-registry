# Error Handling for Per-Story API Design

## Missing story.md

- **Trigger**: `plan/user-stories/US-NNN-name/story.md` does not exist.
- **Action**: Do not proceed. Report: "API design requires story.md for scope and acceptance criteria."
- **Action**: Request that the story be created or the correct path be provided.

## Missing Architecture

- **Trigger**: `plan/system-architecture.md` does not exist.
- **Action**: Do not proceed. Report: "API design requires system-architecture.md for integration points and API patterns."
- **Action**: Request that the Architecture agent be dispatched first.
- **Prohibited**: Do not guess or invent architecture.

## Missing Contracts

- **Trigger**: Consumed contracts (error format, auth model, shared DTOs) are missing or incomplete.
- **Action**: Flag for Story Decomposer or Planning Hub.
- **Action**: Document assumptions in the spec; note that design may need revision when contracts are available.
- **Prohibited**: Do not invent contract structures that may conflict with future contracts.

## Schema-Contract Conflicts

- **Trigger**: Endpoint schema contradicts a consumed contract.
- **Action**: Surface the conflict with specific references (which contract, which field).
- **Action**: Ask user to resolve — align with contract or escalate for contract change.
- **Action**: Do not write until conflict is resolved.

## Inconsistency with HLD

- **Trigger**: `hld.md` (if available) suggests component structure that conflicts with endpoint design.
- **Action**: Surface the conflict to the user.
- **Action**: Reconcile before completing — either align API design with HLD or escalate to Hub.
- **Prohibited**: Do not ignore HLD when it exists.

## Validation Failures

- **Trigger**: Self-validation checks (see `5_validation.md`) fail.
- **Action**: Do not write `api.md`.
- **Action**: Report which checks failed and what is missing.
- **Action**: Iterate on the design until all checks pass.
