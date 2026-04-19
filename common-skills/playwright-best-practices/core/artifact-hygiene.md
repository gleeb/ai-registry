# Playwright Artifact Hygiene

**Load this reference when:** configuring Playwright in a new project, writing visual-regression tests, dispatching Playwright via shell or ad-hoc browser-smoke scripts, or cleaning up a project root that has accumulated `.log`, `.png`, `.webm`, `.zip`, or `.last-run.json` files.

**Why this matters:** Playwright scatters artifacts across the project unless you configure it not to. Across multi-session agent runs, those artifacts accumulate at the project root, leak into commits, balloon `git status`, and pollute PR reviews. The rule is simple — every artifact goes under `test-artifacts/` (or equivalent), nothing at the root.

## The three classes of pollution

In order of how often they actually happen:

### 1. Loose snapshot baselines

`toHaveScreenshot()` writes baseline PNGs next to the test file by default. If tests live at the project root, or in a non-standard directory, baselines land at the root. Worst case, a test written in `smoke.spec.ts` produces `smoke.spec.ts-snapshots/<name>.png` in the cwd.

**Fix:** always set `snapshotPathTemplate`. Collocate baselines under the test directory or under a dedicated artifact directory.

### 2. Ad-hoc log redirects

When an agent debugs Playwright via shell, the common pattern is:

```bash
npx playwright test specs/smoke.spec.ts > smoke.log 2>&1
```

Then the agent forgets to delete `smoke.log`, and it sits in the project root until a human spots it.

**Fix:** redirect to `/tmp/` or to `test-artifacts/logs/`. Never to the project root. Any log an agent creates during a task must be deleted or moved before the agent returns.

### 3. Standard artifact directories

`test-results/`, `playwright-report/`, `.last-run.json`, trace zips. These are well-known and the most-often-gitignored. They're still worth routing explicitly via `outputDir` + `reporter` so their location is deterministic.

## Baseline config that prevents classes 1 and 3 without agent discipline

```typescript
// playwright.config.ts
import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./tests/e2e",

  // All test-run output lives under test-artifacts/. One directory to gitignore.
  outputDir: "test-artifacts/results",

  // HTML report goes under the same umbrella.
  reporter: [
    ["html", { outputFolder: "test-artifacts/report", open: "never" }],
    ["list"],
  ],

  // Baselines co-locate predictably. "__snapshots__" alongside the test file
  // is standard; "test-artifacts/snapshots/..." is fine if the team prefers
  // baselines out of the test tree.
  snapshotPathTemplate:
    "{testDir}/__snapshots__/{testFileName}/{arg}{ext}",

  // Traces and videos only on retry/failure — not per-test — to keep the
  // artifact directory small under the green path.
  use: {
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
    video: "retain-on-failure",
  },
});
```

Trade-offs worth knowing:

- `outputDir` controls per-test output (screenshots on failure, videos, traces). It does NOT control the HTML report location — that's the reporter's `outputFolder`. Both must be set.
- `.last-run.json` cannot be redirected. Playwright writes it next to the config. Just gitignore it.
- `snapshotPathTemplate`'s `{testFileName}` includes the extension (`.spec.ts`), which is unusual but intentional — it guarantees uniqueness across sibling test files. Use `{testFilePath}` instead if you want the directory structure preserved.

## `.gitignore` entries every project should have

```gitignore
# Playwright artifacts
test-artifacts/
test-results/
playwright-report/
.last-run.json
**/*.trace.zip

# Optional: if diff/actual snapshots are NOT committed but baselines ARE,
# the default __snapshots__ output is fine; only gitignore the diff variants.
**/*-actual.png
**/*-diff.png

# Catch-all for ad-hoc logs at the project root. Narrow this pattern if the
# project legitimately uses `.log` files for runtime output.
/*.log
```

**About snapshot baselines:** most teams commit baselines (so reviewers can see what changed visually). If yours doesn't, add `**/__snapshots__/` to `.gitignore`. Do not add this line "just in case" — it silently drops the baselines you intend to version.

## End-of-task rule for agents

Any agent dispatching Playwright or redirecting shell output during a Playwright session must, before returning:

1. `ls` the project root and confirm no new loose `.log`, `.png`, `.webm`, `.zip` files appeared.
2. If any exist that the agent created, delete them or move them under `test-artifacts/`.
3. Confirm `git status` shows no untracked artifacts — only intended code changes.

Treat this as a completion-contract item. Reviewers should refuse a task that returns with loose artifacts in the root.

```bash
# Quick pre-return audit — any output here is a cleanup action for the agent.
find . -maxdepth 2 -type f \
  \( -name "*.log" -o -name "*.webm" -o -name "*.zip" \
     -o -name ".last-run.json" -o -name "*-snapshots.png" \) \
  -not -path "./node_modules/*" \
  -not -path "./.git/*" \
  -not -path "./test-artifacts/*"
```

## Ad-hoc dispatches (no persistent Playwright config)

When an agent runs Playwright directly without a project config — typical for browser-smoke sessions — pass flags that prevent the default pollution:

```bash
# Route artifacts explicitly; silence the reporter that writes to disk.
npx playwright test \
  --output=test-artifacts/results \
  --reporter=null \
  specs/smoke.spec.ts

# If logs are genuinely needed, redirect to /tmp, NOT to the project root.
npx playwright test specs/smoke.spec.ts > /tmp/pw-smoke-$(date +%s).log 2>&1

# Or use Playwright's own debug channel into a temp file.
DEBUG=pw:api npx playwright test 2> /tmp/pw-debug.log
```

If a one-off debug run writes snapshots (`--update-snapshots`), and those snapshots are not meant for commit, delete them before returning. Do not stage them "to see what happens in review".

## Anti-patterns

- **`snapshotPathTemplate` left at the default when tests are not in the default `testDir`.** Baselines end up wherever the test file sits, which can be the project root.
- **Redirecting shell output to the project root during debugging.** One surviving `smoke.log` at root is how every polluted project starts.
- **Gitignoring loose artifacts but not removing them from the tree.** `.gitignore` only affects untracked files; already-committed `.log` files stay committed. Use `git rm --cached` to un-track, then gitignore to prevent recurrence.
- **Using `trace: 'on'` and `video: 'on'` in a passing build.** Fine for debugging sessions, wasteful in a green CI run. `'retain-on-failure'` is the right default.
- **Configuring `outputDir` but not the reporter `outputFolder`.** The HTML report still lands at the default `playwright-report/` next to the config. Both must be set.

## Gate function

```
BEFORE returning from a task that dispatched Playwright (directly or via npm script):
  1. ls the project root for any .log / .png / .webm / .zip / .last-run.json that the agent created.
  2. Move them to test-artifacts/ or delete them.
  3. Check .gitignore covers test-artifacts/, test-results/, playwright-report/, .last-run.json.
  4. Confirm `git status` shows only intended changes.

  IF any artifact remains that the agent created and cannot justify:
    Delete it. The task is not complete until the tree is clean.
```

## Red flags

- `git status` after a Playwright run shows `.log`, `.png`, `.webm`, `.zip`, or `.last-run.json` as untracked.
- Multiple `pw-*.log` files at the project root across sessions — indicates a recurring cleanup miss, not a one-off.
- `playwright-report/` and `test-results/` at the root *plus* `test-artifacts/` — someone set `outputDir` but not `reporter outputFolder`.
- Snapshot baselines scattered across arbitrary directories (`src/components/Foo.spec.ts-snapshots/` and `tests/e2e/Foo.spec.ts-snapshots/` both exist) — no `snapshotPathTemplate` set.

## Related

- [configuration.md](./configuration.md) — the umbrella reference for `outputDir`, `reporter`, `use`, and other config knobs.
- [../infrastructure-ci-cd/performance.md](../infrastructure-ci-cd/performance.md) — includes the `retain-on-failure` patterns in the context of performance trade-offs.
- [../testing-patterns/visual-regression.md](../testing-patterns/visual-regression.md) — snapshot management and baseline-vs-diff semantics.
- `common-skills/webapp-testing/` — the agent-browser + ad-hoc dispatch skills that most often redirect logs to the root during debugging sessions.
