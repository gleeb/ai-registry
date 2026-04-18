# Implementer Dispatch Template

Use this template when dispatching `sdlc-implementer` via the Task tool.

**Architect**: Before sending this dispatch, log it via `checkpoint.sh dispatch-log --event dispatch`. After the implementer returns, log the response via `checkpoint.sh dispatch-log --event response`.

## Required Message Structure

```
TASK: [Task ID] — [Task Name]

SPECIFICATION:
- [Function signatures and parameters]
- [Interface definitions]
- [File paths for each change]
- [Dependencies on prior tasks]

ACCEPTANCE CRITERIA:
- [Testable condition 1]
- [Testable condition 2]

TECH SKILLS:
- [skill-name] (path: skills/[skill-name]/)
  Load and apply patterns from this skill during implementation.
[Include all tech skills identified in Phase 0. Omit section if no tech skills apply.]

EXTERNAL LIBRARIES (search documentation before implementing):
- [library-name] (topic: [what to look up])
- [library-name-2] (topic: [what to look up])
[List every external library/SDK/platform API this task integrates with.
The implementer MUST search context7 and/or Tavily for each before writing
integration code. Omit only if the task uses no external libraries.]

REQUIRED CONTEXT (read before writing any code):
1. Task context document: Read [exact path to docs/staging/US-NNN-name.task-N.context.md].
   This contains verbatim plan excerpts (acceptance criteria, design spec, API contract,
   security controls, design references, testing requirements), a file inventory (paths,
   line counts, exports), and prior review feedback. The Source Files section is a file
   inventory only — read source files from disk when you need their content for editing.
   Do NOT read story.md, hld.md, api.md, security.md, or testing-strategy.md directly.
2. Staging document: Read [exact path to docs/staging/US-NNN-*.md].
   Check "Technical Decisions" and "Issues & Resolutions" sections for decisions from
   earlier tasks that affect this task. Do NOT follow plan references — use the context doc.
3. Project docs: Read docs/index.md and relevant domain docs if present. Skip if absent.
[Any additional context from prior tasks — include here, not in the context doc]

LIBRARY CACHE: docs/staging/[story-id].lib-cache.md
[Always include. This is the story-level library documentation cache. Check this file
BEFORE querying context7 or Tavily for any library. An entry with non-empty apis_used
and code_snippets is sufficient — do not re-query. Write new entries here after querying.]

[If any library is at 2/3 or above of the 3-query budget, include:]
LIBRARY BUDGET: [library-name] [N]/3 used — re-query only if strictly required.

DOCUMENTATION (update throughout implementation):
- Update the staging document with progress after each significant change.
- Document all technical decisions with rationale in the staging doc's
  "Technical Decisions & Rationale" section.
- Record all created/modified files in the staging doc's
  "Implementation File References" section.
- Document any issues encountered and their resolutions in the
  "Issues & Resolutions" table.

STAGING DOCUMENT PROTECTION:
- Do NOT overwrite or replace the staging document. Only UPDATE specific sections.
- Preserve ALL existing content (task board, blockers, technical decisions,
  plan references, other tasks' information).
- You may APPEND to: Implementation File References, Technical Decisions,
  Issues & Resolutions.
- You may UPDATE: your task's status row in the Task Status Board,
  your task's checkbox in the LLD Execution Plan.
- You must NEVER delete or rewrite other tasks' information, the Overview,
  Plan References, Acceptance Criteria, or Execution Blockers (unless adding
  a new one).

INTEGRATION CONTEXT:
[For each external dependency in this task's scope, declare the realization level
and provide the details the implementer needs. Omit this section only if the task
has no external dependencies.]

- [Dependency name]: [mock | interface-only | real | realize]
  [If mock: describe the mock approach — in-memory array, fixture file, adapter
  returning hardcoded data, etc. Reference the HLD's integration realization
  subsection for the exact design.]
  [If interface-only: specify the adapter interface to define and where it lives.]
  [If realize: identify which prior mock is being replaced, the adapter interface
  to preserve, and the real connection details.]
  [If real/realize and DevOps agent was dispatched — include from infra manifest:]
    Connection: [connection string / URL / file path from DevOps manifest]
    Env var: [env var name, e.g., DATABASE_URL]
    Health: [verified running — DevOps health check passed]
    Notes: [any DevOps agent notes relevant to implementation]

COVERAGE THRESHOLDS:
- Lines: [threshold from testing strategy, e.g., 80%]
- Branches: [threshold from testing strategy, e.g., 70%]
- Functions: [threshold from testing strategy, e.g., 90%]
- Command: [e.g., npx jest --coverage --coverageReporters=json-summary]
- Report: coverage/coverage-summary.json
[Omit section only if no testing strategy exists AND project has no test tooling.]

TESTING STRATEGY CONTEXT:
- AC test types: [from testing-strategy.md traceability table, e.g.,
  AC-1: unit + integration, AC-2: E2E, AC-3: unit with negative paths]
- Negative testing required for: [list ACs with validation/error/conditional logic]
[Omit section only if no testing strategy exists.]

BOUNDARIES:
- IN SCOPE: [what to implement]
- OUT OF SCOPE: [what NOT to implement]
- Do not expand scope beyond this task specification.
- TASK SIZE CONSTRAINT: This task should modify at most 4 production files
  (excluding tests). If you find yourself needing to modify more, HALT and
  report to the hub that the task should be split.

SELF-VERIFICATION:
Before returning your final summary to the parent agent:
1. Load the verification-before-completion skill (skills/verification-before-completion/).
2. For each acceptance criterion above, identify a verification command and run it fresh.
3. If any criterion fails verification, fix it before claiming completion.
4. If a BROWSER VERIFICATION section is included below, run a browser smoke check
   after quality gates pass (see that section for details).
5. Include verification evidence (commands + outputs) in the completion summary.

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Code-change summary: files created/modified with brief description.
2. Verification evidence: per-criterion command + output + PASS/FAIL.
3. Staging doc updates: list each section updated and what was added/changed.
   Example: "Technical Decisions: added rationale for X. Implementation File
   References: added src/foo.ts, src/bar.ts. Issues & Resolutions: added row
   for dependency conflict."
4. CHANGES APPLIED (mandatory — enables hub to update the context doc without re-reading all files):
   For each file created, modified, or deleted, report:
   - File path
   - Change type: CREATED | MODIFIED | DELETED
   - For CREATED: line count and a one-line description of what it contains.
   - For MODIFIED: the key changes made (function signatures added/changed, imports added,
     config values changed, sections restructured). Include before/after snippets for
     non-trivial modifications so the hub can patch the context doc inline.
   Example:
     CHANGES APPLIED:
     - CREATED src/components/Button.tsx (42 lines) — React component implementing AC-1 button behavior.
     - MODIFIED src/app/routes.tsx — Added /dashboard route (lines 15-22).
       Before: routes array had 3 entries [/, /about, /settings]
       After: routes array has 4 entries [/, /about, /settings, /dashboard]
     - CREATED src/components/__tests__/Button.test.tsx (38 lines) — Unit tests for Button.
5. Any blockers encountered.
6. Do NOT create standalone summary or report files (e.g., Implementation_summary.md,
   completion_summary.md). All summary information goes in THIS return message
   and in the staging document — nowhere else.
7. After composing this return message, STOP. Do not write files, do not re-verify.
   Your task is complete.

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

Run a browser smoke check AFTER quality gates pass (lint, typecheck, tests, build).
Start the dev server, navigate to the affected routes via PinchTab, confirm pages
load and expected content is present. If something is broken, fix it before claiming
completion. If PinchTab is unreachable, skip — do not block on infrastructure.
```

## Re-dispatch (after review feedback)

When re-dispatching after code review rejection, add:

```
REVIEW FEEDBACK (iteration [N]):
The following issues were identified by code review. Fix ALL listed issues:

[Paste reviewer's COMPLETE issues section verbatim — all Critical, Important,
AND Suggestion items with their original file:line references and code snippets.
Do not summarize or omit any findings.]

Update the staging document with the review feedback and fixes applied.
```

## Re-dispatch (after diagnostic analysis — guided)

When the architect has analyzed the actual code and determined the implementer needs
concrete guidance (typically after iteration 3 with same-defect pattern):

```
DIAGNOSTIC GUIDANCE (iteration [N]):
The architect has reviewed the actual implementation and identified the following
specific issues with exact code references:

[Exact current code that is wrong, with file:line]
[What it should be changed to, with reasoning]
[Any patterns from existing codebase to follow]

REVIEW FEEDBACK (from previous review):
[Paste reviewer's COMPLETE issues section verbatim as above]

Apply these changes precisely. If the guidance conflicts with your understanding
of the architecture, explain why in your completion summary rather than ignoring it.
Update the staging document with fixes applied.
```

## Re-dispatch (after semantic review guidance)

When re-dispatching after semantic review NEEDS WORK, add the guidance package:

```
SEMANTIC GUIDANCE (from commercial semantic review):

REASONED CORRECTIONS:
[Paste the corrections section from the semantic reviewer's guidance package.
Each correction includes what's wrong, what the better result looks like, and
the reasoning chain explaining why.]

DOCUMENTATION:
[Paste any fetched documentation excerpts from the guidance package.]
[Paste any documentation fetch instructions — if included, use context7 MCP
to retrieve the specified docs before implementing fixes. Search for the
exact terms, library, and sections specified.]

IMPROVEMENT INSTRUCTIONS:
[Paste the consolidated improvement instructions from the guidance package.
These are specific, actionable steps to follow.]

Apply the corrections and follow the improvement instructions. If documentation
fetch instructions are included, retrieve the docs via context7 first — they
contain the framework/library context needed to implement the fixes correctly.
Update the staging document with fixes applied.
```
