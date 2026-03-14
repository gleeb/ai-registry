# Error Handling

## Missing story.md

- **Trigger:** `plan/user-stories/US-NNN-name/story.md` does not exist or is incomplete.
- **Action:** DENY HLD work. Report to Planning Hub: "Story US-NNN story.md is missing or incomplete. Story Decomposer must produce story.md first."
- **Prohibited:** Do not attempt HLD work. Do not guess story scope or acceptance criteria.

## Missing Architecture

- **Trigger:** `plan/system-architecture.md` does not exist or is incomplete.
- **Action:** DENY HLD work. Report to Planning Hub: "plan/system-architecture.md is required. Dispatch sdlc-planner-architecture first."
- **Prohibited:** Do not infer architecture. Do not proceed without architecture.

## Missing Contracts

- **Trigger:** A consumed contract listed in the story's dependency manifest is missing from `plan/contracts/`.
- **Action:** DENY HLD work. Report to Planning Hub: "Consumed contract(s) missing: [list]. Story Decomposer or contract owner must provide them."
- **Prohibited:** Do not design against assumed contracts. Do not create placeholder contracts.

## Design-Contract Conflicts

- **Trigger:** The design contradicts a consumed contract definition.
- **Action:** Correct the design to comply with the contract. If the design requires contract changes, flag for Story Decomposer: "Design requires changes to consumed contract [name]. Contract owner must update."
- **Prohibited:** Do not silently redefine contracts. Do not proceed with conflicting design.

## Over-Scoped Design

- **Trigger:** Design units go beyond the story's acceptance criteria.
- **Action:** Identify out-of-scope content. Remove it or split into a separate story. Re-run validation.
- **Prohibited:** Do not include design that cannot be traced to story ACs.

## Validation Failures

- **Trigger:** Self-validation checks fail (traceability, contract compliance, technology alignment, etc.).
- **Action:** Iterate on the design. Fix failures. Re-run all checks. Do not proceed to completion until all pass.
- **Prohibited:** Do not skip or bypass validation. Do not write `hld.md` with failing checks.

## Incremental Mode

- **Trigger:** User wants to update an existing HLD rather than create from scratch (e.g., based on validation feedback).
- **Action:** Read existing `plan/user-stories/US-NNN-name/hld.md`. Identify what changed. Update only affected design units. Re-run all self-validation checks on the full artifact. Check for new overlap or traceability breaks.
- **Prohibited:** Do not overwrite without understanding context. Do not assume unchanged sections are still valid.
