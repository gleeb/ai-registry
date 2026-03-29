# QA Verifier Dispatch Template

Use this template when dispatching `sdlc-qa` via the Task tool.

**Architect**: Before sending this dispatch, log it via `checkpoint.sh dispatch-log --event dispatch`. After the QA verifier returns, log the response via `checkpoint.sh dispatch-log --event response`.

## Required Message Structure

```
VERIFY TASK: [Task ID] — [Task Name]

STAGING DOCUMENT: [exact path to docs/staging/US-NNN-*.md]
Read the staging document for acceptance criteria and expected behavior.

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
- Coverage command: [e.g., npx jest --coverage --coverageReporters=json-summary]
- Report location: coverage/coverage-summary.json
- Implementer claimed coverage: [lines %, branches %, functions % from implementer report]
[Omit section only if no testing strategy exists AND project has no test tooling.]

IRON LAW: No completion claims without fresh verification evidence.
Run every command fresh. Do not trust prior results or implementer claims.

DOCUMENTATION VERIFICATION:
- Verify that file references in the staging doc's "Implementation File References"
  section point to files that actually exist on disk.
- Verify that created/modified files listed by the implementer actually exist.
- Flag any file reference mismatches as verification failures.

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Verification Status: PASS / FAIL.
2. Per-criterion results: criterion → command → output → PASS/FAIL.
3. Evidence: full command outputs and exit codes.
4. Coverage Report: lines %, branches %, functions % for new/modified files.
   Files below threshold listed individually. Overall project coverage.
   Comparison against implementer's claimed coverage (flag discrepancies).
5. Documentation verification: file references valid / mismatches found.
6. Browser verification evidence (if BROWSER VERIFICATION section was included).
7. Any regressions or unexpected failures.

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
