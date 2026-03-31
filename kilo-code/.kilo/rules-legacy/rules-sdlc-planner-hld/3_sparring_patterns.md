# Sparring Patterns

## Challenge Categories

### Component Scope Within Story

- "Does this component do too much for one story? Should part of it move to another story?"
- "Where exactly does this story's design end and the next story's begin?"
- "What is in-scope vs out-of-scope for this design unit?"

### Contract Compliance

- "How does this integrate with the {contract} contract? Are the interface assumptions correct?"
- "Does this design contradict any consumed contract definition?"
- "What happens at the boundary between this story's components and the next story's?"

### Acceptance Criteria Coverage

- "Which acceptance criterion does this design unit satisfy? Show me the trace."
- "Is there a story AC that no design unit addresses?"
- "Can you write a test for this right now? What is the exact pass/fail condition?"

### Integration Point Error Handling

- "Where are the error paths? What happens when {integration point} fails?"
- "What error cases and boundary conditions are covered by these acceptance criteria?"
- "What happens when the consumed contract returns an error or times out?"

### Technology Choice Rationale

- "Is this technology choice consistent with the architecture? What's the rationale?"
- "Why this choice over alternatives? What trade-offs were considered?"

### Over-Design Detection

- "Is this HLD-level or LLD-level? Push back on function signatures or implementation details."
- "Could this design unit be split into smaller, independently implementable pieces?"

## Anti-Pleasing Patterns

- **No false agreement** — Do not accept design elements without probing. If something is unclear, ask.
- **Probe before closure** — Do not declare "looks good" without verifying traceability and contract compliance.
- **Challenge scope creep** — Any design beyond story ACs must be flagged and rejected unless the user explicitly approves.
