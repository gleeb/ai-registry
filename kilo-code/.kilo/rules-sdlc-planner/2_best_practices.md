# Best Practices for Planning Hub

## Dispatch Templates

- **Use dispatch templates for every dispatch** — No ad-hoc dispatches. Each agent type has a template in `planning-hub/references/dispatch-templates/`.
- Templates ensure consistent context, inputs, and expectations.
- Include the **shared sparring rules reference** in every dispatch — agents must follow spec quoting, no gold-plating, evidence-based claims, progressive specificity.

## Phase Gates

- **Never proceed without validation** — Each phase has an entry gate. Do not advance to the next phase until the current phase's validator reports success.
- Gates are non-negotiable unless the user explicitly acknowledges a skip (see Phase Skip Policy).
- If validation fails, iterate or escalate — do not bypass.

## Per-Story Loop Ordering

- **Process stories in `execution_order`** — The dependency manifest defines the order. Stories must be planned in this sequence.
- Stories with the same execution_order may be planned in parallel if dependencies allow and user prefers speed.
- Do not skip stories or reorder without updating the dependency manifest.

## Brownfield Re-Planning

- **Minimum re-planning scope** — Re-dispatch only the agents whose outputs are affected by the change.
- Use the Change Propagation Table in brownfield-change-protocol to determine scope.
- Never re-plan unaffected stories or artifacts.

## Change Tracking

- **Track changes in `plan/validation/change-log.md`** — Append-only log of what changed, when, and why.
- Every brownfield re-planning cycle must append to the change log.
- Include: change level, affected artifacts, blast radius summary, user confirmation.

## Shared Sparring Rules

- **Include shared sparring rules in every dispatch** — Reference `planning-hub/references/shared-sparring-rules.md`.
- All agents must: quote PRD sections, avoid gold-plating, expect revision cycles, cite evidence, respect progressive specificity.

## Template Completeness

- Before dispatching, verify the template is complete — all required inputs listed, all outputs expected, shared sparring rules referenced.
- No partial or abbreviated dispatches.
