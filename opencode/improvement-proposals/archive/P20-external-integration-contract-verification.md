# P20: External Integration Contract Verification via Real-Traffic E2E

**Status:** Implemented — 2026-04-27 (drafted 2026-04-22; resolved + implemented 2026-04-27)
**Sequencing:** Depends on P19 (credentials are the prerequisite for any real-traffic verification). Lands after P19.
**Relates to:** P13 (lib-cache breadth), P16 (AC traceability and evidence binding — extended by this proposal), P19 (env secrets protocol — prerequisite), P21 (defect triage — consumer)
**Scope:**
- `opencode/.opencode/agents/sdlc-planner-api.md` (wire-format declaration)
- `opencode/.opencode/agents/sdlc-planner.md` (plan-validator cross-check)
- `opencode/.opencode/agents/sdlc-engineering-implementer.md`, `opencode/.opencode/agents/sdlc-engineering-qa.md`, `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md`, `opencode/.opencode/agents/sdlc-engineering-acceptance-validator.md`
- Test conventions for integration smoke tests
**Transcript evidence:** `ses_24a319c81ffelunHGnCfk7KcBT` — US-004. The story's `plan/user-stories/US-004-photo-intake-identification/api.md` defined an invented request envelope that placed the API key in the JSON body (`{"api_key": "..."}`) and used no `Authorization` header. The OpenRouter API actually requires `Authorization: Bearer <key>` and rejects body-embedded keys. The mismatch produced 401 responses from first real call. Every gate (implementer, code-reviewer, QA, story-reviewer, acceptance-validator) validated against api.md's fabricated contract rather than against the provider's actual behavior. Critically, **no test in the suite ever touched the real OpenRouter endpoint.** All tests used mocked fetch. When real traffic was finally produced (via a developer-run `curl`), the defect surfaced immediately.

---

## Read Order

**Prerequisites** (read / land first):
- **P19** — strict prerequisite. §3.1 plan-time curl and §3.2 smoke tests both read credentials from `process.env` via the declared `required_env` mechanism; without P19, the verification steps cannot execute.
- **P16** — §3.4 reviewer Wire-Format Conformance check and §3.5 validator verdict plug into P16's per-task AC evidence rendering. Base P16 (items 1–4) must be in place before the §3.5 `evidence_class` amendment in this batch is meaningful.
- P15 (light) — stories annotated with the `external_integration` risk shape are the natural P20 population; not a hard dependency, but tells the planner which stories need §3.1 wire-format blocks.

**Consumers** (depend on this proposal):
- **P14 trigger 5** — reads `api.md.wire_format` to identify external-integration defect incidents as Oracle-eligible.
- **P21** — defect-incident `verify` step (§3.2 step 4) re-runs P20's smoke tests; defects whose root cause is a wrong `wire_format` block route back into P20's plan-validation path.
- **P22** — plan changes that add or swap external providers re-run §3.1 verification for the new endpoint and retire smoke tests for removed endpoints.
- **P16 (amended §3.5)** — the `evidence_class: real` value is defined as "QA's `external_integration_evidence` (from §3.3) records `ran-200`", so P16's amendment reads P20's output shape directly.

**Suggested batch reading order** (2026-04-22 cluster): P19 → **P20 (you are here)** → P16 (amended §3.5) → P21 → P14 (amended trigger 5) → P22.

---

## 1. Problem Statement

The pipeline has seven agent-level gates between "planner writes api.md" and "acceptance validator signs off." In US-004, all seven approved a contract that was wrong. The contract was not wrong in a subtle way — it was wrong in the most basic way possible (wrong auth mechanism, wrong field location) — and the reason every gate missed it is the same: every gate validated against the internal `api.md` document, not against the external provider's actual behavior.

This is not primarily a documentation-fidelity problem. You can write down a wrong contract very carefully and very well-formatted and it will still be wrong. What is missing is a step where someone — planner, implementer, reviewer, or validator — produces and inspects **real traffic** against the real external endpoint and confirms the contract matches what the service accepts.

The user's framing from the transcript: *"with proper testing this would have been caught and resolved. I would evaluate strengthening the E2E testing and in this example, real open code integration."* P20 operationalizes that framing: shift the verification locus from "does the code match api.md" (the seven gates already do this, successfully, and it doesn't help) to "does the wire actually work against the real provider" (no gate currently does this).

## 2. Root Cause Analysis

### 2.1 api.md is the oracle of truth and the oracle is fabricated

The planner-api agent produces `api.md` from docs-search and architectural reasoning. When the search returns incomplete or ambiguous information, the agent synthesizes a contract that looks plausible. In US-004 the planner produced an "internal proxy envelope" that wrapped the OpenRouter request, conceptually reasonable, but OpenRouter does not accept such an envelope. Once written, api.md is treated as authoritative by every downstream agent. The oracle is wrong but undisputed.

### 2.2 No agent has an incentive or a capability to emit real traffic

- The planner-api has docs-search tools but not curl. It cannot verify its contract against the live provider.
- The implementer has shell access but no standing instruction to run a one-shot curl against the planned endpoint before or after coding.
- The code-reviewer reads code and tests. If the tests all mock the network, the reviewer has nothing to review against.
- The QA runs the test suite. The suite passes because the mocks match api.md. The real provider is never contacted.
- The acceptance-validator checks ACs against evidence. Evidence is test output. Test output is derived from mocks. The circle closes without ever touching the real endpoint.

### 2.3 Integration tests default to mocked fetch

The project's test conventions default to `vi.mock('fetch', ...)` for anything that would make a network call. This is correct for unit tests and fast for CI. It is wrong as the exclusive strategy for verifying external integrations. There is no conventional slot for "this one test actually calls the real endpoint when credentials are available."

### 2.4 The cache-and-search pattern cannot catch contract shape

P13 (lib-cache breadth) raises the bar on cache content. Even at its most aggressive, the cache records what docs say; it does not record what the provider actually does. For providers whose docs are subtly wrong or subtly interpreted — which is most providers at some point — cache improvement does not close this gap. Only real traffic does. (The user's feedback on this proposal explicitly rejected doc-loop-fidelity framing in favor of real integration; this proposal honors that.)

### 2.5 The one real-traffic verification that happened was user-driven, post-hoc

In the US-004 transcript, a real curl against OpenRouter eventually happened — the user ran it, realized the contract was wrong, and dispatched the hub to fix it. The pipeline had no earlier version of that step. Real traffic existed only as a user-initiated debug action, not as a pipeline gate.

## 3. Proposed Approach

Five changes, numbered in execution order across the SDLC lifecycle.

### 3.1 Planner-api produces a verified `wire_format` block for every external endpoint

When the planner-api agent writes `api.md` for an external (out-of-project) host, it adds a `Wire-Format Verification` block per endpoint. The block contains:

```yaml
wire_format:
  method: POST
  url: https://openrouter.ai/api/v1/chat/completions
  auth:
    mechanism: bearer
    header: Authorization
    value_source: env:OPENROUTER_API_KEY   # ties to P19
  headers:
    Content-Type: application/json
  request_body_example: |
    {
      "model": "google/gemma-4-26b-a4b-it:free",
      "messages": [...]
    }
  response_shape_example: |
    { "id": "...", "choices": [{ "message": { "content": "..." } }] }
  verified_via:
    mode: curl                       # one of: curl | provider-doc-quote
    evidence: |
      curl -sS -X POST https://openrouter.ai/api/v1/chat/completions \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"model":"...","messages":[{"role":"user","content":"hi"}]}'
      → HTTP 200
    captured_at: 2026-04-22T14:30:00Z
```

Two evidence modes:
- **`mode: curl`** (preferred). The planner-api agent executes the curl, captures the request/response shape, and records a redacted trace. When `required_env` (P19) is set, this is mandatory. When the environment variable is not available at plan time, the planner records `mode: curl` and `pending: true` and raises a planning blocker; validation defers to execution (§3.3).
- **`mode: provider-doc-quote`** (fallback only when `pending: true` is resolved negatively). The planner quotes the provider's docs verbatim with a URL and a fetch timestamp. This is acceptable only when the provider is unreachable from the planning environment (e.g., requires paid tier the user hasn't purchased). Flagged explicitly so downstream validation knows the contract is paper-verified, not wire-verified.

The plan-validator pass (P15 vicinity) fails plan approval if an external endpoint's `wire_format.verified_via` is absent.

### 3.2 Implementer produces a smoke test that hits the real endpoint

For every external endpoint declared in api.md, the implementer writes **one** integration smoke test with the `test-mode: real` header (P19 §3.5). The smoke test:

- Reads credentials from `process.env`.
- `test.skip`s with a visible log line when the env var is unset.
- Makes ONE minimal real request against the endpoint.
- Asserts on the response shape matching `wire_format.response_shape_example`.
- Does NOT assert on AC-level correctness — those go in deeper tests.

The smoke test's role is intentionally narrow: prove the **integration physically works**. That means the auth mechanism is correct, the wire shape is accepted by the provider, and the response shape matches what the contract claims. Once that holds, following the provider's documented schemas is expected to produce consistent results for routine calls; this proposal does not attempt to validate every business scenario against the live provider.

A 401 from the provider means the contract is wrong, not that the feature is broken. The test's failure message is explicitly worded to communicate that distinction.

**Out of scope for the default smoke test:** complex multi-step scenarios, business-logic-shaped requests where the provider's response is hard to predict, and cases where the provider's docs are ambiguous. When such cases arise (typically discovered during implementation or QA when a mocked test passes but the developer is uncertain the real provider would behave the same way), the implementer adds **additional** `test-mode: real` cases ad hoc, scoped to the specific ambiguity. There is no requirement to enumerate these up front, and no plan-time obligation to predict them. The default contract is: one integration-works smoke test per endpoint; further real-traffic tests are added on demand and justified per case.

### 3.3 QA runs the smoke test once per validation, records evidence

QA's report format (P16 §3.3) gains a `external_integration_evidence` section, one entry per endpoint:

- Endpoint URL (from api.md).
- Smoke test path.
- Execution status at QA time: `ran-200 | ran-non-200 | skipped-no-env`.
- A recorded sample of the outgoing request headers (with secret VALUES redacted, names intact) so the reviewer can verify the auth mechanism matches `wire_format.auth.mechanism`.
- Response status and a shape-summary (key paths present).

This section is the primary evidence for P16's AC-traceability check when an AC depends on an external integration. `skipped-no-env` is acceptable at QA but triggers the `ACCEPTED-STUB-ONLY` verdict chain in P19 §3.6.

### 3.4 Code-reviewer cross-checks emitted request against declared wire_format

The code-reviewer gains a new check class: **Wire-Format Conformance**. For each external endpoint declared in api.md, the reviewer verifies:

- The emitted request's auth mechanism matches `wire_format.auth.mechanism` (`bearer` → `Authorization: Bearer <value>`; `api-key-header` → named header with declared name; `body-field` → declared field path).
- The emitted request's URL matches `wire_format.url` (modulo declared path parameters).
- The emitted request's content-type matches `wire_format.headers.Content-Type`.
- The body shape conforms to `wire_format.request_body_example` (field names, nesting depth).

Evidence for the check comes preferentially from QA's `external_integration_evidence` (real traffic, §3.3). When unavailable (smoke test skipped), the reviewer falls back to static analysis of the request-building code path. Reviewer output records which evidence mode was used.

Findings:
- Emitted request does not match declared wire_format → **Critical**.
- Declared wire_format does not match the smoke-test-observed real response → **Critical** (api.md itself is wrong; routes to planner for correction before the reviewer can continue).
- Smoke test marked `skipped-no-env` but the AC requires real-path acceptance → **Important** (routes to the coordinator via the P19 MISSING_CREDENTIALS channel, not a code-level fix).

### 3.5 Acceptance-validator requires at least one real-path trace per external endpoint, or downgrades

Validator checks each external endpoint declared in api.md:

- If QA's `external_integration_evidence` records `ran-200` (or `ran-non-200` with an explicitly expected non-200 case such as auth rejection in a negative test), the evidence is `real-verified`.
- If QA records `skipped-no-env`, the validator emits `ACCEPTED-STUB-ONLY` per P19 §3.6 — story passes structural checks but lacks live-provider evidence.
- The validator does NOT re-run smoke tests itself (read-only per P11). It reads QA's recorded evidence.

Story-level acceptance status becomes one of:
- `ACCEPTED` — every external endpoint has `real-verified` evidence.
- `ACCEPTED-STUB-ONLY` — one or more endpoints lack real-verified evidence due to env unset; the verdict names which ones.
- `CHANGES_REQUIRED` — at least one real-verified run returned a status inconsistent with api.md (contract wrong).

## 4. Expected Impact / ROI

**Primary impact:** The US-004 failure chain — 401 on first real user attempt — becomes mechanically impossible on new stories. A wrong-auth contract would be surfaced either at plan time (§3.1 curl) or at QA time (§3.3 smoke test), not on the user's first real attempt.

**Secondary impact:** Stronger P16 evidence. AC-traceability for externally-integrated ACs gains a concrete "this AC's behavior has been observed against the real provider at least once" anchor. Story-review and validator arguments become shorter and more defensible.

**Scope note:** P20 applies prospectively only. Existing stories and plans are not retrofitted. The plan documents from already-completed stories are no longer the artifacts under active work — re-deriving wire_format blocks for them would not feed back into anything. If a need to audit past stories ever arises, it belongs in a separate, narrowly-scoped audit protocol, not in P20.

**ROI consideration:** Non-trivial implementation cost (the smoke-test convention is new; the planner's wire_format discipline is new; the reviewer's conformance check is new). The cost is bounded — one smoke test per endpoint is a small asset, and the reviewer check is a mechanical comparison. Net payoff is an order-of-magnitude reduction in "shipped-green-failed-on-first-real-use" outcomes for externally-integrated stories, which are the stories most likely to embarrass the system in front of a user.

## 5. Success Metrics (for post-run verification)

- **M1 (hard):** 100% of api.md files that reference an out-of-project host include a populated `wire_format.verified_via` block. Verifiable by grep/YAML parse.
- **M2 (hard):** Every external endpoint declared in api.md has exactly one corresponding `test-mode: real` smoke test in `tests/integration/`. Verifiable by parsing both.
- **M3 (hard):** For stories marked `ACCEPTED` (not `ACCEPTED-STUB-ONLY`), QA's `external_integration_evidence` records `ran-200` (or explicitly-expected non-200) for every endpoint. Verifiable from QA output.
- **M4 (hard):** No code-reviewer sign-off for a story with an external endpoint closes without a "Wire-Format Conformance" entry. Verifiable from reviewer output.
- **M5 (soft):** Post-ship "wrong auth / wrong body shape" defects against external providers drop to zero across the next N stories. Baseline: US-004 (one such defect per integrated story so far).
- **M6 (soft):** Time from "user first tries real integration" to "either works or we know why it doesn't" drops from US-004's multi-round-trip debugging to a single smoke-test rerun.

## 6. Risks & Tradeoffs

- **Risk: rate-limit/cost pressure on providers during plan-time curl.** Mitigation: the planner's §3.1 verification is a single minimal call per endpoint per plan (not per story). Cacheable. When a subsequent story uses the same endpoint, the planner re-uses the existing `wire_format` block unless the endpoint has changed.
- **Risk: flaky real endpoints make CI/QA unstable.** Mitigation: smoke tests are `test.skip`-on-no-env (so CI without secrets doesn't run them). The smoke test does not gate CI merge; it gates story acceptance. QA retries once on transient failure and records the final status.
- **Risk: non-idempotent endpoints (POST with side effects) can't be freely called at plan time.** Mitigation: the planner uses provider-recommended "hello" endpoints when they exist (many providers offer cheap verification endpoints). When no such endpoint exists, the planner falls back to `mode: provider-doc-quote` with `pending: true` explicitly flagged, and the verification burden shifts to §3.2's smoke test — which the story owner agrees to in planning.
- **Risk: the smoke-test convention conflicts with projects that treat all external calls as "contract tests" with recorded cassettes (Pact/VCR).** Mitigation: cassette-recorded mode is a valid `verified_via: cassette` variant, accepted on equal footing with `curl`, provided the cassette was captured against the real provider within a declared recency window.
- **Tradeoff: adds plan-time work for the planner-api agent.** Acceptable — the cost is front-loaded and pays back across every downstream gate.
- **Tradeoff: small ongoing cost of one smoke test per endpoint per story.** Acceptable — smoke tests are cheap to write and maintain, and they are the single highest-leverage test shape for the class of bug P20 targets.

## 7. Resolved Decisions

1. **Retroactive application — REJECTED.** P20 does not retroactively apply to already-completed stories (US-001 through US-004). The plan documents for those stories are no longer the artifacts under active work, and changes to them would not feed back into anything currently in motion. If past stories ever need an external-integration audit, that belongs in a separate, narrowly-scoped audit protocol — not P20.
2. **Multi-endpoint stories — RESOLVED.** Default contract is one `test-mode: real` smoke test per api.md-declared endpoint per story, scoped to "the integration physically works (auth + shape)." Endpoints shared across stories share the smoke test via `tests/integration/_shared/`. Additional real-traffic tests for complex or ambiguous scenarios are added **ad hoc** by the implementer or QA as needed (per §3.2), not enumerated up front. There is no requirement to predict which scenarios will need real-traffic verification at plan time.
3. **Provider-doc-quote fallback bar — RESOLVED.** When `mode: curl` is unavailable, require a direct quote from the provider's canonical docs page with a URL and a fetch timestamp within the last 90 days. The story's `required_env` must reference the declared auth variable. Weaker citations are rejected at plan-validation.
4. **Cross-story reuse of `wire_format` blocks — RESOLVED.** Verified `wire_format` blocks are stored in `plan/cross-cutting/external-contracts/<provider>.md` (one file per provider). This is a planning-cross-cutting artifact, parallel to `plan/cross-cutting/required-env.md` (P19), NOT a lib-cache extension — P13 archived "project-level library cache" specifically because library API surface drifts per story; wire formats do not have that property (one provider has one canonical wire format). A subsequent story that touches the same provider reads the existing file and reuses the block unless its `captured_at` is older than the proposal's recency window or a provider doc-change signal invalidates it.
5. **Smoke test ownership on mid-story endpoint changes — RESOLVED.** The implementer updates the smoke test in the same task that updates the request builder. The reviewer cross-checks both as part of Wire-Format Conformance (§3.4).
6. **Recording redaction — RESOLVED.** In QA's `external_integration_evidence`, header VALUES are replaced with `<REDACTED>`. Header NAMES and non-secret payload structure remain intact, so structural verification is preserved while secrets do not leak into evidence artifacts.

## 8. Affected Agents, Skills, and Files (preliminary)

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-planner-api.md` | Modified | Emit `wire_format` block with `verified_via` for each external endpoint per §3.1. |
| `opencode/.opencode/agents/sdlc-planner.md` | Modified | Plan-validator rejects api.md missing `wire_format.verified_via` for external hosts. |
| `opencode/.opencode/agents/sdlc-engineering-implementer.md` | Modified | Write one `test-mode: real` smoke test per external endpoint per §3.2. |
| `opencode/.opencode/agents/sdlc-engineering-qa.md` | Modified | Execute smoke tests, emit `external_integration_evidence` per §3.3. |
| `opencode/.opencode/agents/sdlc-engineering-code-reviewer.md` | Modified | Wire-Format Conformance check per §3.4. Severity-map per that section. |
| `opencode/.opencode/agents/sdlc-engineering-acceptance-validator.md` | Modified | Read `external_integration_evidence`; emit `ACCEPTED` / `ACCEPTED-STUB-ONLY` / `CHANGES_REQUIRED` per §3.5. |
| `tests/integration/_shared/` (in consuming projects) | Created | Conventional location for shared external-endpoint smoke tests. |
| Test fixture template | Modified | Add `test-mode: real` header for integration smoke tests; inherit P19's `real | stub` taxonomy. |
| `plan/cross-cutting/external-contracts/<provider>.md` (in consuming projects) | Created | One file per external provider, holding the verified `wire_format` block(s) for cross-story reuse. Parallel to `plan/cross-cutting/required-env.md` (P19); not a lib-cache extension. Written by the planner-api at plan time; read by downstream stories that touch the same provider. |

---

## 9. Relation to Prior Proposals

- **P13 (lib-cache breadth):** P20 explicitly does NOT lean on cache-breadth as the primary fix for this defect class, per the user's explicit direction. Cache improvements help for library-shape ambiguity; they don't close contract-shape gaps against live providers. P20 introduces a separate evidence channel (real traffic) that complements P13 without depending on it. Open Question 4 sketches an optional reuse path through the cache.
- **P15 (planner risk annotations):** Stories with `external_integration` risk shape are the obvious P20 population. P15's annotation identifies P20's scope; P20 supplies the verification gate P15's annotation implies.
- **P16 (AC traceability):** P20 strengthens P16 by giving externally-integrated ACs a concrete real-traffic evidence anchor. The "real-integration evidence" clause promised under P16's amendment notes is fulfilled by P20 §3.3–3.5.
- **P19 (environment secrets):** Strict prerequisite. Real-traffic verification cannot occur without a real credential, and the `ACCEPTED-STUB-ONLY` verdict flows directly from P19.
- **P21 (user-reported defect triage):** P21's reproduction step uses P20's smoke-test convention to reproduce user-reported external-integration bugs against the real provider. When such reproduction succeeds, the resulting evidence upgrades the story's validator verdict retroactively.
- **P22 (plan change protocol):** When a plan change swaps one external provider for another, P22's re-plan includes a fresh §3.1 `wire_format` verification for the new provider and retires the old smoke test.
