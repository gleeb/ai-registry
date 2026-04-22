# verify.sh fixtures

These fixture pairs (`execution.yaml` + `staging.md`) exercise the
`verify_execution` drift-detection logic for the staging-doc parser introduced
by proposal P12.

Each fixture directory contains:

- `execution.yaml` — a minimal `.sdlc/execution.yaml`. The `staging_doc:` field
  uses the placeholder `FIXTURE_STAGING_DOC`, which the test runner rewrites to
  the absolute path of the fixture's `staging.md` in a throwaway temp dir.
- `staging.md` — the execution journal for the fixture scenario.

## Scenarios

| Directory | Checkpoint says | Staging shows | Expected verify.sh output |
|-----------|----------------|----------------|---------------------------|
| `agreement/` | 2 done | 2 done (via `**Status:** Complete/Done`) | no `verification:` drift line |
| `staging-ahead/` | 0 done | 2 done (via `✓` on heading) | `staging ahead of checkpoint ... trusting staging doc` |
| `checkpoint-ahead/` | 3 done | 1 done | `checkpoint ahead of staging ... counts differ; inspect staging doc manually` |
| `legacy-checkbox/` | 2 done | 2 done (via `- [x]`) | no `verification:` drift line (backward compat) |

## Running

From the skill root (`common-skills/sdlc-checkpoint/` or the hardlinked
`opencode/.opencode/skills/sdlc-checkpoint/`):

```bash
bash tests/test-verify.sh
```

Exits 0 on success, 1 on any failure. The runner prints a one-line
`PASS`/`FAIL` per case and the full verify.sh output for any failures.
