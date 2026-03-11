# Sparring Patterns for Planning Hub

## Philosophy

The Hub's sparring is meta-level: it challenges orchestration decisions, not content. The Hub does not author plan content — it questions whether the right agents are being dispatched at the right time with the right inputs.

## Challenge Categories

### Dispatch Timing

- **"Is this the right time to dispatch this agent?"** — Prerequisites must be met. Dispatching Architecture before PRD validation is wrong. Dispatching Design before HLD is wrong.
- Challenge: "Why are we dispatching this agent now? What does it need that might not be ready?"

### Prerequisite Completeness

- **"Have all prerequisites been met?"** — Each agent has specific inputs. Before dispatching, verify the inputs exist and are validated.
- Challenge: "Story Decomposer needs validated architecture. Has the architecture validator passed? What does the API agent need — story.md, system-architecture, contracts?"

### Dispatch Template Quality

- **"Is the dispatch template complete?"** — Does the template include all required context, inputs, outputs, and shared sparring rules?
- Challenge: "Are we sending a generic prompt or a template that specifies the story path, consumed contracts, and validation expectations?"

### Brownfield Scope

- **"Should brownfield re-planning be broader or narrower?"** — Impact analysis may suggest a large blast radius. Is it accurate? Could we narrow scope with user input?
- Challenge: "The blast radius shows 10 stories affected. Is that correct, or did we over-trace? Should we re-plan all 10 or can the user narrow to 3?"

### Validation Gate Skipping

- **"What would happen if we skipped this validation gate?"** — Before allowing a skip, surface the consequences.
- Challenge: "If we skip per-story validation, we may proceed with inconsistent artifacts. What would break downstream? What would the validator flag?"

### Phase Transition Rationale

- **"Why are we moving to the next phase?"** — Ensure the gate passed, not just that an agent completed.
- Challenge: "The PRD agent finished. Did the validator pass? If not, we're not ready for Phase 2."

## Anti-Pleasing Patterns (DENIED)

- **Dispatching without validation** — Proceeding to the next phase because an agent "finished" without running the validator.
- **Ad-hoc dispatches** — Sending prompts without using the dispatch template.
- **Over-broad brownfield re-planning** — Re-planning everything when only a subset is affected.
- **Skipping gates without user acknowledgment** — Never skip a phase gate unless the user explicitly acknowledges and understands the risk.
