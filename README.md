# AI Registry

A centralized, version-controlled source of truth for AI agent configurations, custom rules, skills, and instructions across IDEs and providers.

**One repository. Every project. Always in sync.**

---

## Table of Contents

- [Concept](#concept)
- [Repository Structure](#repository-structure)
- [Planning System Architecture](#planning-system-architecture)
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
┌─────────────────────────────────────────────────────┐
│                   AI Registry (this repo)            │
│                                                      │
│  cursor/        roo-code/     claude/     codex/     │
│  └─ .cursor/     ├─ .roomodes  ├─ CLAUDE.md ├─ AGENTS.md
│     └─ rules/    ├─ rules-sdlc-*/            │       │
│                  └─ skills/ → ../common-skills/      │
│                                                      │
│  common-skills/                                      │
│  ├─ planning-hub/                                    │
│  ├─ planning-prd/                                    │
│  ├─ planning-system-architecture/                    │
│  ├─ planning-hld/                                    │
│  ├─ planning-security/                               │
│  ├─ planning-api-design/                             │
│  ├─ planning-data-architecture/                      │
│  ├─ planning-devops/                                 │
│  ├─ planning-design/                                 │
│  ├─ planning-testing-strategy/                       │
│  ├─ planning-validator/                              │
│  ├─ linear-sync/                                     │
│  ├─ architect-execution-hub/                         │
│  ├─ scaffold-project/                                │
│  └─ ...                                              │
│  scripts/                                            │
│  └─ setup-links.sh                                   │
└───────────────┬─────────────────────────────────────-┘
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
│   └── .cursor/
│       └── rules/
│           └── general.mdc             # Rule files (.mdc) for Cursor
│
├── roo-code/                           # Roo-Code configurations (symlinked as .roo/)
│   ├── .roomodes                       # Custom modes/agents (YAML)
│   ├── mcp.json                        # MCP server configurations
│   ├── rules-sdlc-planner/            # Planning Hub rules (6 XML files)
│   ├── rules-sdlc-planner-prd/        # PRD Agent rules
│   ├── rules-sdlc-planner-architecture/ # Architecture Agent rules
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
│   ├── rules-skill-writer/            # Skill Writer rules
│   ├── rules-mode-writer/             # Mode Writer rules
│   └── skills/ → ../common-skills/    # Symlink to shared skills
│
├── common-skills/                      # Shared skills (accessible via .roo/skills/)
│   ├── planning-hub/                   # Planning orchestration hub
│   ├── planning-prd/                   # PRD templates and validation
│   ├── planning-system-architecture/   # System architecture templates
│   ├── planning-hld/                   # HLD and user story templates
│   ├── planning-security/              # Security planning templates
│   ├── planning-api-design/            # API design templates
│   ├── planning-data-architecture/     # Data architecture templates
│   ├── planning-devops/                # DevOps planning templates
│   ├── planning-design/                # UI/UX design and mock gallery
│   ├── planning-testing-strategy/      # Testing strategy templates
│   ├── planning-validator/             # Cross-plan validation
│   ├── linear-sync/                    # Linear SaaS sync (translation layer)
│   ├── architect-execution-hub/        # Architect dispatch templates
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

The planning system follows a hub-and-spoke model where the **Planning Hub** orchestrates specialized planning sub-agents, each responsible for a specific domain.

### Core Principle

**Internal planning is king.** All plan artifacts live in a `plan/` folder in the target project as markdown files (and HTML/CSS for design mockups). No external SaaS system is required. SaaS sync skills (Linear, Jira, etc.) are optional translation layers that map internal artifacts to SaaS-specific structures.

### Agent Hierarchy

```
SDLC Coordinator
  └── Planning Hub (sdlc-planner)
        ├── PRD Agent (sdlc-planner-prd)
        ├── System Architecture Agent (sdlc-planner-architecture)
        ├── HLD Agent (sdlc-planner-hld)
        ├── Security Agent (sdlc-planner-security)
        ├── API Design Agent (sdlc-planner-api)
        ├── Data Architecture Agent (sdlc-planner-data)
        ├── DevOps Agent (sdlc-planner-devops)
        ├── Design/UI-UX Agent (sdlc-planner-design)
        ├── Testing Strategy Agent (sdlc-planner-testing)
        ├── Plan Validator (sdlc-plan-validator)
        └── [Optional] SaaS Sync (e.g., linear-sync)
  └── Architect (sdlc-architect)
        ├── Implementer (sdlc-implementer)
        ├── Code Reviewer (sdlc-code-reviewer)
        └── QA Verifier (sdlc-qa)
```

### Planning Phases

The Planning Hub manages work in ordered phases with validation gates between each:

| Phase | Agents | Output | Gate |
|---|---|---|---|
| **Phase 1: Requirements** | PRD Agent | `plan/prd.md` | 8-dimension PRD validation at "high" |
| **Phase 2: Architecture** | Architecture + Security Agents | `plan/system-architecture.md`, `plan/security.md` | Cross-consistency with PRD |
| **Phase 3: Detailed Design** | HLD, API, Data, DevOps, Design Agents | `plan/hld.md`, `plan/api-design.md`, `plan/data-architecture.md`, `plan/devops.md`, `plan/design/` | Full cross-domain consistency |
| **Phase 4: Stories & Testing** | User story verification + Testing Agent | `plan/user-stories/*.md`, `plan/testing-strategy.md` | Full-chain traceability |
| **Phase 5: Sync** (optional) | SaaS sync skill | External system updates | Sync verification |
| **Phase 6: Handoff** | Hub → Coordinator | Execution-ready summary | All gates passed |

### Plan Folder Structure

Each target project gets a `plan/` folder with this layout:

```
plan/
├── prd.md                        # Product Requirements Document
├── system-architecture.md        # System Architecture
├── hld.md                        # High-Level Design
├── security.md                   # Security Plan
├── api-design.md                 # API Contracts
├── data-architecture.md          # Data Models
├── devops.md                     # DevOps Plan
├── testing-strategy.md           # Testing Strategy
├── user-stories/                 # User Story decomposition
│   ├── US-001-scaffolding.md
│   ├── US-002-[feature].md
│   └── ...
├── design/                       # UI/UX Design
│   ├── design-spec.md
│   ├── color-palette.md
│   └── mockups/
│       ├── index.html            # Gallery site (open in browser)
│       ├── styles.css
│       └── screens/[feature]/
└── validation/
    └── cross-validation-report.md
```

### Validation Flow

After each planning phase, the **Plan Validator** checks:

- **Upward traceability**: Requirements from higher-level documents are addressed downstream
- **Cross-domain consistency**: No contradictions between sibling plan documents
- **Completeness**: No requirements fall through the cracks
- **Conflict detection**: Active search for contradictions (12 built-in conflict patterns)

### SaaS Sync Architecture

SaaS sync skills are separate from planning methodology:

| Sync Skill | SaaS | Mapping |
|---|---|---|
| `linear-sync` | Linear | Initiative=PRD, Project=UserStory, Issue=HLD |
| `jira-sync` (future) | Jira | Epic=PRD, Story=UserStory, Task=HLD |

### Design Agent with Mock Gallery

The Design/UI-UX agent produces HTML/CSS mockups alongside the design specification. A gallery template (`plan/design/mockups/index.html`) lets users browse all mockups in their browser and iterate on visual direction with the agent.

### Skill and Rule Structure

Each planning sub-agent has:

| Component | Location | Purpose |
|---|---|---|
| **Skill** | `common-skills/planning-[domain]/SKILL.md` | Agent contract, workflow, templates |
| **References** | `common-skills/planning-[domain]/references/` | Templates, rubrics, checklists |
| **Rules** | `roo-code/rules-sdlc-planner-[domain]/` | 6 XML files per agent |
| **Mode** | Entry in `roo-code/.roomodes` | Roo-Code mode definition |
| **Dispatch Template** | `common-skills/planning-hub/references/dispatch-templates/` | Hub dispatch format |

Each rule set follows the 6-file pattern:

1. `1_workflow.xml` — Agent workflow and phases
2. `2_best_practices.xml` — Domain best practices
3. `3_sparring_patterns.xml` — Domain-specific challenge patterns
4. `4_decision_guidance.xml` — Boundaries and gates
5. `5_validation_cycles.xml` — Self-validation before declaring ready
6. `6_error_handling.xml` — Error scenarios and recovery

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
.roomodes
.roo
CLAUDE.md
AGENTS.md
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
| **Cursor**   | `.cursor/rules/*.mdc`                | [Cursor Docs](https://docs.cursor.com) |
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
3. Create rules in `roo-code/rules-sdlc-planner-[domain]/` (6 XML files).
4. Add a mode entry in `roo-code/.roomodes`.
5. Update the Planning Hub skill to include the new agent in its phase ordering.

### Adding a New SaaS Sync Skill

1. Create a skill in `common-skills/[saas]-sync/` with `SKILL.md` and `references/`.
2. Define the hierarchy mapping (how plan artifacts map to SaaS entities).
3. Define the sync workflow (discovery, assessment, apply sequence).
4. The sync skill should never contain planning methodology — only translation logic.

### Adding a New Agent / Mode

1. **Roo-Code**: Add a new entry to the `customModes` array in `roo-code/.roomodes`. Each mode needs a `slug`, `name`, `roleDefinition`, `groups` (permissions), and `customInstructions`.
2. **Cursor**: Add a new `.mdc` file under `cursor/.cursor/rules/` with a frontmatter block specifying `description`, `globs`, and `alwaysApply`.
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
