# Browser Verification Protocol

Defines when and how SDLC agents run browser verification against a web application using PinchTab.

## When to Run

Browser verification applies when **all** of these are true:

1. The story is a web application (tech stack includes a web framework: React, Next.js, Vite, Vue, Angular, etc.).
2. The task touches UI-visible code (components, pages, routes, layouts, styles).
3. The dispatch message includes a `BROWSER VERIFICATION` section.

If any condition is false, skip browser verification entirely.

## Prerequisites

Before browser verification:

1. **PinchTab is healthy**: `pinchtab health` succeeds. If not, report as a blocker — do not attempt to start PinchTab.
2. **Dev server start command is known**: The dispatch provides the command (e.g., `npm run dev`, `pnpm dev`).
3. **Expected routes are known**: The dispatch lists routes to verify.

## Procedure

### Step 1: Start the dev server

```bash
# Start in background, capture PID
<dev-server-command> &
DEV_PID=$!
```

### Step 2: Wait for server ready

Poll the dev server until it responds:

```bash
for i in $(seq 1 30); do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:<PORT> | grep -q "200\|304"; then
    break
  fi
  sleep 2
done
```

If the server doesn't respond after 60 seconds, report as a verification failure and stop.

### Step 3: Verify PinchTab health

```bash
pinchtab health
```

### Step 4: Navigate and verify each route

For each route in the expected routes list:

```bash
# Navigate to the route
pinchtab nav "http://localhost:<PORT><route>"

# Wait for page load
sleep 2

# Check for JavaScript errors via evaluate
pinchtab eval "(function(){ var errs = []; window.onerror = function(m){errs.push(m)}; return JSON.stringify(errs); })()"

# Get page text to verify content loaded
pinchtab text

# Get interactive snapshot for structure verification
pinchtab snap -i -c
```

### Step 5: Evaluate results

For each route, check:

| Check | Pass Condition | Fail Condition |
|---|---|---|
| Page loads | HTTP navigate succeeds, `/text` returns non-empty content | Navigate timeout, empty page text |
| No console errors | No uncaught exceptions in evaluate output | Console errors present |
| Expected content | Page text contains expected keywords/headings | Missing expected content |
| Interactive elements | Snapshot contains expected interactive elements | Critical UI elements missing |

### Step 6: Stop the dev server

```bash
kill $DEV_PID 2>/dev/null
```

## Evidence Format

Browser verification evidence should be reported in this structure:

```
BROWSER VERIFICATION EVIDENCE:
  PinchTab health: [HEALTHY | UNREACHABLE]
  Dev server: [STARTED on port NNNN | FAILED TO START]
  Routes verified:
    - /path1: [PASS | FAIL] — [brief description]
    - /path2: [PASS | FAIL] — [brief description]
  Console errors: [NONE | list of errors]
  Overall: [PASS | FAIL]
```

## Per-Task vs Story-Level

### Per-task verification (Phase 2 QA)

- Verify only the route(s) affected by the current task.
- Lighter check: page loads, no console errors, expected content visible.

### Story-level verification (Phase 3 QA)

- Verify all key routes listed in the story's acceptance criteria or design spec.
- Full smoke test: every route loads, no console errors, navigation between routes works.
- Include interactive element verification (forms render, buttons are clickable).

### Acceptance criterion verification (Phase 4)

- For each acceptance criterion that describes UI behavior, navigate to the relevant page and verify the behavior in the browser.
- Example: "User sees a login form" → navigate to `/login`, verify form fields are present in the snapshot.

## Failure Handling

- If PinchTab is unreachable: report as infrastructure blocker, do not fail the task's functional criteria.
- If the dev server fails to start: report as a verification blocker with the error output.
- If a route fails to load: report as FAIL with the page text and any error output.
- If console errors are found: report as FAIL with the error messages.
- Browser verification failures are reported alongside (not instead of) standard QA evidence (lint, typecheck, tests, build).
