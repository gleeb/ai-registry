# Review Cycle Rules

## Per-Task Cycle

```
implement → test-gate → coverage-gate → code-review → security-review (conditional) → qa → (pass) → DONE
                                           ↓ (fail, iter 1-3)                              ↓ (fail)
                                     re-implement (verbatim feedback)                 re-implement
                                           ↓ (fail, iter 3+ same defect)             (max 2 retries)
                                     diagnostic analysis → self-implement or guided re-dispatch
                                           ↓ (iter 5 hard ceiling)
                                     architect self-implements → continues to review/QA
```

### Security Review Integration

The security review is part of the code review step, not a separate dispatch. When `SECURITY_REVIEW: true` is set in the reviewer dispatch:

1. The code reviewer loads `skills/security-review/` during review.
2. The reviewer adds a `## Security Review` section to the review output.
3. Security findings are categorized alongside standard code review findings.
4. Critical security findings cause the same "Changes Required" verdict as critical code issues.

**When to enable**: Set `SECURITY_REVIEW: true` when:
- Story has `security` in `candidate_domains`
- Task touches authentication, authorization, or session management
- Task handles user input (forms, API parameters, file uploads)
- Task accesses or modifies data storage
- Task involves secrets, tokens, or credential handling

## Iteration Limits

| Gate | Max Iterations | On Limit Reached |
|------|---------------|------------------|
| Code Review (incl. security) | Adaptive (see below) | Adaptive Recovery Protocol — architect self-implements after diagnostic analysis. Never blocks. |
| QA Verification | 2 failures | Mark task BLOCKED. Return to coordinator with QA failure evidence. |
| Story Review (Phase 3) | 3 Changes Required | Escalate per "Story-Review Cap" below. Write planning-gotchas entry. Never user-escalate. Never dispatch a standard 4th iteration. |
| Semantic Review (Phase 3b) | 2 NEEDS WORK | Escalate to coordinator. Include both review reports and all guidance packages. |

## Story-Review Cap (Phase 3)

The `sdlc-engineering-story-reviewer` has a hard cap of **3 Changes Required** verdicts per story. After the 3rd, the hub MUST NOT dispatch a 4th standard story-review round.

**Required dispatch metadata (every story-review dispatch):**
- `STORY REVIEW ITERATION: N` (starting at 1).
- From iteration 2 onward: `PRIOR STORY REVIEW (iteration N-1):` with the prior report verbatim (no summarization — the reviewer needs it for the New-vs-Rediscovered Audit).

**Required reviewer output (every iteration):**
- **Review Coverage Matrix** — hardcoded minimum lenses (spec compliance, cross-task integration seams, full-story AC coverage and traceability, security controls uniformity, payload/input-boundary edges, error-path and negative-case tests, automated checks, docs and staging-doc consistency, comment policy) plus story-specific lenses derived from plan artifacts. Every row is either `findings: [...]` or `no findings: [one-line rationale]`. Bare `no findings` without rationale is a protocol violation.
- **New-vs-Rediscovered Audit** (iteration ≥ 2 only, for findings in code unchanged since N-1) — each such finding tagged and justified, or downgraded to Suggestion-class.

**Verdict rules:**
- Iteration 1 with Suggestion-only findings → Changes Required (graduated rule — cost of addressing is low, we are already in the loop).
- Iteration ≥ 2 with Suggestion-only findings → Approved.
- Any Critical or Important → Changes Required.

**Escalation routing at the cap (after 3rd Changes Required):**
- **Integration / complexity / external-API / platform-capability findings** → dispatch `@sdlc-engineering-oracle` with the full iteration chain. Oracle returns FIX (apply, verify, closing architect-verified story-review pass) or ESCALATION REPORT (return to coordinator, Tier 4).
- **Code-quality / pattern-consistency / cross-task-refactor findings** → architect self-implements at story scope (`architect-implemented (story-scope)`), runs verify, then ONE closing architect-verified story-review pass.
- **Mixed** → Oracle subset first; architect-self subset in parallel if independent, serial otherwise.

**Planning-gotchas write (required on cap trigger):**
At the moment the cap triggers, append a structured entry to `docs/staging/US-NNN-name.planning-gotchas.md` per the schema in `.opencode/skills/project-documentation/references/planning-gotchas-template.md`. Fill `runtime_resolution` after the escalation resolves. The hub only writes this file; it does NOT read, roll up, or otherwise consume it during the run. Post-run evaluation and any promotion back into planning agents/skills is a separate out-of-band process.

**DENY:**
- 4th standard story-review round after 3 Changes Required verdicts.
- User escalation for story-review iteration caps (Review Milestones and Oracle ESCALATION REPORTs are the only user-pause paths).

## Situational References

Load these only when the situation arises. Do NOT load all at once.

| Reference | Load when |
|-----------|-----------|
| [`review-gates.md`](review-gates.md) | Before first review dispatch (test existence + coverage gates) |
| [`adaptive-recovery.md`](adaptive-recovery.md) | On review iteration 3+ or when self-implementation is needed |
| [`re-dispatch-patterns.md`](re-dispatch-patterns.md) | On any review/QA/semantic failure requiring re-dispatch |

## Status Tracking

Update the staging document task checklist after each dispatch cycle:

| Status | Meaning |
|--------|---------|
| `pending` | Not yet started |
| `in-progress` | Implementer dispatched, cycle active |
| `done` | QA verification passed |
| `blocked` | QA limit reached, escalated (never for review iterations) |

Track per task:
- Review iteration count (0+, no hard max — adaptive recovery applies)
- QA retry count (0-2)
- Last review verdict summary
- Last QA verdict summary
- Recovery method: `implementer` | `architect-implemented` (when self-implementation was used)

## Doc-Only Changes

Changes that ONLY modify documentation files (`docs/staging/*.md`, `docs/**/*.md`) and do not touch any source code:

- Do NOT require code review dispatch.
- Do NOT require QA verification dispatch.
- The architect applies them directly and logs the change in the staging document.
- This reduces a 3-dispatch cycle to a single edit.

## Resume Support

On resume (Phase 0), the architect reads the staging document and:
- Finds the last task with status `done`
- Identifies the next task with status `pending` or `in-progress`
- Continues the cycle from that point
- All context comes from the staging doc, not session memory
