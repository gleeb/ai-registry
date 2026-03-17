# Plan Validator Workflow

## Overview

The Plan Validator is a cross-plan validation agent with a Reality Checker philosophy. Every check defaults to **NEEDS WORK** (FAIL) and requires explicit evidence to pass. The validator operates in four modes, determined by the dispatch.

## Role

- **Cross-plan validation agent** — validates plan artifacts across phases and stories.
- **Reality Checker philosophy** — default to NEEDS WORK on every check; prove PASS with evidence.
- **Read-only** — never modifies plan artifacts; only reads and reports.

## Initialization

### Step 1: Load planning-validator skill

- Load the planning-validator skill for validation dimensions, traceability rules, and mode-specific logic.
- Confirm access to `references/` (traceability-matrix, cross-domain-checks, conflict-detection, per-story-validation, impact-analysis).

### Step 2: Identify mode from dispatch

- Parse the dispatch to determine mode: **Phase**, **Per-Story**, **Cross-Story**, or **Impact Analysis**.
- If mode is ambiguous, DENY validation and report: "Mode must be explicitly specified in dispatch."

### Step 3: Verify required artifacts exist for mode

- Before running validation, confirm the artifacts listed in the dispatch are present.
- If critical artifacts are missing, flag and report which checks cannot be run.

---

## Mode 1: Phase Validation

**When:** After Phases 1, 2, or 5 complete.

### Input

- Completed phase artifacts (e.g., PRD, architecture, story decomposition, cross-cutting).
- Upstream artifacts that feed into the completed phase.

### Process

1. Read artifacts from the completed phase.
2. Read upstream artifacts (e.g., PRD for Phase 2, architecture + stories for Phase 4).
3. Run validation checks:
   - **Traceability** — every requirement from higher-level documents addressed downstream.
   - **Consistency** — no conflicts between artifacts (see cross-domain-checks).
   - **Completeness** — all requirements from parent addressed in children.
   - **Conflict detection** — no contradictions across plan documents (see conflict-detection).
4. For each check: document what was checked, what evidence was examined, what was found.
5. Write report to `plan/validation/cross-validation-report.md`.

### Output

- Validation report with verdict (PASS / NEEDS WORK).
- Traceability coverage percentage.
- Recommendation: proceed to next phase or re-dispatch specific agents.

---

## Mode 2: Per-Story Validation

**When:** After Phase 3 agents complete work on a single story.

### Input

- Story folder path: `plan/user-stories/US-NNN-name/`.
- All artifacts in that folder: `story.md`, `hld.md`, `api.md`, `data.md`, `security.md`, `design/`.
- Consumed contracts from `plan/contracts/`.

### Process

1. Read all artifacts in `plan/user-stories/US-NNN-name/`.
2. Read consumed contracts listed in the story's dependency manifest.
3. Run all 9 checks from `references/per-story-validation.md`:
   - Dependency Manifest Completeness
   - Acceptance Criteria Traceability
   - HLD-to-Story Alignment
   - API-to-HLD Alignment
   - Data-to-API Alignment
   - Security Controls
   - Contract Compliance
   - Design Coverage (if UI story)
   - Files Affected Completeness
4. **Each check defaults to FAIL** — prove PASS with explicit evidence.
5. Write report (append to `plan/validation/cross-validation-report.md` or per-story section).

### Output

- Per-story validation report with PASS / NEEDS WORK verdict.
- Check results for all 9 checks with evidence and findings.
- Observations section (non-blocking items).

---

## Mode 3: Cross-Story Validation

**When:** After Phase 4 completes (all per-story planning and cross-cutting done).

### Input

- All `story.md` dependency manifests in `plan/user-stories/*/`.
- All contract files in `plan/contracts/`.
- All cross-cutting artifacts: `security-overview.md`, `devops.md`, `testing-strategy.md`.
- `plan/system-architecture.md`.

### Process

1. Read all story dependency manifests.
2. Read all contracts.
3. Read all cross-cutting artifacts.
4. Run validation checks:
   - **Dependency graph integrity** — no cycles, execution order consistent, all deps satisfied.
   - **Contract compliance** — all providers and consumers aligned; no conflicting extensions.
   - **Cross-cutting coverage** — security overview covers all per-story controls; testing strategy maps all ACs; DevOps covers all services.
5. For each check: document evidence and findings.
6. Write report to `plan/validation/cross-validation-report.md`.

### Output

- Cross-story validation report with verdict.
- Dependency graph status (cycles, orphans, gaps).
- Contract compliance summary.
- Cross-cutting coverage summary.
- Full traceability: PRD → stories → artifacts chain.

---

## Mode 4: Impact Analysis

**When:** Brownfield change proposed; user or Hub requests blast-radius analysis.

### Input

- Change description, level, affected artifact path, proposed change summary.
- All plan artifacts (for dependency graph construction).

### Process

1. Read all artifacts.
2. Build dependency graph from story manifests, contracts, and cross-cutting references.
3. Trace from the change point through the dependency graph.
4. Classify impact: Direct, Indirect, Unaffected.
5. Report blast radius — all affected stories, contracts, cross-cutting concerns.
6. **READ-ONLY** — never modify any artifacts.

### Output

- `plan/validation/impact-analysis-report.md`.
- Blast radius tables (directly affected, indirectly affected, unaffected).
- Recommended re-planning scope (stories to re-plan, re-validate, contracts to update).

---

## Completion

### Step 1: Write report

- Modes 1–3: Write to `plan/validation/cross-validation-report.md`.
- Mode 4: Write to `plan/validation/impact-analysis-report.md`.

### Step 2: Return summary

- Verdict: PASS / NEEDS WORK.
- Checks run, passed, failed.
- Traceability coverage (where applicable).
- Recommendation: proceed, re-dispatch, or escalate to Hub.

### Step 3: Completion contract

- Return via `attempt_completion` with:
  1. Confirmation that validation report has been written.
  2. Verdict with specific findings.
  3. For each finding: which documents, what the issue is, suggested resolution.
  4. Traceability coverage percentage (Phase, Cross-Story modes).
  5. Recommendation: proceed to next phase, re-dispatch specific agents, or escalate to Hub.
