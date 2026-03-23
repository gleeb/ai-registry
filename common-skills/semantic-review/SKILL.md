---
name: semantic-review
description: >
  Use when the sdlc-semantic-reviewer needs to validate local model outputs
  and review code quality as a senior developer. Provides a 3-check validation
  process (agent report integrity, code quality review, terminology alignment),
  agent report integrity rules, code quality review protocol, and structured
  guidance package format.
---

# Semantic Review

## Overview

Commercial-model senior-developer review skill for the execution phase. Validates local model outputs and reviews the actual implementation quality after story-level integration. Produces structured guidance packages that propagate commercial-grade reasoning back into local model re-dispatches.

**Core principle:** The commercial model's intelligence should not stop at a verdict. It should flow through the feedback loop — reasoned corrections, identified knowledge gaps, and documentation guidance (fetched excerpts or instructions for the local model to fetch itself) — so the local model's next attempt starts from a stronger position.

## Layered Input Strategy

The semantic reviewer uses multiple inputs, each serving a distinct purpose:

- **Git diff** — scoping: identifies which files were changed during the execution cycle
- **Staging document** — context: provides task decomposition, architecture decisions, file references, and what to look for
- **Actual code drill-down** — the real review: read full implementation files, trace logic paths, reason about behavior
- **Verification command execution** — evidence: re-run commands fresh to confirm the work holds up

Git diff and staging doc tell the reviewer WHERE to look and WHAT was planned. The actual validation is done by drilling into the code and reasoning about it as a senior developer.

## When to Use

- Dispatched by sdlc-architect in Phase 3b (after story integration, before acceptance validation)
- The story has completed all per-task dev loops and the full-story review + QA
- All local model outputs (implementer summaries, review verdicts, QA verdicts) are available in the dispatch

## Mentor Philosophy

1. **Validate first** — run all 3 checks with Reality Checker defaults (NEEDS WORK until proven PASS).
2. **Full sweep, not sampling** — review ALL changed files, ALL acceptance criteria, ALL domain terms. No sampling.
3. **Guide on failure** — don't just flag issues; reason about the better result, identify what the local model is missing, and provide the knowledge it needs (either by fetching docs directly or by giving specific fetch instructions for the local model to retrieve via context7).
4. **Observe on success** — even on PASS, note what could be better for future iterations.
5. **Propagate through re-dispatch** — guidance packages are structured for direct inclusion in implementer re-dispatch messages.

## Two-Phase Process

### Phase A: Validation

Three checks, each defaulting to NEEDS WORK:

1. **Agent Report Integrity** — detect contradictions in local review/QA self-reports AND verify all agents worked on the same scope (internal consistency + cross-agent coherence)
2. **Code Quality Review** — full senior-developer review of the story's implementation: drill into every changed file, assess code quality and patterns, verify each AC is semantically implemented, re-run all verification commands fresh
3. **Terminology and Contract Alignment** — full sweep of ALL domain terms from contracts/architecture/story against changed files; detect naming drift

See [`references/semantic-review-checklist.md`](references/semantic-review-checklist.md) for detailed procedures.

### Phase B: Guidance Production

On NEEDS WORK: produce a full guidance package.
On PASS: produce proactive observations.

See [`references/guidance-package-format.md`](references/guidance-package-format.md) for the structured output format.

## References

- [`references/semantic-review-checklist.md`](references/semantic-review-checklist.md) — Detailed procedures for all 3 checks
- [`references/verdict-consistency-rules.md`](references/verdict-consistency-rules.md) — Agent report integrity rules (contradiction patterns + cross-agent coherence)
- [`references/evidence-verification-protocol.md`](references/evidence-verification-protocol.md) — Code quality review protocol (layered review procedure, verification, discrepancy analysis)
- [`references/guidance-package-format.md`](references/guidance-package-format.md) — Structured guidance output format
