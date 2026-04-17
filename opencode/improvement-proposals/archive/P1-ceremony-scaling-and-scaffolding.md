# P1: Ceremony Scaling & Scaffolding Strategy

**Status:** Implemented — decisions recorded, files created/modified
**Relates to:** [P2 (Context Management)](./P2-context-management-and-memory.md), [P3 (Verification Pipeline)](./P3-verification-pipeline.md), [P5 (Testing Strategy)](./P5-testing-strategy-scaffold-verification.md)
**Scope:** `opencode/.opencode/agents/sdlc-engineering.md`, `opencode/.opencode/agents/sdlc-engineering-implementer.md`, `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md`, new scaffolding skill under `common-skills/`
**Transcript evidence:** `ses_278b8ce55ffeKxlkK4NQaSyTHd` — US-001-scaffolding, 20 sessions, 2h56m, 1.4M input tokens for ~500 lines of scaffold code

---

## 1. Problem Statement

The SDLC execution pipeline applies identical ceremony (implement → review → QA → story-review → story-QA → acceptance-validation) regardless of task complexity. A simple project scaffolding task (React + Vite + PWA) consumed 19 subagent dispatches, 20 sessions, and ~35M total tokens to produce ~500 lines of boilerplate code.

The multi-agent review architecture is **sound in principle** — lightweight implementation models need independent verification to prevent silent drift from planning intent. The problem is not the existence of review cycles but their **depth and repetition on low-complexity work**.

---

## 2. Root Cause Analysis (from transcript evidence)

### 2.1 Task boundary confusion — not reviewer strictness

The implementer added install/fallback guidance copy to `app.tsx` during Task 1 (app shell), but this belonged to Task 2 (PWA config). The reviewer **correctly** flagged this as a scope violation. The root cause was ambiguity in the task decomposition, not the reviewer being too strict.

**Evidence:** Task 1 staging doc said "Build app shell entrypoint and route baseline" with files `src/main.tsx`, `src/app/app.tsx`, `src/app/routes.tsx`, `src/styles/globals.css`. Task 2 said "Configure secure Vite + PWA installability and fallback baseline" with `MODIFY src/app/app.tsx`. The overlap on `app.tsx` created ambiguity about where install/fallback copy belongs.

### 2.2 Technical knowledge gaps not covered by documentation

The implementer iterated 4+ times on CSS testing (`?raw` → `?inline` → delete → `readFileSync` → dynamic import trick) because the Vitest CSS transform edge case isn't in context7's Vite documentation. This is a cross-library interaction issue that documentation lookup cannot solve.

**Evidence:** Lines ~14900-15500 of transcript. context7 returned correct Vite `?raw` docs, but the actual problem was Vitest's CSS plugin processing the file before the `?raw` suffix takes effect.

### 2.3 Coverage configuration causing false failures

QA found that `dev-dist/` generated files (workbox service worker, ~3400 lines) were counted in coverage totals, dragging overall coverage to 2.52% despite source files being at 100%. This triggered remediation cycles to fix the coverage config — a config issue that should have been present from initial scaffolding.

**Evidence:** Lines ~25385-25420 — coverage-summary.json shows `dev-dist/workbox-5a5d9309.js` at 0% coverage pulling totals down.

---

---

## Implementation Decisions (recorded after discussion)

### Scaffolding Agent Architecture (section 3.3)

**Decision:** `sdlc-engineering-scaffolder` implemented as a **mini-hub** (not a flat subagent), dispatching the existing implementer and a new dedicated scaffold-reviewer.

- Model: `openai/gpt-5.3-codex` (same as engineering hub — needs orchestration capability)
- Owns: stack detection, implementer dispatch, reviewer dispatch, 1+1 remediation loop, self-implementation fallback
- Phase 3 skip: resolved naturally — scaffolder returns STATUS to hub which proceeds to Phase 1; no story integration review ever triggered for scaffold work
- Existing implementer reused (not a dedicated scaffold-implementer): behavior shaped through dispatch message (scaffold checklist as ACs, no TDD skill, no plan artifacts)

### Scaffold Reviewer (section 5.2)

**Decision:** `sdlc-engineering-scaffold-reviewer` created as a dedicated agent (not TASK_TYPE signal on existing code-reviewer).

- Binary PASS/FAIL per checklist item — no severity tiers, no adversarial stance, no plan artifacts
- Runs verification gate suite independently
- Not in hub's permission block — only the scaffolder dispatches it

### Per-Stack Checklists (sections 3.1 + 5.1)

**Decision:** Checklist approach confirmed (not templates). Separate checklists added to each reference file:
- `common-skills/scaffold-project/references/react-vite.md` — Scaffolding Verification Checklist + Known Gotchas
- `common-skills/scaffold-project/references/pwa.md` — NEW file, PWA-specific checklist + gotchas
- `common-skills/scaffold-project/references/nextjs.md` — checklist + gotchas added
- `common-skills/scaffold-project/references/react-native.md` — checklist + gotchas added
- `common-skills/scaffold-project/references/python-uv.md` — checklist + gotchas added
- `common-skills/scaffold-project/references/monorepo.md` — checklist + gotchas added

Checklist sources: P1 transcript evidence, 2026 web research (per-stack pitfall articles), official docs — NOT model internal memory.

### Phase 3 Skip (section 5.3)

**Decision:** Resolved by architecture. Scaffolder-hub ends when scaffold-reviewer approves and returns STATUS to engineering hub. Hub proceeds to Phase 1. No conditional Phase 3 skip logic needed in the hub.

### Implementer Reuse

**Decision:** Reuse `sdlc-engineering-implementer` for scaffold tasks. Scaffolder-hub shapes behavior via dispatch (no TDD skill, checklist as ACs, gotchas as prevention). If implementer struggles with scaffold dispatches in practice, create dedicated scaffold-implementer as follow-up.

---

## 3. Proposed Solutions

### 3.1 Scaffolding Skill (Checklist-Based, Not Template-Based)

Create a new skill at `common-skills/scaffold-project-pwa/` (or extend existing `scaffold-project/`) containing a **checklist of structural requirements and known gotchas** rather than exact file templates.

**Rationale against full templates:**

- Library versions change; templates become stale and cause worse problems than no template (agent trusts outdated config, reviewer has to fight the template).
- Every project type (PWA, API, monorepo, mobile) would need its own template, creating a maintenance burden.
- context7 lookups for current API details are more reliable for exact syntax.

**Rationale for checklist approach:**

- Checklists encode structural knowledge and known pitfalls without brittle file contents.
- The implementer + checklist + context7 for current APIs produces correct, up-to-date code.
- Checklists are cheap to maintain — update a bullet point when a gotcha is discovered.

**Checklist contents (PWA example):**

```markdown
## PWA Scaffold Checklist

### Vite + React + TypeScript
- [ ] `package.json` with scripts: dev, build, preview, lint, typecheck, test
- [ ] `tsconfig.json` with strict mode, bundler module resolution, react-jsx
- [ ] `vite.config.ts` with React plugin
- [ ] `index.html` with #root div and module script entry
- [ ] `src/main.tsx` entry point with createRoot
- [ ] `src/app/app.tsx` shell component
- [ ] `src/styles/globals.css` base styles

### PWA Configuration
- [ ] `vite-plugin-pwa` installed and configured in vite.config.ts
- [ ] Web manifest with name, short_name, icons (192x192 + 512x512 raster PNGs + maskable)
- [ ] Service worker with precache patterns for static assets
- [ ] devOptions.enabled for development PWA testing

### Testing Infrastructure
- [ ] Vitest configured with coverage provider (v8)
- [ ] Coverage MUST exclude: dist/, dev-dist/, node_modules/, test-results/
- [ ] Coverage MUST scope to: src/**/*.{ts,tsx} excluding test files
- [ ] ESLint with TypeScript plugin, ignoring dist/dev-dist

### Known Gotchas
- Vitest CSS transforms: Do NOT test CSS file contents via ?raw or ?inline imports — they return empty strings. Use readFileSync for static content checks, or test rendered behavior instead (preferred).
- dev-dist/ generated files: Always exclude from coverage and lint config from the start. vite-plugin-pwa generates these during dev.
- PWA icons: Chrome requires raster PNG icons (not just SVG) for installability. Include both 192x192 and 512x512.
- Coverage threshold: During scaffolding tasks, verify coverage on source files only. Do not enforce global thresholds until feature implementation begins.

### Verification Script (Makefile target)
- [ ] Single `make verify` or `npm run verify` that runs: lint && typecheck && test && build
```

### 3.2 Task Decomposition Clarity Rules

Add rules to the hub's Phase 1c (task decomposition) to prevent the boundary confusion seen in the transcript:

1. **No overlapping MODIFY targets across tasks.** If Task 1 creates `app.tsx` and Task 2 needs to modify it, the task decomposition must explicitly state what content belongs to which task. The staging doc should include a "Boundary" note for shared files.
2. **Scaffolding tasks should be self-contained.** Task 0 (scaffold) should produce a building, linting, type-checking, testing project. No subsequent task should need to fix scaffold-level config (coverage exclusions, lint ignores, etc.).
3. **Feature-boundary tasks should not include install/runtime behavior.** The "app shell" task produces the structural shell. The "PWA installability" task adds all install-related behavior. If both touch the same component, the decomposition must specify exactly which JSX/logic belongs to which task.

### 3.3 Review Iteration Cap for Scaffold Tasks

Currently the engineering hub allows up to 3 review iterations per task. For scaffolding tasks (Task 0, Phase 0b), cap this at **1 review + 1 remediation**. Rationale:

- Scaffold code is structural, not business logic. If the scaffold builds, lints, type-checks, and tests pass, the review should focus on structural completeness, not code style refinement.
- The existing "Adversarial by default" stance in the code reviewer (`sdlc-engineering-code-reviewer.md` line 68-73) forces finding issues even when none exist, which is counterproductive for boilerplate.

**Proposed change to `sdlc-engineering-code-reviewer.md`:**

Add a dispatch-level signal `TASK_TYPE: scaffold | feature | integration` that the hub sets. When `TASK_TYPE: scaffold`, the reviewer applies relaxed criteria:

- Spec compliance check: does the scaffold match the checklist? PASS/FAIL.
- Build/lint/type/test gates: PASS/FAIL.
- Do NOT require style-level suggestions on scaffold boilerplate.
- Do NOT flag coverage thresholds below target if all source files are individually at 100%.

---

## 4. Affected Agents and Skills (as implemented)

| File | Change Type | Description |
|------|-------------|-------------|
| `common-skills/scaffold-project/SKILL.md` | Modified | Added gotcha-first workflow step, per-stack checklist verification gate, pwa.md reference |
| `common-skills/scaffold-project/references/react-vite.md` | Modified | Added Scaffolding Verification Checklist + Known Gotchas |
| `common-skills/scaffold-project/references/pwa.md` | Created | PWA-specific checklist + gotchas (new file) |
| `common-skills/scaffold-project/references/nextjs.md` | Modified | Added Scaffolding Verification Checklist + Known Gotchas |
| `common-skills/scaffold-project/references/react-native.md` | Modified | Added Scaffolding Verification Checklist + Known Gotchas |
| `common-skills/scaffold-project/references/python-uv.md` | Modified | Added Scaffolding Verification Checklist + Known Gotchas |
| `common-skills/scaffold-project/references/monorepo.md` | Modified | Added Scaffolding Verification Checklist + Known Gotchas |
| `.opencode/agents/sdlc-engineering-scaffolder.md` | Created | Mini-hub: stack detection, implementer + reviewer dispatch, 1+1 remediation loop |
| `.opencode/agents/sdlc-engineering-scaffold-reviewer.md` | Created | Checklist-based scaffold reviewer (binary PASS/FAIL, no adversarial stance) |
| `.opencode/agents/sdlc-engineering.md` | Modified | Phase 0b single dispatch to scaffolder; added scaffolder to permissions; removed scaffold-project from Skills table |


---

## 5. Open Questions

1. **Should there be per-stack scaffolding checklists?** **Resolved: Yes.** Separate checklists added to each reference file under `common-skills/scaffold-project/references/`. PWA got its own dedicated file (`pwa.md`). Each stack's reference now has `## Scaffolding Verification Checklist` and `## Known Gotchas` sections sourced from transcript evidence and 2026 web research.

2. **Does the reviewer's "adversarial by default" stance need a broader rethink?** **Resolved for scaffold context:** dedicated `sdlc-engineering-scaffold-reviewer` created with binary PASS/FAIL and no adversarial stance. Existing code-reviewer unchanged. Broader adversarial scaling for feature work is deferred to a future proposal.

3. **Should scaffolding bypass Phase 3?** **Resolved by architecture:** `sdlc-engineering-scaffolder` mini-hub completes before Phase 2 begins. Engineering hub receives a single STATUS and proceeds to Phase 1. Phase 3 never runs for scaffold work.

**Remaining open question:**

4. **Dedicated scaffold-implementer vs reusing existing implementer?** Current decision: reuse with scaffold-specific dispatch context (no TDD skill, checklist as ACs, gotchas as pre-prevention). Evaluate after first scaffold runs — if implementer struggles with missing plan artifacts or TDD overhead, create dedicated scaffold-implementer as follow-up.

---

## 6. Success Metrics

- A PWA scaffolding task (equivalent to US-001 Task 0 + Task 1) completes in **1 implementer dispatch + 1 review + 1 QA**, not 3+ cycles.
- Total token consumption for a 4-task scaffold story drops below **500K input tokens** (from 1.4M).
- Zero coverage-config-related remediation cycles (gotchas checklist prevents them).
- Zero task-boundary confusion cycles (decomposition rules prevent them).

