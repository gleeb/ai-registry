# How-To Guides

Step-by-step procedures for common SDLC operations.

---

## Start a New Project from Scratch

1. **Link the AI Registry** into your project directory:
   ```bash
   ~/ai-registry/scripts/setup-links.sh /path/to/your-project
   ```
   This creates symlinks for Cursor rules/agents/skills and Roo-Code modes/rules/skills.

2. **Set up the global gitignore** (first time only) to prevent AI config symlinks from being committed:
   ```bash
   cat >> ~/.gitignore_global << 'EOF'
   .cursor/rules
   .cursor/agents
   .roomodes
   .roo
   CLAUDE.md
   AGENTS.md
   .sdlc
   EOF
   git config --global core.excludesfile ~/.gitignore_global
   ```

3. **Start planning** by telling the agent to plan your project. The Coordinator will detect STATE_NONE (no existing plan) and route to the Planning Hub. You can also explicitly say `plan <project-name>`.

4. **Walk through planning phases** — the Planning Hub will guide you through PRD sparring, architecture, story decomposition, and per-story planning. Each phase requires your input and approval.

5. **Begin execution** — after planning completes, the Hub hands off to the Execution Orchestrator, which implements stories in dependency order.

---

## Continue After an Interruption

If an agent stopped mid-workflow (token exhaustion, IDE crash, session timeout):

1. **Send `/sdlc-continue`** in a new session.
2. The Coordinator reads `.sdlc/coordinator.yaml` via `verify.sh`.
3. Routes to the correct hub (planning or execution).
4. The hub reads its checkpoint and verifies against artifacts on disk.
5. Resumes from the exact point — re-dispatching the agent that was in progress if its artifact is missing, or advancing if the artifact was produced.

No manual state tracking needed. The checkpoint system handles it.

---

## Re-Plan After a Requirement Change

When requirements change after planning is complete (or partially complete):

1. **Describe the change** to the agent. The Planning Hub classifies the change level:
   - PRD-level: fundamental requirements changed
   - Architecture-level: system design needs updating
   - Story-internal: change affects one story's internals only
   - Story-contract: a shared interface needs to change
   - Cross-cutting: DevOps, security, or testing strategy affected

2. **Impact analysis runs automatically** — the Plan Validator traces the dependency graph from the change point and reports the blast radius (directly affected, indirectly affected, unaffected artifacts).

3. **Review and confirm scope** — you see exactly what needs re-planning. You can narrow the scope if some impacts are acceptable.

4. **Minimum re-dispatch** — only the agents needed for affected artifacts are re-dispatched. Unaffected artifacts remain untouched.

5. **Re-validate** — the Plan Validator re-runs on affected artifacts to ensure consistency.

---

## Skip a Planning Phase

You can request to skip a planning phase, but the system will surface consequences:

1. **Tell the agent** you want to skip the phase.
2. The Planning Hub explains what will be missing:
   - Skipping PRD → no validated requirements, all downstream phases lack a foundation
   - Skipping Architecture → no component boundaries, stories may be incorrectly scoped
   - Skipping per-story domains → execution agents will lack design guidance for those domains
   - Skipping cross-cutting → no security overview, no DevOps plan, no testing strategy
3. **Provide explicit acknowledgment** — you must acknowledge the specific risks for each skipped phase.
4. The Hub records the skip with your acknowledgment and proceeds.

Validation gates for skipped phases are marked as "skipped with user acknowledgment" rather than passed.

---

## Link the Registry into a New Project

```bash
# From the project directory
~/ai-registry/scripts/setup-links.sh

# Or specify a target explicitly
~/ai-registry/scripts/setup-links.sh /path/to/project

# Force clean and recreate all links
~/ai-registry/scripts/setup-links.sh --force
```

The script creates these symlinks:

| Source (Registry) | Link (Project) |
|---|---|
| `cursor/.cursor/rules/` | `.cursor/rules/` |
| `cursor/.cursor/agents/` | `.cursor/agents/` |
| `common-skills/` | `.cursor/skills/` |
| `roo-code/.roomodes` | `.roomodes` |
| `roo-code/` | `.roo/` |

To add a single skill to a project:
```bash
~/ai-registry/scripts/add-skill.sh <skill-name> /path/to/project <provider>
# provider: cursor, roo, claude, codex, windsurf, or all
```

---

## Switch IDEs Mid-Workflow

The SDLC system is IDE-portable:

1. **Ensure the registry is linked** for the target IDE in the project. If only Roo-Code links exist and you want to switch to Cursor:
   ```bash
   ~/ai-registry/scripts/setup-links.sh /path/to/project
   ```

2. **Open the project in the new IDE.** The checkpoint files (`.sdlc/*.yaml`) are plain YAML at the project root and are IDE-independent.

3. **Send `/sdlc-continue`** in the new IDE. The Coordinator reads the checkpoint and resumes.

Plan artifacts (`plan/`) and staging documents (`docs/staging/`) are also IDE-independent Markdown files.

---

## Force Re-Validation of an Existing Plan

To re-validate an existing plan without re-running planning agents:

1. **For a specific phase**: Ask the agent to validate Phase N. The Planning Hub dispatches the Plan Validator in Phase Validation mode for that phase.

2. **For a specific story**: Ask the agent to validate story US-NNN. The Plan Validator runs in Per-Story Validation mode with 9 consistency checks.

3. **For cross-story consistency**: Ask for cross-story validation. The Plan Validator checks inter-story consistency, contract compliance, and cross-cutting coverage.

4. **For full-chain validation**: Ask for full execution readiness validation. The Plan Validator runs the complete end-to-end traceability check.

5. **For impact analysis**: Describe a proposed change. The Plan Validator runs in Impact Analysis mode (read-only) and reports the blast radius without modifying anything.

---

## Add a New Planning Agent to the System

To extend the SDLC with a new planning domain:

1. **Create a skill** in `common-skills/planning-[domain]/` with `SKILL.md` and `references/` (templates, rubrics, checklists).

2. **Create a dispatch template** in `common-skills/planning-hub/references/dispatch-templates/[domain]-dispatch.md`.

3. **For Roo-Code**: Create rules in `roo-code/rules-sdlc-planner-[domain]/` (4-6 Markdown files following the pattern: workflow, best practices, sparring patterns, decision guidance, validation, error handling). Add a mode entry in `roo-code/.roomodes`.

4. **For Cursor**: Create an agent file at `cursor/.cursor/agents/sdlc-planner-[domain].md` with frontmatter (name, description, model) and agent instructions.

5. **Update the Planning Hub** skill to include the new agent in its phase ordering and dispatch workflow.

6. **Update the Plan Validator** to include checks relevant to the new domain.

---

## Add a New Execution Agent

1. **Create an agent file** in `cursor/.cursor/agents/` (Cursor) or add a mode in `roo-code/.roomodes` (Roo-Code).

2. **Create a dispatch template** in `common-skills/architect-execution-hub/references/`.

3. **Update the Execution Orchestrator** rule/mode to include the new agent in its dispatch workflow.

4. **If the agent needs a skill**, create it in `common-skills/`.

---

## Initialize Checkpoints for an In-Progress Project

If you started work without the checkpoint system and want to adopt it:

```bash
.roo/skills/sdlc-checkpoint/scripts/checkpoint.sh init
# or for Cursor:
.cursor/skills/sdlc-checkpoint/scripts/checkpoint.sh init
```

The `init` subcommand scans `plan/` and `docs/staging/` to derive full state from existing artifacts. After initialization, `/sdlc-continue` will work normally.
