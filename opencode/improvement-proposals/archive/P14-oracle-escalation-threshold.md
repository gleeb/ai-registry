# P14: Count-Based Oracle Escalation on Complex Browser/Integration Work

**Status:** Implemented — 2026-04-26 (drafted 2026-04-18; amended 2026-04-22 — trigger 5 added per P21; revised 2026-04-26 — cost-arithmetic framing removed, cross-cutting governors added; landed 2026-04-26)
**Relates to:** [P6 (Type Safety & Error Recovery)](./P6-type-safety-and-error-recovery.md), [P10 (Story-Reviewer Severity Guard)](./P10-story-reviewer-severity-guard.md), [P20 (External Integration Contract Verification)](../P20-external-integration-contract-verification.md), [P21 (User-Reported Check / Defect Triage)](../P21-user-reported-check-defect-triage.md) — P6 introduced Oracle escalation as a pattern; P10 creates the iteration cap that triggers it; P14 specifies the thresholds; P21 supplies the defect-incident trigger (§3 trigger 5)
**Scope:** `opencode/.opencode/agents/sdlc-engineering.md` (hub escalation policy), `opencode/.opencode/agents/sdlc-engineering-oracle.md`, Oracle dispatch contract. **All routing logic lives in the hub.** Implementer and reviewer agents are deliberately **not** modified by this proposal — they have no awareness of Oracle and no role in the escalation decision (see §2.5).
**Transcript evidence:** `ses_26105317cffeCAev1W8UP3BtK1` — US-003 Task 4 (PWA installability + browser evidence) accumulated **~45 context7/Tavily queries** in a single task, and triggered 3 implementer re-dispatches (task-level) plus contributed to 2 of the 4 story-review iterations. Oracle was never invoked; the fallback was "more context7 queries + more implementer retries." Net: the cheapest-model path was used for the hardest technical problem. Additional evidence (2026-04-22 amendment): `ses_24a319c81ffelunHGnCfk7KcBT` — US-004 shipped with a wrong OAuth mechanism against the OpenRouter API; when the defect surfaced, the engineering hub handled it via ordinary implementer retry rather than routing to Oracle. External-contract mismatches are precisely the analytical shape where Oracle's breadth pays off, and P21's defect-incident lifecycle is now the structural trigger that sends them there.

---

## Read Order

**Prerequisites** (read / land first):
- **P6** (archived) — introduced the Oracle pattern originally. P14 generalizes it; read P6 for the base concept.
- **P10** (archived) — the story-reviewer iteration cap that produces the escalation events triggers 1–2 consume.
- **P15** — supplies the planner-side task-shape / risk annotations consumed by trigger 3 (proactive preauthorize).
- **P20** (2026-04-22 amendment) — the `api.md.wire_format` block is how trigger 5 identifies external-integration defect incidents.
- **P21** (2026-04-22 amendment) — introduces the `defect-incident` lifecycle that trigger 5 fires on.

**Consumers** (depend on this proposal):
- **P21** — defect incidents dispatch Oracle via trigger 5; P21 reads P14 to understand when that happens.
- **P17** — ceremony scaling on high-risk tasks aligns with Oracle's preauthorize flag (trigger 3).
- **P18** — phase-boundary mode interacts with Oracle dispatch budget; P18's worst-case sub-session caps make over-dispatch less dangerous.

**Suggested batch reading order** (2026-04-22 cluster): P19 → P20 → P16 (amended §3.5) → P21 → **P14 (you are here; amended trigger 5)** → P22.

---

## 1. Problem Statement

Oracle (a premium-model escalation route, described in P6) exists for high-stakes technical questions that the per-task implementer cannot reliably answer from docs alone. In the current engineering pipeline, **Oracle is never triggered for a technical complexity reason** — only for severity escalations on already-broken code.

The failure mode is visible in US-003 Task 4:
- Task topic: PWA installability acceptance evidence via browser automation (CDP triggering `beforeinstallprompt`, Playwright assertions across Chromium/Edge/Firefox with browser-specific capability differences, service-worker registration timing).
- Implementer attempted solution → failed → queried context7 → tried again → failed → queried Tavily → tried again → asked story-reviewer → failed → queried context7 again, etc.
- Task consumed most of the ~45 doc queries observed in US-003.
- Eventually "solved" via a workaround (fallback banner + skipping some browser assertions) that acceptance-validator later tried to remediate over 7 hours.

An early Oracle dispatch (after the first default cycle) with the combined context (implementer's failed attempts + cache + AC + Playwright/CDP constraints) would likely have produced a working approach with far fewer total dispatches across the pipeline (implementer retries, reviewer iterations, doc queries). The exact cost comparison is **not computable inside the hub** — different agents run on different model tiers, and there is no model→cost registry or post-run cost feedback hook plumbed into dispatch metadata. This proposal therefore does not rely on cost arithmetic; it routes on counts and structural signals only.

## 2. Root Cause Analysis

### 2.1 Oracle is defined but not routed
P6 introduced Oracle as an escalation path for specific severity-escalation scenarios (repeated similar bugs, type-system deadlocks). There is no routing rule that says "if doc-query count exceeds X for this task, or if implementer retries exceed Y, or if the task shape is <browser-evidence | CDP | cross-browser>, escalate to Oracle."

### 2.2 The hub does not evaluate count signals before re-dispatching
Each implementer dispatch happens in isolation: the hub re-dispatches "the next attempt" without checking whether cumulative counters (attempts, doc queries, reviewer iterations) on this task have crossed an escalation threshold. The signals exist in dispatch metadata; the hub simply does not act on them. This is a hub orchestration gap — not a worker-prompt gap. The fix lives entirely in the hub.

> **Why counts, not cost.** This proposal deliberately does not use token or dollar cost as the routing signal. The hub has no model→cost registry, agents in the pipeline run on heterogeneous model tiers (implementer/reviewer may be 10× to 1000× cheaper per token than a top-tier Oracle, or in some "pro" configurations the inverse), and there is no plugin/hook that feeds post-run cost back into dispatch metadata. Counts (queries, attempts, iterations) are the only honest unit available inside the current hub, and the hub already observes all of them directly.

### 2.3 Task-shape signals are ignored
Some task categories predict high Oracle ROI: browser automation with timing sensitivity, service-worker lifecycle, CDP interaction, WebRTC, real-time systems, complex type-system puzzles. A task-shape heuristic could *accelerate* Oracle entry after the first default cycle (it does not replace the default cycle — see §3 cross-cutting rules).

### 2.4 Cultural reluctance toward Oracle
Oracle is perceived as expensive. We do not have data to argue with that perception (see §2.2). The mitigation is therefore **structural rather than informational**: at threshold counts the hub MUST consider Oracle (or log an explicit decline reason), and the planner can preauthorize Oracle for high-risk task shapes — but only after the default cycle has run once.

### 2.5 Separation of concerns: workers do not route
Oracle is an orchestration construct. The implementer and reviewer are worker agents whose responsibilities are scoped to their tasks (produce a diff; assess a diff). They are deliberately **not** told about Oracle's existence in this proposal, for three reasons:

1. **The hub already owns every signal.** It dispatches the implementer (so it knows attempt N), it dispatches the reviewer (so it knows iteration K), it observes tool calls (so it knows query count M). There is no information the worker holds that the hub does not. Surfacing those counters to the worker would be duplication.
2. **Worker self-assessment of escalation is structurally biased.** An implementer asked "should this go to Oracle?" has two failure modes hard to distinguish from honest answers: it says yes to offload, or it says no to seem capable. The hub's direct counter check is a stronger signal than the worker's self-report.
3. **Escalation-target swappability.** If a future proposal replaces Oracle with human review, a different tool, or pause-and-ask, only the hub changes. Hardcoding Oracle's name into worker prompts would make every escalation-target change ripple into worker specs.

The reviewer's existing job — flagging findings such as "the implementer repeatedly misuses API X across attempts 1, 2, 3" — is unchanged. The hub reads those findings as part of its routing decision; the reviewer never names Oracle.

## 3. Proposed Approach

Five layered triggers, governed by two cross-cutting rules. Trigger 5 was added 2026-04-22 per the P21 amendment. Triggers 1–4 and the cross-cutting rules were revised 2026-04-26 to remove cost-arithmetic framing and add explicit governors against Oracle abuse.

### 3.0 Cross-cutting rules (apply to triggers 1–4)

These rules exist because Oracle, if uncapped and unconditioned, becomes the hub's "easy way out" for any ambiguous failure — bypassing the cheaper agents that are likely to succeed and burning premium-model dispatch on problems they could have solved.

- **Default-cycle precondition.** Oracle MUST NOT be dispatched on a task before at least one complete `implementer → code-reviewer → QA` cycle has executed on that task within the current story. This holds **regardless of any preauthorize flag, retry count, or query count.** Triggers 1–3 fire *after* the default cycle, not in place of it. (Trigger 5 — defect-incident — is exempt because the original story execution satisfies the precondition.)
- **Per-task dispatch cap.** Oracle is dispatched at most **once per task** by default. A second Oracle dispatch on the same task is permitted only if the hub logs a justification entry stating (a) what materially changed since the prior Oracle dispatch (new failing test, new error symptom, newly available context, scope expansion approved by user), and (b) why the re-dispatch is expected to produce different output. A third Oracle dispatch on the same task is forbidden without coordinator approval.
- **Per-story soft cap.** Beyond **3 Oracle dispatches across all tasks in a story**, the SDLC coordinator is paused for review before the next dispatch. This protects against the "Oracle on everything" failure mode without blocking legitimate use.

### 3.1 The five triggers

1. **Query-budget trigger.** When the task's cumulative doc-query count (context7 + Tavily) exceeds a threshold (proposed: 8 queries for a single task) **and the default cycle has completed at least once**, the hub MUST consider Oracle before authorizing another implementer dispatch. The hub can still decline if the reason for queries is benign (e.g., broad exploration into well-cached territory), but the decline must be logged with an explicit reason.

2. **Retry-budget trigger.** When the implementer would be dispatched for the 3rd+ attempt on the same task (i.e., after the default cycle plus at least one retry), Oracle MUST be offered as an alternative. The hub's delegation contract includes Oracle selection as a first-class option at attempt 3.

3. **Task-shape trigger (accelerator, not bypass).** Planner-produced stories can annotate tasks with a `oracle_preauthorize: true` flag for task shapes known to benefit (browser automation, CDP-dependent work, service-worker lifecycle, type-system bridges with generics). See P15 for the planner-side mechanism. When the flag is present, **the default cycle still runs first** (per §3.0); after the first cycle completes without satisfying the AC, Oracle is dispatched immediately on the second attempt rather than waiting for the trigger 1 or 2 thresholds. The flag accelerates Oracle entry; it does not bypass the default cycle.

4. **Hub-internal escalation evaluation (replaces prior cost-aware framing).** Before every implementer or reviewer re-dispatch on a task that has already completed one default cycle, the hub MUST evaluate the task's per-task counters (doc queries, implementer attempts, reviewer iterations) and the most recent reviewer findings against triggers 1–3. The evaluation is hub-internal: it does **not** prompt the implementer or reviewer with counters or with an "Oracle?" question. If a trigger fires, the hub either dispatches Oracle or logs an explicit decline reason in `dispatch-log.jsonl`; in both cases the worker prompts are unchanged. (Rationale: see §2.5 on separation of concerns. The worker's job is to do the task; routing is the hub's job.)

5. **Defect-incident trigger (added 2026-04-22 per P21).** When the engineering hub opens a `defect-incident` (P21 §3.2) against a completed story, Oracle is dispatched as the **first-line investigator** — not as escalation — when any of the following apply:
   - The contradicted AC involves an external integration (the target story's `api.md` declares a `wire_format` block per P20). Rationale: external-contract mismatches are the defect shape US-004 produced, and retrying the implementer against an already-wrong contract is the failure mode P14 exists to prevent.
   - The reproduced behavior indicates a cross-cutting contract mismatch — wrong auth mechanism, wrong envelope, wrong serialization — rather than a local logic bug. Rationale: cross-cutting mismatches require holistic analysis Oracle does well and narrow-scope implementer dispatches do poorly.
   - The story's original execution consumed ≥ 8 doc queries or ≥ 3 implementer retries on the now-contradicted AC. Rationale: the original path was already in Oracle-indicative territory and the implementer's iteration budget would have escalated anyway; the defect incident is simply a second chance to make that routing decision correctly.

   For defect incidents that do NOT meet any of the above (local logic bugs, UI regressions, simple state-machine bugs), Oracle remains available via triggers 1–2 on iteration 3+ per the normal retry-budget path. The default-cycle precondition (§3.0) is considered satisfied for defect incidents because the original story execution already ran a complete cycle. The defect-incident trigger is additive, not exclusive.

### 3.2 Oracle dispatch contract (input/output)

- **Input.** Oracle dispatch MUST include: task spec, all prior implementer attempts (diffs and outputs), all prior reviewer feedback, all relevant cache entries, the failing AC and failing test name(s), the specific error symptoms, and an explicit `scope` block listing the file paths Oracle is authorized to edit.
- **Output.** Oracle returns **direct file edits scoped to the dispatched issue** (it solves; it does not merely advise). Oracle's system prompt enforces scope discipline — solve only the dispatched issue; do not refactor adjacent code; do not address issues observed outside the failing AC. Out-of-scope observations are returned as **notes** for the hub to triage (potentially as separate `defect-incident` records or follow-up tasks); Oracle does not edit out-of-scope files.
- **Verification.** After Oracle's edits, the next default-cycle pass (code-reviewer + QA) verifies the result. If the result still fails, the hub considers re-dispatch under §3.0 per-task cap rules; it does not auto-retry Oracle.

> **Scope discipline note.** This proposal enforces scope at the **prompt level only** (Oracle's system prompt is explicit and strict). No mechanical post-dispatch path-diff check is added in this revision. If observed scope creep recurs, a follow-up proposal will add mechanical enforcement (compare files-touched to the `scope` block and flag overruns as a defect-incident on Oracle itself).

## 4. Expected Impact / ROI

> **Framing note.** Impact is described in terms of **dispatches, attempts, and doc queries** — not token or dollar cost — for the reasons given in §2.2. End-to-end cost may rise, fall, or move sideways depending on the model-tier configuration in use; the hub cannot compute that today.

**Primary impact:** Reduces total dispatches on structurally hard tasks by routing them to Oracle after one default cycle, instead of looping the implementer 5+ times against a problem it cannot reliably solve. US-003 Task 4 ran 5+ implementer attempts, multiple reviewer iterations, and contributed most of ~45 doc queries. Under the revised triggers, Oracle would have been dispatched after attempt 2 (one default cycle + one retry) with full prior-attempt context — replacing roughly 3+ subsequent implementer passes with a single Oracle pass plus a verifying default cycle.

**Secondary impact:** Reduces story-review iteration count. When the task ships a coherent solution after Oracle's pass + verification cycle, story-review has less to escalate on.

**Tertiary impact:** Establishes a count-based vocabulary for "is this worth escalating?" that generalizes beyond Oracle. The same counters can later route to human review, a different tool, or a pause-and-ask — without ever needing model→cost data.

**ROI consideration:** High leverage, low–medium implementation cost. Requires plumbing per-task counters (doc queries, implementer attempts, reviewer iterations) and an Oracle-dispatch counter into hub state, plus prompt-level changes to two agent specs and the new Oracle agent definition. **No model→cost data is required** at any layer. If a model→cost registry is built later, it can extend (not replace) this design as a separate proposal.

## 5. Success Metrics (for post-run verification)

Measurable from transcript and dispatch log. All metrics are count-based — no token/dollar cost is required to verify any of them.

- **M1 (hard):** For tasks with doc-query count > 8 *and* default cycle complete, Oracle is dispatched within 1 additional implementer attempt or the hub logs an explicit "Oracle declined because: <reason>" entry. Verifiable in `dispatch-log.jsonl`.
- **M2 (hard):** No task has more than 4 implementer retry dispatches without Oracle involvement (counting only post-default-cycle attempts). Baseline: US-003 Task 4 had 5+.
- **M3 (hard):** Browser-automation / CDP / service-worker-lifecycle tasks with `oracle_preauthorize: true` (P15) see Oracle dispatched on attempt 2, after exactly one default cycle — never on attempt 1, never delayed beyond attempt 2. Verifiable by joining planner annotations to dispatch log.
- **M4 (soft):** Total doc queries per story drop. Targeting the same window as P13: ≤ 15/story average, ≤ 25 max. Baseline ~32.
- **M5 (hard, replaces prior cost-based M5):** No task receives an Oracle dispatch before at least one complete `implementer → code-reviewer → QA` cycle has logged for that task, except for trigger 5 defect-incidents (which the original story execution already satisfies). Verifiable in `dispatch-log.jsonl` by checking the cycle-completion event precedes the Oracle dispatch event.
- **M6 (hard):** No task receives a 2nd Oracle dispatch without a justification log entry containing both (a) what changed since the prior Oracle dispatch and (b) the expected differentiator. Verifiable in `dispatch-log.jsonl`.
- **M7 (hard):** No story exceeds 3 Oracle dispatches without a coordinator-pause event. Verifiable in `dispatch-log.jsonl`.
- **M8 (soft):** Mean implementer attempts on tasks where Oracle was eventually dispatched ≤ 2 (i.e., the default cycle plus at most one extra implementer pass before Oracle). High values here indicate the hub is delaying Oracle past the trigger thresholds.

## 6. Risks & Tradeoffs

- **Risk:** Oracle is dispatched for tasks that would have succeeded on a 2nd or 3rd implementer attempt, consuming premium-model dispatch unnecessarily. Mitigation: the default-cycle precondition guarantees one normal pass before Oracle; per-task dispatch cap (1 default, 2 with justification) prevents repeated Oracle calls on the same task; thresholds are tuned from observation and revised if M8 indicates routine premature escalation.
- **Risk:** "Task shape" annotations become a dumping ground where planners flag everything as complex, undermining the signal. Mitigation: P15 requires justification for the flag, reviewable by the SDLC coordinator on plan approval. The default-cycle precondition also blunts the impact of over-flagging — even flagged tasks must run one normal cycle first.
- **Risk (new, 2026-04-26): Oracle becomes the hub's "easy way out."** Without governors, the hub may route ambiguous failures to Oracle to avoid harder reasoning about which cheaper agent should handle them. Mitigation: per-task dispatch cap (§3.0) forbids casual re-dispatch; story-level soft cap of 3 dispatches triggers coordinator pause; the default-cycle precondition forces baseline normal-path effort on every task before Oracle is even on the table.
- **Risk (new, 2026-04-26): Oracle scope creep.** Oracle, freed to edit files directly, may expand its work beyond the dispatched issue (refactor adjacent code, fix tangentially observed bugs, restructure modules). Mitigation: prompt-level discipline only at this stage — Oracle's system prompt is explicit that it must solve only the dispatched issue, return out-of-scope observations as notes, and not edit out-of-scope files. If observed scope creep recurs in transcripts, a follow-up proposal will add mechanical post-dispatch path-diff enforcement (compare files-touched to the dispatched `scope` block; flag overruns as a defect-incident on Oracle itself).
- **Tradeoff:** Routing logic lives entirely in the hub; workers (implementer, reviewer) gain no awareness of Oracle and no role in the escalation decision. This is intentional (see §2.5) but means the hub is the single point that must implement the trigger evaluation correctly. If the hub's evaluation logic has a bug, no worker-side fallback will surface it; mitigation is the hard metrics M1–M3 and M5–M7 in §5, all verifiable from `dispatch-log.jsonl`.
- **Tradeoff:** Removing cost-arithmetic framing means there is no quantitative cost signal at decision time. Counts (queries, attempts, iterations) are the honest substitute given today's hub capabilities. If a model→cost registry and post-run cost feedback hook are built later, cost-aware evaluation can be added to the hub's routing logic in a separate proposal alongside (not replacing) count-based evaluation.
- **Tradeoff:** Oracle's "direct edit, scoped" output contract eliminates the implementer-applies-the-patch step but means the implementer is not in the loop on Oracle's edits. The next default-cycle pass (review + QA) is the verification mechanism. If Oracle's edit fails review/QA, the hub considers re-dispatch under §3.0, not auto-retry.

## 7. Resolved Decisions and Open Questions

### 7.1 Resolved decisions (2026-04-26)

The four open questions originally listed here are resolved as follows:

1. **What constitutes "Oracle" concretely?** Oracle is a single agent definition (`opencode/.opencode/agents/sdlc-engineering-oracle.md`) with the model **pinned to a top-tier model from one of {Anthropic, OpenAI, Google}**. The specific model is configurable per release and reviewed periodically; "top-tier" means the provider's currently-recommended flagship for complex reasoning (not a "pro"/budget tier and not a small/fast tier). Oracle is not a role any capable model can play; the pinning is intentional so dispatch reasoning is consistent.
2. **Query-budget threshold semantics.** The threshold is **per task, cumulative across all attempts within the current story execution**. The counter resets at story boundary. For trigger 5 (defect-incident), a fresh counter is started for the incident — defect-incident query history does not accumulate against the original story's counter, and vice versa.
3. **Oracle context.** Yes — Oracle dispatch MUST include the full context: task spec, all prior implementer attempts (diffs and outputs), all prior reviewer feedback, all relevant cache entries (per P13), the failing AC and failing test name(s), the specific error symptoms, and the explicit `scope` block of authorized file paths. Partial-context dispatch is forbidden; the hub assembles full context or does not dispatch.
4. **Oracle output contract.** Oracle returns **direct file edits scoped to the dispatched issue** (per §3.2). It does not produce advisory-only output. Out-of-scope observations are returned as notes for the hub to triage. The next default-cycle pass (code-reviewer + QA) verifies Oracle's edits.

### 7.2 Remaining open questions

- After Oracle has edited files and the next default-cycle pass (review + QA) still fails, the hub may dispatch the implementer to take a follow-up pass. Should the implementer in that follow-up be given Oracle's prior diff and reasoning notes as **context** (not as awareness of Oracle's role)? The current answer is yes — Oracle's diff and notes are framed in the implementer's prompt as "prior work on this task" without naming Oracle. This preserves §2.5 separation while not throwing away useful context. Flag for the implementation step to confirm framing.
- Mechanical scope-creep enforcement is **deferred**. If prompt-level discipline (§3.2) proves insufficient in observed runs, a follow-up proposal will add post-dispatch path-diff checks comparing files-touched to the `scope` block. Triggering observation: any single Oracle dispatch where files-touched ⊄ `scope`.
- The query-budget threshold (8) and the per-story Oracle soft cap (3) are starting values from observation of US-003/US-004, not tuned from a large sample. Both should be revisited after 5–10 stories of operating data.

## 8. Affected Agents and Skills (preliminary)

All P14 routing logic lands on the hub. Worker agents (implementer, reviewer) are deliberately unmodified — see §2.5.

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-engineering.md` | Modified | Hub escalation policy: maintains per-task counters (doc queries, implementer attempts, reviewer iterations) in dispatch metadata; **evaluates triggers 1–3 hub-internally** before every re-dispatch on a task that has completed one default cycle (§3.1 trigger 4); enforces the **default-cycle precondition** (§3.0); maintains the **per-task Oracle dispatch counter and cap** (1 default, 2 with logged justification, 3rd forbidden without coordinator approval); enforces the **per-story Oracle soft cap** of 3 with coordinator pause. Logs an explicit "Oracle declined because: <reason>" entry whenever a trigger fires and the hub elects not to dispatch. Reads reviewer findings (e.g., "implementer repeatedly misuses API X") as additional input to its routing decision; reviewer never names Oracle. |
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | **Not modified by P14** | Listed for clarity. The implementer has no awareness of Oracle, no counter framing, and no escalation question in its prompt. The hub may, in a follow-up pass after an Oracle dispatch, include Oracle's prior diff and notes as "prior work on this task" context — without naming Oracle. (See §7.2 open question.) |
| `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md` | **Not modified by P14** | Listed for clarity. The reviewer continues to flag findings such as repeated API misuse, severity escalations, and AC-contradiction concerns in its normal output. The hub interprets those findings as routing signals. The reviewer does not request Oracle and does not see Oracle in its prompt. |
| `opencode/.opencode/agents/sdlc-engineering-oracle.md` | Created/Confirmed | Oracle agent definition. **Model**: pinned top-tier from {Anthropic, OpenAI, Google} (configurable per release; not "pro"/budget tier). **Input contract**: task spec + scope block (allowed file paths) + all prior implementer attempts + all prior reviewer feedback + cache entries + failing AC/test + error symptoms. **Output contract**: direct file edits within scope + out-of-scope observations as notes (no edits outside scope). **System prompt**: enforces scope discipline — solve only the dispatched issue; do not refactor adjacent code; do not address adjacent issues; return out-of-scope findings as notes. |
| `dispatch-log.jsonl` schema | Modified | Adds per-task counter fields (doc_queries, implementer_attempts, reviewer_iterations), Oracle dispatch event with per-task index and `scope` block, and Oracle-decline event with reason. Required for M1–M8 verifiability. |

---

## 9. Relation to Prior Proposals

- P6 introduced the Oracle pattern for type-system and repeated-bug scenarios. P14 generalizes it to doc-query-count and task-shape triggers, and (2026-04-26) adds the cross-cutting governors (default-cycle precondition, per-task cap, per-story soft cap) that prevent Oracle-as-easy-way-out.
- P10 creates the story-level iteration cap; P14 supplies the escalation target when the cap is hit.
- P13 makes caches more comprehensive, reducing how often the query-budget trigger fires for doc-availability reasons (vs. genuine complexity reasons).
- P15 supplies the planner-side task-shape flag that enables trigger 3 (accelerator). Per the 2026-04-26 revision, the flag accelerates Oracle entry to attempt 2 but does not bypass the default cycle.
- **P20** supplies the `api.md.wire_format` annotation that P14 trigger 5 reads to recognize external-integration defects as Oracle-eligible.
- **P21** introduces the `defect-incident` lifecycle; P14 trigger 5 is how incidents route to Oracle. Defect incidents are the only path that bypasses the default-cycle precondition (because the original story execution already satisfied it).
