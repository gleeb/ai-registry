# P12: Fix verify.sh Staging-Doc Drift Heuristic

**Status:** Implemented — 2026-04-21 (drafted 2026-04-18)
**Relates to:** [P3 (Verification Pipeline)](./P3-verification-pipeline.md), [P7 (Scaffolding Story Ownership)](./P7-scaffolding-story-ownership.md) — both introduced staging-doc conventions; this proposal hardens how those conventions are verified
**Scope:** `opencode/.opencode/skills/sdlc-checkpoint/scripts/verify.sh`, `opencode/.opencode/skills/sdlc-checkpoint/references/resume-protocol.md`, task-context and staging-doc templates
**Transcript evidence:** `ses_26105317cffeCAev1W8UP3BtK1` — repeated warnings of the form `WARN: US-002-local-persistence-foundation has 0 tasks done (checkpoint says 2) -- staging doc is more current` (lines 201, 16838, and ~14 more instances for both stories). The staging docs in fact contained completed tasks; verify.sh's regex missed them.

---

## 1. Problem Statement

Every `verify.sh` invocation during the run printed false WARN messages claiming staging docs were "more current" than the checkpoint, when in reality the checkpoint was correct. Agents reading the WARN then spent tokens reasoning about a nonexistent state discrepancy — including explicit attempts to reconcile a drift that did not exist.

The script's detection logic (approximately) is:
```bash
completed_in_doc=$(grep -c "- \[x\]" "$staging_doc")
completed_in_checkpoint=$(yq '.tasks_completed | length' "$execution_yaml")
if [ "$completed_in_doc" != "$completed_in_checkpoint" ]; then
  echo "WARN: ... staging doc is more current"
fi
```

Two bugs:
1. **Regex mismatch.** Staging docs use `### Task N: <title> ✓` headers or `Status: Complete` metadata — not GitHub-style `- [x]` checkboxes. `grep -c "- \[x\]"` returns 0 on every run, so the script concludes "doc has 0 tasks done."
2. **Directionality bug in the warning text.** Even if counts differ, the message is hardcoded as "staging doc is more current." A real drift could be in either direction.

## 2. Root Cause Analysis

### 2.1 Heuristic coupling to a never-adopted convention
The `- [x]` markdown-checkbox convention was presumably intended when the script was written, but staging docs evolved toward section-header + status-metadata conventions (per P3's template and P7's scaffolder output). The script was not updated.

### 2.2 No test for the detector
There is no unit test, integration test, or smoke test that asserts "given a checkpoint with 2 tasks complete and a staging doc with 2 tasks complete, verify.sh does NOT warn." A trivial fixture would have caught this.

### 2.3 Warning language is declarative, not investigative
"Staging doc is more current" is a specific claim. When it's wrong on every run, it erodes agent trust in all verify.sh output. Better phrasing would be "possible drift detected — inspect manually" with both counts surfaced.

### 2.4 Noise pollutes downstream dispatch prompts
Every hub dispatch includes the verify.sh output as part of the delegation packet. False warnings consume tokens in every sub-agent's prompt, multiplied by ~70 sub-agent dispatches.

## 3. Proposed Approach

Three changes (implementation details TBD):

1. **Replace the regex with a staging-doc-convention-aware parser.** The parser looks for task sections with a completion marker. Accept multiple conventions for robustness:
   - A task section header containing `✓`, `✅`, or `(complete)` in any case.
   - A `Status: Complete` or `Status: Done` line within a task section.
   - A GitHub-style `- [x]` checkbox at task scope (backward compatibility).
   A task counts as done if ANY of these signals match.

2. **Tighten the warning to be two-directional and investigative.** When counts differ, print both counts with `checkpoint: N, staging: M — counts differ; expected equal` and only emit the "more current" language when one side clearly shows later tasks than the other.

3. **Add a pre-commit or CI smoke test.** A fixture pair (`test-checkpoint.yaml`, `test-staging.md`) that verify.sh must process without warning. Prevents regression on both sides of the heuristic.

## 3a. Implementation Decisions (2026-04-21)

1. **Parser approach over structured frontmatter.** Kept the current staging-doc template. A convention-aware awk parser (`count_completed_tasks_in_staging` in `verify.sh`) walks `### Task` sections and counts a section done if the heading carries `✓` / `✅` / `complete` / `done`, or if a `**Status:**` line within the section has value `complete` / `done` (case-insensitive, before any `|`), or — as legacy fallback — a `- [x]` appears in the section body. Defers Open Question §7.1.
2. **Asymmetric directionality.** Counts equal → silent. Staging > checkpoint → override `tasks_completed` and print `staging ahead of checkpoint (staging: N/M, checkpoint: K) -- trusting staging doc` (preserves the resume-protocol contract that staging is more current when it disagrees upward). Staging < checkpoint → warn with both counts and do NOT override: `checkpoint ahead of staging (checkpoint: K, staging: N/M) -- counts differ; inspect staging doc manually`. The hardcoded "staging doc is more current" phrasing is gone.
3. **Plain bash test runner.** No `bats` harness exists in the repo; a single `tests/test-verify.sh` covers agreement / staging-ahead / checkpoint-ahead / legacy-checkbox fixtures plus explicit "stale phrasing must not reappear" assertions. Runnable via `bash tests/test-verify.sh` from the skill root. No CI wiring added (repo has none).
4. **Open Questions §7.2 (single source of truth) and §7.3 (strict / non-zero exit mode) remain out of scope.** Revisit only if false positives recur or the parser starts accumulating convention-specific special cases.

## 4. Expected Impact / ROI

**Primary impact:** Removes false-positive noise from every dispatch. Rough measurement: ~30 verify.sh invocations × ~200 tokens of warning text per invocation × propagation into sub-agent prompts = low-thousands of wasted tokens per run. Not large in isolation, but consistent noise degrades agent decision quality over long sessions.

**Secondary impact:** Prevents agents from triggering reconciliation work that does not need doing. In this run, at least one implementer dispatch began with re-reading the checkpoint and staging doc to "reconcile" the supposed drift before proceeding. That's lost time.

**Tertiary impact:** Restores trust in verify.sh output. If WARN means something, agents take it seriously; if WARN is noisy, agents learn to ignore it (including the real warnings).

**ROI consideration:** Low-cost fix (≤50 lines of bash plus one test fixture). Low-magnitude direct savings per run, but compounding benefit from restored trust in the verification layer. Very easy win.

## 5. Success Metrics (for post-run verification)

Measurable from transcript:

- **M1 (hard):** Zero false-positive "staging doc is more current" warnings in a run where checkpoint and staging doc agree. Verifiable by grepping verify.sh output in the transcript against the actual task-completion state.
- **M2 (hard):** When counts genuinely differ, the warning text includes BOTH counts and does NOT hardcode direction. Verifiable by inspecting verify.sh output format.
- **M3 (hard):** A `test-verify.sh` or equivalent CI check exists and runs in the repo's test pipeline. Verifiable by `ls` and by CI log.
- **M4 (soft):** Agent output that mentions "reconcile drift" or "staging is more current" drops to near zero when no actual drift exists. Verifiable by grepping agent output.

## 6. Risks & Tradeoffs

- **Risk:** Over-permissive regex accepts false-positive task completions (e.g., a literal "✓" in prose). Mitigation: require the marker to appear on the task heading line, not anywhere in the section body.
- **Risk:** Staging-doc conventions drift again and the parser falls behind. Mitigation: the test fixture. Any new staging-doc template update must include updating the fixture.
- **Tradeoff:** Adding a parser makes verify.sh slightly slower per invocation. Cost: milliseconds per story. Accepted.

## 7. Open Questions

1. Should the parser read the staging doc as structured (e.g., via a YAML frontmatter block with `tasks_completed: [...]`) rather than relying on markdown heuristics? If yes, this proposal expands to include a template update.
2. Is it worth consolidating task-completion tracking in ONE place (checkpoint only, staging doc is reference), eliminating drift detection entirely? That's a bigger change but removes the whole class of problem.
3. Should verify.sh treat drift as an error (non-zero exit) or a warning? Current behavior is warn-only; strict mode may be appropriate when the check is reliable.

## 8. Affected Agents and Skills (preliminary)

| File | Change Type | Description |
|------|-------------|-------------|
| `opencode/.opencode/skills/sdlc-checkpoint/scripts/verify.sh` | Modified | Added `count_completed_tasks_in_staging` awk helper; replaced the `- [x]` regex drift block with convention-aware parsing and three-way directionality (equal / staging-ahead / checkpoint-ahead). |
| `opencode/.opencode/skills/sdlc-checkpoint/references/resume-protocol.md` | Modified | Updated the "read staging doc to identify next pending task" row: dropped the stale `- [ ]` pointer, now references the `### Task` + `**Status:** pending` convention. |
| `opencode/.opencode/skills/sdlc-checkpoint/tests/test-verify.sh` | **Created** | Plain bash smoke test runner. Covers agreement, staging-ahead, checkpoint-ahead, legacy-checkbox, and explicit "stale phrasing must not reappear" assertions. |
| `opencode/.opencode/skills/sdlc-checkpoint/tests/fixtures/{agreement,staging-ahead,checkpoint-ahead,legacy-checkbox}/{execution.yaml,staging.md}` | **Created** | Fixture pairs for each drift scenario. Placeholder `FIXTURE_STAGING_DOC` in the yaml is rewritten by the runner to an absolute path in a temp dir. |
| `opencode/.opencode/skills/sdlc-checkpoint/tests/fixtures/README.md` | **Created** | Fixture catalog and run instructions. |
| `common-skills/project-documentation/references/task-context-template.md` | Not modified | Structured-frontmatter migration deferred (Open Question §7.1). |

Note: `opencode/.opencode/skills` is a directory symlink into `common-skills/`, so each file above physically lives under `common-skills/sdlc-checkpoint/` and is reachable via both paths.

---

## 9. Relation to Prior Proposals

- P3 introduced the staging-doc structure. P12 makes verify.sh correctly understand it.
- P7 introduced scaffolder-produced staging docs. Those docs use headers + status metadata, not checkboxes — which is what exposed the verify.sh bug.
- Interacts with P10 and P11 only insofar as reduced false-positive noise helps those agents focus on real signal.
