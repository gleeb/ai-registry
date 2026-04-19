# Vite Dev Server Port Hygiene for Browser Smoke

**Load this reference when:** starting a Vite dev server for Playwright-based browser smoke and seeing `Port 4173 is already in use` (or similar) in the dev server log, combined with 404s, `Invalid hook call` errors, preamble complaints, or generally "the page loads but the app is wrong" symptoms in the browser tab.

## The failure mode

Vite's default ports (`5173` for dev, `4173` for preview) are persistent across sessions. When a previous dev/preview process is still running — or was killed uncleanly and is held by a zombie — Vite does one of two things depending on configuration:

1. **Logs "Port X is already in use" and silently picks the next available port** (e.g. `5174`). The new process is serving your fresh code on a *different* port. The browser tab opened against the default port loads whatever the *original* process is still serving — which is stale.
2. **Fails outright.** Less common in dev, more common in preview; easier to diagnose because the browser just can't connect.

Case 1 is the insidious one. The browser tab shows a working-looking app with mysteriously wrong behavior: 404s for newly added routes, `Invalid hook call` because the React copy under the old bundle differs from the one your test imports, missing preamble complaints because the old process doesn't have your latest plugin config.

## Symptom signature

In the dev server log:

```
Port 5173 is already in use, trying another one...
  ➜  Local:   http://localhost:5174/
```

In the browser console (against the default port):

- 404s on newly added static assets.
- `Invalid hook call` with no recent React-multiple-copies change.
- `@vitejs/plugin-react can't detect preamble` that wasn't there before.
- The app renders, but in a state that doesn't match `git status`.

If you see the server fallback-port log *and* any of the above in the browser, you're loading stale code.

## The fix: bind to an explicit non-default port

```typescript
// vite.config.ts
export default defineConfig({
  server: {
    port: 5180,           // explicit, non-default
    strictPort: true,     // fail loudly instead of silently falling back
  },
  preview: {
    port: 4180,
    strictPort: true,
  },
});
```

**Why `strictPort: true`:** silent fallback is the entire failure mode. Making the server refuse to start when the port is taken turns a subtle wrong-tab bug into a loud, fixable error.

**Why an off-default port (e.g. `5180`):** separate from any other dev server the user / previous agent may have left running on `5173` or `5174`. Picking a dedicated number for browser-smoke dispatches avoids collisions with whatever the human has open in another terminal.

## Before running browser smoke, sanity-check

```bash
# Confirm the target port is free before starting the server.
# If it returns any output, a process is holding it.
lsof -i :5180 -sTCP:LISTEN || echo "free"

# If held, identify and deal with it. Do NOT blindly kill.
lsof -i :5180 -sTCP:LISTEN
```

Decision on what to do if the port is held:

- **If the holder is a zombie / old Vite process from a previous agent run:** kill it (`kill <pid>`), re-run the check, start fresh.
- **If the holder is the user's active dev server:** switch to a different dedicated port (`5181`, `5182`…). Do not kill the user's process.
- **If you can't tell:** ask. Do not kill processes you can't identify.

## End-of-task cleanup

Any agent that starts a Vite dev server for smoke must ensure the process is terminated before returning:

- Track the PID you started.
- Kill it on success, on failure, and on timeout — use a `trap` in shell or a `try/finally` in Node.
- Do not rely on the parent process exit to clean up; child processes survive ambient shell deaths.

```bash
# ✅ GOOD — guaranteed cleanup
npx vite --port 5180 &
VITE_PID=$!
trap "kill $VITE_PID 2>/dev/null" EXIT

# ... run Playwright here ...

# trap handles the kill on normal exit AND on ctrl-c AND on script error
```

Leaking Vite processes is the primary cause of *future* runs hitting this gotcha, so cleanup discipline matters across agent sessions.

## Anti-patterns

- **Relying on `reuseExistingServer: true` without checking what's on the port.** Playwright will happily connect to whatever is listening — including an old, wrong process.
- **Using `strictPort: false` plus "let Vite pick a port".** You now have to communicate the picked port to Playwright's `baseURL`. Every step of that coordination is a place for the mismatch to slip back in.
- **Killing every process on a port without identifying it first.** Occasionally correct; mostly destroys the user's unrelated work.
- **Treating "it works on retry" as a fix.** Retries mask the underlying port collision; the next run will fail in the same way.

## Gate function

```
BEFORE running browser smoke against a Vite dev / preview server:
  1. Confirm server config pins an explicit, non-default port with strictPort: true.
  2. Run lsof on that port; if held, identify the holder before proceeding.
  3. Start the server; confirm the log shows the expected port with no fallback warning.
  4. Install a trap or try/finally that kills the server on every exit path.
```

## Red flags

- Dev server log contains "Port X is already in use, trying another one".
- Browser console 404s, `Invalid hook call`, or preamble warnings appear and disappear between retries.
- Multiple `node` / `vite` processes in `ps` after a smoke run.
- Smoke "works the second time" after a port error on the first.

## Related

- [vite-react-preamble.md](./vite-react-preamble.md) — the preamble complaint has two possible causes (wrong entrypoint OR wrong-port-stale-bundle). Eliminate port staleness first; it's cheaper to verify.
- [pwa-vite-plugin.md](./pwa-vite-plugin.md) — PWA installability checks are especially sensitive to serving the wrong bundle, because a stale service worker can mask even the port-fallback evidence.
