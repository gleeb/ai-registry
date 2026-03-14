# AI Registry

A centralized, version-controlled source of truth for AI agent configurations, custom rules, skills, and instructions across IDEs and providers.

**One repository. Every project. Always in sync.**

---

## Table of Contents

- [Concept](#concept)
- [Repository Structure](#repository-structure)
- [Planning System Architecture](#planning-system-architecture)
- [Implementation Hub Architecture](#implementation-hub-architecture)
- [Cursor Architecture](#cursor-architecture)
- [Checkpoint and Resume System](#checkpoint-and-resume-system)
- [Quick Start](#quick-start)
- [Git Safety — Global Gitignore](#git-safety--global-gitignore)
- [Supported Providers](#supported-providers)
- [Contributing](#contributing)

---

## Concept

Modern AI-assisted development involves multiple tools — Cursor, Roo-Code, Claude Code, Codex/Windsurf — each with its own configuration format. Without a central system, you end up with:

- **Drift**: Rules diverge across projects as each copy evolves independently.
- **Duplication**: The same instructions are pasted into dozens of repos.
- **Leakage**: AI config files accidentally committed to project repos.

The **AI Registry** solves this by storing all agent configurations in a single Git repository and symlinking them into active projects. Update once, propagate everywhere.

```
┌──────────────────────────────────────────────────────┐
│                   AI Registry (this repo)             │
│                                                       │
│  cursor/        roo-code/      claude/     codex/     │
│  └─ .cursor/     ├─ .roomodes   ├─ CLAUDE.md ├─ AGENTS.md
│     └─ rules/    ├─ rules-sdlc-*/             │       │
│                  └─ skills/ → ../common-skills/       │
│                                                       │
│  common-skills/                                       │
│  ├─ planning-hub/                                     │
│  ├─ planning-prd/                                     │
│  ├─ planning-system-architecture/                     │
│  ├─ planning-stories/            ← NEW               │
│  ├─ planning-hld/                                     │
│  ├─ planning-security/                                │
│  ├─ planning-api-design/                              │
│  ├─ planning-data-architecture/                       │
│  ├─ planning-devops/                                  │
│  ├─ planning-design/                                  │
│  ├─ planning-testing-strategy/                        │
│  ├─ planning-validator/                               │
│  ├─ linear-sync/                                      │
│  ├─ architect-execution-hub/                          │
│  ├─ sdlc-checkpoint/                                  │
│  ├─ scaffold-project/                                 │
│  └─ ...                                               │
│  scripts/                                             │
│  └─ setup-links.sh                                    │
└────────────────┬──────────────────────────────────────┘
                 │  symlinks
        ┌────────┼────────┐
        ▼        ▼        ▼
    Project A  Project B  Project C
```

---

## Repository Structure

```
ai-registry/
├── cursor/                             # Cursor IDE configurations
│   ├── .cursor/
│   │   ├── rules/
│   │   │   ├── general.mdc             # General coding standards
│   │   │   ├── sdlc-coordinator.mdc    # Phase routing orchestrator rule
│   │   │   ├── sdlc-planning-orchestrator.mdc  # 7-phase planning rule
│   │   │   └── sdlc-execution-orchestrator.mdc # Implementation lifecycle rule
│   │   ├── agents/                     # 17 SDLC subagents (dispatched via Task tool)
│   │   │   ├── sdlc-planner-prd.md ... sdlc-planner-testing.md  # 10 planning
│   │   │   ├── sdlc-plan-validator.md                            # 1 validator
│   │   │   ├── sdlc-implementer.md ... sdlc-acceptance-validator.md  # 4 execution
│   │   │   └── sdlc-project-research.md, sdlc-documentation-writer.md  # 2 utility
│   │   └── skills -> ../../common-skills/  # Symlink to shared skills
│   └── ROO-MIGRATION-PROTOCOL.md      # Guide for migrating Roo Code modes to Cursor
│
├── roo-code/                           # Roo-Code configurations (symlinked as .roo/)
│   ├── .roomodes                       # Custom modes/agents (YAML)
│   ├── mcp.json                        # MCP server configurations
│   ├── rules-sdlc-planner/            # Planning Hub rules (6 .md files)
│   ├── rules-sdlc-planner-prd/        # PRD Agent rules
│   ├── rules-sdlc-planner-architecture/ # Architecture Agent rules
│   ├── rules-sdlc-planner-stories/    # Story Decomposer rules
│   ├── rules-sdlc-planner-hld/        # HLD Agent rules
│   ├── rules-sdlc-planner-security/   # Security Agent rules
│   ├── rules-sdlc-planner-api/        # API Design Agent rules
│   ├── rules-sdlc-planner-data/       # Data Architecture Agent rules
│   ├── rules-sdlc-planner-devops/     # DevOps Agent rules
│   ├── rules-sdlc-planner-design/     # Design/UI-UX Agent rules
│   ├── rules-sdlc-planner-testing/    # Testing Strategy Agent rules
│   ├── rules-sdlc-plan-validator/     # Plan Validator rules
│   ├── rules-sdlc-coordinator/        # Coordinator rules
│   ├── rules-sdlc-architect/          # Architect rules
│   ├── rules-sdlc-implementer/        # Implementer rules
│   ├── rules-sdlc-code-reviewer/      # Code Reviewer rules
│   ├── rules-sdlc-qa/                 # QA Verifier rules
│   ├── rules-sdlc-acceptance-validator/ # Acceptance Validator rules
│   ├── rules-skill-writer/            # Skill Writer rules
│   ├── rules-mode-writer/             # Mode Writer rules
│   └── skills/ → ../common-skills/    # Symlink to shared skills
│
├── common-skills/                      # Shared skills (accessible via .roo/skills/)
│   ├── planning-hub/                   # Planning orchestration hub + dispatch templates
│   ├── planning-prd/                   # PRD templates and validation
│   ├── planning-system-architecture/   # System architecture templates
│   ├── planning-stories/              # Story Decomposer — decomposition + manifests
│   ├── planning-hld/                   # Per-story HLD templates
│   ├── planning-security/              # Dual-mode security (per-story + rollup)
│   ├── planning-api-design/            # Per-story API design templates
│   ├── planning-data-architecture/     # Per-story data architecture templates
│   ├── planning-devops/                # Cross-cutting DevOps planning
│   ├── planning-design/                # 7-phase Design/UI-UX with accessibility
│   ├── planning-testing-strategy/      # Cross-cutting testing strategy
│   ├── planning-validator/             # 4-mode validation with Reality Checker
│   ├── linear-sync/                    # Linear SaaS sync (translation layer)
│   ├── architect-execution-hub/        # Implementation Hub — full lifecycle orchestration
│   ├── project-documentation/          # Documentation skill — staging docs, templates, integration
│   ├── security-review/                # Security review skill — OWASP, secrets, RN security
│   ├── acceptance-validation/          # Acceptance validation skill — criterion mapping, reports
│   ├── sdlc-checkpoint/                # Checkpoint and resume — crash-safe cross-IDE continuation
│   ├── scaffold-project/               # Project bootstrapping
│   ├── code-review/                    # Code review skill
│   ├── react-native/                   # React Native skill
│   ├── verification-before-completion/ # Verification skill
│   └── universal-skills.md             # Universal skill guidelines
│
├── claude/                             # Claude Code (CLI) configurations
│   └── CLAUDE.md
│
├── codex/                              # Codex / Windsurf configurations
│   └── AGENTS.md
│
├── scripts/                            # Automation
│   ├── setup-links.sh                  # Symlink installer
│   └── add-skill.sh                    # Skill linker
│
└── README.md
```

---

## Planning System Architecture

The planning system follows a **per-story architecture** where the **Planning Hub** orchestrates specialized planning sub-agents. The primary organizing unit is the **user story** — each story gets a self-contained package of all artifacts an execution agent needs.

### Core Principles

- **Internal planning is king.** All plan artifacts live in a `plan/` folder in the target project as Markdown files (and HTML/CSS for design mockups). No external SaaS system is required.
- **Per-story execution packages.** Each user story gets its own folder containing HLD, API, data, security, and design artifacts — everything an execution agent needs in one place.
- **Mechanical impact analysis.** Explicit dependency manifests and a shared contracts registry enable automated blast-radius detection for brownfield changes.
- **Reality Checker validation.** Every validation check defaults to NEEDS WORK and requires explicit evidence to pass.

### Agent Hierarchy

```
SDLC Coordinator
  └── Planning Hub (sdlc-planner)
        ├── PRD Agent (sdlc-planner-prd)
        ├── System Architecture Agent (sdlc-planner-architecture)
        ├── Story Decomposer (sdlc-planner-stories)
        ├── HLD Agent (sdlc-planner-hld)                     ← per-story
        ├── Security Agent (sdlc-planner-security)            ← dual mode
        ├── API Design Agent (sdlc-planner-api)               ← per-story
        ├── Data Architecture Agent (sdlc-planner-data)       ← per-story
        ├── DevOps Agent (sdlc-planner-devops)                ← cross-cutting
        ├── Design/UI-UX Agent (sdlc-planner-design)          ← 7-phase per-story
        ├── Testing Strategy Agent (sdlc-planner-testing)     ← cross-cutting
        ├── Plan Validator (sdlc-plan-validator)               ← 4-mode Reality Checker
        └── [Optional] SaaS Sync (e.g., linear-sync)
  └── Architect / Implementation Hub (sdlc-architect)
        ├── Implementer (sdlc-implementer)                   ← with tech skills + anti-fabrication
        ├── Code Reviewer (sdlc-code-reviewer)               ← with security review
        ├── QA Verifier (sdlc-qa)                            ← with doc verification
        └── Acceptance Validator (sdlc-acceptance-validator)  ← evidence-based criterion check
```

### 7-Phase Planning Workflow

The Planning Hub manages work in ordered phases with validation gates between each:

```
Phase 1: Requirements
    PRD Agent → Validator
         │
Phase 2: Architecture + Story Decomposition
    Architecture Agent → Story Decomposer → Validator
         │
Phase 3: Per-Story Planning (loop over stories in execution_order)
    For each story: HLD + API + Data + Security + Design → Per-Story Validator
         │
Phase 4: Cross-Cutting Concerns
    Security Rollup + DevOps + Testing Strategy → Cross-Story Validator
         │
Phase 5: Execution Readiness
    Full-chain Validator
         │
Phase 6: Optional SaaS Sync
         │
Phase 7: Handoff to Coordinator
```

| Phase | Agents | Output | Gate |
|---|---|---|---|
| **1: Requirements** | PRD Agent | `plan/prd.md` | 8-dimension validation at "high" |
| **2: Architecture + Stories** | Architecture → Story Decomposer | `plan/system-architecture.md`, `plan/user-stories/US-NNN-name/story.md`, `plan/contracts/` | Story coverage + dependency acyclicity |
| **3: Per-Story Planning** | HLD, API, Data, Security, Design (per story) | `plan/user-stories/US-NNN-name/{hld,api,data,security,design/}.md` | Per-story internal consistency |
| **4: Cross-Cutting** | Security rollup, DevOps, Testing | `plan/cross-cutting/{security-overview,devops,testing-strategy}.md` | Cross-story consistency |
| **5: Execution Readiness** | Full-chain Validator | Validation report | Full-chain traceability passes |
| **6: SaaS Sync** (optional) | Sync skill | External system updates | Sync verification |
| **7: Handoff** | Hub → Coordinator | Execution-ready summary | All gates passed |

### Per-Story Plan Folder Structure

Each target project gets a `plan/` folder with this layout:

```
plan/
├── prd.md                                  # Product Requirements Document
├── system-architecture.md                  # System Architecture
│
├── user-stories/                           # Per-story execution packages
│   ├── US-001-user-authentication/
│   │   ├── story.md                        # Story outline + dependency manifest
│   │   ├── hld.md                          # Per-story high-level design
│   │   ├── api.md                          # Per-story API contracts
│   │   ├── data.md                         # Per-story data architecture
│   │   ├── security.md                     # Per-story security controls
│   │   └── design/                         # Per-story design artifacts
│   │       ├── design.md                   # Design spec
│   │       └── mockups/                    # HTML/CSS mockups
│   │           ├── index.html              # Gallery for this story
│   │           └── screens/
│   ├── US-002-dashboard/
│   │   └── ...
│   └── ...
│
├── contracts/                              # Shared interface contracts
│   ├── auth-session-contract.md            # Owned by US-001, consumed by others
│   └── user-profile-contract.md
│
├── cross-cutting/                          # Phase 4 rollup artifacts
│   ├── security-overview.md                # Security rollup across all stories
│   ├── devops.md                           # CI/CD, deployment, infrastructure
│   └── testing-strategy.md                 # Test pyramid, coverage, CI/CD gates
│
├── design/                                 # Shared design foundation
│   ├── brand-foundation.md                 # Brand identity + design tokens
│   ├── information-architecture.md         # Navigation + content hierarchy
│   └── gallery/                            # Cross-story mockup gallery
│       └── index.html
│
└── validation/                             # Validation reports
    ├── phase-1-prd-validation.md
    ├── phase-2-stories-validation.md
    ├── US-001-validation.md
    └── cross-story-validation.md
```

### Dependency Manifests and Contracts Registry

Every `story.md` file includes a machine-readable dependency manifest header:

```yaml
---
prd_sections: [3.1, 3.2, 5.1]
architecture_components: [auth-service, session-store, api-gateway]
provides_contracts: [auth-session-contract]
consumes_contracts: []
depends_on_stories: []
execution_order: 1
candidate_domains: [api, data, security, design]
---
```

The **contracts registry** (`plan/contracts/`) holds shared interface definitions that span stories. A contract defines a data shape, API contract, or authentication model that one story owns and other stories consume. This enables mechanical impact analysis.

### Brownfield Change Protocol

When a plan already exists and a change is proposed:

1. **Classify change level** — PRD / Architecture / Story (internal) / Story (contract) / Cross-cutting.
2. **Dispatch impact analysis** — Validator runs in IMPACT ANALYSIS mode, traces the dependency graph.
3. **Present blast radius** — Which stories, contracts, and cross-cutting concerns are affected.
4. **User confirms scope** — User may narrow or approve the re-planning scope.
5. **Re-dispatch minimum agents** — Only agents needed to address the change; unaffected artifacts are untouched.

### Plan Validator — 4 Modes with Reality Checker Philosophy

The Plan Validator operates in 4 modes, all following the Reality Checker philosophy where every check defaults to NEEDS WORK and requires explicit evidence to pass:

| Mode | When | What It Checks |
|---|---|---|
| **Phase Validation** | After Phase 1, 2 | Phase-level completeness and PRD/Architecture coverage |
| **Per-Story Validation** | After Phase 3 (per story) | Internal story consistency — HLD/API/Data/Security alignment |
| **Cross-Story Validation** | After Phase 4 | Inter-story consistency, contract compliance, cross-cutting alignment |
| **Impact Analysis** | Brownfield changes | Read-only blast radius analysis from proposed change point |

### Enhanced Design Agent — 7-Phase Workflow

The Design/UI-UX agent follows a 7-phase workflow for comprehensive per-story design:

1. **UX Discovery** — Persona definition, journey mapping, usability heuristics
2. **Brand Foundation** — Brand identity, visual identity (color, typography, spacing), design tokens
3. **Information Architecture** — Navigation structure, content hierarchy, interaction patterns
4. **Visual Design** — Component patterns, layout system, responsive grid
5. **HTML/CSS Mockups** — Interactive prototypes browsable in the user's browser
6. **Accessibility Audit** — WCAG 2.2 AA compliance check across perceivable, operable, understandable, robust criteria
7. **Developer Handoff + User Review** — Design tokens, component specs, responsive specs, gallery for user feedback

### SaaS Sync Architecture

SaaS sync skills are separate from planning methodology:

| Sync Skill | SaaS | Mapping |
|---|---|---|
| `linear-sync` | Linear | Initiative=PRD, Project=UserStory, Issue=HLD |
| `jira-sync` (future) | Jira | Epic=PRD, Story=UserStory, Task=HLD |

### Skill and Rule Structure

Each planning sub-agent has:

| Component | Location | Purpose |
|---|---|---|
| **Skill** | `common-skills/planning-[domain]/SKILL.md` | Agent contract, workflow, templates |
| **References** | `common-skills/planning-[domain]/references/` | Templates, rubrics, checklists |
| **Rules** | `roo-code/rules-sdlc-planner-[domain]/` | 4–6 Markdown files per agent |
| **Mode** | Entry in `roo-code/.roomodes` | Roo-Code mode definition |
| **Dispatch Template** | `common-skills/planning-hub/references/dispatch-templates/` | Hub dispatch format |

Each rule set follows the Markdown file pattern:

1. `1_workflow.md` — Agent workflow and phases
2. `2_best_practices.md` — Domain best practices
3. `3_sparring_patterns.md` — Domain-specific challenge patterns
4. `4_decision_guidance.md` — Boundaries and gates
5. `5_validation.md` — Self-validation before declaring ready
6. `6_error_handling.md` — Error scenarios and recovery

---

## Implementation Hub Architecture

The **Implementation Hub** extends the sdlc-architect into a full lifecycle orchestrator. After the Planning Hub produces execution-ready story packages, the Implementation Hub manages the entire journey from readiness check through user acceptance.

### Execution Phases

```
Phase 0: Readiness Check — verify plan artifacts, dependencies, load tech skills
    ↓
Phase 1: Task Decomposition + Staging Doc — architecture planning, create staging doc
    ↓
Phase 2: Per-Task Dev Loop — implement → code review (+ security) → QA
    ↓
Phase 3: Story Integration — full-story review + QA
    ↓
Phase 4: Acceptance Validation — independent criterion verification
    ↓
Phase 5: Documentation Integration — merge staging doc into permanent docs
    ↓
Phase 6: User Acceptance — present evidence, get approval
```

| Phase | Purpose | Agents Involved | Gate |
|---|---|---|---|
| **0: Readiness** | Verify plan artifacts exist, dependencies complete, load tech skills | Architect | All prerequisites met |
| **1: Decomposition** | Architecture planning, staging doc creation | Architect | Task checklist ready |
| **2: Dev Loop** | Per-task implement → review → QA cycle | Implementer, Code Reviewer, QA | Each task passes review + QA |
| **3: Integration** | Full-story holistic review and verification | Code Reviewer, QA | Story-level review + QA pass |
| **4: Acceptance** | Independent criterion-by-criterion verification | Acceptance Validator | All criteria verified with evidence |
| **5: Doc Integration** | Merge staging doc into permanent documentation | Architect | Checklist complete |
| **6: User Acceptance** | Present evidence report, get user approval | Architect → User | User confirms |

### Key Features

- **Technology Skill Loading**: The story manifest's `tech_stack` field maps to skills (e.g., `react-native` → `common-skills/react-native/`). Skills are loaded by the implementer and verified by the reviewer.
- **Security Review Integration**: The code reviewer loads `common-skills/security-review/` when the dispatch includes `SECURITY_REVIEW: true`. No separate security agent dispatch needed.
- **Anti-Fabrication Rules**: The implementer has strict DENY rules preventing placeholder implementations, skipped criteria, scope changes, and unverified completion claims.
- **Evidence-Based Verification**: Every stage requires fresh evidence — the implementer self-verifies, QA re-verifies, and the acceptance validator independently maps every criterion to code and proof.
- **Documentation-First Workflow**: The staging doc is scaffolded from plan artifacts in Phase 1 and continuously updated. Every dispatch template includes documentation requirements for that role.

### Documentation System

Documentation is enforced through the architect-execution-hub and its dispatch templates, not through global rules or per-mode rule files. This avoids polluting planner modes with implementation-time documentation rules.

**How it works:**

1. The architect loads `common-skills/project-documentation/` and scaffolds a staging doc from plan artifacts.
2. Every dispatch template includes a documentation contract for the receiving role.
3. The implementer updates staging docs with progress, decisions, and file references.
4. The code reviewer verifies staging docs are current.
5. The QA verifier validates file references point to real files.
6. The acceptance validator checks documentation completeness as a gate.

**`docs/` is the project's technical reference for agents.** It is NOT a project board. Planning artifacts live in `plan/`. Documentation captures how the system works and how it was built.

### Story Manifest — tech_stack Field

The story dependency manifest includes a `tech_stack` field that drives skill loading:

```yaml
---
prd_sections: [3.1, 3.2]
architecture_components: [auth-service, api-gateway]
provides_contracts: [auth-session-contract]
consumes_contracts: []
depends_on_stories: []
execution_order: 1
candidate_domains: [api, data, security, design]
tech_stack: [react-native, typescript, expo]
---
```

---

## Cursor Architecture

The Cursor implementation mirrors the Roo Code SDLC system but adapts to Cursor's single-level nesting constraint (main agent → subagent). The 3-level Roo Code hierarchy (coordinator → hub → worker) is flattened by promoting orchestrators to rules.

### How It Works

```
User message
  → Main Chat Agent (loads orchestrator rules automatically)
    → Dispatches subagents via Task tool
```

**Orchestrator rules** (`.cursor/rules/*.mdc`) teach the main agent how to coordinate. They load via Cursor's "Apply Intelligently" mechanism when SDLC work is detected. **Subagents** (`.cursor/agents/*.md`) are leaf workers dispatched by the main agent using the Task tool.

### Dispatch Protocol

Roo Code's `new_task` / `attempt_completion` / `switch_mode` primitives are translated:

| Roo Code | Cursor |
|---|---|
| `new_task(mode="X", message="Y")` | Task tool: `/X Y` |
| `attempt_completion(result="Z")` | Subagent returns final message |
| `switch_mode(mode="X")` | Rules auto-load; or `/X` |
| `groups: [read]` | `readonly: true` in subagent frontmatter |
| `fileRegex` restrictions | Prompt-level "You may ONLY write to..." |

### Orchestrator Rules (3)

| Rule | Purpose |
|---|---|
| `sdlc-coordinator.mdc` | State-aware phase router: determines planning vs execution |
| `sdlc-planning-orchestrator.mdc` | 7-phase planning workflow with validation gates |
| `sdlc-execution-orchestrator.mdc` | Implementation lifecycle: readiness → dev loop → acceptance |

### Subagents (17)

| Category | Subagents | Model |
|---|---|---|
| **Planning** (10) | prd, architecture, stories, hld, security, api, data, devops, design, testing | inherit |
| **Validation** (1) | plan-validator | inherit |
| **Execution** (4) | implementer, code-reviewer, qa, acceptance-validator | inherit / fast |
| **Utility** (2) | project-research, documentation-writer | fast / inherit |

### Skills

Skills are shared with Roo Code via symlink: `cursor/.cursor/skills → ../../common-skills/`. No skill migration is needed — the same Agent Skills standard works across both IDEs.

### Adding New Cursor Agents

See [cursor/ROO-MIGRATION-PROTOCOL.md](cursor/ROO-MIGRATION-PROTOCOL.md) for the full step-by-step guide, decision tree, templates, and checklist.

---

## Checkpoint and Resume System

The SDLC workflow includes a crash-safe checkpoint system that enables seamless continuation across agents, models, and IDEs. If an agent stops mid-workflow (token exhaustion, IDE switch, model change), you can resume from the exact point using `/sdlc-continue`.

### How It Works

- **Write-ahead checkpointing**: Before every sub-agent dispatch, the orchestrating hub calls a shell script to record the current state. If the agent dies mid-dispatch, the checkpoint reflects what was about to happen.
- **Split YAML state files**: State is stored in `.sdlc/` at the project root, split by concern (coordinator, planning, execution) so each agent only reads what it needs.
- **Shell scripts handle I/O**: All checkpoint reads and writes go through bundled scripts in `common-skills/sdlc-checkpoint/scripts/`, not the LLM. This reduces token cost by ~10x compared to agent-written checkpoints.
- **Deterministic verification**: On resume, a verify script checks checkpoint state against actual artifacts on disk and outputs a concrete next-action recommendation. No LLM reasoning needed for the verification step.

### State Files

```
<target-project>/.sdlc/
├── coordinator.yaml         # Active hub, current story, stories progress
├── planning.yaml            # Phase, story loop position, per-story agent progress
├── execution.yaml           # Phase, task, dev-loop step, iteration counts
└── history.log              # Append-only timestamped action log
```

### Resume Flow

```
User: /sdlc-continue
  → Coordinator reads .sdlc/coordinator.yaml (via verify.sh)
  → Routes to sdlc-planner or sdlc-architect
  → Hub reads its own checkpoint (via verify.sh planning|execution)
  → Verifies against artifacts on disk
  → Resumes from the exact point
```

### Cross-IDE Portability

The checkpoint files are plain YAML in the project root. The scripts are accessible via `.roo/skills/sdlc-checkpoint/scripts/` (symlinked from the registry). Any IDE that can run shell commands can read and write checkpoints — Roo-Code, Cursor, Claude Code, and Codex all work.

### Skill Structure

| Component | Location | Purpose |
|-----------|----------|---------|
| **Skill** | `common-skills/sdlc-checkpoint/SKILL.md` | Skill contract, script API docs |
| **Scripts** | `common-skills/sdlc-checkpoint/scripts/` | `checkpoint.sh` (write), `verify.sh` (read + recommend) |
| **References** | `common-skills/sdlc-checkpoint/references/` | Resume protocol, artifact mapping |

---

## Quick Start

### 1. Clone the Registry

```bash
git clone https://github.com/YOUR_ORG/ai-registry.git ~/ai-registry
```

### 2. Link Into a Project

Navigate to any project directory and run the setup script:

```bash
~/ai-registry/scripts/setup-links.sh
```

Or specify a target directory explicitly:

```bash
~/ai-registry/scripts/setup-links.sh /path/to/my-project
```

To clean up stale links and recreate everything from scratch:

```bash
~/ai-registry/scripts/setup-links.sh --force
```

The script will create symlinks for:

| Source (Registry)              | Link (Project)       |
| ------------------------------ | -------------------- |
| `cursor/.cursor/rules/`       | `.cursor/rules/`     |
| `cursor/.cursor/agents/`      | `.cursor/agents/`    |
| `roo-code/.roomodes`          | `.roomodes`          |
| `roo-code/`                   | `.roo/`              |
| `claude/CLAUDE.md`            | `CLAUDE.md`          |
| `codex/AGENTS.md`             | `AGENTS.md`          |

### 3. Set Up the Global Gitignore (Important!)

See the [Git Safety](#git-safety--global-gitignore) section below.

---

## Git Safety — Global Gitignore

Symlinked AI config files should **never** be committed to your project repositories. Set up a global gitignore to prevent this.

### Step 1: Create the Global Gitignore File

Create or append to `~/.gitignore_global`:

```bash
cat >> ~/.gitignore_global << 'EOF'
# ===========================================
# AI Registry — Symlinked Configuration Files
# ===========================================
.cursor/rules
.cursor/agents
.roomodes
.roo
CLAUDE.md
AGENTS.md

# ===========================================
# SDLC Checkpoint — Session State (not code)
# ===========================================
.sdlc
EOF
```

### Step 2: Register It with Git

```bash
git config --global core.excludesfile ~/.gitignore_global
```

### Verify

```bash
git config --global core.excludesfile
# Should output: /Users/<you>/.gitignore_global
```

From this point forward, Git will ignore these files in **every** repository on your machine, regardless of whether the project has its own `.gitignore`.

> **Tip**: If a project already tracks one of these files, the global ignore will not apply. You'll need to `git rm --cached <file>` first to untrack it.

---

## Supported Providers

| Provider     | Config Files                         | Docs |
| ------------ | ------------------------------------ | ---- |
| **Cursor**   | `.cursor/rules/*.mdc`, `.cursor/agents/*.md` | [Cursor Docs](https://docs.cursor.com) |
| **Roo-Code** | `.roomodes`, `.roo/`                 | [Roo-Code Docs](https://docs.roocode.com) |
| **Claude Code** | `CLAUDE.md`                       | [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code) |
| **Codex / Windsurf** | `AGENTS.md`                 | — |

---

## Contributing

### Adding a New Skill

1. Create a skill folder in `common-skills/` with a `SKILL.md` entry point (e.g., `common-skills/database-migrations/SKILL.md`).
2. Follow the structure of existing skills — clear headings, numbered steps, actionable guidance. Use `references/` subdirectories for templates.
3. Reference the skill from relevant provider configs if agents should load it automatically.

### Adding a New Planning Agent

1. Create a skill in `common-skills/planning-[domain]/` with `SKILL.md` and `references/`.
2. Create a dispatch template in `common-skills/planning-hub/references/dispatch-templates/`.
3. Create rules in `roo-code/rules-sdlc-planner-[domain]/` (4–6 Markdown files following the pattern above).
4. Add a mode entry in `roo-code/.roomodes`.
5. Update the Planning Hub skill to include the new agent in its phase ordering and dispatch workflow.

### Adding a New SaaS Sync Skill

1. Create a skill in `common-skills/[saas]-sync/` with `SKILL.md` and `references/`.
2. Define the hierarchy mapping (how plan artifacts map to SaaS entities).
3. Define the sync workflow (discovery, assessment, apply sequence).
4. The sync skill should never contain planning methodology — only translation logic.

### Adding a New Agent / Mode

1. **Roo-Code**: Add a new entry to the `customModes` array in `roo-code/.roomodes`. Each mode needs a `slug`, `name`, `roleDefinition`, `groups` (permissions), and `customInstructions`.
2. **Cursor**: For orchestrators, add a `.mdc` rule under `cursor/.cursor/rules/`. For leaf workers, add a `.md` subagent under `cursor/.cursor/agents/`. See [cursor/ROO-MIGRATION-PROTOCOL.md](cursor/ROO-MIGRATION-PROTOCOL.md) for the decision tree and templates.
3. **Claude**: Update `claude/CLAUDE.md` with additional context or behavioral instructions.
4. **Codex**: Update `codex/AGENTS.md` with new agent directives.

### Editing Existing Rules

Edit the files directly in this repository. Changes take effect immediately in all linked projects — no re-linking required. That's the point.

### Pull Request Guidelines

- Describe **what** changed and **why**.
- If adding a new mode or skill, include a short example of the expected agent behavior.
- Test the symlink setup on a clean project directory before merging.

---

## License

This repository is private to your organization. Add a `LICENSE` file if you plan to open-source it.
