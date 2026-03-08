# AI Registry

A centralized, version-controlled source of truth for AI agent configurations, custom rules, skills, and instructions across IDEs and providers.

**One repository. Every project. Always in sync.**

---

## Table of Contents

- [Concept](#concept)
- [Repository Structure](#repository-structure)
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
│  ├─ .cursorrules ├─ .roomodes  ├─ CLAUDE.md ├─ AGENTS.md
│  └─ .cursor/     └─ .clinerules              │       │
│     └─ rules/                  common/       │       │
│                                └─ *.md       │       │
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
├── cursor/                     # Cursor IDE configurations
│   ├── .cursorrules            # Global coding standards
│   └── .cursor/
│       └── rules/
│           └── general.mdc     # Rule files (.mdc) for Cursor
│
├── roo-code/                   # Roo-Code configurations
│   ├── .roomodes               # Custom modes/agents (JSON)
│   └── .clinerules             # Global rules for Roo-Code
│
├── claude/                     # Claude Code (CLI) configurations
│   └── CLAUDE.md               # Project context read at session start
│
├── codex/                      # Codex / Windsurf configurations
│   └── AGENTS.md               # Agent behavior instructions
│
├── common/                     # Shared skills & documentation
│   └── universal-skills.md     # Cross-provider agent capabilities
│
├── scripts/                    # Automation
│   └── setup-links.sh          # Symlink installer
│
└── README.md
```

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

The script will create symlinks for:

| Source (Registry)              | Link (Project)       |
| ------------------------------ | -------------------- |
| `cursor/.cursorrules`          | `.cursorrules`       |
| `cursor/.cursor/rules/`       | `.cursor/rules/`     |
| `roo-code/.roomodes`          | `.roomodes`          |
| `roo-code/.clinerules`        | `.clinerules`        |
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
.cursorrules
.cursor/rules
.roomodes
.clinerules
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

> **Tip**: If a project already tracks one of these files (e.g., a committed `.cursorrules`), the global ignore will not apply. You'll need to `git rm --cached .cursorrules` first to untrack it.

---

## Supported Providers

| Provider     | Config Files                         | Docs |
| ------------ | ------------------------------------ | ---- |
| **Cursor**   | `.cursorrules`, `.cursor/rules/*.mdc`| [Cursor Docs](https://docs.cursor.com) |
| **Roo-Code** | `.roomodes`, `.clinerules`           | [Roo-Code Docs](https://docs.roocode.com) |
| **Claude Code** | `CLAUDE.md`                       | [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code) |
| **Codex / Windsurf** | `AGENTS.md`                 | — |

---

## Contributing

### Adding a New Skill

1. Create a Markdown file in `common/` (e.g., `common/database-migrations.md`).
2. Follow the structure in `common/universal-skills.md` — clear headings, numbered steps, actionable guidance.
3. Reference the skill from relevant provider configs if agents should load it automatically.

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
