---
name: semantic-review
description: >
  Use when the sdlc-semantic-reviewer needs to validate local model outputs
  and produce guidance packages for re-dispatch. Provides the 5-check validation
  process, verdict consistency rules, evidence verification protocol, and
  structured guidance package format.
---

# Semantic Review

## Overview

Commercial-model mentor skill for the execution phase. Validates local model outputs (implementer, code reviewer, QA verifier) after story-level integration, and produces structured guidance packages that propagate commercial-grade reasoning back into local model re-dispatches.

**Core principle:** The commercial model's intelligence should not stop at a verdict. It should flow through the feedback loop — reasoned corrections, identified knowledge gaps, and documentation guidance (fetched excerpts or instructions for the local model to fetch itself) — so the local model's next attempt starts from a stronger position.

## When to Use

- Dispatched by sdlc-architect in Phase 3b (after story integration, before acceptance validation)
- The story has completed all per-task dev loops and the full-story review + QA
- All local model outputs (implementer summaries, review verdicts, QA verdicts) are available in the dispatch

## Mentor Philosophy

1. **Validate first** — run all 5 checks with Reality Checker defaults (NEEDS WORK until proven PASS).
2. **Guide on failure** — don't just flag issues; reason about the better result, identify what the local model is missing, and provide the knowledge it needs (either by fetching docs directly or by giving specific fetch instructions for the local model to retrieve via context7).
3. **Observe on success** — even on PASS, note what could be better for future iterations.
4. **Propagate through re-dispatch** — guidance packages are structured for direct inclusion in implementer re-dispatch messages.

## Two-Phase Process

### Phase A: Validation

Five checks, each defaulting to NEEDS WORK:

1. **Verdict Consistency** — detect contradictions in local review/QA self-reports
2. **Work Verification** — independently re-run 2-3 verification commands to confirm the work holds up
3. **Plan-to-Code Spot-Check** — trace 2-3 ACs through actual code to verify semantic implementation
4. **Terminology Consistency** — compare domain terms in code vs plan/contracts
5. **Cross-Report Coherence** — verify all agents worked on the same scope

See [`references/semantic-review-checklist.md`](references/semantic-review-checklist.md) for detailed procedures.

### Phase B: Guidance Production

On NEEDS WORK: produce a full guidance package.
On PASS: produce proactive observations.

See [`references/guidance-package-format.md`](references/guidance-package-format.md) for the structured output format.

## References

- [`references/semantic-review-checklist.md`](references/semantic-review-checklist.md) — Detailed procedures for all 5 checks
- [`references/verdict-consistency-rules.md`](references/verdict-consistency-rules.md) — Enumeration of contradiction patterns
- [`references/evidence-verification-protocol.md`](references/evidence-verification-protocol.md) — How to independently verify the local model's work holds up
- [`references/guidance-package-format.md`](references/guidance-package-format.md) — Structured guidance output format
