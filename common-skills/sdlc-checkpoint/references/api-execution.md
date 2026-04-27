# checkpoint.sh execution

Manages execution hub state: phase, current task, dev-loop step, iteration counts, acceptance tracking.

## Flags

| Flag | Purpose |
|------|---------|
| `--story` | Set the current story identifier |
| `--phase` | Set the current execution phase (0, 1, 2, 3, 3b, 4, 5, 6) |
| `--tasks-total` | Total number of implementation tasks |
| `--task` | Set the current task (`"{id}:{name}"`) |
| `--step` | Set the dev-loop step (`implement`, `review`, `qa`) |
| `--iteration` | Set the review iteration number |
| `--task-done` | Mark a task as completed by ID |
| `--staging-doc` | Set the staging document path |
| `--acceptance-iteration` | Set the acceptance revalidation counter (0-2) |
| `--acceptance-verdict` | Set the acceptance verdict (`COMPLETE`, `INCOMPLETE`, `null`) |
| `--status` | Set execution status: `IN_PROGRESS` (default), `COMPLETE`, or `BLOCKED`. Set `COMPLETE` after Phase 6 merge to signal the coordinator |
| `--incident-open` | Append a new defect-incident stub to `incidents:`. Requires `--id`, `--story`, `--reporter`, `--reported-behavior`. Seeds `status: open`, `iterations: 0`, `opened_at: <ISO-8601 now>`, `oracle_consulted: false`, `verdict: null`. |
| `--incident-init` | Initialize the incident's on-disk artifact directory. Requires `--id`, `--story`. Creates `.sdlc/incidents/<id>/` with empty `incident.md`, `investigation.md`, `fix-plan.md`, `verification.md`, and `incident.yaml`; copies the target story's `docs/staging/<story>.lib-cache.md` to `.sdlc/incidents/<id>/lib-cache.md`; assembles `contradicted-ac-context.md` from the target story's contradicted ACs. |
| `--incident-update` | Update an existing incident entry. Requires `--id` and at least one of `--status`, `--iterations`, `--target-story`, `--reassigned-from`, `--oracle-consulted`, `--verdict`. |
| `--id` | Incident identifier (`INC-NNN`). Used with `--incident-*` flags. |
| `--reporter` | Incident reporter handle (defaults to `user`). Used with `--incident-open`. |
| `--reported-behavior` | Verbatim reporter description (used with `--incident-open`). |
| `--target-story` | Reassigned target story id (used with `--incident-update`). Records the reassignment in `incident.md`. |
| `--reassigned-from` | The original target story id (used with `--incident-update --target-story`). |
| `--oracle-consulted` | Boolean flag — `true` once Oracle has been dispatched for this incident. |
| `--verdict` | Final incident verdict (`resolved`, `reclassified-to-B`, `scope-expansion`, `escalated`). Set at incident close. |

## `incidents:` schema in `execution.yaml` (P21)

The execution checkpoint carries an `incidents:` array that tracks defect-incident state. The hub never reads this schema directly — it manipulates it via the `--incident-*` flags above — but post-mortem readers may. Each entry:

```yaml
incidents:
  - id: INC-001                                # `INC-{NNN}`, zero-padded, monotonic from 001
    story: US-004-photo-intake-identification  # current target story (after any reassignment)
    reassigned_from: null                      # original target if reassigned, else null
    status: open | investigating | fix-proposed | verifying | resolved | reclassified-to-B | escalated | not_reproduced
    iterations: 0                              # incident iteration counter, capped at 3 per P21 §3.2
    opened_at: 2026-04-22T10:00:00Z            # ISO-8601 UTC
    closed_at: null                            # set on terminal verdict
    reporter: user                             # or other handle
    oracle_consulted: false
    verdict: null | resolved | reclassified-to-B | scope-expansion | escalated
```

Artifact directory layout (per P21 §3.2):

```
.sdlc/incidents/<INC-NNN>/
  incident.md                         # narrative: reporter, classification, contradicted ACs, target story, reproduction steps
  investigation.md                    # implementer / Oracle working notes (per iteration)
  fix-plan.md                         # proposed diff summary and affected files
  verification.md                     # AC-test re-run + smoke-test re-run evidence + verdict promotion record
  incident.yaml                       # local mirror of the execution.yaml entry (status, iterations, verdict)
  lib-cache.md                        # inherited copy of the target story's lib-cache; supplemented on reassignment
  contradicted-ac-context.md          # full text of contradicted ACs + their evidence_path bindings from the target story
  reproduction.log                    # captured reproduction output (Step 1)
  evidence/AC-N/                      # per-AC evidence bundles from the incident-narrow validator
    verify.sh
    stdout.log
  validation-report.evidence.md       # the incident-narrow validator's report
```

## Examples

```bash
# Starting execution for a story
checkpoint.sh execution --story US-001 --phase 2 --tasks-total 8 --staging-doc "docs/staging/US-001-auth.md"

# Before dispatching implementer (write-ahead)
checkpoint.sh execution --task "4:Implement session store" --step implement

# Transitioning to review
checkpoint.sh execution --step review --iteration 1

# Task done
checkpoint.sh execution --task-done 4

# Phase transition
checkpoint.sh execution --phase 3

# Tracking acceptance revalidation (Phase 4)
checkpoint.sh execution --phase 4 --acceptance-iteration 0
checkpoint.sh execution --acceptance-iteration 1 --acceptance-verdict INCOMPLETE
checkpoint.sh execution --acceptance-verdict COMPLETE

# Signal story completion (Phase 6, after merge)
checkpoint.sh execution --status COMPLETE

# Defect-incident lifecycle (P21)
# 1. Coordinator opens the incident from triage Category C
checkpoint.sh execution --incident-open --id INC-001 \
  --story US-004-photo-intake-identification \
  --reporter user \
  --reported-behavior "I click Choose file and nothing happens"

# 2. Engineering hub initializes the artifact directory
checkpoint.sh execution --incident-init --id INC-001 --story US-004-photo-intake-identification

# 3. Hub advances status as the lifecycle proceeds
checkpoint.sh execution --incident-update --id INC-001 --status investigating --iterations 1
checkpoint.sh execution --incident-update --id INC-001 --oracle-consulted true
checkpoint.sh execution --incident-update --id INC-001 --status verifying

# 4. Reassignment — root cause was in a different completed story
checkpoint.sh execution --incident-update --id INC-001 \
  --target-story US-002-photo-capture --reassigned-from US-004-photo-intake-identification

# 5. Reclassification — target depends on a story not yet executed
checkpoint.sh execution --incident-update --id INC-001 \
  --status reclassified-to-B --verdict reclassified-to-B

# 6. Resolution
checkpoint.sh execution --incident-update --id INC-001 --status resolved --verdict resolved

# 7. Verdict promotion on the original story (Stub→Real)
checkpoint.sh execution --story US-004-photo-intake-identification --acceptance-verdict ACCEPTED
```
