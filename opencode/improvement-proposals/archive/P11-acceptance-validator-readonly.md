# P11: Acceptance Validator Scope Boundary — Path-Scoped Write Allowlist

**Status:** Resolved — drafted 2026-04-18, refreshed and implemented 2026-04-21 after P10 landed
**Relates to:** [P10 (Story-Reviewer Cap)](./P10-story-reviewer-severity-guard.md) — P10 capped Phase 3, which shifts residual pressure toward Phase 4; P11 defines the Phase 4 scope boundary
**Scope:** `opencode/.opencode/agents/sdlc-engineering-acceptance-validator.md`, `kilo-code/.kilo/agents/sdlc-engineering-acceptance-validator.md`, `common-skills/architect-execution-hub/references/acceptance-validation-dispatch-template.md`. Minor touch-ups in `opencode/.opencode/agents/sdlc-engineering.md`, `kilo-code/.kilo/agents/sdlc-engineering.md`, and `common-skills/architect-execution-hub/references/phase4-acceptance-flow.md` (narrative notes only; no hub-side audit logic).
**Transcript evidence:** `ses_26105317cffeCAev1W8UP3BtK1` — the Phase 4 acceptance-validator dispatch `ses_25f1097f8ffe1Y6zTrn1PHptgA` was associated with a cross-cutting diff across a set of source and context files that, by shape, could not be validator-owned artifacts. Named in the original post-mortem:

- `src/features/shell/theme-provider.tsx` (+130) and `src/features/shell/theme-provider.test.tsx` (+168) — implementation + test
- `tests/integration/pwa-shell.test.ts` (+441) — new integration test
- `src/main.tsx` (+6), `styles/globals.css` (+33), `src/features/.../install-fallback-banner.tsx` (-3), `install-fallback-banner.test.tsx` (+4), `app.test.tsx` (+19), `routes.test.ts` (+8), `globals.test.tsx` (+15), `touch-target-style.ts` (+4) — assorted implementation and test edits
- `vite.config.test.ts` (+5), `register-service-worker.test.ts` (-78) — ambiguous but tracked source
- `offline-shell.tsx` (deleted or re-created)
- `docs/staging/US-003-pwa-shell-baseline.lib-cache.md` (+143 / -85) — context cache rewrite
- Skill-gotchas file(s) and per-task context docs (count unspecified)

None of these are typical Playwright / Vitest byproducts (snapshots, trace files, HTML reports, coverage). The aggregate count in the original draft ("~32 files / +1373 / -300") is not independently reproducible from repo state, and the exact attribution of each write to the validator's tool calls vs the parent hub vs uncommitted Phase 2/3 drift cannot be reconstructed without the transcript. The named files above are sufficient motivation: by shape, they are writes a Phase 4 validator has no mandate to produce. The dispatch duration (7h 15m) was a provider-side token-throttling artifact, not agent runaway, and is not part of the problem statement.

---

## 1. Problem Statement

The `sdlc-engineering-acceptance-validator` is designed as the last read-only gate before a story is accepted: it runs fresh evidence against each AC and returns COMPLETE / INCOMPLETE. During the `ses_2610...` run, a Phase 4 dispatch was associated with source-file, test-file, and context-cache writes across the files named in the Transcript Evidence block above — none of which are Phase 4 mandate. Implementation, tests, and context caches belong to Phase 2 (implementer + code-review + QA) and Phase 3 (story-review + story-QA). When the validator rewrites them to "make ACs pass," the pipeline's role separation collapses: the hub's loop accounting is bypassed, review coverage is skipped, and the repository ends up with cross-cutting changes whose provenance is a single validator report rather than a reviewed implementer dispatch.

After P10 landed (2026-04-21), Phase 3 story-review is hard-capped at 3 iterations with escalation to Oracle or architect self-implementation. That cap deliberately transfers some residual detection to Phase 4. With Phase 4's scope undefined, any pressure released by P10 can re-manifest as a scope-drifting validator. P11 closes that gap.

### 1.1 Write vectors in scope

The validator's frontmatter has had `edit: deny` since commit `3996d77` (2026-03-27), predating the cited transcript by several weeks. So the OpenCode-native `edit` / `apply_patch` / `write` tools were already blocked at the time of the incident. Any cross-cutting writes during that Phase 4 dispatch must therefore have come from one of:

- **Bash-based writes.** `bash: "*": allow` is in effect, so `cat > file`, `sed -i`, heredocs, `tee`, and `git apply` all bypass `edit: deny`. This is the most plausible vector. A path-scoped `edit:` allowlist alone does **not** close it; P11 must address the bash write vector explicitly at the spec level (see §3 Change #2).
- **Attribution of parent-hub activity to the validator's dispatch window.** Cannot be ruled out without transcript tool-call-level detail. If true, some of the diffs were not validator writes at all. P11 does not address parent-hub attribution directly in this pass — the validator's self-check (§3 Change #3) reports its own delta, which is sufficient for the current goal of bounding the validator.

The architectural gap P11 closes is: the agent had no positive write-scope definition, and `bash: "*": allow` was an uncovered loophole. Both are addressed by spec + schema.

## 2. Root Cause Analysis

### 2.1 Role contract is descriptive, partially enforced
`sdlc-engineering-acceptance-validator.md` already has `edit: deny`, `task: deny` at the frontmatter level and "DENY: Modifying any code — this is a read-only verification role" in its Explicit Boundaries. These landed outside P11's original scope and are now in place. The remaining gap is that the spec has no positive definition of what the validator IS allowed to write — no notion of "validator-owned artifacts." The result is an all-or-nothing contract: the agent is told "don't edit code" but also has a natural need to record verification evidence, raw logs, skill-level gotchas discovered while verifying, and a structured report somewhere durable. Without a sanctioned destination for those artifacts, the agent improvises.

### 2.2 Permission schema is global on `edit:`, and leaves `bash:` open
Two separable gaps here:

- **`edit:` is scalar.** OpenCode's permission schema supports path-scoped maps (used by `sdlc-engineering.md`, `sdlc-engineering-scaffolder.md`, `sdlc-engineering-oracle.md` as `edit: "*": allow`), but the validator uses the scalar form. A path-scoped allowlist that permits writes only to validator-owned artifact paths gives the agent a legal destination for evidence while architecturally preventing scope drift via the OpenCode-native write tools.
- **`bash:` is unrestricted.** `bash: "*": allow` means `cat > file`, `sed -i`, heredocs, `tee`, and `git apply` all route around `edit: deny` today. Any path-scoped `edit:` hardening without a parallel bash constraint is defense against one vector while the other stays open. This is the vector most consistent with the original transcript's cross-cutting diff.

### 2.3 Phase boundary with Phase 2/3 is implicit
The spec does not explicitly say "when AC-N fails, report it and stop — do not write implementation, tests, lib-cache, staging-doc narrative, or task-context docs." The existing "DENY: Modifying any code" covers `src/` intent but is silent on context caches, narrative sections, test files, and task-context docs. The boundary needs to be stated positively by category (what IS owned) and negatively by category (what is explicitly not owned), not just by permission key.

### 2.4 No self-check by the validator
Even with permission hardening, the validator had no step in its workflow where it confirmed its own writes stayed inside the allowlist. If bash-driven drift occurred (or a tool invocation mutated a tracked file as a side effect — snapshot updates, lockfile regenerations, etc.), it would be invisible to the validator's own reporting and only surface on the next git operation. A one-line `git status --porcelain` check at the end of the workflow, run by the agent itself, catches this cheaply without requiring hub-side policing.

### 2.5 Permission-map ordering discovered during P11 implementation
While mirroring the hub's permission-map pattern (`task: "*": deny` first, specific allows after), we flipped the validator's draft ordering (which had placed `"*": deny` last). The repo's working convention is **catch-all first, specific overrides after**, matching `sdlc-engineering.md`'s `task:` block and `sdlc-coordinator.md`'s `bash:` block (`"*": allow` first, `"git push*": deny` after). Placing the catch-all last risks being interpreted as the effective policy depending on how the runtime resolves keys, which would silently deny all edits — plausibly contributing to earlier observations where the validator reached for bash as an improvised write path. Corrected in this revision.

## 3. Proposed Approach

Three stacked constraints, all on the validator itself. The engineering hub is deliberately left out — it is already large, and loading it with a post-dispatch audit step would add cognitive weight for a defense-in-depth layer that the agent can mostly provide itself. (Budget cap and early-return protocol from the original draft are also dropped — see §10.)

1. **Path-scoped `edit:` allowlist in the validator's frontmatter, catch-all first.** Replace the scalar `edit: deny` with a map that denies by default and explicitly allows only validator-owned artifact paths. Catch-all FIRST, specific overrides AFTER, matching the convention used by `sdlc-engineering.md`'s `task:` block and `sdlc-coordinator.md`'s `bash:` block:
   ```yaml
   permission:
     edit:
       "*": deny
       "docs/staging/**/evidence/**": allow
       "docs/staging/**/*.evidence.md": allow
       "docs/staging/**/*.skill-gotchas.md": allow
     bash:
       "*": allow
     task: deny
   ```
   The allowlist covers **only** artifacts that document what the validator observed or learned, never artifacts that change what the story produces. Implementation files (`src/**`), test files (`tests/**`, `**/*.test.*`, `**/*.spec.*`), library-cache entries (`docs/staging/**/*.lib-cache.md`), per-task context docs, planning-gotchas (`docs/staging/**/*.planning-gotchas.md`, hub-owned per P10), and the main staging-doc narrative are all `deny` by catch-all. This is a hard architectural boundary, not a convention.

2. **Spec-level "validator-owned artifacts" contract, with an explicit bash write constraint.** Add a new section to `sdlc-engineering-acceptance-validator.md` that positively defines the agent's write scope, and explicitly closes the bash write path that the `edit:` schema does not cover:
   - **Owned (may write via the write/edit tool):**
     - Verification evidence files under the story's `docs/staging/**/evidence/` subtree (raw playwright/vitest stdout, curl captures, screenshot paths, per-AC evidence bundles).
     - The structured validation report, co-located under the evidence subtree.
     - Skill-gotchas entries in `docs/staging/**/*.skill-gotchas.md` describing verification-time discoveries — flaky-evidence patterns, library/test-runner timing sensitivities, environment requirements surfaced during AC checks. The validator appends to the existing per-story sibling file using the standard skill-gotchas template; it does not create new sibling files in unrelated locations.
   - **Not owned (must not write, even if doing so would make an AC pass):** implementation code under `src/`; any test file, pre-existing or new; the main staging-doc narrative sections (hub appends the Phase 4 verdict); `lib-cache` sibling files; `planning-gotchas` sibling files (hub-owned per P10, written only on the 3-iteration-cap escalation — if the validator observes a planning miss, it surfaces it as failure guidance in the report and the hub decides whether to record it); per-task context docs; project docs under `docs/` outside the story's evidence subtree.
   - **All writes go through the write/edit tool.** The validator MUST NOT use bash to create or modify files. The forbidden patterns include redirection (`>`, `>>`, `tee`), in-place editing (`sed -i`, `perl -i`, `awk` with redirection), heredoc writes (`cat <<EOF > file`, `cat <<EOF >> file`), and `git apply` / `git commit` / `git push`. Bash remains allowed for running verification commands, invoking test runners, `curl`, `grep`, `node -e` (non-writing), and similar read-only probes. If the validator needs to persist evidence, it uses the write tool, whose path-scoped allowlist (Change #1) enforces the architectural boundary.
   - **Behavior when an AC fails:** report INCOMPLETE with failure guidance (root cause + suggested remediation). Do not attempt to remediate by writing an owned-elsewhere artifact. The hub's Phase 2 re-dispatch path exists for this.

   The triviality shortcut — letting the validator apply small patches to unblock cosmetic AC failures without a full Phase 2 re-dispatch — is deliberately deferred to a separate follow-up proposal. P11 keeps the scope boundary sharp; the cost/benefit of relaxing it for trivial fixes is a different discussion.

3. **Pre-completion self-check, run by the validator.** The validator's workflow gains a "Pre-Completion Self-Check" phase immediately before Completion. The validator itself runs `git status --porcelain`, walks the resulting path list, and confirms every tracked-file change matches the allowlist patterns from Change #1. If any path falls outside the allowlist:
   - The validator reverts the out-of-scope change (`git checkout -- <path>` for modifications; `rm` for files created outside allowlisted subtrees).
   - The completion report includes a "Scope Self-Check" entry recording the reverted paths and the triggering cause (e.g., bash redirection the agent used, test-runner side effect like `--update-snapshots`).
   - If the trigger was a bash command the agent ran, the report names the specific command so future dispatch guidance can pre-emptively forbid it.

   If all paths are inside the allowlist, the report records `Scope self-check: clean (N tracked paths)`. The self-check is mandatory — the spec declares skipping it a protocol violation.

   This is deliberately agent-side, not hub-side. Reasoning: the hub spec is already 700+ lines and loading it with per-dispatch audit logic adds cognitive weight for a safety net that the agent itself can provide more cheaply. The permission schema (Change #1) is the primary enforcement layer; the bash-write spec rule (Change #2) closes the only known loophole; the self-check (Change #3) catches both agent-side mistakes (accidental bash redirection, test-runner side effects) and its own protocol drift. If the self-check detects recurring patterns of drift in production, a hub-side audit becomes a straightforward follow-up — but that escalation is deferred until data supports it.

## 4. Expected Impact / ROI

**Primary impact:** Restores the phase boundary. Phase 4 becomes what the pipeline was designed around — an evidence-based gate that returns a verdict, not a cross-cutting editing pass. A validator INCOMPLETE verdict produces a targeted Phase 2 remediation dispatch, reviewed and QA'd through the normal cycle, instead of unreviewed file modifications attributed to a single validator report.

**Secondary impact:** Post-P10 defense in depth. P10 intentionally transfers some Phase 3 escape conditions into Phase 4's lap via its iteration cap. Without P11, that transfer can re-manifest as validator scope drift. With P11, any escaped issue must surface as an INCOMPLETE verdict routed through Phase 2 remediation, which is exactly what the pipeline loop accounting expects.

**Tertiary impact:** Provenance hygiene. Modifications to implementation, tests, and context caches are attributable to reviewed implementer dispatches with clear git history. Validator runs produce structured evidence bundles under a predictable path, which a follow-up proposal could consume (e.g., for automated acceptance dashboards).

**ROI consideration:** Small, focused change. The frontmatter diff is ~6 lines. The spec addition is ~30 lines defining the owned/not-owned boundary plus ~15 lines for the Pre-Completion Self-Check phase. The engineering hub is essentially untouched (narrative paragraph only). The path-scoped allowlist is architecturally enforced; the self-check is the single agent-side safety net that can be extended to a hub audit later if observability warrants it.

## 5. Success Metrics (for post-run verification)

Measurable from the validator's returned completion report (Scope Self-Check entry) and from repo state after each validator dispatch:

- **M1 (hard):** Zero source-file, test-file, or context-cache modifications attributable to an acceptance-validator dispatch. The `edit:` allowlist (Change #1) blocks the primary vector; the spec rule (Change #2) blocks the bash loophole; the self-check (Change #3) catches and reverts anything that slips through either. A simple post-hoc spot-check — diff HEAD across a validator dispatch window and check for paths outside the allowlist — should return empty. If it does not, the self-check's "Scope Self-Check" entry in the returned report should already have flagged and reverted the same paths, making the repo-state delta empty anyway.
- **M2 (hard):** Every validator dispatch that returns INCOMPLETE produces per-AC failure guidance (root cause + suggested remediation). Already required by the existing spec; P11 does not relax this. Included as a regression guard.
- **M3 (hard):** Every validator completion report contains a "Scope Self-Check" entry — either `clean` or a list of reverted paths with triggering cause. Absence of this entry is a protocol violation and the hub should treat the report with suspicion (the self-check is the only enforcement layer below the permission schema).
- **M4 (soft):** Every validator dispatch writes at least one artifact under `docs/staging/**/evidence/**` (raw verification output for the ACs it checked). Indicates the allowlist is being used as intended rather than just denied-past. Tracks whether the sanctioned destination actually absorbs the evidence-capture intent.
- **M5 (soft):** Validator-authored skill-gotchas entries accumulate over successive stories rather than staying at zero. Zero would indicate the validator is still improvising capture (bash-writing to unsanctioned locations, which the self-check should revert) or not surfacing verification-time learnings at all. Non-zero indicates the sanctioned path is absorbing genuine insight.
- **M6 (soft):** Phase 4 INCOMPLETE → Phase 2 remediation converges in ≤ 2 iterations for at least 80% of cases. Indicates that routing residuals through the hub's loop (rather than absorbing them at Phase 4) is not creating a new treadmill. If this moves the wrong way, the triviality-shortcut follow-up proposal becomes higher priority.
- **M7 (observability):** If "Scope Self-Check" entries consistently report reverts for the same trigger across multiple dispatches (e.g., a specific bash command, a specific test-runner flag), that is the signal to either (a) add a hub-side audit for defense in depth, or (b) amend the dispatch template to pre-emptively forbid that specific trigger. The self-check data feeds both decisions.

## 6. Risks & Tradeoffs

- **Risk:** Path allowlist is too narrow — validator has a genuine need to write an artifact whose path isn't allowlisted. Mitigation: the initial allowlist is a starting point; if the self-check consistently reports reverts for the same path pattern, the allowlist is extended in a targeted revision. First version errs narrow.
- **Risk:** Path allowlist schema is underspecified (per-AC subdirectory vs flat layout under `evidence/**`), leading to inconsistent evidence layouts across stories. Mitigation: spec addition includes a minimum-viable evidence-bundle schema (per-AC subdirectory, stdout capture, verification command) so the evidence is machine-readable by any future consumer.
- **Risk (primary):** The bash write prohibition is spec-level (not permission-schema-enforced) and a misbehaving agent could ignore it. The self-check (Change #3) is the backstop, but it is also agent-side and therefore subject to the same agent-trust assumption. If the agent drifts badly enough to ignore its own self-check directive, neither layer catches it. Mitigation: (1) the permission schema makes the `edit:`-tool vector architecturally impossible, so the only bypass is bash, which is narrower than the original surface; (2) repo-state is observable — any realized drift that escapes the self-check becomes visible at the next commit/PR/verify.sh run; (3) M7 (observability metric) records whether self-check drift is happening, and if it recurs a hub-side audit becomes the obvious follow-up. The decision to defer hub-side enforcement is explicit and revisitable.
- **Risk:** Validator uses the skill-gotchas write privilege as a back door to record implementer-flavored observations that belong in other artifacts ("the theme provider needs this refactor"). Mitigation: the spec restricts skill-gotchas entries to verification-time discoveries using the existing skill-gotchas template's category fields. Entries that don't fit the template's "library/environment/runner" categories are a protocol violation.
- **Risk:** The self-check runs `git status --porcelain`, which honors `.gitignore`. If a consumer project does not gitignore Playwright / Vitest / coverage runner output directories (`test-results/`, `playwright-report/`, `coverage/`, etc.), the self-check will report them as out-of-scope writes and revert them. Mitigation: project-side prerequisite; document in the acceptance-validation skill's setup notes.
- **Risk:** Tracked `__snapshots__/` directories get updated as a side effect of running tests with `--update-snapshots`. The self-check will revert these and record the triggering flag. Mitigation: the spec forbids `--update-snapshots` in verification runs; revert + report handles any accidental invocation.
- **Tradeoff:** Validator cannot apply trivially-small fixes inline, even when doing so would be cheaper than a Phase 2 re-dispatch. Accepted for P11; the follow-up triviality proposal will evaluate a bounded exception once we have data on how often it would actually fire.
- **Tradeoff (by design):** The hub is not modified to audit the validator. Chosen to keep the engineering hub spec compact. If observability (M7) shows recurring drift, a hub-side audit lands as a ~20-line addition to the Phase 4 workflow — straightforward escalation, but not paid for pre-emptively.
- **Risk:** Staging-doc "Phase 4 Evidence" append — the validator currently has no sanctioned way to surface its verdict into the main staging-doc narrative. The hub owns that write. Mitigation: the hub already reads the validator's returned report summary; appending to staging doc is a hub responsibility that simply becomes explicit. No runtime regression.

## 7. Open Questions

1. What is the exact path schema under `docs/staging/**/evidence/**`? Per-AC subdirectories (`evidence/AC-1/`, `evidence/AC-2/`) or a flat layout with filename prefixes? Decision affects the allowlist pattern in §3 Change #1 and the evidence-bundle schema in §3 Change #2.
2. Should the main validation report itself live inside the allowlisted evidence subtree, or at staging-doc root? The former is cleanest for the permission schema; the latter matches how other artifacts at the staging root are discovered. Leaning toward evidence subtree for P11; revisit if downstream consumers complain.
3. Where exactly does the post-hoc audit logic live — inline in the Phase 4 step of `sdlc-engineering.md`, or as a helper inside `checkpoint.sh`/`verify.sh`? The latter is more reusable (future read-only roles could opt in) but adds scope. Recommendation: inline first, extract if a second use case appears.
4. Is the skill-gotchas append pattern — multiple agents writing to the same per-story sibling file — already safe under concurrent dispatches? The validator runs strictly after Phase 3 so sequencing is fine in practice, but worth confirming no agent format-check expects a single-writer history.
5. If a future triviality-shortcut proposal lands, does it relax the allowlist (validator may write small patches under `src/` when classified as trivial) or introduce a separate "fix-manifest" artifact that the hub applies? Out of P11 scope; recorded here so the follow-up starts from a known baseline.

## 8. Affected Agents and Skills

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/agents/sdlc-engineering-acceptance-validator.md` | Modified | Replace scalar `edit: deny` with path-scoped allowlist (catch-all `"*": deny` FIRST, then allow for evidence subtree, `*.evidence.md`, `*.skill-gotchas.md`). Add a "Validator-Owned Artifacts" section defining owned vs not-owned categories with examples. Add an explicit "Writes go through the write/edit tool, not bash" constraint with the forbidden-patterns list (`>`, `>>`, `tee`, `sed -i`, heredoc, `git apply`, etc.). Include a minimum-viable evidence-bundle schema. Add a "Pre-Completion Self-Check" workflow phase where the validator runs `git status --porcelain`, verifies every tracked path is in the allowlist, reverts any off-allowlist path, and reports the result in the completion contract. |
| `kilo-code/.kilo/agents/sdlc-engineering-acceptance-validator.md` | Modified | Mirror the opencode changes. Identical contract; different runtime. |
| `common-skills/architect-execution-hub/references/acceptance-validation-dispatch-template.md` | Modified | Updated DENY block to reference the path-scoped allowlist and the explicit bash-write prohibition. No audit/gating language — enforcement is on the validator side. |
| `opencode/.opencode/agents/sdlc-engineering.md` | Touched (narrative only) | Phase 4 description updated to note that the validator has a narrow write scope enforced by the validator itself (schema + spec + self-check). No hub-side audit logic added; hub remains compact. |
| `kilo-code/.kilo/agents/sdlc-engineering.md` | Touched (narrative only) | Same narrative update as opencode hub. |
| `common-skills/architect-execution-hub/references/phase4-acceptance-flow.md` | Touched (narrative only) | Leading paragraph updated to describe the validator's enforced write scope. No hub-side audit steps. |

**Explicitly NOT affected** (already hardened or out of scope):

- `opencode/.opencode/agents/sdlc-engineering-story-qa.md` — already has `edit: deny` + `task: deny`. Whether it needs its own path-scoped allowlist (and bash constraint + audit) depends on whether it exhibits similar drift; no transcript evidence it does. Defer to a follow-up if observed.
- `opencode/.opencode/agents/sdlc-engineering-semantic-reviewer.md` — same as above. Already matches the validator's pre-P11 permission posture.
- `docs/staging/**/*.planning-gotchas.md` — hub-owned per P10. The validator does not write here; planning-miss observations surface in the validator's failure guidance and the hub decides whether to write.

## 9. Relation to Prior Proposals

- **P10 (landed 2026-04-21):** P10 capped Phase 3 story-review iterations at 3 with escalation to Oracle or architect self-implementation. That cap deliberately allows some edge cases to arrive at Phase 4. P11 defines Phase 4's response: the validator may report INCOMPLETE with targeted failure guidance, which routes to Phase 2 remediation — but may not itself become the remediation path. P10 + P11 together keep the loop accounting honest.
- **P1 (Ceremony Scaling, archived):** P1 established the notion of role-scoped dispatch. P11 is a specific instance of that pattern applied to the Phase 4 validator.
- **Future: triviality-shortcut proposal.** An acknowledged follow-up, out of P11 scope. It will either (a) relax the allowlist for bounded change classes (docs, comments, type-only, a11y attributes) under strict caps, or (b) introduce a fix-manifest protocol where the validator proposes patches and the hub applies them via a fast-path dispatch. The choice between (a) and (b) is a future decision that depends on M4 signal from this proposal.

## 10. Dropped from earlier draft

Recorded for the decision trail.

- **Original Change #3 (dispatch-level time/token budget).** Dropped. The 7h 15m runtime in the transcript was a provider-side token-throttling artifact, not agent runaway; no pipeline-level enforcement is warranted. The agent has no way to observe its own token usage, and external watchdogs require plugins/hooks that are out of scope at present.
- **Original Change #4 (early-return protocol).** Dropped. With the path-scoped allowlist (Change #1) plus the bash write prohibition (Change #2) plus the self-check (Change #3), the validator has no path to implementation/test files that isn't caught and reverted before the report returns. The mechanism that motivated the early-return protocol is architecturally foreclosed. A simple spec note that the validator reports each AC once per run (no self-retry loops) is folded into Change #2's Behavior-on-failure paragraph.
- **Intermediate draft's hub-side post-hoc audit.** Deliberately replaced by the agent-side self-check (current §3 Change #3). The hub is already over 700 lines; adding a per-dispatch audit step trades measurable hub-complexity cost for a defense-in-depth layer the agent can mostly provide itself. If observability (§5 M7) shows recurring self-check drift, a hub audit is a ~20-line follow-up — but not paid for pre-emptively. The dispatch template retains explicit `DENY` language covering the same scope, so the agent is still told what the boundary is.
- **Intermediate draft's permission map ordering (catch-all last).** Corrected to catch-all first, specific allows after — matching `sdlc-engineering.md`'s `task:` block (`"*": deny` first, specific agent allows after) and `sdlc-coordinator.md`'s `bash:` block (`"*": allow` first, `"git push*": deny` after). The inverted ordering from the intermediate draft risked interacting with runtime resolution order and silently denying all edits, which would paradoxically have pushed the agent toward bash as an improvised write path. Corrected and noted in §2.5.
- **Original Open Questions Q1/Q2 (evidence writes, staging-doc appends).** Resolved in favor of a narrow allowlist that includes skill-gotchas (a user-request addition to this refresh). Main staging-doc narrative remains hub-owned.
- **Original Open Question Q3 (timeout recovery).** N/A — no runtime timeout is proposed.
- **Original Open Question Q4 (parallel agents).** Largely resolved: `story-qa` and `semantic-reviewer` already have `edit: deny` + `task: deny` matching the validator's pre-P11 posture. Extending the full P11 treatment to them is deferred pending transcript evidence of similar drift.
- **Original "32 files / +1373 / -300" aggregate framing.** Replaced with the named source-file list in the Transcript Evidence block. The named files (implementation, tests, lib-cache, gotchas, per-task context docs) are by shape not Playwright / Vitest byproducts and are not Phase 4 mandate regardless of which specific write vector produced them. The aggregate count and the unnamed residual (~17 files) are dropped; the named files are sufficient motivation.
