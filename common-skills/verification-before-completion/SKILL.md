---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing — requires running verification commands and confirming output before making any success claims; prevents false completion claims through evidence-based verification gates.
---

# Verification Before Completion

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this session, you cannot claim it passes.

## Verification Tiers

For projects with `scripts/verify.sh` (scaffolded via the SDLC pipeline), use the appropriate tier:

| Tier | Command | Used by | What it runs |
|------|---------|---------|-------------|
| `verify:full` | `npm run verify:full` (JS/TS) or `bash scripts/verify.sh full` (Python) | Implementer, QA, hub self-implementation | lint + typecheck + test (with coverage) + build |
| `verify:quick` | `npm run verify:quick` (JS/TS) or `bash scripts/verify.sh quick` (Python) | Code Reviewer | lint + typecheck + test (no coverage, no build) |

**Silent mode:** Both scripts are silent on success. If the command prints `=== ALL GATES PASSED ===` and exits 0, that is your verification evidence — paste it. If it prints output before exiting non-zero, a gate failed — read the output, fix the issue, re-run.

**No project verify script?** Fall back to the individual commands (lint, typecheck, test, build). The individual commands must still be run — claiming they pass without running them is a violation.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: Which tier applies? (full = implementer/QA, quick = reviewer)
2. RUN: Execute npm run verify:full / verify:quick (or bash scripts/verify.sh)
3. READ: Did it print "ALL GATES PASSED"? Or did it print a failure?
4. VERIFY: Does output confirm the claim?
   - If "ALL GATES PASSED": claim is substantiated — use that line as evidence
   - If gate failed: state the failure with the output, do NOT claim success
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | `npm run verify:full` or `verify:quick`: `ALL GATES PASSED` | Previous run, "should pass", implementer's word |
| Tests exist for new code | Test files present for each new/modified source module | No test files, empty test files, or trivial assertions |
| Linter clean | `verify:quick` passed (lint gate) | Partial check, extrapolation |
| Build succeeds | `verify:full` passed (build gate) | Linter passing, logs look good |
| Browser loads without errors | Dev server started, PinchTab navigates key routes, no console errors (web app stories) | Build passing, code looks correct |
| Coverage meets threshold | `verify:full` passed (coverage gate via vitest thresholds config) | "I wrote tests" without running `verify:full` |
| Negative paths tested | Error/validation ACs have at least one failure-case test (invalid input, error response, boundary) | Only happy-path tests for all ACs |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Requirements met | Line-by-line checklist | Tests passing |
| Browser loads without errors (web apps) | Dev server started, PinchTab navigated to key routes, no console errors, expected content present | Build passing, tests passing, code looks correct |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!")
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- ANY wording implying success without having run verification

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence is not evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter is not compiler — run `verify:quick` |
| "Agent said success" | Verify independently with `verify:full` |
| "Partial check is enough" | Partial proves nothing — run the full tier |
| "`verify:full` is slow" | It's silent; ~50 tokens on success — no reason to skip |

## When to Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- Committing, PR creation, task completion
- Moving to next task
- Return your final summary to the parent agent

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.
