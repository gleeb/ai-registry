# Lifecycle Overview

## End-to-End Flow

The SDLC system turns a user request into a fully implemented, validated, and documented set of user stories. The flow has three stages: routing, planning, and execution.

```
1. User Request
   → Coordinator assesses project state
   → Routes to Planning Hub or Execution Hub

2. Planning Hub (7 phases)
   Phase 1: PRD
   Phase 2: System Architecture → Story Decomposition
   Phase 3: Per-story planning loop (HLD, API, Data, Security, Design)
   Phase 4: Cross-cutting concerns (Security rollup, DevOps, Testing)
   Phase 5: Execution readiness validation
   Phase 6: Optional SaaS sync
   Phase 7: Handoff to execution

3. Execution Hub (per story, 7 phases)
   Phase 0: Readiness check
   Phase 1: Task decomposition + staging doc
   Phase 2: Per-task dev loop (implement → review → QA)
   Phase 3: Story-level integration
   Phase 4: Acceptance validation
   Phase 5: Documentation integration
   Phase 6: User acceptance

4. After each story completes, the Coordinator dispatches the next story
   in execution_order until all stories are done.
```

### Decision Points

- **Coordinator routing**: If no plan exists → Planning Hub. If plan exists and stories are ready → Execution Hub. Command overrides: `plan <project>` forces planning, `implement <project>` forces execution.
- **Greenfield vs brownfield**: If `plan/` is empty → full planning from Phase 1. If `plan/` has existing artifacts → classify the change and re-plan only what is affected.
- **Story ordering**: Stories execute in `execution_order` from their dependency manifests. A story cannot begin execution until all stories it `depends_on` are complete.

## Agent Hierarchy

```
SDLC Coordinator
├── Planning Hub (orchestrator rule, not a subagent)
│   ├── PRD Agent
│   ├── System Architecture Agent
│   ├── Story Decomposer
│   ├── HLD Agent                       (per-story)
│   ├── Security Agent                  (dual mode: per-story + rollup)
│   ├── API Design Agent                (per-story)
│   ├── Data Architecture Agent         (per-story)
│   ├── DevOps Agent                    (cross-cutting)
│   ├── Design/UI-UX Agent             (per-story, 7-phase)
│   ├── Testing Strategy Agent          (cross-cutting)
│   └── Plan Validator                  (4 modes)
│
└── Execution Hub (orchestrator rule, not a subagent)
    ├── Implementer
    ├── Code Reviewer
    ├── QA Verifier
    ├── Acceptance Validator
    ├── Project Research               (utility, dispatched on demand)
    └── Documentation Writer           (utility, dispatched on demand)
```

Total: 3 orchestrator rules + 17 subagents = 20 components.

In Cursor, orchestrators are `.mdc` rules loaded by the main chat agent. Subagents are `.md` files dispatched via the Task tool.

In Roo-Code, orchestrators and subagents are both modes defined in `.roomodes`, dispatched via `new_task`.

## Artifact Structure

All plan artifacts live in a `plan/` folder at the project root:

```
plan/
├── prd.md                                  # Phase 1 output
├── system-architecture.md                  # Phase 2 output
│
├── user-stories/                           # Phase 2-3 outputs
│   ├── US-001-scaffolding/
│   │   ├── story.md                        # Story outline + dependency manifest
│   │   ├── hld.md                          # High-level design
│   │   ├── api.md                          # API contracts
│   │   ├── data.md                         # Data architecture
│   │   ├── security.md                     # Security controls
│   │   └── design/                         # Design artifacts
│   │       ├── design.md
│   │       └── mockups/
│   ├── US-002-feature-name/
│   │   └── ...
│   └── ...
│
├── contracts/                              # Shared interface contracts
│   ├── auth-session-contract.md
│   └── user-profile-contract.md
│
├── cross-cutting/                          # Phase 4 outputs
│   ├── security-overview.md
│   ├── devops.md
│   └── testing-strategy.md
│
├── design/                                 # Shared design foundation
│   ├── brand-foundation.md
│   ├── information-architecture.md
│   └── gallery/
│
└── validation/                             # Validator reports
    ├── phase-1-prd-validation.md
    ├── phase-2-stories-validation.md
    ├── US-001-validation.md
    └── cross-story-validation.md
```

Execution artifacts live in `docs/staging/` (per-story staging documents) and are merged into permanent `docs/` on completion.

## Dependency Manifests and Contracts

Every `story.md` includes a YAML frontmatter dependency manifest:

```yaml
---
prd_sections: [3.1, 3.2, 5.1]
architecture_components: [auth-service, session-store]
provides_contracts: [auth-session-contract]
consumes_contracts: []
depends_on_stories: []
execution_order: 1
candidate_domains: [api, data, security, design]
tech_stack: [react-native, typescript, expo]
---
```

Key fields:
- `provides_contracts` / `consumes_contracts` — Links stories via shared interface definitions in `plan/contracts/`.
- `depends_on_stories` — Enforces execution ordering.
- `candidate_domains` — Determines which Phase 3 agents are dispatched for this story.
- `tech_stack` — Maps to skills loaded by the Implementer during execution (e.g., `react-native` → `common-skills/react-native/`).

The **contracts registry** (`plan/contracts/`) holds shared data shapes, API contracts, and auth models. One story owns a contract; other stories consume it. This enables mechanical impact analysis during brownfield changes.

## Per-Story Execution Packages

A story is "execution-ready" when its folder contains all artifacts required by its `candidate_domains`. The Execution Hub's Phase 0 readiness check verifies this before implementation begins.

A complete package for a story with all domains:
- `story.md` — Scope, acceptance criteria, dependency manifest
- `hld.md` — Component design within story boundaries
- `api.md` — Endpoint specifications, request/response schemas
- `data.md` — Entity models, schemas, migrations
- `security.md` — Threat model, auth requirements, PII handling
- `design/` — UI specs, HTML/CSS mockups, accessibility audit

The Execution Hub reads these artifacts and decomposes them into implementation tasks.

## Cross-IDE Architecture

The system works identically across IDEs through shared skills and IDE-specific wrappers:

| Component | Cursor | Roo-Code |
|---|---|---|
| Orchestrators | `.mdc` rules in `.cursor/rules/` (loaded by main chat agent) | Modes in `.roomodes` |
| Subagents | `.md` files in `.cursor/agents/` (dispatched via Task tool) | Modes in `.roomodes` (dispatched via `new_task`) |
| Skills | `.cursor/skills/` → `common-skills/` (symlink) | `.roo/skills/` → `common-skills/` (symlink) |
| Dispatch protocol | Task tool: `/agent-name message` | `new_task(mode="slug", message="...")` |
| Completion protocol | Subagent returns final message | `attempt_completion(result="...")` |
| Checkpoint | `.sdlc/` at project root (plain YAML) | Same |
| Plan artifacts | `plan/` at project root | Same |

Skills are shared — both IDEs read from `common-skills/` via their respective symlinks. Checkpoint state and plan artifacts are IDE-independent.

### Registry Linking

The AI Registry is linked into projects via `scripts/setup-links.sh`, which creates symlinks from the registry into the target project directory. Changes to the registry take effect immediately in all linked projects.
