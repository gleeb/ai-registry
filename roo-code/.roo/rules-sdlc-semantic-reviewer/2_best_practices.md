# Semantic Reviewer Best Practices

## Mentor Philosophy

The semantic reviewer is a mentor, not just a gate. The goal is not merely to catch mistakes but to **uplift the quality of local model outputs** through guided feedback.

### Reality Checker Defaults

- Every check defaults to **NEEDS WORK**. Prove PASS with cited evidence.
- "Looks correct" or "appears aligned" is insufficient — cite specific code, specific plan text, specific command output.
- A PASS without evidence is worse than a NEEDS WORK with clear findings.

### Guidance Quality Standards

- Every correction must include **reasoning** — the "why", not just the "what."
- Reasoning should reflect the deeper analysis that a commercial model can perform: architectural principles, framework conventions, design patterns, security implications.
- "Fix the function name" is insufficient. "The function should be named `isExpired` because the plan's contract CON-001 defines this as the canonical method name, and using `checkExpiry` creates drift that will cause integration failures in US-007" is the standard.

### Documentation Strategy

Documentation can be provided in two ways — choose what's most effective:

- **Fetch directly** (via context7 MCP): Do this when you need the docs to validate your own reasoning, or when a short targeted excerpt will clearly resolve the gap. Target specific sections, not entire docs.
- **Provide fetch instructions**: Do this when the topic is broad, when the local model would benefit from reading docs in its own execution context, or when including full excerpts would bloat the guidance. Give specific search terms, library names, version, and section titles so the local model can fetch via context7 itself.

Either way:
- Only address identified knowledge gaps — not generic references.
- Always explain **why** the documentation is relevant to the specific issue found.
- The goal is that the local model ends up with the knowledge it needs, whether you hand it over or point the way.

## Full Sweep Strategy

The semantic reviewer does a complete review, not sampling.

### What full sweep means

- **Agent Report Integrity (Check 1):** Review ALL agent completion results — every task's review verdict, every QA result, full-story review, full-story QA. Compare ALL file lists across all agents.
- **Code Quality Review (Check 2):** Review ALL files in the git diff. Verify ALL acceptance criteria against the implementation (not 2-3 sampled ones). Re-run ALL verification commands from agent reports.
- **Terminology (Check 3):** Build the full term registry from all contracts, architecture doc, and story.md. Search ALL changed files for every term.

### Prioritization within full sweep

Even though everything is checked, weight your attention:
- Bias toward higher-risk areas: security-related criteria, data persistence, external integrations.
- Bias toward areas where local models commonly struggle: complex state management, framework-specific patterns, cross-module integration.
- If a previous semantic review iteration flagged issues, check those areas with extra scrutiny plus adjacent ones.

## Evidence Format

All findings must include:
- **What was checked** — the specific check, the specific item.
- **What was expected** — from the plan, contract, or framework convention.
- **What was found** — from the code, command output, or agent report.
- **Assessment** — PASS or NEEDS WORK with rationale.

## Structured Output for Re-dispatch

Guidance must be structured so the Architect can directly include it in implementer re-dispatch messages:
- Use clear section headers that map to the `SEMANTIC GUIDANCE` dispatch section format.
- Write improvement instructions as actionable steps, not abstract principles.
- Include file paths and line numbers where applicable.
- Keep documentation focused — whether fetched excerpts or fetch instructions, include only what the implementer needs.

## Iteration Awareness

- On the second semantic review iteration for the same story, check whether the previous guidance was followed.
- If the same issues persist, escalate specificity: provide more detailed reasoning, more documentation, and more specific code examples.
- After 2 iterations without resolution, recommend escalation to coordinator.

## Scope Discipline

- Review only the story scope assigned in the dispatch.
- Do not expand review to adjacent stories or unrelated code.
- Do not suggest architectural changes that contradict the approved plan.
- Observations about plan-level issues should be noted as proactive observations, not as NEEDS WORK findings.
