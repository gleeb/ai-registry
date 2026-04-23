# P19: Environment-Variable-Based Secrets Protocol

**Status:** Implemented — 2026-04-23 (drafted 2026-04-22)
**Sequencing:** Foundational for this batch. P20 (external integration contract verification), P21 (user-reported check / defect triage), and P22 (plan-change protocol) all depend on a working credential story because their own verification steps assume they can or cannot reach a real external endpoint. Land P19 first so downstream proposals can reference a concrete mechanism instead of re-deriving one.
**Relates to:** P5 (Testing Strategy — archived), P11 (Acceptance Validator Read-Only), P16 (Per-Task AC Traceability), P20, P21, P22
**Scope:**
- `opencode/.opencode/agents/sdlc-planner-api.md`, `opencode/.opencode/agents/sdlc-planner-stories.md`, `opencode/.opencode/agents/sdlc-planner.md`
- `opencode/.opencode/agents/sdlc-engineering.md` (Phase 0a readiness check)
- `opencode/.opencode/agents/sdlc-engineering-implementer.md`, `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md`, `opencode/.opencode/agents/sdlc-engineering-qa.md`, `opencode/.opencode/agents/sdlc-engineering-acceptance-validator.md`
- `opencode/.opencode/agents/sdlc-coordinator.md` (escalation taxonomy entry)
- Per-project `.env.example`, per-project `.env` (gitignored), per-project `plan/cross-cutting/required-env.md`
**Transcript evidence:** `ses_24a319c81ffelunHGnCfk7KcBT` — US-004-photo-intake-identification. The story shipped with `demo-api-key` hardcoded in the `PhotoIntakeHarness` component and a mocked fetch plumbing path. The real provider code path was never exercised end-to-end during execution or validation. When the user provided a real OpenRouter key, the app still failed: `tests/resources/openrouter-free.key.txt` was a stand-in file the agents masked for security reasons, and when the user saved a key there, the application code never read from it — there was no convention saying where credentials should live or how to consume them.

---

## Read Order

**Prerequisites** (read / land first): none in the 2026-04-22 cluster. P19 is the foundational proposal of this batch. Light conceptual familiarity with the existing testing conventions (archived P5) helps but is not required.

**Consumers** (depend on this proposal):
- **P20** — real-traffic wire-format verification at plan time and QA time needs a real credential; P19's `required_env` field and Phase 0a gate are the mechanisms P20 consumes.
- **P21** — defect-incident reproduction against a real external endpoint requires credentials; the `MISSING_CREDENTIALS` escalation is P21's fallback when `required_env` is unset.
- **P22** — plan changes that add or swap external providers atomically update `.env.example` and `required-env.md` as part of the PC-NNN artifact.
- **P16 (amended §3.5)** — the `evidence_class: real | stub-only | static-analysis-only` field assumes P19's taxonomy and validator verdict (`ACCEPTED-STUB-ONLY`) exist.

**Suggested batch reading order** (2026-04-22 cluster): **P19 (you are here)** → P20 → P16 (amended §3.5) → P21 → P14 (amended trigger 5) → P22.

---

## 1. Problem Statement

The US-004 failure chain had three credential-handling defects that each compounded into the next:

1. **The implementer invented a placeholder credential (`demo-api-key`) in product code** to make the harness "run green" locally, because there was no convention for "this story needs a real key; stop if you don't have one." The placeholder silently shadowed the real provider-settings path.
2. **The test layer baked the same placeholder in as the expected value.** Tests asserted against `demo-api-key`, which meant any real-credential regression would still produce green tests. There was no `real:` vs `stub:` distinction at the test fixture level.
3. **When a real key finally arrived it arrived in an ad-hoc location** (`tests/resources/openrouter-free.key.txt`). There was no declared place for it, no declared consumer, no declared name, and multiple agents tried to mask or scrub the value thinking it was a leaked secret, because the file's purpose was not legible to them.

The underlying issue: **the SDLC pipeline has no protocol for secrets.** No planner declares what secrets a story needs. No hub checks whether declared secrets are present before starting. No implementer rule says "halt instead of inventing a placeholder." No validator rule says "if this story's real-path verification required a secret and the secret is unset, you cannot sign off." No coordinator escalation type covers "missing credential."

This is the smallest change that unblocks the rest of the batch. P20 cannot verify a real external contract without a real credential. P21 cannot reproduce a user-reported defect against a live endpoint without a real credential. P22 cannot evaluate a plan change that adds a new provider without knowing whether that provider's credential is available.

## 2. Root Cause Analysis

### 2.1 Secrets are not first-class planning artifacts

`plan/user-stories/<story>/story.md` and `plan/user-stories/<story>/api.md` list dependencies, contracts, and risks, but neither declares what environment variables a story needs at runtime or in tests. The planner has no field to fill in, so the implementer has no field to read, so the hub has no field to gate on. The information exists only in the planner's head.

### 2.2 No pre-flight gate on the engineering hub

Phase 0a (Readiness Check) verifies plan artifacts exist and dependency stories are complete. It does not verify that the runtime environment required by the story is present. A story that needs `OPENROUTER_API_KEY` enters Phase 1b with that variable unset and only discovers the problem when an integration test runs (or, as in US-004, not even then, because the test used a placeholder).

### 2.3 Implementer and scaffolder have no "halt on missing credential" directive

When a required configuration value is absent, the current implementer spec tolerates three behaviors: substitute a placeholder, hardcode a stub, or mock the dependency. All three happened in US-004. None of them are wrong in isolation — the wrong thing is that no policy says which to pick when, and none of them carry a marker that makes the choice legible downstream.

### 2.4 Test conventions don't distinguish real from stub

Tests mix two unrelated concerns:
- **Unit-level stubs** — where a placeholder credential is semantically correct because no network call is made.
- **Integration-level wiring** — where the same placeholder is a defect because a real call would fail.

Nothing in the test naming, fixture location, or `describe`-block conventions separates these. The reviewer and QA agents cannot tell them apart either.

### 2.5 Security-minded masking fought the real-credential workflow

When the user saved a real key into `tests/resources/openrouter-free.key.txt`, subsequent agents — doing exactly what their security instincts told them — masked or scrubbed the value. That behavior is correct in general but wrong in this specific flow: the user's intent was "here is a real key I deliberately want the tests to use." Without a declared, legitimate channel for live credentials, agents cannot distinguish "leaked secret" from "approved test credential," and they default (correctly, given their priors) to treating it as leaked.

### 2.6 No coordinator escalation type for "missing credential"

The coordinator's escalation taxonomy covers plan gaps, blocker incidents, and user-request mismatches. It does not name "this story cannot start because a declared credential is unset." So when the hub hits a missing credential, it has no named channel to surface it through, and ends up either silently proceeding (the US-004 outcome) or returning an unstructured "blocked: unclear" message.

## 3. Proposed Approach

Six changes, sequenced so each depends only on the previous ones:

### 3.1 Planner declares `required_env` in story manifests

`required_env` covers every external-service environment variable a story consumes — API keys, database URLs, BaaS credentials (Supabase, Firebase, etc.), storage tokens, webhook secrets, non-secret base URLs, feature flags sourced from the environment. It is not limited to HTTP-API authentication. The planner-api agent owns the declaration for all of these, because from the story's perspective they are all "external-service configuration the runtime needs"; whether the service happens to be accessed via REST, an SDK, or a connection string is an implementation detail.

Every `story.md` manifest gains a `required_env` field listing the environment variable names the story needs at implementation time, at test time, and at validation time. Each entry records:

```yaml
required_env:
  - name: OPENROUTER_API_KEY
    purpose: >
      Live provider authentication for the photo-identification path.
      Used by src/features/media/identify-bottles.ts at runtime.
      Consumed by integration tests in tests/integration/photo-intake-identification.test.ts.
    scope: [runtime, integration-test, validation]
    sensitivity: secret
    reference: "https://openrouter.ai/docs"
```

- `scope` is one or more of `runtime | integration-test | validation | unit-test-placeholder`.
- `sensitivity: secret` means the value must never be logged, echoed, or committed; `sensitivity: config` means it's non-secret configuration (e.g., a base URL) that can still be declared for portability.
- `reference` is an optional link to the provider's technical documentation (how the credential is used, rate limits, SDK docs). It is not an acquisition guide — the value itself is always supplied by the user. Omit the field entirely when no useful public documentation exists (e.g., internal services).

Stories that legitimately need no environment variables declare `required_env: []` with a one-line reason (e.g., "purely in-memory feature"). Empty-by-omission is not allowed — the field is present on every story.

The planner-api and planner-stories agents populate this field jointly: api contributes the runtime-integration entries, stories contributes the test/validation scope annotations.

### 3.2 `.env.example` is the canonical consolidated declaration

The project maintains a single `.env.example` at the repo root. It lists every `required_env` entry from every story ever planned, as a union. Each entry carries a comment identifying which story introduced it:

```dotenv
# Introduced by US-004-photo-intake-identification (scope: runtime, integration-test, validation)
# Purpose: OpenRouter provider authentication for photo identification.
# Reference: https://openrouter.ai/docs
OPENROUTER_API_KEY=
```

`.env` (the real file with values) is gitignored and holds the user's actual secrets. Applications and tests load it via `dotenv` (already in the project's dependency tree per the user's clarification). Agents are forbidden from reading, echoing, committing, or quoting the contents of `.env`; they may read `.env.example` freely.

There is exactly one `.env` file per project. Stories never get their own `.env`. When two stories declare the same variable (by `name`), the entry in `.env.example` is deduped and its comment header lists all contributing stories; the single shared value lives in the one `.env`. A future plan change can partition environments if a genuine reason emerges (e.g., mutually incompatible tenants), but the default and overwhelmingly common case is one `.env`.

A lightweight sibling file — `plan/cross-cutting/required-env.md` — is maintained by the planner aggregator (or a small script triggered from checkpoint.sh) and is the human-readable cross-reference: which stories consume which variables, with `reference` links and purpose text. This file is the one the coordinator reads when it needs to explain a missing variable to the user.

**Who reads what — the three-way split.** This section is called out explicitly because the US-004 failure mixed these up and the fix relies on keeping them separate:

- The **application** (code in `src/` or `app/`) loads `.env` via `dotenv` at startup and reads values from `process.env` at runtime. This is the *only* place credential values are read.
- The **Phase 0a gate** (§3.3) checks *presence only* of named variables in the shell environment the hub is running in — a boolean per name, never the value. The gate does not read `.env` directly; it relies on the shell having loaded it (or on the user having exported the values).
- **Agents** read only declaration artifacts: `.env.example`, `plan/cross-cutting/required-env.md`, and each story's `required_env` block. Agents never parse `.env`, never echo values from `process.env`, and never quote credential values in transcripts or tool output.

This split is what reconciles the secret-masking instinct (§2.5) with the real-credential workflow: values live in exactly one path (`.env` → `process.env` → application), and every other actor deals in names and declarations.

**CI is explicitly out of scope for v1.** This proposal governs local development and local validation only. CI secret-store integration (GitHub Actions secrets, Vercel env, etc.) is a future proposal if and when CI enters the pipeline.

### 3.3 Phase 0a gate: verify declared env vars are set

The engineering hub's Readiness Check (sdlc-engineering.md §Phase 0a) adds a third gate alongside the existing "plan artifacts exist" and "dependency stories complete" gates:

- Read `required_env` from the active story's `story.md`.
- For each entry with `scope` including `runtime` or `integration-test`:
  - Check that the environment variable is set to a non-empty value in the shell environment the hub is running in.
  - If unset → HALT.
- On HALT, the hub returns a structured `MISSING_CREDENTIALS` blocker to the coordinator:
  ```
  BLOCKER TYPE: MISSING_CREDENTIALS
  STORY: US-004-photo-intake-identification
  MISSING:
    - name: OPENROUTER_API_KEY
      reference: "https://openrouter.ai/docs"
      set_instruction: "add OPENROUTER_API_KEY=<value> to .env"
  ```

The hub does NOT proceed, does NOT fabricate placeholder values, does NOT downgrade the story to a stub-only implementation. Escape hatch: if a story's planner annotation marks a variable as `scope: [unit-test-placeholder]` only (not runtime or integration), the gate tolerates it unset, but then downstream validators (§3.5) record the story as "stub-validated" rather than "real-validated."

### 3.4 Implementer and scaffolder halt-on-missing rule

The implementer spec gains an explicit directive:

> **Never fabricate or hardcode credentials.** If an environment variable declared in the story's `required_env` is not present at runtime, return `BLOCKER: MISSING_CREDENTIALS` with the variable name. Do NOT substitute a placeholder value such as `demo-api-key`, `test-key`, or any literal string, even to make a local test pass. Placeholder values are permitted only in test files explicitly marked `scope: unit-test-placeholder` in the test fixture header.

The scaffolder spec carries a mirror of this rule for scaffolding stories. The code-reviewer spec adds a corresponding finding class: "hardcoded-placeholder-credential" → Critical finding when the story declares the variable in `required_env`.

### 3.5 Test convention: `real:` vs `stub:` fixtures

Tests that exercise a credential-bearing path declare their mode in the first line of the test file or fixture:

```ts
// test-mode: real (requires OPENROUTER_API_KEY; skips if unset)
```
or
```ts
// test-mode: stub (offline; uses fixture __TEST_PLACEHOLDER_KEY__)
```

Rules:
- `real` tests read credentials from `process.env` and `test.skip` themselves (with a visible log line) when the variable is unset. They never synthesize a value.
- `stub` tests use a single canonical placeholder (`__TEST_PLACEHOLDER_KEY__`) that is deliberately obvious and would fail loudly if accidentally sent to a real endpoint. They never read from `process.env` for the credential under test.
- QA dashboards aggregate per-story: "N real tests, M stub tests, K real tests skipped because env unset." If all tests for a credential-bearing AC are stub-only, the AC is annotated "stub-evidence-only" and P16's AC-traceability report flags it.

### 3.6 Acceptance validator downgrade rule

The acceptance validator (Phase 4) checks `required_env` at validation time:

- If a declared `runtime` or `integration-test` variable is unset, the validator cannot produce real-path evidence and MUST either:
  - Block acceptance (default for stories whose ACs are explicitly framed in terms of a real provider), or
  - Record "evidence type: stub-only, env var X unset at validation time" and downgrade the verdict to `ACCEPTED-STUB-ONLY`.

The downgraded verdict is a distinct status, not a pass. The coordinator surfaces it to the user as "this story passed with stub evidence only; to upgrade to real-path acceptance, set X and re-run validation." This ensures the US-004 pattern — "shipped green, failed on first real use" — cannot recur silently.

### 3.7 Coordinator escalation entry

The coordinator's escalation taxonomy gains a `MISSING_CREDENTIALS` entry:

- **Trigger:** hub returns `BLOCKER: MISSING_CREDENTIALS`.
- **Response:** show the user the missing variable list from the structured blocker, quote the `reference` link verbatim when present (otherwise state that no reference link is declared), show the exact `.env` line to add, and pause until the user confirms the environment is configured. On confirmation, re-dispatch the hub (not re-plan, not re-decompose — just retry Phase 0a).
- **Not a plan-change.** Missing credentials do not trigger the planner. They trigger a user environment action. If the user reports the credential is unobtainable (e.g., the provider requires payment they don't want to make), THAT is a plan change and routes to P22's flow.

### 3.8 User-initiated credential registration (bootstrap + mid-execution)

§3.1–§3.7 describe the forward path: planner declares, hub gates, implementer halts, validator downgrades. They do not cover two real scenarios that surface during day-to-day use:

- **Bootstrap / retrofit.** An existing project predates P19 and has no `required_env` declarations, no `.env.example`, and no `required-env.md`. The user wants to bring it up to P19 compliance before or during the next execution cycle. This is the state every project-in-flight is in on the day P19 lands.
- **Mid-execution addition.** A story is already executing and the user realizes an additional credential is needed — e.g., an OpenRouter key to drive end-to-end validation — that the planner did not anticipate. The user wants to declare the new variable and continue without replanning.

Both scenarios require a judgment the coordinator cannot make: **is this a missed declaration (the plan already implied this variable; we just forgot to record it), or is it a disguised scope change (the plan said we'd call provider X but we now want provider Y)?** Only the planner can tell the difference, because only the planner can read `api.md`, the architecture artifacts, and the story scope declarations with the context to judge. The same applies to attribution ("which other stories should also declare this variable?"), to classification sanity ("the user said `scope: [runtime]`, but the integration tests for this feature will need it too"), and to contract-gap detection ("this new variable reveals that `api.md`'s auth model is under-specified"). Putting these decisions on the coordinator would either force the coordinator to grow planner-shaped capabilities or force it to accept user input without validation — the same class of failure that produced US-004.

Therefore: credential registration is a **planner-owned flow**, dispatched by the coordinator but executed by the planner hub with a dedicated skill. The coordinator is the user-facing router; the planner hub is the decision-maker and writer.

- **Skill:** `.opencode/skills/credential-registration/SKILL.md` (new). Loaded by the **planner hub** (`sdlc-planner`) when it is dispatched with a `CREDENTIAL_REGISTRATION` directive. Not loaded by the coordinator. Not loaded by any execution agent.
- **Coordinator's role** (thin): recognize the user intent ("add / register / wire / declare an environment variable / secret / API key / provider credential"), dispatch the planner hub with the directive and any fields the user supplied, relay the planner's summary back to the user on return, and on user confirmation that `.env` has been populated, re-dispatch the engineering hub to re-run Phase 0a. The coordinator never writes `.env.example`, `required-env.md`, or any `story.md`. See §3.7 for the adjacent but distinct `MISSING_CREDENTIALS` flow (declaration exists, value missing locally) which remains coordinator-handled.
- **Planner hub's role** (decision + write): under the skill's guidance, decide whether the request is (a) declaration-only (missed declaration; skill writes the three artifacts atomically), (b) scope-change-in-disguise (new provider, swapped provider; hand off to P22's plan-change protocol), or (c) bootstrap (retrofit scan + attribution across all in-flight stories). The planner hub has read access to `api.md`, architecture artifacts, and every `story.md`; it has write access to `plan/` and repo-root `.env.example`. These are exactly the tools the decision requires.

**Bootstrap mode** (planner-hub execution):

1. Detect the gap: no `.env.example` at repo root, or no `plan/cross-cutting/required-env.md`, or in-flight stories with no `required_env` field.
2. Inventory current env-var usage by scanning `src/`, `app/`, `lib/`, and `tests/` for `process.env.<NAME>`, `import.meta.env.<NAME>`, and framework-specific accessors detected from `package.json`.
3. Classify each detected variable (sensitivity, scope) using naming heuristics and usage location; the planner hub can consult `planner-api` as a read-only subagent to validate classifications against each story's `api.md`.
4. Attribute each variable to a story by cross-referencing consuming files against each `story.md`'s scope declarations. Unambiguous matches are assigned directly; genuinely shared code is marked `attribution: unassigned` with the candidate stories listed for user confirmation.
5. Seed `.env.example` and `plan/cross-cutting/required-env.md` in one pass; append `required_env` blocks to affected `story.md` files.
6. Return a structured summary to the coordinator: inventory counts, per-variable classification, unassigned-attribution list requiring user confirmation, and next-step instruction (typically "set values in `.env`, then resume").

**Mid-execution addition mode** (planner-hub execution):

1. Receive the dispatch payload: `name`, optional `purpose`, optional `scope`, optional `sensitivity`, optional `reference`, the active story identifier, and any user-provided attribution hints.
2. **Scope-change detection.** Read the active story's `api.md` and architecture artifacts. Ask: does the current plan already reference this provider or the class of integration this variable authenticates? If not, the request is a plan change — return a `ROUTE_TO_P22` verdict to the coordinator with a one-paragraph rationale, and do not write any artifacts. If yes, proceed as declaration-only.
3. **Field validation.** Reconcile user-provided fields with what `api.md` implies (e.g., integration tests referencing this provider in `scope: [integration-test]`). Flag conflicts in the return summary; the coordinator surfaces them to the user.
4. **Cross-story propagation.** Search other `story.md` files for code paths that will also consume this variable; if any are found, include them in the attribution list (`Also consumed by:` in `required-env.md`, additional `required_env` entries in those stories).
5. **Atomic write.** Update `.env.example`, `plan/cross-cutting/required-env.md`, and all affected `story.md` files' `required_env` blocks in one pass.
6. Return a structured summary: declared variable, attributions, detected classifications, the exact `.env` line the user needs to add, and a re-dispatch hint for Phase 0a.

**Coordinator-side flow** (receiving the planner's return):

1. Relay the planner's summary to the user. If the verdict is `ROUTE_TO_P22`, present the rationale and ask whether to proceed with a plan change (route via P22) or abandon the registration.
2. Instruct the user to add the value to `.env`. Never ask the user to paste the value into chat; never echo or quote a value the user does include. If the user pastes a value anyway, reply with a single redaction notice and proceed as if the value was not shown.
3. On user confirmation, re-dispatch the engineering hub to re-run Phase 0a. The §3.3 gate now sees the declaration and either proceeds (value set) or returns `MISSING_CREDENTIALS` (value still unset). No re-plan, no re-decompose, no task re-shuffling.

**What this flow does not do.** It does not invent values, does not write to `.env`, does not modify product code, and does not create or merge branches. A declaration-only run does not alter `api.md`, story scope, architecture, or acceptance criteria — that is P22's job, and the planner hub routes there explicitly when it detects the scope-change case.

**Cross-machine workflow (relevant for multi-device development).** Because `.env.example` and `required-env.md` are committed (values in `.env` are not), a declaration produced on machine A travels with the repo. On machine B the user pulls, the locally-committed declarations are present, but the local shell has no values. That is a `MISSING_CREDENTIALS` situation (§3.7), not a registration situation — the coordinator handles it directly without dispatching the planner, because no planning decision is required. Bootstrap mode is idempotent: dispatching the planner hub with `CREDENTIAL_REGISTRATION --bootstrap` on a project that already has `.env.example` detects no gap and returns a no-op summary.

## 4. Expected Impact / ROI

**Primary impact:** Eliminates the silent-stub-ship failure mode. US-004's observed sequence — "shipped with `demo-api-key` hardcoded, green locally, 401 on first user attempt" — is structurally blocked by §3.3 (hub halts before the story starts) and §3.4 (implementer halts instead of inventing placeholder) and §3.6 (validator won't sign off without real-path evidence).

**Secondary impact:** Unblocks P20 and P21. External contract verification (P20) and defect reproduction (P21) both presume a real endpoint is reachable. Without P19, both proposals reduce to "hope the developer hand-configured the environment correctly." With P19, both can declare "this step requires `required_env: X`; if X is unset the step blocks with a named escalation."

**Tertiary impact:** Reduces agent-security thrash. Without a declared channel for live credentials, agents oscillate between "mask everything that looks like a secret" and "use whatever literal value is in the file." With a declared channel (`.env` values come from env, not from files), agents have a stable policy: never echo env values, treat the `.env.example` and `required-env.md` as readable, treat `.env` and all env values as redacted-on-output.

**ROI consideration:** Low implementation cost (all agent-spec and template changes, no runtime plumbing; `dotenv` is already present). High unblock value for the rest of the batch. Zero ongoing cost once in place — the gates are one-time checks per dispatch.

## 5. Success Metrics (for post-run verification)

- **M1 (hard):** Every story.md in `plan/user-stories/` has a `required_env` field (possibly `[]` with reason). Verifiable by grep or a checkpoint.sh validator.
- **M2 (hard):** No product code file in `src/` or `app/` contains a hardcoded credential-shaped literal matching the patterns `demo-api-key`, `test-key`, or similar placeholders. Verifiable by a lint rule or a checkpoint.sh audit step.
- **M3 (hard):** Every test file that touches a credential-bearing path has a `test-mode: real | stub` header. Verifiable by grep.
- **M4 (hard):** When a story with a populated `required_env` is dispatched and the variable is unset, the hub returns `BLOCKER: MISSING_CREDENTIALS` without entering Phase 1. Verifiable by transcript inspection.
- **M5 (soft):** No story is accepted as `ACCEPTED` (not `ACCEPTED-STUB-ONLY`) when its `required_env` was unset during validation. Verifiable by cross-referencing validator output with env state.
- **M6 (soft):** Zero occurrences of agents masking or quoting the user's live credentials after the user has legitimately set them in `.env`. Qualitative, reviewable during post-mortem.

## 6. Risks & Tradeoffs

- **Risk:** The planner under-declares `required_env` and the gate misses a real dependency. Mitigation: the api.md contract in P20 requires any external host to trace to a `required_env` entry; plan-validator cross-checks. A missing entry becomes a planning defect caught in Phase 3-plan.
- **Risk:** Developers hate `.env` dances for trivial local tinkering. Mitigation: stub mode is first-class (§3.5). Day-to-day unit-test loops do not need the real key. Only integration and validation paths do.
- **Risk:** `MISSING_CREDENTIALS` escalations become noisy for multi-provider stories. Mitigation: the blocker batches all missing variables in one return; the user sees a single list, not one escalation per variable.
- **Risk:** Secrets leak via verbose logging in agent transcripts. Mitigation: agents are instructed to quote only variable NAMES, never values; the transcript-scrubbing behavior that fought the US-004 workflow stays intact for actual values but is suppressed for names.
- **Tradeoff:** Stories with truly no external dependencies still carry an `required_env: []` declaration. Small cost, uniform shape.
- **Tradeoff:** `ACCEPTED-STUB-ONLY` is a new verdict status that downstream tooling (dashboards, release notes) must learn to read. Acceptable — it makes a previously invisible distinction visible.

## 7. Open Questions (resolved 2026-04-23)

1. **Who writes `.env.example`?** The planner-api agent owns initial declarations at plan time; the planner aggregator cross-validates against the union of all `required_env` fields. For mid-execution additions and for retrofitting existing projects, the coordinator's `credential-registration` skill (§3.8) writes the artifacts directly. The declaration scope is **all** external-service variables — API keys, BaaS credentials (Supabase, Firebase, etc.), database URLs, storage tokens, webhook secrets, environment-sourced config — not just HTTP-API authentication.
2. **Multi-story sharing.** Each story declares its own `required_env` (local truth). `.env.example` is the deduped union: a variable used by multiple stories appears exactly once, with all contributing stories listed in its comment header. There is exactly one `.env` file per project. Per-story `.env` partitioning is explicitly not supported by v1; a future plan change can introduce it if a concrete reason emerges.
3. **`reference:` field (renamed from `acquire:`).** Optional, human-readable link to the provider's **technical documentation** — how the credential is used, rate limits, SDK references. It is not an acquisition guide. The value itself is always supplied by the user; there is no agent-driven acquisition step, and the coordinator never asks the user "how do I get this key?" Omit `reference:` entirely when no useful public documentation exists.
4. **Interaction with CI.** Explicitly out of scope for v1. This proposal governs local development and local validation only. CI secret-store mapping (GitHub Actions, Vercel, etc.) is a future proposal if and when CI enters the pipeline.
5. **Who reads what?** Three-way split (also documented at the end of §3.2): the **application** loads `.env` via `dotenv` and reads values from `process.env` at runtime — this is the only place values are read. The **Phase 0a gate** checks *presence only* in the shell environment (boolean per name, never value). **Agents** read only declaration artifacts (`.env.example`, `plan/cross-cutting/required-env.md`, and the `required_env` block of each `story.md`); agents never parse `.env`, never echo `process.env` values, and never quote credential values in transcripts or tool output.

## 8. Affected Agents, Skills, and Files (preliminary)

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-planner-api.md` | Modified | When producing `api.md`, record every external-service environment variable — API keys, BaaS credentials, DB URLs, storage tokens, webhook secrets, non-secret base URLs — as a `required_env` entry with the appropriate `scope`. Update `.env.example` as a side-effect of producing api.md. Scope is explicitly not limited to HTTP-API auth. |
| `opencode/.opencode/agents/sdlc-planner-stories.md` | Modified | When producing `story.md`, consolidate `required_env` entries from api.md and testing into the story manifest. Emit `required_env: []` with reason if none. |
| `opencode/.opencode/agents/sdlc-planner.md` | Modified (light) | Plan-validator cross-checks: every external service referenced in api.md has a matching `required_env` entry; no unused entries in `.env.example`. |
| `opencode/.opencode/agents/sdlc-engineering.md` | Modified | Phase 0a adds the env-var gate per §3.3. Return contract gains `BLOCKER: MISSING_CREDENTIALS`. |
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | Modified | "Never fabricate credentials" directive per §3.4. `BLOCKER: MISSING_CREDENTIALS` return. |
| `opencode/.opencode/agents/sdlc-engineering-scaffolder.md` | Modified | Mirror of the implementer rule for scaffolding stories. |
| `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md` | Modified | New finding class: `hardcoded-placeholder-credential` → Critical when variable exists in `required_env`. |
| `opencode/.opencode/agents/sdlc-engineering-qa.md` | Modified | Per-story summary reports `real / stub / skipped-real` test counts. Flags "all-stub" ACs. |
| `opencode/.opencode/agents/sdlc-engineering-acceptance-validator.md` | Modified | Per §3.6: check env at validation time; emit `ACCEPTED` or `ACCEPTED-STUB-ONLY`; block if ACs require real evidence. |
| `opencode/.opencode/agents/sdlc-coordinator.md` | Modified | `MISSING_CREDENTIALS` escalation entry per §3.7 (declaration exists, value missing locally — coordinator-handled). New routing entry per §3.8: when the user's intent is "register / add / declare an env var," dispatch `sdlc-planner` with a `CREDENTIAL_REGISTRATION` directive and the user-supplied fields. The coordinator never writes declaration artifacts; it relays the planner's summary and re-dispatches the engineering hub at Phase 0a on user confirmation. |
| `opencode/.opencode/agents/sdlc-planner.md` | Modified | Accept `CREDENTIAL_REGISTRATION` dispatch directive (bootstrap or mid-execution addition). Load `credential-registration` skill on receipt. Runs in a narrow declaration-only mode that does NOT trigger a full planning cycle; may consult `planner-api` as a read-only subagent for classification and scope-consistency checks. Returns a structured summary to the coordinator with one of three verdicts: `DECLARED` (artifacts written), `ROUTE_TO_P22` (request is a scope change in disguise), or `NOOP` (bootstrap detected no gap). |
| `opencode/.opencode/skills/credential-registration/SKILL.md` | Created | Planner-hub-loaded skill that implements §3.8. Covers bootstrap (retrofit scan, classification, cross-story attribution), mid-execution addition (scope-change detection against `api.md`, cross-story propagation, atomic three-artifact write), and the scope-change escalation path to P22. |
| `.env.example` | Created (in consuming projects) | Canonical consolidated declaration per §3.2. Produced by planner-api at plan time or by the §3.8 skill at retrofit/registration time. |
| `plan/cross-cutting/required-env.md` | Created (in consuming projects) | Human-readable cross-reference per §3.2. |
| Test fixture template | Modified | `test-mode: real | stub` header per §3.5. |

---

## 9. Relation to Prior Proposals

- **P5 (archived — Testing Strategy):** P19 refines P5's test-intensity model with a `real | stub` axis orthogonal to P5's task-class axis. Unit tests remain stub; integration and validation tests are where the `real` distinction bites.
- **P11 (Acceptance Validator Read-Only):** P19 extends the validator's contract with an env-state check and a new downgraded verdict. Doesn't conflict with P11's read-only allowlist; the env check is read-only.
- **P16 (Per-Task AC Traceability):** P19's stub-vs-real distinction plugs directly into P16's evidence rendering — an AC whose evidence is stub-only is reported differently from an AC whose evidence is real-path. P16 is where the distinction becomes visible in reviewer output.
- **P20 (External Integration Contract Verification — sibling):** P20's wire-format verification requires a real credential to produce a real curl trace. P19 is the mechanism P20 uses to obtain (or decline) that credential.
- **P21 (User-Reported Check / Defect Triage — sibling):** P21's defect reproduction requires real-path access to reproduce a user-reported bug. P19 is the gate that decides whether reproduction is possible; if the env var is unset, P21's protocol routes through P19's MISSING_CREDENTIALS escalation before any defect work begins.
- **P22 (Plan Change Protocol — sibling):** A plan change that adds a new external provider must add a corresponding `required_env` entry. P22's planner re-dispatch reads P19's field as part of its "what's the blast radius of this change" assessment.
