# best_practices

## general_principles

### principle (priority: critical)

**Name:** Challenge over-engineering

**Description:** Push back on architectures that add complexity before it is justified. Prefer the simplest topology that meets the PRD's requirements.

**Rationale:** Over-engineering increases cost, maintenance burden, and failure mode surface. Start simple; evolve when evidence demands it.

### principle (priority: critical)

**Name:** Justify every technology choice

**Description:** Every technology in the stack must have a documented rationale. No "industry standard" or "best practice" without project-specific justification.

**Rationale:** Technology choices without justification lead to bandwagon adoption and inappropriate tooling.

### principle (priority: critical)

**Name:** Document trade-offs

**Description:** For every significant architectural decision, document what was chosen, what was rejected, and why.

**Rationale:** Trade-offs are invisible without documentation. Future maintainers need to understand the reasoning.

### principle (priority: high)

**Name:** Consider failure modes

**Description:** Every component and integration point must have its failure modes addressed: what happens when it fails, how is it detected, how is it recovered.

**Rationale:** Systems that only consider the happy path fail in production.

### principle (priority: high)

**Name:** Keep components loosely coupled

**Description:** Component boundaries should minimize coupling. Prefer interfaces over implementation details. Dependencies should flow in one direction where possible.

**Rationale:** Tight coupling makes changes expensive and cascading failures likely.

### principle (priority: high)

**Name:** Plan for scalability based on evidence not assumptions

**Description:** Scalability decisions must be grounded in PRD projections, load estimates, or explicit constraints. No "we might need to scale" without quantified targets.

**Rationale:** Premature scaling adds complexity without benefit. Evidence-based scaling avoids both under- and over-engineering.

## common_pitfalls

### pitfall

**Description:** Adding microservices without load or team-size justification

**why_problematic:** Microservices add operational complexity. Without evidence of need, they are premature.

**correct_approach:** Ask: "What load or team size justifies this topology? What is the cost of starting simpler?"

### pitfall

**Description:** Technology stack without rationale

**why_problematic:** Leads to inappropriate tooling and maintenance burden.

**correct_approach:** Document why each technology was chosen for this project specifically.

### pitfall

**Description:** Ignoring failure modes

**why_problematic:** Produces brittle systems that fail unpredictably in production.

**correct_approach:** For every component, document: failure detection, failure handling, recovery.

### pitfall

**Description:** Vague scalability claims

**why_problematic:** "We can scale" without targets or strategy is meaningless.

**correct_approach:** Require quantified targets: requests/sec, users, data volume. Document scaling strategy.

### pitfall

**Description:** Tight coupling between components

**why_problematic:** Makes changes brittle and cascading failures likely.

**correct_approach:** Define clear boundaries and interfaces. Minimize cross-component dependencies.

## quality_checklist

### category: before_draft_completion

- Every PRD capability maps to at least one component.
- Every technology choice has rationale.
- All integration points have failure mode coverage.
- Scalability strategy is grounded in PRD projections.
- Component dependency graph is complete.

### category: before_user_review

- No placeholder sections.
- Trade-offs documented for each major decision.
- Single points of failure identified and addressed.
