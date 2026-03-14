# Planning Deep Dive

The Planning Hub manages a 7-phase workflow that transforms a user request into execution-ready story packages. The Hub never writes plan content directly — it dispatches specialized agents and validates their output at every gate.

## Phase 1: Requirements (PRD)

**Agent**: PRD Agent (`sdlc-planner-prd`)
**Output**: `plan/prd.md`

The PRD Agent is a rigorous sparring partner, not a passive scribe. It:
1. Gathers context: problem statement, desired outcome, constraints, team context.
2. Challenges every major requirement with probing questions — one at a time.
3. Settles technology decisions (backend language, frontend framework, database, deployment targets) during planning, not later.
4. Drafts the PRD using a 14-section template covering everything from goals to user stories to technical constraints.
5. Self-validates against 8 dimensions: structure completeness, testability, consistency, security/privacy, clarity, technical feasibility, scope definition, downstream readiness.

**Gate**: All 8 validation dimensions must reach "high" before advancing. The user can override with explicit per-dimension risk acknowledgment.

After the PRD is written, the Plan Validator runs in Phase Validation mode to independently verify completeness.

## Phase 2: Architecture + Story Decomposition

**Agents**: System Architecture Agent → Story Decomposer
**Output**: `plan/system-architecture.md`, `plan/user-stories/US-NNN-name/story.md`, `plan/contracts/*.md`

This phase runs sequentially within itself:

### Step 1: System Architecture
The Architecture Agent reads the validated PRD and produces:
- System topology and component inventory with boundaries
- Technology stack with rationale for every choice
- Integration patterns and cross-cutting concerns
- Deployment architecture, scalability strategy, failure modes
- Architecture Decision Records (ADRs)

**Gate**: Architecture must pass validation (PRD-Architecture alignment) before story decomposition begins.

### Step 2: Story Decomposition
The Story Decomposer breaks the PRD and architecture into right-sized user stories:
- Target: ~30-60 minutes of agent execution work per story
- Each story gets a folder (`plan/user-stories/US-NNN-name/`) with a `story.md` containing scope, acceptance criteria, and a dependency manifest
- Shared interfaces are extracted as contracts in `plan/contracts/`
- `US-001-scaffolding` always comes first with `execution_order: 1`

**Gate**: Story coverage (every PRD requirement mapped), dependency acyclicity (no circular dependencies), and valid manifests.

## Phase 3: Per-Story Planning (Loop)

**Agents**: HLD, API, Data, Security, Design (per story, based on `candidate_domains`)
**Output**: `plan/user-stories/US-NNN-name/{hld,api,data,security,design/}.md`

For each story in `execution_order`:

1. The Hub reads the story's `candidate_domains` from its dependency manifest.
2. Dispatches relevant agents:
   - **HLD** — Always dispatched. Designs components within story boundaries.
   - **API Design** — If `api` in domains. Defines endpoints, schemas, error handling.
   - **Data Architecture** — If `data` in domains. Designs schemas, access patterns, migrations.
   - **Security** — If `security` in domains. Per-story threat model, auth requirements, PII handling.
   - **Design/UI-UX** — If `design` in domains. 7-phase design workflow: UX discovery → brand foundation → information architecture → visual design → HTML/CSS mockups → accessibility audit → developer handoff.

3. **Parallelism**: HLD, API, Data, and Security can run in parallel. Design waits on HLD completion because it needs the component structure.

4. **Gate**: Per-story validation checks internal consistency — HLD-to-story alignment, API-to-HLD alignment, data-to-API alignment, security controls coverage, design coverage (if UI story), and contract compliance.

5. The next story in execution_order does not begin planning until the current story passes its gate.

### Per-Story Agent Behavior

Each per-story agent:
- Reads `story.md` for scope and acceptance criteria
- Reads `system-architecture.md` for architectural context
- Reads consumed contracts from `plan/contracts/` as authoritative (never redefines shared interfaces)
- Writes only to its assigned file within the story folder
- Spars with the user on key design decisions before finalizing

## Phase 4: Cross-Cutting Concerns

**Agents**: Security (rollup mode), DevOps, Testing Strategy
**Output**: `plan/cross-cutting/{security-overview,devops,testing-strategy}.md`

After all stories are planned, three cross-cutting agents run in parallel:

- **Security Rollup** — Aggregates all per-story `security.md` files into a unified security overview. Identifies systemic patterns, conflicting controls, credential management, compliance requirements.
- **DevOps** — Reads all HLDs and the system architecture to define CI/CD pipelines, deployment strategy (blue-green, canary, rolling), infrastructure provisioning, monitoring, rollback procedures.
- **Testing Strategy** — Inventories all acceptance criteria across all stories, maps each to a test type, designs the test pyramid, plans specialized testing (API, security, accessibility, performance), defines CI/CD test gates.

**Gate**: Cross-story validation checks inter-story consistency, contract compliance, and that cross-cutting concerns cover all stories and services.

## Phase 5: Execution Readiness

**Agent**: Plan Validator (full-chain mode)
**Output**: `plan/validation/` report

The final validation pass checks the entire plan end-to-end:
- Full PRD → stories → artifacts traceability chain
- All contracts have providers and consumers aligned
- Dependency graph is consistent
- Cross-cutting coverage is complete

**Gate**: Full validation pass required. Any failures must be resolved before handoff.

## Phase 6: Optional SaaS Sync

If a SaaS sync skill is loaded (e.g., `linear-sync`), plan artifacts are synced to the external system:
- Linear: Initiative = PRD, Project = User Story, Issue = HLD
- The sync skill handles translation only — it never contains planning methodology

This phase is optional and skipped if no sync skill is available.

## Phase 7: Handoff

The Planning Hub presents a completion summary to the user and transitions to the Execution Orchestrator. The handoff includes:
- What was planned (story count, key decisions)
- Which story to execute first (lowest `execution_order`)
- The full dependency graph

## Validation Gates — Failure Handling

Every phase has a validation gate. When validation fails:

| Attempt | Action |
|---|---|
| First failure | Re-dispatch the agent with specific feedback from the validator |
| Second failure | Re-dispatch with more detailed guidance |
| Third failure | Escalate to user with three options: (a) iterate with manual guidance, (b) accept partial with documented gaps, (c) skip with explicit acknowledgment |

A gate is never bypassed without user acknowledgment. The user must explicitly accept responsibility for any non-passing dimension.

## Brownfield Change Protocol

When a plan already exists and the user proposes a change:

1. **Classify change level**:
   - PRD-level: requirements changed
   - Architecture-level: system design changed
   - Story-internal: change within a single story's scope
   - Story-contract: a shared interface changed
   - Cross-cutting: DevOps, security, or testing strategy changed

2. **Impact analysis**: The Plan Validator runs in Impact Analysis mode (read-only). It traces the dependency graph from the change point and classifies each artifact as: Direct impact, Indirect impact, or Unaffected.

3. **Blast radius review**: The user sees exactly which stories, contracts, and cross-cutting concerns are affected.

4. **User confirms scope**: The user may narrow or approve the re-planning scope.

5. **Minimum re-dispatch**: Only the agents needed to address the change are re-dispatched. Unaffected artifacts remain untouched.

## Checkpoint Integration

The Planning Hub writes checkpoints before and after every dispatch using `checkpoint.sh planning`. This enables crash-safe resume at any point in the 7-phase workflow. See [troubleshooting.md](troubleshooting.md) for the checkpoint system details.
