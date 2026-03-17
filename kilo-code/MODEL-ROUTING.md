# Model Routing — Mode to Model Assignment

Reference for assigning models to each SDLC mode in Kilo Code.

## Model Configuration

In Kilo Code, models can be configured globally in `kilo.json` or per-mode in custom mode definitions. This document provides recommended model assignments for optimal cost-performance balance.

## Recommended Models

| Tier | Provider/Model | Use Case |
|------|----------------|----------|
| **Commercial** | `anthropic/claude-sonnet-4-20250514` | High-stakes decisions, orchestration, validation |
| **Local-Planning** | `http://localhost:1234/v1/qwen3.5-35b-a3b` | Template-driven planning, structured output |
| **Local-Coder** | `http://localhost:1234/v1/qwen3-coder-30b-a3b` | Code generation, review, testing |

## Mode Assignments

### Orchestrators — Commercial

These make routing decisions and interpret validation results. Quality here determines the entire workflow.

| Mode Slug | Mode Name | Model | Rationale |
|-----------|-----------|-------|-----------|
| `sdlc-coordinator` | SDLC Coordinator | **Commercial** | Phase routing decisions |
| `sdlc-planner` | SDLC Planning Hub | **Commercial** | Dispatches agents, interprets gates |
| `sdlc-architect` | SDLC Architect | **Commercial** | Manages execution lifecycle |

### Foundational Planning — Commercial

Few dispatches (1-2 each), but errors here cascade into everything downstream.

| Mode Slug | Mode Name | Model | Rationale |
|-----------|-----------|-------|-----------|
| `sdlc-planner-prd` | SDLC PRD Agent | **Commercial** | Foundational — weak PRD cascades everywhere |
| `sdlc-planner-architecture` | SDLC Architecture Agent | **Commercial** | Foundational — sets technical direction |

### Validation — Commercial

The quality backstop. Catches mistakes from local models at every gate.

| Mode Slug | Mode Name | Model | Rationale |
|-----------|-----------|-------|-----------|
| `sdlc-plan-validator` | SDLC Plan Validator | **Commercial** | Runs after every phase; Reality Checker philosophy |

### Domain Planning Workers — Local-Planning

High-volume, template-guided output. Validated by the commercial Plan Validator after each story.

| Mode Slug | Mode Name | Model | Rationale |
|-----------|-----------|-------|-----------|
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

| Mode Slug | Mode Name | Model | Rationale |
|-----------|-----------|-------|-----------|
| `sdlc-implementer` | SDLC Implementer | **Local-Coder** | Agentic coding with tool use, highest volume |
| `sdlc-code-reviewer` | SDLC Code Reviewer | **Local-Coder** | Pass/fail comparison, structured short output |
| `sdlc-qa` | SDLC QA Verifier | **Local-Coder** | Evidence-based pass/fail |
| `sdlc-acceptance-validator` | SDLC Acceptance Validator | **Local-Coder** | Checklist verification against story criteria |

### Utility — Local

Lower stakes, on-demand.

| Mode Slug | Mode Name | Model | Rationale |
|-----------|-----------|-------|-----------|
| `sdlc-project-research` | SDLC Project Research | **Local-Coder** | Quick codebase lookups |
| `sdlc-documentation-writer` | SDLC Documentation Writer | **Local-Planning** | Technical docs, lower stakes |

## Summary

| Tier | Modes | Dispatches per Project |
|------|-------|----------------------|
| **Commercial** | 6 modes | ~25-30 dispatches |
| **Local-Planning** | 9 modes | ~20-25 dispatches |
| **Local-Coder** | 5 modes | ~80-100 dispatches |
| **Total** | 20 modes | ~125-155 dispatches |

Commercial usage reduction: **~80%** of all dispatches move to local models.

## Implementation in Kilo Code

### Global Configuration (kilo.json)

```json
{
  "$schema": "https://app.kilo.ai/config.json",
  "model": "anthropic/claude-sonnet-4-20250514",
  "agent": {
    "sdlc-coordinator": {
      "model": "anthropic/claude-sonnet-4-20250514"
    },
    "sdlc-planner": {
      "model": "anthropic/claude-sonnet-4-20250514"
    },
    "sdlc-planner-prd": {
      "model": "anthropic/claude-sonnet-4-20250514"
    },
    "sdlc-planner-architecture": {
      "model": "anthropic/claude-sonnet-4-20250514"
    },
    "sdlc-plan-validator": {
      "model": "anthropic/claude-sonnet-4-20250514"
    },
    "sdlc-architect": {
      "model": "anthropic/claude-sonnet-4-20250514"
    },
    "sdlc-planner-stories": {
      "model": "http://localhost:1234/v1/qwen3.5-35b-a3b"
    },
    "sdlc-planner-hld": {
      "model": "http://localhost:1234/v1/qwen3.5-35b-a3b"
    },
    "sdlc-planner-api": {
      "model": "http://localhost:1234/v1/qwen3.5-35b-a3b"
    },
    "sdlc-planner-data": {
      "model": "http://localhost:1234/v1/qwen3.5-35b-a3b"
    },
    "sdlc-planner-security": {
      "model": "http://localhost:1234/v1/qwen3.5-35b-a3b"
    },
    "sdlc-planner-devops": {
      "model": "http://localhost:1234/v1/qwen3.5-35b-a3b"
    },
    "sdlc-planner-design": {
      "model": "http://localhost:1234/v1/qwen3.5-35b-a3b"
    },
    "sdlc-planner-testing": {
      "model": "http://localhost:1234/v1/qwen3.5-35b-a3b"
    },
    "sdlc-documentation-writer": {
      "model": "http://localhost:1234/v1/qwen3.5-35b-a3b"
    },
    "sdlc-implementer": {
      "model": "http://localhost:1234/v1/qwen3-coder-30b-a3b"
    },
    "sdlc-code-reviewer": {
      "model": "http://localhost:1234/v1/qwen3-coder-30b-a3b"
    },
    "sdlc-qa": {
      "model": "http://localhost:1234/v1/qwen3-coder-30b-a3b"
    },
    "sdlc-acceptance-validator": {
      "model": "http://localhost:1234/v1/qwen3-coder-30b-a3b"
    },
    "sdlc-project-research": {
      "model": "http://localhost:1234/v1/qwen3-coder-30b-a3b"
    }
  }
}
```

### Mode-Level Configuration (.kilocodemodes)

Alternatively, specify models directly in custom mode definitions:

```yaml
customModes:
  - slug: sdlc-coordinator
    name: 👔 SDLC Coordinator
    model: anthropic/claude-sonnet-4-20250514
    # ... other configuration
```

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

## API Timeout Configuration

Both Kilo Code and Roo Code require proper timeout configuration when using local models, especially for complex tasks that may take longer than the default timeout periods.

### Kilo Code Timeout Settings

**Current Status (2026)**: Kilo Code had hardcoded timeout issues that have been resolved in recent versions.

**Historical Issues**:
- **300-second API timeout**: Previously hardcoded for Ollama/LM Studio requests (fixed in v4.72.0+)
- **60-second embedding timeout**: Affected codebase indexing (fixed via PR #3807)

**Configuration**: 
- **API Request Timeouts**: Configurable through Kilo Code's internal settings system via the `getApiRequestTimeout` helper function, but **exact configuration method is not clearly documented**
- **Settings Management**: Use the settings gear icon (⚙️) in Kilo Code chat view to access timeout configuration options
- **MCP Server Timeouts**: Can be configured in `kilo.json`:

```json
{
  "mcp": {
    "my-server": {
      "type": "local",
      "command": ["npx", "-y", "my-mcp-command"],
      "timeout": 10000
    }
  }
}
```

**Configuration Status**: 
- **Fixed Issues**: Hardcoded timeouts removed in v4.72.0+ (API requests) and via PR #3807 (embeddings)
- **Current State**: The `getApiRequestTimeout` helper function reads from user settings, but the specific setting name/location is not publicly documented
- **Access Method**: Timeout settings are managed through Kilo Code's built-in settings interface, not `kilo.json`

### Roo Code Timeout Settings

**VSCode Setting**: `roo-cline.apiRequestTimeout`
- **Default**: 600 seconds (10 minutes)
- **Range**: 0-3600 seconds 
- **Special value**: 0 = disables timeout entirely

**Configuration**:
```json
{
  "roo-cline.apiRequestTimeout": 1800
}
```

**Why It May Not Work**: Earlier versions had underlying `undici` bodyTimeout issues that prevented the setting from taking effect. Recent versions (2025+) include fixes for:
- Custom fetch implementation to override undici's bodyTimeout
- Proper timeout=0 behavior (sets to maximum safe integer)
- OpenAI-compatible provider timeout support

### Recommended Timeout Values

| Model Type | Recommended Timeout | Rationale |
|------------|-------------------|-----------|
| **Local-Planning** (qwen3.5-35b) | 1200-1800s (20-30 min) | Complex planning tasks, template generation |
| **Local-Coder** (qwen3-coder-30b) | 900-1200s (15-20 min) | Code generation, review cycles |
| **Commercial Models** | 300-600s (5-10 min) | Faster response, shorter tasks |

**For Large Models on Slower Hardware**:
- CPU-only inference: 2400s (40 min) or more
- GPU/CPU split processing: 1800s (30 min)
- Complex refactoring tasks: Consider timeout=0 (unlimited)

### Troubleshooting Timeout Issues

1. **Kilo Code**: 
   - Ensure you're running v4.72.0+ where hardcoded timeouts were removed
   - Configure timeouts via the settings gear icon (⚙️) in Kilo Code chat view
   - The exact setting name is not documented - look for timeout/request-related options
   - If still experiencing timeouts, try exporting/importing settings or check for newer versions

2. **Roo Code**: 
   - Use VSCode setting: `"roo-cline.apiRequestTimeout": 1800`
   - Must be set in VSCode settings, not project-level configuration
   - Value is in seconds (0 = unlimited)

3. **Both**: 
   - Monitor LM Studio logs for actual processing time vs timeout duration
   - Test with simple tasks first to verify timeout configuration is working

4. **Key Difference**: 
   - **Kilo Code**: Configurable through built-in settings interface (setting name undocumented)
   - **Roo Code**: Requires explicit VSCode setting configuration

### How to Configure `getApiRequestTimeout` in Kilo Code:

**Current Status**: The `getApiRequestTimeout` helper function is internal to Kilo Code and reads from user settings, but the exact configuration method is not publicly documented.

**Steps to Try**:
1. Open Kilo Code chat view
2. Click the settings gear icon (⚙️) 
3. Look for timeout, request timeout, or API timeout settings
4. Alternatively, try the settings export/import feature to see available configuration options
5. If no timeout settings are visible, they may be automatically managed in recent versions

**Note**: This is a known limitation in Kilo Code's documentation. The setting exists (confirmed by GitHub issues and PRs) but isn't clearly exposed in public documentation.