# Roo Code → Cursor Migration Protocol

A step-by-step guide for migrating Roo Code modes to Cursor rules and subagents.

---

## 1. Decision Tree: Rule vs Subagent

```
New Roo Code mode
  ├── Does it dispatch other modes via new_task?
  │   └── YES → Create a RULE (.cursor/rules/*.mdc)
  └── NO
      ├── Is it a leaf worker that receives work and returns results?
      │   └── YES → Create a SUBAGENT (.cursor/agents/*.md)
      └── Is it read-only research/analysis?
          ├── YES → Create a SUBAGENT with readonly: true
          └── NO  → Create a SUBAGENT (default)
```

Decision criteria:

- **Orchestrators** (dispatch other modes, manage workflows, make routing decisions) → Cursor **rule** with `alwaysApply: false`
- **Workers** (receive scoped work, produce output, return results) → Cursor **subagent**
- **Read-only investigators** (no writes needed) → Cursor **subagent** with `readonly: true`

---

## 2. Migrating an Orchestrator Mode to a Rule

**Input:** A Roo Code mode from `.roomodes` that uses `new_task` to dispatch other modes.

**Steps:**

1. Create `cursor/.cursor/rules/{slug}.mdc`
2. Add frontmatter:

```yaml
---
description: "[roleDefinition summary]. [whenToUse summary]. Dispatches subagents via Task tool."
alwaysApply: false
---
```

3. Add the role definition from `.roomodes` as the opening section.
4. Inline all files from `roo-code/rules-{slug}/` (in numbered order).
5. Add the **Cursor Dispatch Protocol** section:

```markdown
## Cursor Dispatch Protocol
When dispatch templates reference `new_task`, use the Task tool to launch the named subagent.
When dispatch templates reference `attempt_completion`, the subagent returns its final summary to you.
Mode slugs in dispatch templates map to subagent names (e.g., `sdlc-planner-prd` → `/sdlc-planner-prd`).
```

6. Add a **Path Translation** subsection to the dispatch protocol:

```markdown
### Path Translation
Shared skills and dispatch templates use Roo Code paths. When reading or composing dispatch messages, translate:
- `.roo/skills/` → `.cursor/skills/`
- `common-skills/` → `.cursor/skills/`
```

7. Reference the associated skill's dispatch templates (e.g., `.cursor/skills/planning-hub/references/dispatch-templates/`).
8. If the orchestrator uses the `sdlc-checkpoint` skill, add a **Checkpoint Integration** section with:
   - Script paths using `.cursor/skills/sdlc-checkpoint/scripts/`
   - Write-ahead REQUIRE rules (before every dispatch, after every completion)
   - A resume protocol (check YAML, run verify.sh, follow recommendation)
   - Per-phase checkpoint call examples
9. Add to `setup-links.sh` candidate list if not already covered by the directory-level symlink.

---

## 3. Migrating a Worker Mode to a Subagent

**Input:** A Roo Code mode from `.roomodes` that receives work and produces output.

**Steps:**

1. Create `cursor/.cursor/agents/{slug}.md`
2. Add YAML frontmatter:

```yaml
---
name: {slug}
description: >-
  {.roomodes description}. {.roomodes whenToUse, condensed}.
  [If file-restricted: "Writes to {paths} only."]
model: {inherit|fast}  # inherit for complex work, fast for focused verification
readonly: {true|false}  # true only for pure read/verify modes
---
```

3. Add the role definition from `.roomodes` as the prompt body.
4. If the Roo mode has `fileRegex` edit restrictions, add a `## File Restrictions` section:

```markdown
## File Restrictions
You may ONLY write to: `{pattern from fileRegex}`
Do not create or modify any other files.
```

5. **Inline rules (required):** Concatenate all files from `roo-code/rules-{slug}/` into the prompt body, each under its own heading. Cursor agents cannot reference `roo-code/` or `.roo/` at runtime — those paths don't exist in Cursor's world. All rule content must be inlined.
6. For skill references, use `.cursor/skills/{skill-name}/` (the symlink resolves to `common-skills/` in the registry). Never reference `common-skills/` directly.
7. Replace all `attempt_completion` references with: "Return your final summary to the parent agent with: [list completion contract items]"
8. Add a `## Completion Contract` section listing what the subagent must return.

### Model Selection

| Workload | Model | Rationale |
|---|---|---|
| Complex reasoning, planning, drafting | `inherit` | Needs full parent model capability |
| Focused verification, review, research | `fast` | Scoped task, speed over depth |

---

## 4. Migrating a New Skill

No migration needed. Skills use the same Agent Skills standard across Roo and Cursor.

1. Add the skill to `common-skills/{skill-name}/SKILL.md` in the registry.
2. It is automatically available to Cursor agents at `.cursor/skills/{skill-name}/` via the symlink.
3. It is automatically available to Roo Code agents at `.roo/skills/{skill-name}/` via their symlink.
4. If the skill's dispatch templates reference `new_task` or `attempt_completion`, the orchestrator rules' Cursor Dispatch Protocol handles the translation.

---

## 5. Checklist

For any migration, verify each item:

- [ ] Identify the mode in `roo-code/.roomodes` (slug, roleDefinition, whenToUse, groups, customInstructions)
- [ ] Decide: rule or subagent? (use decision tree above)
- [ ] Identify the associated `roo-code/rules-{slug}/` directory (source material to inline)
- [ ] Identify any associated skill in `common-skills/` (referenced at runtime as `.cursor/skills/`)
- [ ] Create the Cursor artifact (rule or subagent) following the template above
- [ ] Translate `new_task` → Task tool, `attempt_completion` → return message, `switch_mode` → N/A
- [ ] Translate `fileRegex` → prompt-level file restrictions
- [ ] Translate `groups` → `readonly: true` if read-only, otherwise omit (full access)
- [ ] Choose model: `inherit` for complex work, `fast` for focused tasks
- [ ] If orchestrator rule: add Cursor Dispatch Protocol section with Path Translation
- [ ] If orchestrator rule using checkpoints: add Checkpoint Integration section
- [ ] If subagent: add Completion Contract section
- [ ] Test: invoke the new rule/subagent and verify it behaves as expected

---

## 6. Roo-to-Cursor Translation Reference

| Roo Code | Cursor Equivalent |
|---|---|
| `new_task(mode="X", message="Y")` | Task tool: `/X Y` or "Use the X subagent to Y" |
| `switch_mode(mode="X")` | Rules auto-load; or `/X` for explicit invocation |
| `attempt_completion(result="Z")` | Return final message with Z |
| `groups: [read]` | `readonly: true` in frontmatter |
| `groups: [read, command]` | `readonly: true` (commands available in readonly) |
| `groups: [read, edit, command, mcp]` | No restriction (default) |
| `fileRegex: (plan/prd\.md$)` | Prompt: "You may ONLY write to: `plan/prd.md`" |
| `whenToUse: "..."` | Merge into `description` field |
| `customInstructions: "..."` | Inline into prompt body or reference rule files |
| `rules-{slug}/*.md` (auto-loaded) | Inlined into subagent prompt or referenced via Read |
| `.roo/skills/{name}/` | `.cursor/skills/{name}/` (path translation in dispatch protocol) |
| `common-skills/{name}/` | `.cursor/skills/{name}/` (path translation in dispatch protocol) |

---

## 7. Architecture Summary

```
cursor/
  .cursor/
    rules/                              # Orchestrator rules (loaded by main agent)
      sdlc-coordinator.mdc              # Phase routing: planning vs execution
      sdlc-planning-orchestrator.mdc    # 7-phase planning workflow
      sdlc-execution-orchestrator.mdc   # Implementation lifecycle
    agents/                             # Leaf-worker subagents (dispatched via Task tool)
      sdlc-planner-prd.md              # 10 planning subagents
      sdlc-planner-architecture.md
      sdlc-planner-stories.md
      sdlc-planner-hld.md
      sdlc-planner-security.md
      sdlc-planner-api.md
      sdlc-planner-data.md
      sdlc-planner-devops.md
      sdlc-planner-design.md
      sdlc-planner-testing.md
      sdlc-plan-validator.md            # Validator
      sdlc-implementer.md              # 4 execution subagents
      sdlc-code-reviewer.md
      sdlc-qa.md
      sdlc-acceptance-validator.md
      sdlc-project-research.md          # 2 utility subagents
      sdlc-documentation-writer.md
    skills -> ../../common-skills/      # Shared skills (symlink)
```

The key insight: Cursor supports only 1 level of nesting (main agent → subagent). Roo Code's 3-level hierarchy (coordinator → hub → worker) is flattened by promoting orchestrators to rules that teach the main agent how to coordinate. The main agent then dispatches leaf workers directly as subagents.
