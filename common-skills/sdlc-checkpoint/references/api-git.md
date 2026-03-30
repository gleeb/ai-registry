# checkpoint.sh git

Manages git branch lifecycle: branch creation, commits at validated boundaries, and story branch merging.

## Flags

| Flag | Purpose |
|------|---------|
| `--branch-create` | Create a new story branch |
| `--commit` | Commit validated work |
| `--merge` | Merge story branch into target |
| `--story` | Story identifier for branch naming |
| `--base` | Base branch for branch creation |
| `--task` | Task identifier for commit message |
| `--message` | Custom commit message (for remediation/doc commits) |
| `--phase` | Phase identifier for commit context |
| `--target` | Target branch for merge |

## Examples

```bash
# Phase 0: Create story branch after readiness gate passes
checkpoint.sh git --branch-create --story US-001-auth --base main

# Phase 2: Commit after task passes QA
checkpoint.sh git --commit --story US-001-auth --task "3:Implement session store" --phase 2

# Phase 3b/4: Commit remediation fixes
checkpoint.sh git --commit --story US-001-auth --message "Address semantic review findings" --phase 3b

# Phase 5: Commit doc integration
checkpoint.sh git --commit --story US-001-auth --message "Integrate staging doc" --phase 5

# Phase 6: Merge story branch and clean up
checkpoint.sh git --merge --story US-001-auth --target main
```
