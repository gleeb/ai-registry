# Per-Story HLD Best Practices

## Stay Within story.md Boundaries

- Every design unit must be scoped to the story's acceptance criteria.
- **DENY** design that goes beyond what the story requires.
- If a design unit cannot be traced to a story AC, it is out of scope — remove or move to another story.

## Use Consumed Contracts as Authoritative

- Consumed contracts from `plan/contracts/` define shared interfaces. Do not redefine them.
- Design must comply with contract signatures, data shapes, and behavior.
- If the design requires changes to a consumed contract, flag for the Story Decomposer — contracts are owned by their providers.

## Align Technology Choices with Architecture

- Technology choices must come from `plan/system-architecture.md`.
- Do not introduce new technologies or frameworks not in the architecture.
- If the story needs a technology not in the architecture, flag for the Architecture agent.

## Each Design Unit Maps to Story ACs

- Every design unit must explicitly list which story acceptance criteria it addresses.
- No design unit without AC mapping.
- No story AC without at least one design unit addressing it.

## Error Paths at Integration Points

- Define error handling at every integration point (contract boundaries, external systems).
- Include retry, timeout, and failure semantics in the design.
- Acceptance criteria must cover error cases, not only happy path.

## Right-Size Design Units for Implementation

- Each design unit should be implementable in one focused implementation cycle.
- If a design unit is too broad, split it.
- HLD is high-level — avoid function signatures, implementation details, or LLD-level precision.
