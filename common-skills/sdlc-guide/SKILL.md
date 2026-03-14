---
name: sdlc-guide
description: >
  Expert knowledge base for the AI Registry SDLC system. Load this skill when
  the user asks for clarifications on how to operate the SDLC — lifecycle flow,
  phase ordering, agent roles, what happens next, why something happened,
  validation gates, recovery from stuck states, checkpoint/resume, brownfield
  re-planning, troubleshooting errors, or any "how do I..." question about the
  SDLC workflow. This skill is for explanation only — it does NOT perform SDLC
  tasks (planning, implementing, reviewing). Those have dedicated agents.
---

# SDLC Guide

Reference skill for answering user questions about how the SDLC system works.

## Lifecycle at a Glance

```
User request
  → Coordinator (state assessment — is this planning or execution?)
    → Planning Hub (7 phases: PRD → Architecture → Stories → Per-Story Plans → Cross-Cutting → Validation → Handoff)
      → Execution Hub (7 phases: Readiness → Decomposition → Dev Loop → Integration → Acceptance → Docs → User Approval)
        → Done (next story or completion)
```

The Coordinator routes work. The Planning Hub produces plan artifacts. The Execution Hub implements them. Every phase has a validation gate that must pass before advancing.

## The Three Orchestrators

**Coordinator** — State-aware router. Assesses project state (nothing exists, planned, ready, in-progress, done) and routes to the Planning Hub or Execution Hub. Entry point for all SDLC work. Handles `/sdlc-continue` for checkpoint resume.

**Planning Orchestrator** — Manages the 7-phase planning workflow. Dispatches specialized planning agents (PRD, Architecture, Stories, HLD, Security, API, Data, DevOps, Design, Testing) and the Plan Validator. Never writes plan content directly — only coordinates.

**Execution Orchestrator** — Manages the implementation lifecycle for a single story. Dispatches Implementer, Code Reviewer, QA, and Acceptance Validator in structured loops with iteration limits. Owns the staging document as the single source of truth.

## Quick FAQ

**Q: What phase am I in?**
Check `.sdlc/coordinator.yaml` for the active hub, then `.sdlc/planning.yaml` or `.sdlc/execution.yaml` for the current phase. Or run `verify.sh` from the checkpoint skill. See [troubleshooting.md](references/troubleshooting.md).

**Q: My agent crashed mid-task. How do I continue?**
Use `/sdlc-continue`. The Coordinator reads checkpoint state, verifies against artifacts on disk, and resumes from the exact point. See [troubleshooting.md](references/troubleshooting.md).

**Q: What order do the planning agents run in?**
Phase 1: PRD → Phase 2: Architecture then Stories → Phase 3: Per-story loop (HLD, API, Data, Security in parallel; Design after HLD) → Phase 4: Security rollup, DevOps, Testing in parallel → Phase 5-7: Validation and handoff. See [planning-deep-dive.md](references/planning-deep-dive.md).

**Q: What happens during the dev loop?**
For each task: Implementer builds it → Code Reviewer reviews → QA verifies. Max 3 review rejections, max 2 QA failures per task before escalation. See [execution-deep-dive.md](references/execution-deep-dive.md).

**Q: Validation failed. What do I do?**
First failure: the agent is re-dispatched with specific feedback. Second/third failure: escalated to user with options (iterate, accept partial, skip with acknowledgment). See [planning-deep-dive.md](references/planning-deep-dive.md).

**Q: How do I change requirements after planning is done?**
Use the brownfield change protocol: classify the change level, run impact analysis, review blast radius, confirm scope, re-dispatch minimum agents. See [planning-deep-dive.md](references/planning-deep-dive.md).

**Q: What does agent X do?**
See [agent-reference.md](references/agent-reference.md) for a complete reference of all 20 agents with their roles, inputs, outputs, and boundaries.

**Q: How do I start a new project from scratch?**
Link the registry into your project with `setup-links.sh`, then tell the Coordinator to plan your project. See [how-to-guides.md](references/how-to-guides.md).

**Q: Can I switch IDEs in the middle of a workflow?**
Yes. Checkpoint files are plain YAML in `.sdlc/` at the project root. Any IDE with the registry linked can read them and resume. See [how-to-guides.md](references/how-to-guides.md).

**Q: Where do plan artifacts live?**
All in the `plan/` folder at the project root. PRD and architecture at the top level, per-story packages under `plan/user-stories/US-NNN-name/`, contracts in `plan/contracts/`, cross-cutting in `plan/cross-cutting/`. See [lifecycle-overview.md](references/lifecycle-overview.md).

## Reference Navigation

| Question Type | Read |
|---|---|
| Overall flow, agent hierarchy, artifact structure | [lifecycle-overview.md](references/lifecycle-overview.md) |
| Planning phases, validation gates, brownfield changes | [planning-deep-dive.md](references/planning-deep-dive.md) |
| Execution phases, dev loop, iteration limits | [execution-deep-dive.md](references/execution-deep-dive.md) |
| What does agent X do? Which agent handles Y? | [agent-reference.md](references/agent-reference.md) |
| Stuck, crashed, recovery, checkpoint, errors | [troubleshooting.md](references/troubleshooting.md) |
| "How do I..." procedural guides | [how-to-guides.md](references/how-to-guides.md) |
