# P6: Type Safety & Error Recovery Patterns

**Status:** Resolved — reasoning directive landed in implementer agent; pattern library and escalation ladder declined in favour of existing infrastructure.
**Relates to:** [P4 (Documentation Lookup)](./P4-documentation-lookup-strategy.md), [P5 (Testing Strategy)](./P5-testing-strategy-scaffold-verification.md)
**Scope:** `opencode/.opencode/agents/sdlc-engineering-implementer.md` (Self-Verification section, reasoning directive added)
**Transcript evidence:** `ses_278b8ce55ffeKxlkK4NQaSyTHd` — Lines ~55100-55330, 4 typecheck iterations on `InstallabilityWindowLike` type; Lines ~14900-15500, CSS test approach iteration

---

## 0. Current Status (2026-04-17)

### What prior proposals addressed

**P3 (silent verification) reduced token cost per iteration, not iteration count.**
A passing `verify:full` now produces ~10 tokens instead of ~500. That helps when gates pass. When gates fail the failing output is still printed in full and the agent still iterates. The core problem P6 identified — compile-fix-compile loops on type errors — is a reasoning-discipline problem that P3 cannot touch.

**P5 (testing strategy) resolved the test-failure side of this problem.**
P5 added a dedicated escalation protocol to the implementer's Test Writing section: stop after 2 failures on the same assertion, apply the Anti-Pattern 0 gate, consult `test-patterns.md`, try fundamentally different approaches, HALT after 3. That covers the CSS test iteration from the transcript (§1.2 below).

**P4 (gotcha classification) handles stack-specific type patterns.**
The P4 pipeline gives implementers a structured way to record unexpected cross-library interactions (`skill-gotchas.md` sibling), which a human reviews post-run and may promote into per-stack references like `react-vite.md`. Stack-specific TypeScript mocking patterns (e.g., `Partial<Navigator>`) belong in that pipeline, not in an agent prompt.

### What this proposal resolves

**A single language-agnostic reasoning directive added to the Self-Verification section of the implementer agent.** The directive instructs the agent to read the full gate output, enumerate all simultaneous constraints, and design the fix before writing any patch. This addresses the root cause of the 4-cycle `InstallabilityWindowLike` loop without duplicating P5's test-runner escalation or P4's gotcha pipeline.

### What was explicitly declined

- **A per-error-count escalation ladder** (§3.2 in the original proposal) — redundant with the existing `max 2 cycles` gate cap and P5's test-failure escalation. The reasoning directive plus its root-cause-aware stopping sentence covers the same ground without a new count-based rule.
- **A known type patterns reference** (§3.3 in the original proposal) — stack-specific fixes (e.g., `Partial<Navigator> & { prop?: type }`) belong in P4's gotcha pipeline, not in an agent prompt or skill. Enshrining one bug's workaround as a permanent pattern over-specifies the agent and will drift as stacks evolve.

---

## 1. Problem Statement

The transcript shows a recurring pattern: the implementer writes code, runs the type checker, gets a type error, patches the first visible error, re-runs, gets a different error from the same root cause, patches again. This "compile-fix-compile" loop burns tool calls and tokens on problems that are solvable in one pass with upfront reasoning.

### 1.1 InstallabilityWindowLike type iteration (4 cycles)

```
Attempt 1: navigator?: { standalone?: boolean }
  → TS2345: Window not assignable to InstallabilityWindowLike

Attempt 2: navigator?: Navigator & { standalone?: boolean }
  → TS2352: test mock {} can't satisfy Navigator (210+ required properties)

Attempt 3: as Parameters<typeof bindInstallabilitySignals>[0]
  → TS2352: still can't satisfy Navigator intersection

Attempt 4: navigator?: Partial<Navigator> & { standalone?: boolean }
  → PASS
```

Each attempt was a full cycle: reason → patch → run typecheck → read error → reason → patch → run typecheck. The correct answer was reachable from the first error message if the agent had enumerated all simultaneous constraints (production code shape, test mock shape, call-site expectations) before writing the first patch.

### 1.2 CSS test approach iteration (4+ cycles)

This problem class — trial-and-error on test approach rather than type constraints — is already resolved by P5's test-failure escalation protocol (stop after 2 failures on the same assertion, consult `test-patterns.md`, try a fundamentally different approach, HALT after 3). Not addressed further here.

---

## 2. Root Cause

### 2.1 Missing "reason before patching" discipline

The implementer agent is optimised for throughput: write code → run checks → fix → repeat. This works when each check catches one issue and the fix is obvious. It breaks down when:
- A gate error is one visible symptom of a multi-constraint root cause.
- The full gate output (chained diagnostics, multiple errors) contains all the information needed for a one-pass fix.
- Patching the first diagnostic introduces a second error from the same root cause (different surface, same mistake).

The correct intervention is not a stopping rule — it is a reasoning instruction issued before the patch is written.

### 2.2 Stack-specific pattern library — declined

The original proposal identified "missing pattern library for browser global mocking" as a root cause. This is declined as a P6 concern. Stack-specific patterns are ephemeral (they change with library versions), project-specific (not all projects use the same browser globals), and already handled by P4's gotcha-classification pipeline. When an implementer encounters a novel mocking pattern during a run, it records a technical gotcha entry in the `skill-gotchas.md` sibling. A human reviews it post-run. If the pattern recurs across stories, it is promoted into the appropriate per-stack reference.

---

## 3. Proposed Solution

### 3.1 Deterministic-Gate Reasoning Directive

Add to the implementer agent's Self-Verification section, immediately before the `max 2 cycles` stopping rule:

> **Reason before patching a gate failure.** When a deterministic gate (typecheck, lint, build, schema validation) fails, read the full gate output before editing. Enumerate every constraint the fix must satisfy simultaneously — existing call sites, test mocks, public signatures, downstream consumers of any changed interface. Design the fix to satisfy all constraints at once, in reasoning, before writing the patch. Target zero re-runs per root cause. If a second patch at the same root cause still fails, the root cause is not what you thought — stop patching and re-analyse source files before attempting a third patch. For test-runner failures, use the dedicated escalation in the Test Writing section, not this rule.

**Why this is language-agnostic:** The rule applies equally to `tsc`, `mypy`, `rustc`, `go build`, `eslint`, `ruff`, or any tool whose output describes constraints the fix must satisfy. It makes no reference to TypeScript syntax, browser globals, or any specific error message format.

**Why the final sentence matters:** P5's test-failure escalation is a separate ladder with different stopping criteria (behavioural vs. source-artifact checks, `test-patterns.md` lookup, HALT after 3 approaches). Explicitly pointing test-runner failures there prevents the two rules from competing.

---

## 4. Affected Agents and Skills

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | Modified | Self-Verification section: new step before `max 2 cycles` rule — deterministic-gate reasoning directive |

---

## 5. Expected Impact

| Metric | Before | After |
|--------|--------|-------|
| Re-runs per root cause (type/lint/build) | 3-4 (patch first visible error, surface new error, repeat) | 1-2 (full output read, constraints enumerated before patch) |
| Tool calls per type fix | 8-12 (patch + typecheck × 4) | 2-4 (patch + typecheck × 1-2) |

**Caveat:** A prompt directive changes the agent's reasoning frame but does not guarantee elimination of reactive patching. The impact depends on how reliably the directive fires and how accurately the agent enumerates constraints from the error output. This is a best-effort improvement, not a hard guarantee. If repeated regressions are observed in post-run transcripts, escalate to a more structural enforcement mechanism (e.g., a required pre-patch reasoning step encoded as an explicit tool-use sequence).

---

## 6. Open Questions

1. **How to enforce "reason before patching" more reliably?** LLM agents are trained toward action. A text directive is the lowest-overhead mechanism; it may not change behaviour on every trigger. A stronger option: encode the constraint-enumeration step as an explicit bash-equivalent (e.g., write a brief analysis to the staging doc before any file edit on a gate failure). This adds overhead on every gate failure but makes the reasoning step observable and auditable.
