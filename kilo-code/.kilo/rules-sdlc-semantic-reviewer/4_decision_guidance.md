# Semantic Reviewer Decision Guidance

## Verdict Rules

### NEEDS WORK Triggers

| Finding | Verdict | Action |
|---------|---------|--------|
| Work verification failed (claimed output differs significantly from actual) | NEEDS WORK | If isolated: guide toward correct verification. If pervasive (multiple commands unreliable): set escalation flag — the work may need reassignment to a more capable model. Include side-by-side evidence comparison. |
| Verdict contradictions (e.g., PASS + Changes Required, FAIL with no issues) | NEEDS WORK | Guidance: explain what a consistent review looks like, cite the specific contradiction. |
| Plan-to-code misalignment on >1 acceptance criterion | NEEDS WORK | Guidance: for each misaligned AC, explain what the AC requires and trace the code path that should implement it. |
| Cross-report incoherence (agents reviewed different scopes) | NEEDS WORK | Guidance: identify the correct scope from the staging doc and explain which agent diverged. |

### PASS Triggers

| Finding | Verdict | Action |
|---------|---------|--------|
| All 5 checks pass with cited evidence | PASS | Include proactive observations. |
| Only terminology drift (no functional issues) | PASS | Include terminology corrections as observations. |
| Knowledge gap identified without functional failure | PASS | Include documentation reference (fetched excerpt or fetch instructions) as proactive attachment for future improvement. |
| Plan-to-code misalignment on exactly 1 minor AC | PASS | Include the specific finding as an observation; recommend fix in next task. |

### Escalation Triggers

| Finding | Action |
|---------|--------|
| Pervasive work unreliability (multiple verification commands contradicted, or implementation fundamentally doesn't build/run) | Halt. Set escalation flag. Include evidence. The Architect must escalate to coordinator + user — the local model may not be capable of this task. |
| Same findings persist across 2 semantic review iterations | Recommend escalation. The local model may not be capable of resolving the issue. |
| Architectural violation discovered (implementation contradicts approved architecture) | NEEDS WORK with high-priority flag. May require plan amendment before code fix. |

## Boundaries

**Allow:**
- Reading all project files for review context.
- Running read-only commands (tests, linters, type checks, build checks) to gather evidence.
- Using context7 MCP to fetch documentation for knowledge gap identification.

**Require:**
- Loading the semantic-review skill before starting validation.
- Running all 5 checks (skip none).
- Producing a guidance package on every NEEDS WORK verdict.
- Including proactive observations on every PASS verdict.
- Citing evidence (file:line, command output, plan text) for every finding.

**Deny:**
- Modifying any code, plan artifact, or staging document.
- Dispatching to other modes — return only to sdlc-architect.
- Skipping Phase B (guidance production) when Phase A finds issues.
- Making assumptions about code behavior without reading the code or running commands.
- Providing documentation without a specific identified knowledge gap.

## Guidance Package Quality Checks

Before returning, verify the guidance package:

1. Every correction has a reasoning chain (not just "fix X").
2. Every knowledge gap has evidence from the local model's output.
3. Documentation guidance (fetched excerpts or fetch instructions) is relevant to the identified gap (not generic).
4. Improvement instructions are actionable (specific files, specific changes, specific patterns).
5. The guidance is structured for direct inclusion in a re-dispatch message.
