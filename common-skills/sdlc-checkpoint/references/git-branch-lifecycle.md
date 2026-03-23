# Git Branch Lifecycle Protocol

## Branch Naming Convention

Each user story executes on a dedicated branch:

```
story/{US-NNN-slug}
```

Examples:
- `story/US-001-auth-scaffold`
- `story/US-003-settings-page`
- `story/US-012-payment-integration`

The slug is the same story identifier tracked in `execution.yaml` (the `--story` value passed to `checkpoint.sh execution`).

## Commit Message Format

| Phase | Trigger | Format | Example |
|-------|---------|--------|---------|
| Phase 2 | Task passes QA (`--task-done`) | `task({story}/{task-id}): {task name}` | `task(US-001-auth/3): Implement session store` |
| Phase 3b | Remediation after semantic review | `fix({story}): {description}` | `fix(US-001-auth): Address semantic review findings` |
| Phase 4 | Remediation after acceptance validation | `fix({story}): {description}` | `fix(US-001-auth): Fix failing acceptance criteria` |
| Phase 5 | Documentation integration | `docs({story}): {description}` | `docs(US-001-auth): Integrate staging doc` |

## Branch Lifecycle

### Creation (Phase 0)

After the readiness gate passes and before any implementation:

```bash
checkpoint.sh git --branch-create --story US-001-auth --base main
```

This:
1. Ensures `.sdlc/` is in `.gitignore`
2. Checks out the `--base` branch (default: `main`)
3. Creates and checks out `story/{story}`
4. Records `branch_name`, `base_branch`, and `base_commit` in `execution.yaml`

### Commits (Phase 2, 3b, 4, 5)

After each validated work boundary:

```bash
# Phase 2: after task passes implement → review → QA cycle
checkpoint.sh git --commit --story US-001-auth --task "3:Implement session store" --phase 2

# Phase 3b/4: after remediation fixes are applied and reviewed
checkpoint.sh git --commit --story US-001-auth --message "Address semantic review findings" --phase 3b

# Phase 5: after documentation integration
checkpoint.sh git --commit --story US-001-auth --message "Integrate staging doc" --phase 5
```

**When NOT to commit:**
- During the implement-review cycle within a single task (review may request changes)
- Before every dispatch (crash safety is handled by checkpoint YAML, not git)
- When there are no changes (the script detects this and skips)

### Diff Scoping (Phase 3b, 4)

The semantic reviewer and acceptance validator use the story branch diff to scope their review:

```
git diff {base_commit}..HEAD
```

This shows the cumulative delta of all committed work on the story branch, regardless of how many individual commits exist. The `base_commit` is read from `execution.yaml` and populated into the dispatch template's GIT CONTEXT section.

**Important:** This is `git diff base..HEAD` (comparing branches), not `git diff` (uncommitted changes). Commits during Phase 2 do not empty this diff — they add to it.

### Merge (Phase 6)

After user acceptance approval:

```bash
checkpoint.sh git --merge --story US-001-auth --target main
```

This:
1. Checks out the target branch (`main`)
2. Merges with `--no-ff` for traceable history
3. Deletes the story branch
4. Clears branch fields from `execution.yaml`

## Resume Handling

On resume (`verify.sh execution`), the verifier checks branch state:

- **Branch exists and is checked out**: Normal — continue from checkpoint phase/task/step
- **Branch exists but not checked out**: Output `branch_action: checkout story/{story} before continuing`
- **Branch missing**: May have been merged or deleted. Output recommendation to verify status and potentially recreate from base

The `checkpoint.sh continue` subcommand includes branch state in its resume instructions.

## Edge Cases

### Branch Already Exists

If `checkpoint.sh git --branch-create` is called and the branch already exists (resume after crash), it checks out the existing branch instead of failing. This is the expected path when resuming interrupted work.

### No Changes to Commit

If `checkpoint.sh git --commit` is called but there are no staged changes (e.g., a task only modified files that were already committed), the script prints "No changes to commit" and logs a skip event. This is not an error.

### Merge Conflicts

If the merge to the target branch produces conflicts, the merge command will fail (non-zero exit from `git merge`). The architect should:
1. Report the conflict to the user
2. Let the user resolve the conflict manually
3. Resume after resolution

### Dirty Working Tree Before Branch Create

If there are uncommitted changes when `--branch-create` is called, `git checkout` may fail. The architect should ensure the working tree is clean before starting a new story. If this happens during resume, `verify.sh` will flag the branch checkout issue.

### .sdlc/ Directory

The `.sdlc/` directory contains checkpoint state files and must NOT be committed to the repository. The `--branch-create` and `--commit` operations ensure `.sdlc/` is listed in `.gitignore` before any git operations.
