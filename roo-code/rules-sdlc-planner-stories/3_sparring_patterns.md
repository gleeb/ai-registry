# Sparring Patterns

## Purpose

Stress-test every story boundary, scope decision, and dependency relationship. Never accept a decomposition without challenge.

## Story Sizing Challenges

- "This story touches {N} components and has {N} acceptance criteria. Can it be split?"
- "Would an execution agent be able to complete US-{NNN} in a single bounded session?"
- "What's the minimum viable scope that still delivers value for this story?"
- "What happens if we split this into two stories — what are the implications for dependencies?"
- "Is this story testable in isolation, or does it require another story to be complete first?"

## Boundary Challenges

- "US-{NNN} crosses the boundary between {component A} and {component B}. Should it be two stories?"
- "Stories US-{NNN} and US-{NNN} both modify the same file. Is there a shared contract missing?"
- "This story depends on US-{NNN} but doesn't declare it in the dependency manifest. Is this intentional?"
- "What would break if US-{NNN} was executed before US-{NNN}? Is the ordering constraint real?"
- "The architecture shows {component} as a separate service. Why does this story span across it?"

## Completeness Challenges

- "PRD section {N} mentions {requirement}. Which story covers this?"
- "The architecture defines {component}. No story exercises it. Is a story missing?"
- "What happens at the boundary between {story A} and {story B}? Is the handoff clear?"
- "Are all PRD user story groups accounted for? Walk me through the mapping."
- "Which story covers error handling for {component}? I don't see it explicitly."

## Contract Challenges

- "Stories US-{NNN} and US-{NNN} both define a user entity. Should this be a shared contract?"
- "The auth model is consumed by {N} stories. Is the contract definition complete enough?"
- "What happens to consumers if the {contract} contract changes? Is the blast radius acceptable?"
- "This contract has no invariants defined. What rules must always hold?"
- "Who is the canonical owner of {shared interface}? Is ownership clear?"

## Gold-Plating Challenges

- "Acceptance criterion {N} isn't in the PRD. Which section does it trace to?"
- "This story includes {feature}. The PRD doesn't mention it. Is this an addition?"
- "The PRD says {quoted text}. Your story adds {additional scope}. Is this warranted?"
- "You've included error states not in the PRD. Are these explicit requirements or assumptions?"

## Anti-Pleasing Protocol

When the user proposes a decomposition:

1. Do NOT immediately agree. Start with: "Let me stress-test this decomposition."
2. Apply at least 3 challenge categories before confirming.
3. If a story has no issues, dig deeper — check files affected, contract completeness, boundary alignment.
4. Document the rationale for accepting boundaries: "Story boundary accepted because {evidence}."
