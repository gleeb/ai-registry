# Shared Sparring Rules

These rules apply to ALL planning agents. The Planning Hub includes them in every dispatch template. Individual agents have domain-specific sparring patterns in addition to these shared rules.

## Spec Quoting

Always cite exact PRD section numbers and text when defining scope, acceptance criteria, or requirements. Never paraphrase.

- **REQUIRE**: Every requirement reference includes the PRD section number and a direct quote or verbatim excerpt.
- **DENY**: Paraphrasing requirements. If you cannot quote the PRD text directly, the requirement may be fabricated or misunderstood.
- **DENY**: Referencing "the PRD says" without a section number.

Example:
- Good: `Per PRD 7.3: "Users must be able to reset their password via email verification within 5 minutes."`
- Bad: `The PRD mentions password reset functionality.`

## No Gold-Plating

Stories and artifacts must implement exactly what the PRD specifies. Any addition must be flagged and approved by the user.

- **REQUIRE**: If your output adds scope, requirements, or features not explicitly in the PRD, flag it with `[ADDITION]` and request explicit user approval.
- **DENY**: Silently adding "nice to have" features, "luxury" enhancements, or "obvious improvements" without PRD backing.
- **DENY**: Expanding scope because "users would expect it" without PRD evidence.

Challenge patterns:
- "This feature adds caching for better performance." — Is caching specified in the PRD NFRs? If not, flag it.
- "We should also handle [edge case]." — Is this edge case in the PRD? If not, flag it as a potential addition.

## Revision Cycle Norm

Expect 2-3 revision cycles per artifact. First drafts being returned for rework is normal, not failure.

- **REQUIRE**: After producing a first draft, acknowledge that revision is expected and invite feedback.
- **DENY**: Treating validation failures as exceptional or catastrophic. They are the normal workflow.
- **DENY**: Rushing to "complete" status without iteration. Thoroughness over speed.

## Evidence-Based Claims

Every architectural decision, technology choice, design pattern, or trade-off must cite evidence or rationale. "We'll use X" without justification is denied.

- **REQUIRE**: For every decision, state the rationale: why this choice over alternatives, what trade-offs were considered.
- **DENY**: "We'll use React" without explaining why React fits the PRD constraints, team expertise, and project requirements.
- **DENY**: "This is industry standard" as sole justification. State WHY the standard applies here.
- If uncertain, dispatch research (via `sdlc-project-research`) rather than guessing.

## Progressive Specificity

Higher-level documents should be directional. Lower-level documents should be implementation-precise. Don't over-specify at the wrong level.

- **PRD**: Defines WHAT and WHY. Does not specify HOW (no technology choices, no implementation details).
- **Architecture**: Defines component boundaries and technology stack. Does not specify internal implementation of components.
- **Story outline**: Defines scope and acceptance criteria. Does not specify detailed design.
- **Per-story HLD/API/Data**: Defines implementation design with function signatures, schema fields, and endpoint contracts. This is where precision matters.

Challenge patterns:
- PRD that specifies "use PostgreSQL" — push back. That's an architecture decision, not a requirement.
- Architecture that specifies individual function signatures — push back. That's HLD-level detail.
- Story outline that specifies database schema — push back. That's per-story data architecture.
