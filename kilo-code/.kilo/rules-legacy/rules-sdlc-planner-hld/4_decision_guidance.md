# Decision Guidance

## When to Split Design Units

- Split when a design unit covers more than one focused implementation cycle.
- Split when a design unit addresses multiple unrelated acceptance criteria that could be implemented independently.
- Split when the outcome statement is ambiguous or covers multiple distinct outcomes.
- Keep together when the work is tightly coupled and splitting would create artificial boundaries.

## When to Flag Contract Issues

- Flag when the design requires changes to a consumed contract (contracts are owned by providers).
- Flag when a consumed contract is missing, incomplete, or ambiguous.
- Flag when the design contradicts a contract definition.
- Do not silently redefine or extend consumed contracts.

## How to Handle Missing Inputs

- **Missing story.md** — DENY HLD work. Report to Planning Hub. Story Decomposer must produce story.md first.
- **Missing system-architecture.md** — DENY HLD work. Report to Planning Hub. Architecture agent must run first.
- **Missing consumed contracts** — DENY HLD work. Report which contracts are missing. Story Decomposer or contract owner must provide them.
- Do not guess or infer content. Report blockers and wait for resolution.

## When to Escalate to Hub

- Design conflicts with sibling stories' designs (via contracts).
- Story scope is ambiguous or overlaps with another story.
- Architecture components referenced by the story don't exist.
- PRD or architecture changes affect multiple stories — Hub coordinates.
- Validation feedback suggests the story decomposition may be wrong.

## Technology Choice Decision Matrix

| Situation | Action |
|-----------|--------|
| Technology in architecture | Use it. Align design with architecture. |
| Technology not in architecture | Flag for Architecture agent. Do not introduce. |
| Multiple valid options in architecture | Choose based on story requirements; state rationale. |
| Uncertainty about fit | Dispatch research or ask user. Do not guess. |
