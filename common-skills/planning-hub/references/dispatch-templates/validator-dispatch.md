# Plan Validator Dispatch Template

Use this template when dispatching `sdlc-plan-validator` via `new_task`.

The validator has three modes. Specify the mode in the dispatch.

## Mode 1: Phase Validation (standard)

```
VALIDATE: [Phase Name] — Phase Validation

MODE: PHASE (standard post-phase validation)

CONTEXT:
- [Which planning phase just completed]
- [Which plan artifacts were created or updated in this phase]

ARTIFACTS TO VALIDATE:
- [List all plan artifacts that should be checked]

VALIDATION SCOPE:
- UPWARD TRACEABILITY: [new artifact] satisfies all requirements from [parent artifact]
- CROSS-DOMAIN CONSISTENCY: No conflicts between artifacts
- COMPLETENESS: All requirements from parent are addressed in children
- CONFLICT DETECTION: No contradictions across plan documents

SPECIFIC CHECKS:
- [Phase-specific checks relevant to what just completed]

OUTPUT:
- Write validation report to plan/validation/cross-validation-report.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Confirmation that validation report has been written
2. PASS / NEEDS WORK verdict with specific findings
3. For each finding: which documents conflict, what the issue is, suggested resolution
4. Traceability coverage percentage
5. Recommendation: proceed to next phase, or re-dispatch specific agents

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Mode 2: Per-Story Validation

```
VALIDATE: US-NNN-name — Per-Story Validation

MODE: PER-STORY (Phase 3 internal consistency check)

STORY FOLDER: plan/user-stories/US-NNN-name/

CONTEXT:
- Phase 3 agents have completed work on this story
- All artifacts in the story folder need internal consistency validation

ARTIFACTS TO VALIDATE:
- plan/user-stories/US-NNN-name/story.md
- plan/user-stories/US-NNN-name/hld.md
- plan/user-stories/US-NNN-name/api.md (if exists)
- plan/user-stories/US-NNN-name/data.md (if exists)
- plan/user-stories/US-NNN-name/security.md (if exists)
- plan/user-stories/US-NNN-name/design/ (if exists)
- plan/contracts/ (consumed contracts)

VALIDATION SCOPE:
Per planning-validator/references/per-story-validation.md — all 9 checks.

OUTPUT:
- Append per-story results to plan/validation/cross-validation-report.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. PASS / NEEDS WORK verdict
2. Check results for all 9 validation checks
3. For each failure: which artifact, what the issue is, suggested fix
4. Observations (non-blocking items for review)

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Mode 3: Impact Analysis

See `impact-analysis-dispatch.md` for the full template.

## Mode 4: Cross-Story Validation (Phase 4)

```
VALIDATE: Cross-Story — Phase 4 Validation

MODE: CROSS-STORY (Phase 4 cross-cutting validation)

CONTEXT:
- All per-story planning is complete and validated
- Phase 4 cross-cutting agents have completed

ARTIFACTS TO VALIDATE:
- ALL plan/user-stories/*/story.md (dependency manifests)
- ALL plan/contracts/*.md
- plan/cross-cutting/security-overview.md
- plan/cross-cutting/devops.md
- plan/cross-cutting/testing-strategy.md
- plan/system-architecture.md

VALIDATION SCOPE:
- Cross-story dependency graph integrity (no cycles, all deps satisfied)
- Contract consistency (all providers and consumers aligned)
- Security overview covers all per-story security controls
- Testing strategy covers all acceptance criteria across all stories
- DevOps supports all architecture components and services

OUTPUT:
- Write validation report to plan/validation/cross-validation-report.md

COMPLETION CONTRACT:
Return via attempt_completion with:
1. PASS / NEEDS WORK verdict
2. Dependency graph status (cycles, orphans, gaps)
3. Contract compliance across all stories
4. Cross-cutting coverage (security, testing, devops)
5. Full traceability: PRD → stories → artifacts chain

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```
