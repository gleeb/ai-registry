# QA Verifier Dispatch Template

Use this template when dispatching `sdlc-qa` via the Task tool.

**Architect**: Before sending this dispatch, log it via `checkpoint.sh dispatch-log --event dispatch`. After the QA verifier returns, log the response via `checkpoint.sh dispatch-log --event response`.

## Required Message Structure

```
VERIFY TASK: [Task ID] — [Task Name]

TASK CONTEXT DOCUMENT: [exact path to docs/staging/US-NNN-name.task-N.context.md]
Read the Acceptance Criteria, Testing Requirements, and Design References sections of
this document for plan context. Do NOT use the Source Files section — QA always reads
source files fresh from disk for independent verification.

STAGING DOCUMENT: [exact path to docs/staging/US-NNN-*.md]
Read for execution-time decisions and file reference verification only.

ACCEPTANCE CRITERIA:
1. [Testable condition 1]
2. [Testable condition 2]
3. [Testable condition 3]

SUGGESTED VERIFICATION COMMANDS:
- [test command for criterion 1]
- [build command if applicable]
- [any other verification commands]

COVERAGE EXPECTATIONS:
- Lines threshold: [from testing strategy, e.g., 80%]
- Branches threshold: [from testing strategy, e.g., 70%]
- Implementer claimed coverage: [lines %, branches %, functions % from implementer report]
- Coverage is enforced by `npm run verify:full` via vitest's `coverage.thresholds` config — a passing `verify:full` confirms thresholds were met.
[Omit section only if no testing strategy exists AND project has no test tooling.]

QUALITY GATE:
Run `npm run verify:full` (JS/TS) or `bash scripts/verify.sh full` (Python) for the full quality gate. The script is silent on success — `=== ALL GATES PASSED ===` is sufficient evidence. If it fails, the output names the failing gate; include that output in your findings.

IRON LAW: No completion claims without fresh verification evidence.
Run `verify:full` fresh. Do not trust prior results or implementer claims.

DOCUMENTATION VERIFICATION:
- Verify that file references in the staging doc's "Implementation File References"
  section point to files that actually exist on disk.
- Verify that created/modified files listed by the implementer actually exist.
- Flag any file reference mismatches as verification failures.

AC EVIDENCE SUMMARY (required when context doc has non-empty `acs_satisfied`):

For each entry in the context doc's `## AC Traceability` (`acs_satisfied`) block,
render an evidence summary block. The Phase 3 story reviewer consumes these
summaries as the primary input for full-story AC coverage instead of
re-deriving from scratch — your summary IS the evidence-of-record for the AC.

Procedure:
1. Read the AC's statement text from `plan/user-stories/<story>/story.md` using
   the `ac_id`. Reproduce it verbatim in the summary block.
2. For each test in `evidence_path` that exercises the AC, run it fresh
   (`verify:full` covers this in aggregate; for a per-AC view, also run the
   specific test files via the test runner — e.g.
   `npx vitest run <path>` — to capture the per-AC stdout/stderr).
3. For ACs with `evidence_class: real`, cross-reference the TEST-MODE
   ACCOUNTING block (Phase 2b above): confirm that at least one `real` test
   in evidence_path was actually exercised this run (not just `skipped-real`).
   If the binding claims `real` but only `skipped-real` or stub tests
   exercised the AC, mark this in the summary as a real-traffic gap.
4. Emit one block per AC in this format:

```
## AC EVIDENCE SUMMARY

### AC-N
- statement: "[verbatim AC text from story.md]"
- evidence_path:
    - <impl-file>
    - <test-file> (test-mode: real | stub)
- tests run: <test-id-or-file> — PASS | FAIL | SKIPPED
- behavioral coverage: PASS / FAIL — does the test fail if the AC is violated?
  Cite the assertion (file:line). If FAIL, the test asserts shape, not behavior.
- evidence_class verified: real | stub-only | static-analysis-only | n/a — confirm
  against test-mode headers and (when P20 lands) external_integration_evidence.
  Flag mismatches between the binding's claim and the actual evidence.
- residual gaps: [empty if none, else list]
```

For empty bindings (`acs_satisfied: []`), emit one block:

```
### refactor-only
- bound: acs_satisfied: []
- reason: [from the binding's reason field]
- confirmed: PASS — diff is genuinely refactor-only, no AC-relevant
  behavior change. (Or FAIL with details if the diff adds AC-relevant
  behavior.)
```

This summary is consumed by the Phase 3 story reviewer to audit full-story AC
coverage. Be precise — vague summaries force the story reviewer to re-derive,
which defeats the per-task evidence pipeline.

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Verification Status: PASS / FAIL.
2. Per-criterion results: criterion → command → output → PASS/FAIL.
3. Evidence: `verify:full` result — `ALL GATES PASSED (exit 0)` or failing gate output with exit code.
4. Coverage Report: lines %, branches %, functions % for new/modified files (from verify:full output if failed, or confirm thresholds met if passed silently).
   Comparison against implementer's claimed coverage (flag discrepancies).
5. **AC Evidence Summary:** the per-AC blocks rendered per the AC EVIDENCE SUMMARY directive above. One block per `acs_satisfied` entry, plus the empty-binding block when applicable.
6. TEST-MODE ACCOUNTING block (per Phase 2b above).
7. Documentation verification: file references valid / mismatches found.
8. Browser verification evidence (if BROWSER VERIFICATION section was included).
9. Any regressions or unexpected failures.

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Conditional: Browser Verification Block

**Include this block when ANY of the following are true:**

1. The story is a web application AND the task touches UI-visible code (components, pages, routes, layouts, styles).
2. The story describes a browser-observable problem (site not loading, blank page, rendering broken, HTTP errors when visiting the site, UI regression, etc.) — include for ALL tasks in the story regardless of whether the individual task appears UI-related, because config, build, server, dependency, and routing changes all affect whether the site loads.
3. The story's acceptance criteria include browser-observable outcomes (e.g., "website loads," "page renders," "no console errors").
4. The task modifies files that indirectly affect web rendering: build config, dev server config, dependency manifests (package.json, requirements.txt), environment variables, middleware, routing, SSR/SSG pipelines, or deployment configuration.

**Omit entirely** only for non-web-app stories or tasks within a web app story where none of the above conditions apply.

When the architect has classified the story as **mandatory browser verification** (recorded in the staging document), include this block for every task in the story without exception.

```
BROWSER VERIFICATION:
Load the PinchTab skill from skills/pinchtab/ and follow the browser verification
protocol at skills/pinchtab/references/browser-verification-protocol.md.

Dev server command: [e.g., npm run dev]
Dev server port: [e.g., 3000]
Routes to verify: [e.g., /, /dashboard, /settings]
Expected content: [brief description of what should appear on each route]

Run browser verification AFTER the standard quality gates (lint, typecheck, tests, build).
Report browser evidence in the BROWSER VERIFICATION EVIDENCE format from the protocol.
```

## Final Story Verification Variant

For the final full-story verification after all tasks complete (Phase 3):

```
VERIFY: Full story — all acceptance criteria across all tasks.
Run full test suite and verify all criteria end-to-end.
Verify all file references in the staging document are valid.
```

For web application stories, add the Browser Verification block to the final story verification as well, listing all key routes from the story's acceptance criteria.
