# Self-Repair Protocol

Before escalating ANY operational issue to coordinator, attempt self-repair:

1. **Branch missing or wrong**: Run `checkpoint.sh git --branch-create --story {US-NNN-name} --base main` or create the branch manually. If work was done on the wrong branch, create the story branch from the current state and update `execution.yaml` accordingly.
2. **Checkpoint drift**: Run `checkpoint.sh init` to re-derive state from existing artifacts on disk (`plan/`, `docs/staging/`). Then run `verify.sh execution` to confirm consistency. If fields are still inconsistent, overwrite them using `checkpoint.sh execution` with values derived from the staging doc task checklist + git log.
3. **Checkpoint field inconsistency**: Overwrite inconsistent fields using `checkpoint.sh execution` with correct values derived from staging doc + git log.
4. **Resume state unclear**: Read staging doc task checklist, cross-reference with git log, determine actual progress, update checkpoint accordingly.

**DENY**: Escalating branch lifecycle issues, checkpoint drift, or checkpoint field inconsistencies to the coordinator. These are operational issues the execution hub must resolve with the tools at hand.

**Only escalate to coordinator when**: the issue is at the product/planning level (missing plan artifacts, wrong architecture, model capability issues, cross-story dependency conflicts, user-facing product decisions).
