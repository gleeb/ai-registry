# P13: Incentivize Comprehensive lib-cache Entries Over Minimal Compliance

**Status:** Implemented — 2026-04-22 (drafted 2026-04-18, revised 2026-04-22: open questions resolved, change 4 dropped)
**Relates to:** [P4 (Documentation Lookup & Cache Schema)](./P4-documentation-lookup-strategy.md), [P8 (Cache/Budget/Coverage/Embedding)](./P8-cache-budget-coverage-embedding.md) — both introduced the cache-first protocol and verbose schema; this proposal closes a gap in how the schema is *filled*
**Scope:** `opencode/.opencode/agents/sdlc-engineering.md` (hub — curator dispatch at Phase 1b), new `opencode/.opencode/agents/sdlc-engineering-cache-curator.md`, `opencode/.opencode/agents/sdlc-engineering-implementer.md`, `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md`, staging-doc `lib-cache` template
**Transcript evidence:** `ses_26105317cffeCAev1W8UP3BtK1` — `tmp/staging/US-002-local-persistence-foundation.lib-cache.md` Vitest entry lists 3 APIs and no error_types; Dexie entry lists 4 APIs (Table, add, get, delete) with no snippets for version migration or hooks. `tmp/staging/US-003-pwa-shell-baseline.lib-cache.md` contains `re_query_log` entries for `vite-plugin-pwa`, `browser installability APIs`, and `@playwright/test` — libraries that had cache entries already, but the entries lacked the needed surface area so new queries were required.

---

## 1. Problem Statement

P8 established the verbose cache schema (apis_used, code_snippets, error_types, gotchas, re_query_log) and the 3-queries-per-library budget. The schema worked as intended — cache entries are present, structured, and compliant. But the entries are frequently **minimally compliant** rather than comprehensive.

In practice, an implementer performing Task 1 for a library:
- Queries context7 for the 1–2 APIs needed for Task 1.
- Writes a cache entry with those 1–2 APIs, 1 snippet, maybe 1 gotcha.
- Marks the entry done and proceeds.

Then Task 3 needs a different API in the same library (often an edge case, error path, or version-migration concern). The implementer checks the cache, finds the library is there but doesn't cover what's needed, and:
- Either issues a `re_query_log` entry and queries again (burning budget), or
- Proceeds without the cache and misses a gotcha (surfacing in code review later).

The completion contract rewards the first behavior (minimal compliance), not the second (comprehensive coverage). The code reviewer does not inspect cache-entry quality, only presence. The incentive structure favors skim-and-move-on.

## 2. Root Cause Analysis

### 2.1 Completion contract is binary
`sdlc-engineering-implementer.md` effectively says "cache entry must contain apis_used and code_snippets" — presence/absence. No quality bar on what "contains apis_used" means. One API counts; ten APIs count; both pass.

### 2.2 3-query budget incentivizes narrow queries
With a small budget, the rational implementer strategy is to ask targeted questions for what Task N needs RIGHT NOW, not broad questions that would build a reusable knowledge base. The budget is enforced per-library and per-story, but within that budget, breadth is not rewarded.

### 2.3 Code reviewer does not evaluate cache quality
Per-task code review covers code, tests, and staging-doc summaries. It does not score the cache entry. A cache entry that will force a re-query in Task 3 has no penalty at Task 1's review boundary.

### 2.4 Task-local viewpoint
Even within a single story, the implementer executing Task 1 doesn't think in story-scope terms for library surface area — they think in task-scope. No agent in the current pipeline has *story-scope library surface* as its primary responsibility.

## 3. Proposed Approach

Three changes:

1. **Raise the quality bar in the implementer's cache contract.** A cache entry is considered complete only when it covers:
   - All APIs the implementer expects to use for the *story* (not the task) in this library.
   - At least one code snippet per API category (setup, primary use, error path).
   - All error_types or failure modes reasonably anticipated for the APIs listed.
   - All known gotchas from the top-ranked doc sections for the APIs listed.

   The contract frames this as: "An implementer reading this entry, without access to docs, should be able to complete any task in this story that uses this library."

2. **Add cache-quality inspection to the code-review contract.** The code reviewer's checklist adds a step: for each library the task diff depends on, confirm the cache entry covers every API used in that task's implementation. If a task uses API X and the cache entry does not list API X (nor has a matching `re_query_log` justification), that is a finding. **Severity: Suggestion-class by default**, escalating to **Important** only when the gap actively produced a defect, security issue, or test failure in this review cycle. Suggestion-class does not block approval (per P10 — avoid iteration churn from cache hygiene alone).

3. **Introduce a cache-curator subagent, dispatched by the engineering hub during Phase 1b (staging creation).** A dedicated subagent, running on the cheapest available model, is responsible for populating `docs/staging/<story-id>.lib-cache.md` with comprehensive entries for every external library listed in the story's task decomposition. The curator runs **once per story**, **after task decomposition and lib-cache file creation, before Phase 2 begins**. It receives:
   - The full list of external libraries (union across all tasks).
   - The story scope excerpt (scope, acceptance criteria summary, HLD design-unit excerpts mentioning each library).
   - The pinned versions from `package.json` (or equivalent manifest).
   - The cache schema.

   The curator queries context7 (and Tavily as fallback) for each library in a single sequential pass, writes a verbose cache entry per the quality bar in change 1, and returns a summary of libraries populated and any gaps. The implementer then consumes the pre-populated cache as its primary source; the existing `re_query_log` mechanism handles task-time gaps nuance that the curator missed.

## 4. Expected Impact / ROI

**Primary impact:** Reduces `re_query_log` entries and overall context7/Tavily calls. This run had 64 total doc-search calls (vs. target ≤10/story from P8). A substantial fraction were re-queries for libraries already cached-but-shallow. Rough target: cut total doc queries by 30–40% on comparable future runs.

**Secondary impact:** Higher signal in cache entries means downstream implementers (including in later tasks of the same story) solve problems faster. Fewer "I need to understand why this errors" pauses.

**Tertiary impact (cost structure):** Offloading doc-fetch-and-summarize work to the cheapest available model (curator subagent) shifts output-token cost from the hub and implementer (larger models) to the curator. Given summarization is a high-volume output-token task, this is where the real cost savings materialize — not from fewer total calls, but from cheaper calls per fetched doc page.

**Compounding across stories (explicit non-goal):** A project-level persistent cache was considered and rejected. Library usage surface differs per story; a union cache would be either shallow or noisy, and staleness creates silent drift. The compounding mechanism is **skills**, not caches: durable, non-obvious library patterns discovered during a story are promoted into skill files via the existing skill-gotchas post-run review flow. This keeps library learning in a curated, reviewed artifact class rather than raw model output.

## 5. Success Metrics (for post-run verification)

Measurable from transcript and staging-doc inspection:

- **M1 (hard):** Total documentation queries (context7 + Tavily) per story (curator + implementer combined) ≤ 15 on average, ≤ 25 maximum. Baseline: ~32 per story in this run.
- **M2 (hard):** `re_query_log` entries per library-cache entry ≤ 1 on average. Baseline: several entries had 2+ re-queries.
- **M3 (hard):** For every library listed in a task's "libraries_used," the library's cache entry covers every API used in that task's implementation. Verifiable by parsing staging docs and grepping implementation files.
- **M4 (soft):** Each cache entry has ≥ 5 APIs, ≥ 3 code snippets, ≥ 2 error_types, ≥ 2 gotchas for libraries used in more than one task. (Trivial libraries used once can stay lean.)
- **M5 (cost):** Per-story curator output-token cost vs. the counterfactual (implementer + hub doing the same fetches) trends downward. Requires logging token usage per agent.

## 6. Risks & Tradeoffs

- **Risk:** The curator is a cheap model and may miss nuance in gotchas (non-obvious consequences). **Mitigation:** Curator prompt explicitly instructs it to extract gotchas *only from doc sections the docs themselves flag* (warnings, notes, "common mistakes" callouts). The curator does not *infer* gotchas. Implementer's existing re-query path handles mid-task discoveries.
- **Risk:** Forcing comprehensive entries inflates Phase 1b front-load work and may not pay off if a library is used only once. **Mitigation:** Scale requirement by expected use — libraries used in 1 task can stay lean; libraries used in 2+ tasks must be comprehensive.
- **Risk:** The code reviewer's cache-quality check adds another failure surface for story-review iteration escalation (anti-P10). **Mitigation:** Cache-quality findings are Suggestion-class by default; only escalate to Important when the gap actively caused a defect in this review.
- **Risk:** Curator context budget is exhausted on stories with many libraries. **Mitigation (only if observed):** curator writes each entry to disk as it finishes rather than holding all entries in context. Not built up front.
- **Tradeoff:** Curator queries may cover APIs that never get used in the actual implementation. Accepted cost for the guaranteed time savings on APIs that *do* get used, plus the cost offset from running on the cheaper model.

## 7. Open Questions — Resolutions

All open questions are resolved. Retained here for decision history.

1. **Who performs the warm-up query?** → **Dedicated cache-curator subagent, hub-dispatched during Phase 1b.** Not the implementer (keeps implementer focused on problem-solving, not doc-digestion), not the planner (planner's output is the library *list*, not the surface). The curator runs on the cheapest available model for cost efficiency.
2. **One curator per library (parallel) or one curator for all libraries (sequential)?** → **One curator, all libraries, sequential.** Starting posture: simpler contract, one prompt to iterate on, one artifact to inspect. Escalation to per-library parallel dispatch is a future optimization if quality drops or if context budget becomes a constraint.
3. **Project-level cache across stories?** → **No.** Per-story scope is correct. Compounding happens via skills (post-run promotion of library gotchas), not via a persistent cache. See section 4 for rationale.
4. **Cache TTL?** → **Not needed.** Story-local caches are ephemeral (merged/archived at story completion). No staleness window exists to manage.
5. **Embedding / semantic retrieval?** → **No.** Cache files are read end-to-end; structured sections act as a lightweight index. Embedding infra is out of scope for this project's scale.

## 8. Affected Agents and Skills

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-engineering-cache-curator.md` | **Created** | New subagent. Single-responsibility: populate the story-level lib-cache.md with comprehensive entries per schema. Runs on `openai/gpt-5.4-mini` (cheapest currently available). Hub-dispatched in Phase 1b. Permissions: edit limited to `docs/staging/**`, bash allowed (for context7/Tavily MCP calls), task deny. |
| `opencode/.opencode/agents/sdlc-engineering.md` | Modified | Add curator to `permission.task` allow-list. Add Phase 1b step: dispatch `@sdlc-engineering-cache-curator` after lib-cache file creation with union of `external_libraries` across tasks + story scope excerpt + pinned versions. Wait for completion before Phase 2. |
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | Modified | Cache-first protocol updated: cache is expected to be **pre-populated by the curator**. Implementer is a consumer. If a specific API detail is absent, the existing `re_query_log` + budget mechanism applies unchanged. Raise the definition of "sufficient cache entry" from presence to story-scope comprehensiveness. |
| `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md` | Modified | Add cache-comprehensiveness check: for each library the task diff uses, confirm cache covers each API used. Missing coverage without matching `re_query_log` entry = Suggestion-class finding (Important only if it caused an observable defect). |
| `opencode/.opencode/skills/project-documentation/references/task-context-template.md` | Modified | Update "Hub Instructions: Story-Level Library Cache" to note curator pre-populates during Phase 1b. Update header in the cache file template to reflect curator-authored baseline + implementer append model. |
| `opencode/.opencode/skills/project-documentation/references/skill-gotchas-template.md` | Modified | Post-run action block notes that the lib-cache.md `gotchas` fields are also review material for skill-update candidates, alongside the runtime-discovered gotchas already captured. |

---

## 9. Relation to Prior Proposals

- Direct follow-up to P4 (cache-first protocol) and P8 (verbose schema).
- P4 solved "do we query before every task?" P8 solved "what goes in the entry?" P13 solves "how does it get filled comprehensively, and by whom?"
- Pairs with P14 (Oracle escalation threshold): better caches mean Oracle gets called less often for "I can't find docs" reasons.
- Supersedes the earlier draft's change 4 (project-level cross-story cache) — compounding now flows through the skills channel instead.
