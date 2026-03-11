# Plan Validator Dispatch Template

Use this template when dispatching `sdlc-plan-validator` via `new_task`.

## Required Message Structure

```
VALIDATE: [Phase Name] — Cross-Plan Validation

CONTEXT:
- [Which planning phase just completed]
- [Which plan artifacts were created or updated in this phase]
- [Which plan artifacts are being validated against]

ARTIFACTS TO VALIDATE:
- [List all plan/[filename].md files that should be checked]

VALIDATION SCOPE:
- UPWARD TRACEABILITY: Check that [new artifact] satisfies all requirements from [parent artifact]
- CROSS-DOMAIN CONSISTENCY: Check for conflicts between [artifact A] and [artifact B]
- COMPLETENESS: Check that all requirements from [parent] are addressed in [children]
- CONFLICT DETECTION: Look for contradictions across all plan documents

SPECIFIC CHECKS:
- [Phase-specific checks, e.g.:]
- [Phase 1: PRD passes all 8 validation dimensions]
- [Phase 2: Architecture covers all PRD components; Security covers all PRD threats]
- [Phase 3: HLD covers all architecture components; API design matches architecture integration points]
- [Phase 4: All user stories have testable criteria; testing strategy covers all acceptance criteria]

OUTPUT:
- Write validation report to plan/validation/cross-validation-report.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that plan/validation/cross-validation-report.md has been written
2. PASS / FAIL verdict with specific findings
3. For each finding: which documents conflict, what the conflict is, suggested resolution
4. Traceability coverage percentage (requirements traced vs total)
5. Recommendation: proceed to next phase, or re-dispatch specific agents to fix issues

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
