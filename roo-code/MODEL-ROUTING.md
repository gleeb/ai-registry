# Model Routing — Mode to Profile Assignment

Reference for assigning Roo-Code API Configuration Profiles to each SDLC mode.

## Profiles

| Profile | Provider | Base URL | Model |
|---------|----------|----------|-------|
| **Commercial** | Anthropic (or OpenAI) | Default (cloud) | Claude Sonnet 4.5 / your preferred |
| **Local-Planning** | OpenAI Compatible | `http://localhost:1234/v1` | qwen3.5-35b-a3b (Q4_K_M, ~24GB) |
| **Local-Coder** | OpenAI Compatible | `http://localhost:1234/v1` | qwen3-coder-30b-a3b (Q4_K_M, ~19GB) |

## Mode Assignments

### Orchestrators — Commercial

These make routing decisions and interpret validation results. Quality here determines the entire workflow.

| Mode Slug | Mode Name | Profile | Rationale |
|-----------|-----------|---------|-----------|
| `sdlc-coordinator` | SDLC Coordinator | **Commercial** | Phase routing decisions |
| `sdlc-planner` | SDLC Planning Hub | **Commercial** | Dispatches agents, interprets gates |
| `sdlc-architect` | SDLC Architect | **Commercial** | Manages execution lifecycle |

### Foundational Planning — Commercial

Few dispatches (1-2 each), but errors here cascade into everything downstream.

| Mode Slug | Mode Name | Profile | Rationale |
|-----------|-----------|---------|-----------|
| `sdlc-planner-prd` | SDLC PRD Agent | **Commercial** | Foundational — weak PRD cascades everywhere |
| `sdlc-planner-architecture` | SDLC Architecture Agent | **Commercial** | Foundational — sets technical direction |

### Validation — Commercial

The quality backstop. Catches mistakes from local models at every gate.

| Mode Slug | Mode Name | Profile | Rationale |
|-----------|-----------|---------|-----------|
| `sdlc-plan-validator` | SDLC Plan Validator | **Commercial** | Runs after every phase; Reality Checker philosophy |

### Domain Planning Workers — Local-Planning

High-volume, template-guided output. Validated by the commercial Plan Validator after each story.

| Mode Slug | Mode Name | Profile | Rationale |
|-----------|-----------|---------|-----------|
| `sdlc-planner-stories` | SDLC Story Decomposer | **Local-Planning** | Structured decomposition, validated afterward |
| `sdlc-planner-hld` | SDLC HLD Agent | **Local-Planning** | Per-story, template-driven |
| `sdlc-planner-api` | SDLC API Design Agent | **Local-Planning** | Schema generation, follows OpenAPI patterns |
| `sdlc-planner-data` | SDLC Data Architecture Agent | **Local-Planning** | Entity-relationship design, well-structured |
| `sdlc-planner-security` | SDLC Security Agent | **Local-Planning** | Per-story mode only; rollup (Phase 4) should escalate to Commercial |
| `sdlc-planner-devops` | SDLC DevOps Agent | **Local-Planning** | CI/CD templates, established patterns |
| `sdlc-planner-design` | SDLC Design Agent | **Local-Planning** | Template-driven 7-phase design workflow |
| `sdlc-planner-testing` | SDLC Testing Strategy Agent | **Local-Planning** | Test pyramid, coverage mapping, checklist-driven |

### Execution Workers — Local-Coder

Highest volume. The implement-review-QA loop runs 60-100 times per project.

| Mode Slug | Mode Name | Profile | Rationale |
|-----------|-----------|---------|-----------|
| `sdlc-implementer` | SDLC Implementer | **Local-Coder** | Agentic coding with tool use, highest volume |
| `sdlc-code-reviewer` | SDLC Code Reviewer | **Local-Coder** | Pass/fail comparison, structured short output |
| `sdlc-qa` | SDLC QA Verifier | **Local-Coder** | Evidence-based pass/fail |
| `sdlc-acceptance-validator` | SDLC Acceptance Validator | **Local-Coder** | Checklist verification against story criteria |

### Utility — Local

Lower stakes, on-demand.

| Mode Slug | Mode Name | Profile | Rationale |
|-----------|-----------|---------|-----------|
| `sdlc-project-research` | SDLC Project Research | **Local-Coder** | Quick codebase lookups |
| `sdlc-documentation-writer` | SDLC Documentation Writer | **Local-Planning** | Technical docs, lower stakes |

## Summary

| Profile | Modes | Dispatches per Project |
|---------|-------|----------------------|
| **Commercial** | 6 modes | ~25-30 dispatches |
| **Local-Planning** | 9 modes | ~20-25 dispatches |
| **Local-Coder** | 5 modes | ~80-100 dispatches |
| **Total** | 20 modes | ~125-155 dispatches |

Commercial usage reduction: **~80%** of all dispatches move to local models.

## Escalation Triggers

When a local agent's output fails validation, the orchestrator (Commercial) decides whether to retry locally or escalate. Specific triggers:

| Trigger | Action |
|---------|--------|
| PRD or Architecture validation fails | Already on Commercial — retry or involve user |
| Per-story validation flags >3 issues | Re-run affected domain agent on Commercial |
| Security rollup (Phase 4) | Always escalate to Commercial |
| Code Reviewer rejects same task 2x | Escalate that task's Implementer dispatch to Commercial |
| QA finds false-pass from Code Reviewer | Re-run review on Commercial |
| Acceptance Validator on security-critical story | Run on Commercial directly |

## LM Studio Setup

1. Download both models in LM Studio
2. In **Developer tab > Server Settings**: keep **Auto-Evict ON** (default) and **JIT loading ON** (default)
3. Models swap automatically — the planning model loads during Phases 1-5, the coder loads during execution
4. Only one model is resident at a time; swap happens once at the planning-to-execution boundary (~15-30s)
