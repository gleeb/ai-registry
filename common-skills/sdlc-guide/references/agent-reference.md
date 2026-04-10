# Agent Reference

Complete reference for all orchestrators and subagents in the SDLC system.

---

## Orchestrators

Orchestrators coordinate work but never write application code or plan content directly. In Cursor they are `.mdc` rules loaded by the main chat agent. In Roo-Code they are modes.

### SDLC Coordinator

| Field | Value |
|---|---|
| **Role** | State-aware phase router — determines planning vs execution and dispatches the appropriate hub |
| **Triggered by** | User request to work on a project, `/sdlc-continue`, or explicit `plan`/`implement` commands |
| **Inputs** | Project state (from `.sdlc/coordinator.yaml` checkpoint) |
| **Outputs** | Routing decision + delegation context to Planning or Execution orchestrator |
| **Boundaries** | Never dispatches directly to implementer, reviewer, or QA — the Execution orchestrator manages those |
| **Read-only** | No |

State classification: STATE_NONE → planning, STATE_PLANNED → planning, STATE_READY → execution, STATE_IN_PROGRESS → execution, STATE_DONE → report completion.

### SDLC Planning Orchestrator

| Field | Value |
|---|---|
| **Role** | Manages the 7-phase planning workflow, dispatching planning agents and validators |
| **Triggered by** | Coordinator routes to planning |
| **Inputs** | Project context, existing `plan/` folder state |
| **Outputs** | Completed plan artifacts in `plan/`, handoff to Execution orchestrator |
| **Boundaries** | Never writes plan content directly — always dispatches a subagent |
| **Read-only** | No |

### SDLC Execution Orchestrator

| Field | Value |
|---|---|
| **Role** | Manages the implementation lifecycle for a single story — readiness through user acceptance |
| **Triggered by** | Coordinator routes to execution, or Planning Hub hands off |
| **Inputs** | Story execution package (plan artifacts), staging document |
| **Outputs** | Implemented code, staging document, acceptance report, completion summary |
| **Boundaries** | Never writes production code — dispatches Implementer. Architecture decisions and task decomposition only. |
| **Read-only** | No |

---

## Planning Agents

All planning agents are dispatched by the Planning Orchestrator. Each writes to a specific file and spars with the user on key decisions.

### PRD Agent (`sdlc-planner-prd`)

| Field | Value |
|---|---|
| **Role** | Rigorous requirements sparring partner — challenges every requirement, drafts airtight PRDs |
| **Dispatched by** | Planning Orchestrator (Phase 1) |
| **Inputs** | User's idea/problem statement, constraints, team context |
| **Outputs** | `plan/prd.md` (14-section template, 8-dimension validated) |
| **Boundaries** | No architecture, HLD, or implementation. No technology guessing — dispatches research instead. |
| **Read-only** | No |
| **Model** | inherit |

### System Architecture Agent (`sdlc-planner-architecture`)

| Field | Value |
|---|---|
| **Role** | Defines system topology, component boundaries, technology stack, integration patterns |
| **Dispatched by** | Planning Orchestrator (Phase 2, step 1) |
| **Inputs** | Validated `plan/prd.md` |
| **Outputs** | `plan/system-architecture.md` |
| **Boundaries** | No detailed API contracts or data schemas — those are per-story agents. |
| **Read-only** | No |
| **Model** | inherit |

### Story Decomposer (`sdlc-planner-stories`)

| Field | Value |
|---|---|
| **Role** | Breaks PRD into right-sized user stories with dependency manifests and shared contracts |
| **Dispatched by** | Planning Orchestrator (Phase 2, step 2, after architecture passes validation) |
| **Inputs** | Validated `plan/prd.md`, `plan/system-architecture.md` |
| **Outputs** | `plan/user-stories/US-NNN-name/story.md` (per story), `plan/contracts/*.md` |
| **Boundaries** | No HLD, API, data, security, or design artifacts. Stories only. |
| **Read-only** | No |
| **Model** | inherit |

### HLD Agent (`sdlc-planner-hld`)

| Field | Value |
|---|---|
| **Role** | Per-story high-level design — component responsibilities, data flow, integration points |
| **Dispatched by** | Planning Orchestrator (Phase 3, always dispatched for every story) |
| **Inputs** | `story.md`, `system-architecture.md`, consumed contracts |
| **Outputs** | `plan/user-stories/US-NNN-name/hld.md` |
| **Boundaries** | No LLD-level detail (function signatures). No cross-story design. |
| **Read-only** | No |
| **Model** | inherit |

### Security Agent (`sdlc-planner-security`)

| Field | Value |
|---|---|
| **Role** | Dual-mode: per-story threat model and controls (Phase 3), or cross-cutting security rollup (Phase 4) |
| **Dispatched by** | Planning Orchestrator (Phase 3 if `security` in domains, Phase 4 for rollup) |
| **Inputs** | Per-story: `story.md`, `system-architecture.md`, auth-model contract. Rollup: all per-story `security.md` files. |
| **Outputs** | Per-story: `plan/user-stories/US-NNN-name/security.md`. Rollup: `plan/cross-cutting/security-overview.md` |
| **Boundaries** | No implementation of security controls. Security is never deferred. |
| **Read-only** | No |
| **Model** | inherit |

### API Design Agent (`sdlc-planner-api`)

| Field | Value |
|---|---|
| **Role** | Per-story API contracts — endpoints, request/response schemas, error handling, auth, versioning |
| **Dispatched by** | Planning Orchestrator (Phase 3 if `api` in domains) |
| **Inputs** | `story.md`, `system-architecture.md`, consumed contracts |
| **Outputs** | `plan/user-stories/US-NNN-name/api.md` |
| **Boundaries** | No database schemas. No implementation. |
| **Read-only** | No |
| **Model** | inherit |

### Data Architecture Agent (`sdlc-planner-data`)

| Field | Value |
|---|---|
| **Role** | Per-story data models, schemas, access patterns, migration strategies |
| **Dispatched by** | Planning Orchestrator (Phase 3 if `data` in domains) |
| **Inputs** | `story.md`, `system-architecture.md`, consumed contracts |
| **Outputs** | `plan/user-stories/US-NNN-name/data.md` |
| **Boundaries** | No API endpoints. No implementation. Consumed contracts are authoritative. |
| **Read-only** | No |
| **Model** | inherit |

### DevOps Agent (`sdlc-planner-devops`)

| Field | Value |
|---|---|
| **Role** | Cross-cutting DevOps — CI/CD pipelines, deployment strategy, infrastructure, monitoring |
| **Dispatched by** | Planning Orchestrator (Phase 4) |
| **Inputs** | All per-story `hld.md` files, `system-architecture.md`, `security-overview.md` |
| **Outputs** | `plan/cross-cutting/devops.md` |
| **Boundaries** | No pipeline implementation. No per-story details. |
| **Read-only** | No |
| **Model** | inherit |

### Design/UI-UX Agent (`sdlc-planner-design`)

| Field | Value |
|---|---|
| **Role** | Per-story UI/UX design with 7-phase workflow: discovery → brand → IA → visual → mockups → a11y → handoff |
| **Dispatched by** | Planning Orchestrator (Phase 3 if `design` in domains, after HLD completes) |
| **Inputs** | `story.md`, `hld.md`, `prd.md`, existing `plan/design/design-spec.md` if any |
| **Outputs** | `plan/user-stories/US-NNN-name/design/` (design.md + mockups/), `plan/design/` (brand foundation, gallery) |
| **Boundaries** | No application code (React, Vue, etc.). HTML/CSS mockups only. |
| **Read-only** | No |
| **Model** | inherit |

### Testing Strategy Agent (`sdlc-planner-testing`)

| Field | Value |
|---|---|
| **Role** | Cross-cutting testing strategy — test pyramid, AC coverage mapping, specialized testing, CI/CD gates |
| **Dispatched by** | Planning Orchestrator (Phase 4) |
| **Inputs** | All `story.md` files, `api.md` files, `security.md` files, `security-overview.md`, `system-architecture.md`, `prd.md` |
| **Outputs** | `plan/cross-cutting/testing-strategy.md` |
| **Boundaries** | No test code. No per-story implementation details. |
| **Read-only** | No |
| **Model** | inherit |

---

## Validation Agents

### Plan Validator (`sdlc-plan-validator`)

| Field | Value |
|---|---|
| **Role** | Cross-plan validation with Reality Checker philosophy — every check defaults to NEEDS WORK |
| **Dispatched by** | Planning Orchestrator (after each phase and at final readiness) |
| **Inputs** | Plan artifacts relevant to the current mode |
| **Outputs** | Validation reports in `plan/validation/` |
| **Boundaries** | Read-only. Never modifies plan artifacts. |
| **Read-only** | Yes |
| **Model** | inherit |

Operates in 4 modes:
1. **Phase Validation** — After Phases 1, 2: phase-level completeness
2. **Per-Story Validation** — After Phase 3 (per story): 9-check internal consistency
3. **Cross-Story Validation** — After Phase 4: inter-story consistency and contract compliance
4. **Impact Analysis** — Brownfield changes: read-only blast-radius analysis

### Acceptance Validator (`sdlc-acceptance-validator`)

| Field | Value |
|---|---|
| **Role** | Independent acceptance criterion verification with fresh evidence — default INCOMPLETE |
| **Dispatched by** | Execution Orchestrator (Phase 4) |
| **Inputs** | `story.md` (acceptance criteria), implemented code, staging document |
| **Outputs** | Validation report (per-criterion evidence table, overall verdict) |
| **Boundaries** | Read-only. Does not modify code. Binary verdicts: PASS, FAIL, or UNABLE TO VERIFY. |
| **Read-only** | Yes |
| **Model** | fast |

---

## Execution Agents

### Implementer (`sdlc-implementer`)

| Field | Value |
|---|---|
| **Role** | Scoped code implementation within strict boundaries, with self-verification and staging doc updates |
| **Dispatched by** | Execution Orchestrator (Phase 2 per-task, Phase 0b scaffolding) |
| **Inputs** | Task specification, tech skills, staging document path, scope boundaries |
| **Outputs** | Code changes, updated staging document, per-criterion verification evidence |
| **Boundaries** | Only assigned tasks. No new features, no scope changes, no placeholders, no deferred work. |
| **Read-only** | No |
| **Model** | inherit |

Subject to strict anti-fabrication rules (see [execution-deep-dive.md](execution-deep-dive.md)).

### Code Reviewer (`sdlc-code-reviewer`)

| Field | Value |
|---|---|
| **Role** | Plan-aligned code review — spec compliance, code quality, security assessment |
| **Dispatched by** | Execution Orchestrator (Phase 2 after implementation, Phase 3 for full-story review) |
| **Inputs** | Staging document, changed files, implementer's completion summary |
| **Outputs** | Review verdict (Approved or Changes Required) with per-issue details |
| **Boundaries** | Read-only. Does not modify code or plans. |
| **Read-only** | Yes |
| **Model** | fast |

Loads `security-review` skill when dispatch includes `SECURITY_REVIEW: true`.

### QA Verifier (`sdlc-qa`)

| Field | Value |
|---|---|
| **Role** | Independent verification through fresh evidence — runs every verification command, trusts no prior results |
| **Dispatched by** | Execution Orchestrator (Phase 2 after review pass, Phase 3 for full-story verification) |
| **Inputs** | Staging document (acceptance criteria), verification commands |
| **Outputs** | Evidence-based PASS/FAIL with per-criterion command output |
| **Boundaries** | Read-only. Does not fix code. "Should work" is not evidence. |
| **Read-only** | Yes |
| **Model** | fast |

---

## Utility Agents

### Project Research (`sdlc-project-research`)

| Field | Value |
|---|---|
| **Role** | Evidence-based technology evaluation, feasibility analysis, competitive landscape research |
| **Dispatched by** | Any agent needing research (typically PRD, Architecture, or Coordinator for blockers) |
| **Inputs** | Research question |
| **Outputs** | Structured research report with findings, comparison, recommendation, confidence level |
| **Boundaries** | Read-only. Returns findings only. If inconclusive, says so. |
| **Read-only** | Yes |
| **Model** | fast |

### Documentation Writer (`sdlc-documentation-writer`)

| Field | Value |
|---|---|
| **Role** | Technical documentation — staging docs, doc integration, README updates, ADRs |
| **Dispatched by** | Execution Orchestrator (Phase 1 staging doc creation, Phase 5 doc integration) |
| **Inputs** | Plan artifacts, staging document, project docs structure |
| **Outputs** | Created/updated documentation files |
| **Boundaries** | Documentation only. No application code. |
| **Read-only** | No |
| **Model** | inherit |
