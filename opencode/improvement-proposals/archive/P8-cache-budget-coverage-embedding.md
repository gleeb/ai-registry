# P8: Story-Level Cache, Query Budget, Coverage Parsing, and Role-Aware Source Embedding

**Status:** Resolved — agent specs, templates, and per-stack scaffold references updated
**Relates to:** [P2 (Context Management)](./P2-context-management-and-memory.md), [P3 (Verification Pipeline)](./P3-verification-pipeline.md), [P4 (Documentation Lookup)](./P4-documentation-lookup-strategy.md)
**Scope:** `opencode/.opencode/agents/sdlc-engineering.md`, `opencode/.opencode/agents/sdlc-engineering-implementer.md`, `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md`, `opencode/.opencode/agents/sdlc-engineering-qa.md`, `opencode/.opencode/agents/sdlc-engineering-scaffolder.md`, `common-skills/project-documentation/references/task-context-template.md`, `common-skills/architect-execution-hub/references/phase1-task-decomposition.md`, `common-skills/architect-execution-hub/references/implementer-dispatch-template.md`, `common-skills/architect-execution-hub/references/scaffolding-dispatch.md`, `common-skills/scaffold-project/references/{react-vite,nextjs,react-native,python-uv,monorepo}.md`
**Transcript evidence:** `ses_2639886c2ffeMI2wLZcZ43UJrP` — scaffolding + US-002 (local persistence foundation) until token exhaustion. 34 documentation queries for a single small story; re-queries for Dexie, `fake-indexeddb`, `@testing-library/react` across dispatch boundaries despite P4's "cache first" rule; Context7 quota exhaustion followed by redundant retry cycles; implementer and QA reading `coverage/index.html`, `coverage-final.json`, and `clover.xml` directly into context.

---

## 1. Problem Statement

P4 introduced a per-task `## Library Documentation Cache` section and a "check first before querying" rule. In practice the US-002 transcript showed three distinct failure modes that let the cache become decorative rather than functional:

1. **Cache was status-only, not content-bearing.** The cache section in `.task-N.context.md` was populated with phrases like "Dexie v4 — queried, see prior dispatch" but contained no API signatures, error types, or code snippets. When the implementer re-read the context doc on a later task and needed, e.g., the exact `db.version(1).stores({...})` syntax, the cache offered nothing usable, so it re-queried Context7 and the entry was overwritten with another status line.
2. **Cache scope was per-task, not per-story.** Each new task got a fresh `.task-N.context.md`. A library queried in Task 1 was not visible to Task 3. The transcript shows Dexie documentation fetched three times across the same story.
3. **No budget and no quota-exhaustion handling.** Context7 returned a quota-exhausted error mid-story. The implementer kept retrying Context7 on subsequent dispatches instead of falling back to Tavily, consuming tokens on error paths. 34 total doc queries for a story covering ~600 lines of code is the clearest signal.

A fourth failure mode, unrelated to caching but observed in the same transcript: the implementer and QA repeatedly read raw coverage artifacts (`coverage/index.html` — 8000+ tokens, `coverage/coverage-final.json` — 40000+ tokens, `coverage/clover.xml`) into context to extract per-file percentages. The LLM is parsing HTML and nested JSON to derive two numbers per file. This is a pure waste: the data can be emitted as stdout lines by the verification script and grepped.

A fifth failure mode, subtler: P2's context document embeds full source-file excerpts under a `## Source Files` section so subagents don't need to re-read from disk. In the transcript, the implementer read the context doc (consuming the embedded excerpts as tokens), then *immediately* read the same files from disk using the Read tool to make edits, because patch-style edits require actual file content not a context-doc copy. The embedding paid no dividend for implementers and doubled the ingestion of source. For reviewers and QA (read-only roles) the embedding is still useful — they don't edit, so they don't re-read.

Root causes:

1. **Cache schema too loose.** P4 specified *that* the cache should exist but not *what* it must contain. A status table satisfies the letter of P4 while providing zero re-use value.
2. **Cache lifetime too short.** Per-task cache is tied to the context document, which is regenerated per task. The implementation-unit of learning (one library) spans the story.
3. **No query governance.** No budget, no quota-exhaustion flag, no thrash guard. The rule "check cache first" was the only governance, and it was easy to defeat with a status-only cache.
4. **Coverage artifacts treated as LLM-readable.** No rule or tooling preventing it, and no structured alternative existed, so the LLM did what it could.
5. **Source embedding applied uniformly across roles.** Implementers always re-read; reviewers/QA sometimes can rely on the embed. Treating them the same meant the embed was either redundant (for implementers) or too thin (for reviewers, who occasionally need more than an excerpt).

---

## 2. Root Cause Analysis

### 2.1 Cache schema failure

Transcript evidence at lines ~14200, ~18900, ~22400 (Dexie queries): three separate Context7 `query-docs` calls for Dexie, all returning substantially the same content. The context doc's cache section after each query contained a one-line status like `- Dexie: queried 2026-04-15 (see task-1 dispatch)`. Nothing quotable, nothing actionable. The next implementer dispatch read that line, decided it couldn't construct a working `db.version(1).stores({...})` call from it, and re-queried.

The cache content was not a cache. It was a log of queries.

### 2.2 Per-task lifetime vs. per-story unit of work

Stories bundle tasks that share a library set by design — US-002 had 2 tasks both touching Dexie and `@testing-library/react`. The cache artifact should match the story's library set, not the task's. A per-task cache forces re-accumulation on every task boundary.

### 2.3 Context7 quota exhaustion

At transcript line ~19800 Context7 returned `quota_exceeded`. The implementer's retry logic was silent: it retried twice more within the same dispatch (each consuming a round-trip), then switched to Tavily. The next dispatch started fresh, hit quota again, retried twice, and switched. No persistent flag across dispatches meant the quota exhaustion was re-discovered repeatedly.

### 2.4 Coverage artifacts read by LLM

QA's Phase 3 in the previous spec said "read the coverage report to determine which files are under-covered." The LLM interpreted this literally and used the Read tool on `coverage/index.html`. One read: 8000+ tokens to extract `src/db.ts: 84% lines, 71% branches`. A structured stdout line `COVERAGE: src/db.ts L=84% B=71% F=90%` carries the same information in ~50 tokens and requires no file read.

### 2.5 Role-symmetric source embedding

Implementers edit files. Edit tools (`StrReplace`, `Write`) require the actual on-disk file content as `old_string` — an excerpt from a context doc doesn't match. So implementers always Read the file before editing, rendering the embed a pre-ingestion of content they will ingest again from disk.

Reviewers and QA never write. For them, an embed is a genuine substitute for a file read, and they frequently don't need full files — excerpts are often enough.

---

## Implementation Decisions

### Story-level cache artifact (`docs/staging/<story-id>.lib-cache.md`)

**Decision:** Move the `## Library Documentation Cache` out of per-task context docs and into a dedicated story-level file. Created at Phase 1b by the engineering hub alongside the staging doc. One entry per library. Shared across all task context docs for that story.

- Defined in: `common-skills/project-documentation/references/task-context-template.md` (cache section now points at the story-level file)
- Created by: `opencode/.opencode/agents/sdlc-engineering.md` Phase 1b
- Referenced by: `common-skills/architect-execution-hub/references/implementer-dispatch-template.md` as `LIBRARY CACHE: docs/staging/<story-id>.lib-cache.md` in every implementer dispatch

**Rationale:** One library → one entry, for the whole story. No regeneration per task.

### Verbose cache entry schema

**Decision:** Each entry MUST contain: `apis_used` (exact signatures), `error_types` (exceptions/rejections the library throws), `code_snippets` (minimal working examples pulled from the query response), and `re_query_log` (timestamps of additional queries with a `reason`). Status-only entries are explicitly forbidden — the code reviewer flags them as Critical.

- Defined in: `opencode/.opencode/agents/sdlc-engineering-implementer.md` (Documentation Search section)
- Enforced by: `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md` (opens `lib-cache.md`, flags any entry without `apis_used` or `code_snippets` as Critical)

**Rationale:** Forces the cache to be actionable on future reads. The code-reviewer gate makes the schema non-optional.

### Hard query budget + quota flag + thrash guard

**Decision:** Three governance mechanisms stacked:

1. **Hard budget:** 3 queries per library per story. The hub tracks this in the `lib-cache.md` re-query log and emits `LIBRARY BUDGET: <lib> N/3 used` in dispatch messages after the first query.
2. **Session quota flag:** When Context7 returns quota-exhausted, the hub sets a session flag and subsequent dispatches include `CONTEXT7 QUOTA EXHAUSTED — TAVILY ONLY`. No retry of Context7 within the same story session.
3. **Query thrash guard:** Maximum 2 topic refinements per query (e.g., "Dexie" → "Dexie transactions" → "Dexie transactions rollback" is 2 refinements; a third is forbidden). Prevents the "just one more query" drift.

- Defined in: `opencode/.opencode/agents/sdlc-engineering-implementer.md` (Documentation Search section)
- Propagated in dispatches by: `opencode/.opencode/agents/sdlc-engineering.md` Phase 2 C1a

**Rationale:** The 34-query transcript was possible because no mechanism stopped it. These three mechanisms together cap total queries at a predictable ceiling.

### Ban reads of raw coverage artifacts; mandate `COVERAGE:` stdout emission

**Decision:** Two-part rule:

1. **Ban:** Implementer, code-reviewer, and QA MUST NOT Read `coverage/index.html`, `coverage/coverage-final.json`, `coverage/clover.xml`, or any per-file HTML report. The only approved sources for coverage data are: stdout `COVERAGE:` lines, `coverage/coverage-summary.json` parsed via `jq` or `node -e`, or a future `scripts/coverage-for.sh` helper.
2. **Emission:** Every `scripts/verify.sh` in newly scaffolded projects must print one line per source file in the format `COVERAGE: <relative-path> L=N% B=N% F=N%` after the test gate. The scaffolder agent was instructed to produce this; the per-stack templates under `common-skills/scaffold-project/references/` were updated to actually contain the reporter flag (Vitest `json-summary`, Jest `--coverageReporters=json-summary`, pytest `--cov-report=json:coverage.json`) and the guarded parsing block that emits the lines.

- Ban defined in: `opencode/.opencode/agents/sdlc-engineering-implementer.md` (Self-Verification), `sdlc-engineering-code-reviewer.md` (Initialization Step 4), `sdlc-engineering-qa.md` (Phase 3)
- Emission defined in: `opencode/.opencode/agents/sdlc-engineering-scaffolder.md` (SELF-VERIFICATION block) + per-stack templates

**Rationale:** Coverage data is tabular and small when emitted correctly. LLM-reading large HTML/JSON to derive the same numbers is pure token waste. The ban without the emission side would leave agents without any coverage signal; the emission without the ban would still allow the old path. Both are required.

### Role-aware source embedding

**Decision:** Split the `## Source Files` section in the task context document by consuming role:

- For **implementer** dispatches: the section is a *file inventory only* — path, line count, key exports. No code bodies. The implementer is explicitly instructed to Read files from disk before editing.
- For **code-reviewer** and **QA** dispatches: the hub embeds verbatim code excerpts in the *dispatch message body* (not in the shared context doc, since they are role-specific). This lets read-only roles work without file reads when the excerpt suffices.

- Defined in: `common-skills/project-documentation/references/task-context-template.md` (Source Files section behavior)
- Orchestrated by: `opencode/.opencode/agents/sdlc-engineering.md` Phase 2 A2 (implementer dispatch: inventory only) and Phase 2 C1a (pre-reviewer/QA: embed excerpts in dispatch message)

**Rationale:** The embed's value is role-dependent. Making it uniform wasted tokens for implementers and didn't fully serve reviewers. Splitting it by role keeps the benefit and removes the waste.

### Per-stack verify.sh template updates

**Decision:** Update every per-stack scaffold reference file so its `verify.sh` template emits `COVERAGE:` lines:

- `react-vite.md`: add `'json-summary'` to `coverage.reporter` in `vitest.config.ts`; add node parser block after the TEST gate.
- `nextjs.md`: inherit from react-vite — add explicit note in the "same as react-vite" paragraph.
- `react-native.md`: change `npx jest --coverage` to include `--coverageReporters=text --coverageReporters=html --coverageReporters=json-summary`; add the same node parser block.
- `python-uv.md`: add `--cov-report=json:coverage.json` to the pytest line; add a Python one-liner that parses `coverage.json` and prints `COVERAGE: <path> L=N% B=na F=na` (pytest-cov JSON doesn't compute branch/function % the same way; `B=na F=na` is honest).
- `monorepo.md`: add a one-line deferral note — per-workspace `verify.sh` carries the responsibility, root verify forwards output unchanged.

**Rationale:** The agent-level rule without the template update would leave newly scaffolded projects without the emission side of the contract. The scaffolder copies these templates verbatim; the rule is only enforced end-to-end if the templates themselves contain the snippet.

---

## 3. Affected Agents and Skills

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-engineering.md` | Modified | Phase 1b: create `docs/staging/<story-id>.lib-cache.md`. Phase 2 A2: implementer dispatch writes Source Files as inventory only. Phase 2 C1a: cache update logic points at story-level file; track `LIBRARY BUDGET:` and `CONTEXT7 QUOTA EXHAUSTED` flags across dispatches; embed code excerpts in dispatch message (not context doc) for reviewer/QA. |
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | Modified | Source Files section is inventory only — Read from disk to edit. Documentation Search: check story-level cache first, verbose entry schema, 3-query budget per library, Context7 quota flag respected without retry, 2-refinement thrash guard. Self-Verification: ban raw coverage artifact reads. Completion Contract: quote cache file path and verbose content on cache updates. |
| `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md` | Modified | Source Files is inventory; code excerpts arrive in dispatch message. Documentation Evidence Check opens `lib-cache.md`, flags entries missing `apis_used`/`code_snippets` as Critical. Ban raw coverage artifact reads. |
| `opencode/.opencode/agents/sdlc-engineering-qa.md` | Modified | Ban raw coverage artifact reads; list approved alternatives (`COVERAGE:` stdout, `coverage-summary.json` via jq/node). |
| `opencode/.opencode/agents/sdlc-engineering-scaffolder.md` | Modified | SELF-VERIFICATION block: `json-summary` reporter requirement for `vitest.config.ts`; embed the node parser snippet in scaffolded `scripts/verify.sh`. |
| `common-skills/project-documentation/references/task-context-template.md` | Modified | Library Documentation Cache section is intentionally blank — points at story-level `lib-cache.md`. Source Files section documents inventory-only for implementers vs. dispatch-message-embed for reviewers/QA. Hub instructions updated. |
| `common-skills/architect-execution-hub/references/phase1-task-decomposition.md` | Modified | Added Step 7 "Library cache file creation" — create `docs/staging/<story-id>.lib-cache.md`. |
| `common-skills/architect-execution-hub/references/implementer-dispatch-template.md` | Modified | REQUIRED CONTEXT includes `LIBRARY CACHE:` (always) and `LIBRARY BUDGET:` / `CONTEXT7 QUOTA EXHAUSTED` (when applicable). Task context document description notes inventory-only Source Files. |
| `common-skills/architect-execution-hub/references/scaffolding-dispatch.md` | Modified | Added Step 5 `COVERAGE REPORTER GATE`: verify scaffolded `vitest.config.ts` includes `json-summary` and `scripts/verify.sh` emits `COVERAGE:` lines. |
| `common-skills/scaffold-project/references/react-vite.md` | Modified | `coverage.reporter` includes `'json-summary'`; verify.sh emits `COVERAGE:` lines via node parser. |
| `common-skills/scaffold-project/references/nextjs.md` | Modified | Explicitly inherits react-vite's reporter + emission block. |
| `common-skills/scaffold-project/references/react-native.md` | Modified | Jest test line adds `--coverageReporters=json-summary`; verify.sh emits `COVERAGE:` lines via the same node parser. |
| `common-skills/scaffold-project/references/python-uv.md` | Modified | pytest line adds `--cov-report=json:coverage.json`; verify.sh emits `COVERAGE:` lines via Python one-liner (`B=na F=na`). |
| `common-skills/scaffold-project/references/monorepo.md` | Modified | Note: per-workspace `verify.sh` uses per-stack snippet; root verify forwards output unchanged. |

---

## 4. Open Questions — Resolved

1. **Should the cache be per-task or per-story?** Resolved: story-level. A library is a story-level unit of knowledge; task-level regeneration is the root cause of re-queries.
2. **Is "cache first" enough governance, or do we need a hard budget?** Resolved: need both. The hard budget (3/library) plus quota flag plus thrash guard close the loopholes that a status-only cache left open.
3. **Should source-file embedding be removed entirely?** Resolved: No — keep it for read-only roles (reviewer, QA) where it saves file reads. Drop it for implementers where it's redundant with their required disk reads.
4. **Should the ban on coverage artifact reads be advisory or enforced?** Resolved: Enforced. Implementer Self-Verification, reviewer Initialization Step 4, and QA Phase 3 all contain an explicit "MUST NOT Read" rule. The reviewer is empowered to flag violations.
5. **Does the pytest-cov JSON format give us branch/function %?** Resolved: No by default. `B=na F=na` is honest output. If a project enables branch coverage in `pyproject.toml`, the `B=` value becomes populated — the snippet will pick it up. Function-level % is not available from pytest-cov JSON regardless.
6. **Do existing scaffolded projects get retrofitted automatically?** Resolved: No. Out of scope for this proposal. A one-time user-issued prompt can instruct the engineering hub to patch an existing `scripts/verify.sh` on demand; building a retrofit gate into the hub would add cost to every story run for a one-time benefit.

---

## 5. Success Metrics

- For a story of comparable size to US-002: ≤10 documentation queries total (vs. 34 in the baseline transcript), with zero queries re-issued for a library that already has a complete cache entry.
- Zero Read tool calls on `coverage/index.html`, `coverage/coverage-final.json`, or `coverage/clover.xml` across implementer, reviewer, and QA roles.
- Implementer context-doc ingestion per task is smaller by the size of the Source Files excerpts (inventory-only is ~100 tokens vs. embedded source of 500–3000 tokens per task).
- Newly scaffolded projects' `scripts/verify.sh` prints `COVERAGE:` lines on success — verified by grep of the scaffolder dispatch's final bash output.
- `lib-cache.md` at end-of-story contains at least `apis_used` and one `code_snippets` entry per library used in the story, with `re_query_log` ≤3 entries per library.
