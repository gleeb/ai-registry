---
name: sdlc-plan-change-recordkeeping
description: >
  Per-plan-change artifact convention and dispatch-lock schema. Load
  this skill in the COORDINATOR or PLANNER when opening, updating, or
  closing a plan-change record (PC-NNN). Triggered when allocating a
  new PC id, writing request.md / decision.md / pc.yaml /
  artifacts-changed.md, or computing the dispatch lock from
  coordinator.yaml: plan_changes[].
---

# Plan-Change Recordkeeping

## Purpose

Defines the directory structure, file conventions, and YAML schema
that make every plan change auditable. Both the coordinator and the
planner write to the per-PC directory; this skill is the shared
contract so neither corrupts the other's artifacts.

The skill exists because P22's audit trail (every plan change has a
record from request through resolution) needs to be a real
filesystem-checkable thing, not a "we'll keep track of it somewhere"
hand-wave. M1 and M2 of P22's success metrics are
directory-inspection assertions — without this skill they have
nothing to check.

## When to Use

Load this skill in:

- **Coordinator** — when allocating a new PC id, writing
  `request.md`, recording the user's `decision.md`, and updating
  `coordinator.yaml: plan_changes[]` to open or close a PC.
- **Planner hub** — when writing `triage.md` (delegated to
  `sdlc-plan-change-triage`), updating `pc.yaml`'s status as the
  routing pass progresses, or appending to `artifacts-changed.md`.

Do NOT load in execution sub-agents. The implementer, code-reviewer,
QA, and acceptance-validator never write to `.sdlc/plan-changes/`.

## Directory Layout

```
.sdlc/plan-changes/
├── PC-001/
│   ├── pc.yaml                   # status, class, opened_at, closed_at
│   ├── request.md                # verbatim user request or hub blocker
│   ├── triage.md                 # planner's blast-radius report
│   ├── decision.md               # user's approval/override
│   └── artifacts-changed.md      # post-facto file list
├── PC-002/
│   └── ...
└── README.md                     # one-line index, optional
```

The directory is created lazily — `.sdlc/plan-changes/` does not exist
until the first PC is opened.

## PC ID Allocation

PC ids are zero-padded to three digits, monotonically increasing,
never reused:

- The first plan change is `PC-001`.
- The next id is the highest existing directory number + 1.
- Allocation is done by the coordinator at trigger time. The planner
  receives the allocated id in the dispatch envelope; it does not
  allocate.

Allocation procedure (coordinator):

```bash
# Highest existing PC number, default 0
last_pc="$(ls .sdlc/plan-changes/ 2>/dev/null \
  | grep -E '^PC-[0-9]{3}$' \
  | sort \
  | tail -1 \
  | sed 's/^PC-//' \
  | sed 's/^0*//')"
next="$((${last_pc:-0} + 1))"
pc_id="PC-$(printf '%03d' "$next")"
mkdir -p ".sdlc/plan-changes/${pc_id}"
```

## File Schemas

### `pc.yaml` (coordinator-owned at open, planner-updated during routing)

```yaml
id: PC-NNN
status: open | triaged | approved | applying | closed | abandoned
class: 1 | 2 | 3 | 4 | null            # null until triage assigns
source: user | category-D | hub-blocker
opened_at: 2026-MM-DDThh:mm:ssZ
triaged_at: 2026-MM-DDThh:mm:ssZ | null
decided_at: 2026-MM-DDThh:mm:ssZ | null
closed_at: 2026-MM-DDThh:mm:ssZ | null
target_story: US-NNN-name | null       # active story at trigger time
recommended_class: 1 | 2 | 3 | 4 | null # hub's guess (only when source=hub-blocker)
affected_planned_stories: [US-NNN-name, ...]   # the dispatch lock list
new_stories_emitted: [US-NNN-name, ...]
retired_stories: [US-NNN-name, ...]
p21_incidents_opened: [INC-NNN, ...]
required_env_delta:
  add: [VAR_NAME]
  remove: [VAR_NAME]
wire_format_delta:
  add: [provider:method:path, ...]
  remove: [provider:method:path, ...]
outcome: applied | abandoned | superseded   # null until closed
```

Status values define the lifecycle:
- `open` — request recorded; awaiting triage.
- `triaged` — `triage.md` written; awaiting user decision.
- `approved` — `decision.md` records user approval; routing pass not
  yet started.
- `applying` — routing pass in progress; planner is writing artifacts.
- `closed` — routing pass complete; `artifacts-changed.md` populated.
- `abandoned` — user rejected the change; no artifacts modified.

### `request.md` (coordinator-owned, immutable after creation)

```markdown
# PC-NNN Request

**Source:** user | category-D | hub-blocker
**Opened:** 2026-MM-DDThh:mm:ssZ
**Active story at trigger:** US-NNN-name | none

## Verbatim request

<For source=user: the user's exact message that triggered the change.
For source=category-D: the user's verbatim message that the triage
classified as Category D, plus the category-D rationale.
For source=hub-blocker: the engineering hub's BLOCKER:
PLAN_CHANGE_REQUIRED return summary, including ARTIFACT, CLAUSE,
DEFECT_CLASS, EVIDENCE, OBSERVED, RECOMMENDED_CLASS, and
SUGGESTED_DELTA blocks verbatim.>

## Coordinator notes

<One paragraph: any context the coordinator added beyond the verbatim
request. Examples: "user clarified during the trigger turn that they
mean the OpenAI provider, not the OpenAI SDK"; or "this PC was opened
because credential-registration's scope-change detection flagged the
addition of OPENROUTER_API_KEY as a scope change.">
```

`request.md` is **immutable after creation**. If the user revises the
request, open a new PC and reference this PC in the new
`request.md`'s coordinator notes.

### `triage.md` (planner-owned, written by `sdlc-plan-change-triage`)

See `sdlc-plan-change-triage/references/triage-report-template.md` for
the full schema. Recordkeeping note: the planner writes this file
once at triage time and does NOT modify it during the routing pass.
Routing-pass changes are recorded in `artifacts-changed.md`.

### `decision.md` (coordinator-owned)

```markdown
# PC-NNN Decision

**Decided at:** 2026-MM-DDThh:mm:ssZ
**Decided by:** user

## Triage class accepted

<Class N as recommended | Class N as overridden by user>

If overridden, one paragraph: what the planner recommended, what the
user chose instead, and the user's stated reason.

## Approved scope

<Bulleted list of the actions the user approved, copied from the
triage report's recommended_routing list. Items the user vetoed are
removed; items the user added are appended with "(user-added)"
suffix.>

## Open questions deferred

<Anything the user explicitly deferred — "decide later whether to
retire US-008 or rescope it; for now treat as affected and rescope on
the routing pass when we get there.">

## Verbatim user response

<The user's actual message approving / overriding / rejecting the
triage. This is the audit-trail anchor for "the user really said
yes.">
```

`decision.md` is **immutable after creation**. The user can revise the
plan change later only by opening a new PC.

### `artifacts-changed.md` (planner-owned, append-only)

```markdown
# PC-NNN Artifacts Changed

Append-only log of every file the planner modified during the routing
pass.

| Timestamp           | File                                            | Change | Notes                                  |
|---------------------|-------------------------------------------------|--------|----------------------------------------|
| 2026-MM-DDThh:mm:ssZ | plan/user-stories/US-007-.../story.md          | retire | Provider-selection out of scope post-PC |
| 2026-MM-DDThh:mm:ssZ | plan/cross-cutting/required-env.md             | edit   | Removed OPENAI_API_KEY entry           |
| 2026-MM-DDThh:mm:ssZ | .env.example                                   | edit   | Removed OPENAI_API_KEY line            |
| 2026-MM-DDThh:mm:ssZ | tests/integration/_shared/openai-chat.smoke.test.ts | delete | Smoke test retired with provider |
```

Change values: `create`, `edit`, `retire` (story-level), `delete`
(file-level).

The file is populated incrementally — the planner appends after each
sub-agent dispatch in the routing pass. This is what makes M3 (Class 3
diff verifiable) checkable.

## `coordinator.yaml: plan_changes[]` Index

The coordinator maintains a flat list of open PC ids in
`coordinator.yaml`:

```yaml
plan_changes: ["PC-001", "PC-003"]
```

The list contains only PCs whose `pc.yaml: status` is in
`{open, triaged, approved, applying}`. Closed and abandoned PCs are
removed from the list (the directory remains for audit).

The index exists so the dispatch-lock check is fast (one yaml_read on
coordinator.yaml + N reads of pc.yaml files where N is small) rather
than globbing the entire `.sdlc/plan-changes/` tree on every dispatch.

### Checkpoint script flags

```bash
checkpoint.sh coordinator --plan-change-open <PC-NNN>
# Adds <PC-NNN> to coordinator.yaml: plan_changes[].

checkpoint.sh coordinator --plan-change-close <PC-NNN>
# Removes <PC-NNN> from coordinator.yaml: plan_changes[].
# pc.yaml's status is updated separately by the closing agent.
```

## Dispatch Lock Computation

The coordinator's pre-dispatch check is:

```text
For each open PC (PC-NNN in coordinator.yaml: plan_changes):
  Read .sdlc/plan-changes/PC-NNN/pc.yaml
  If pc.yaml.affected_planned_stories contains the story being dispatched:
    REFUSE the dispatch.
    Return to user: "Story <id> is locked by open plan-change <PC-NNN>.
                     Status: <pc.yaml.status>. Resolve PC-NNN first."
```

This check runs:
- Before any `@sdlc-engineering` dispatch for a story (Phase 3 of the
  coordinator's workflow).
- Before any `@sdlc-planner` dispatch in `PLAN_CHANGE_APPLY` mode that
  is NOT itself targeting the story under PC-NNN's lock.

The check does NOT block:
- The PC-NNN's own routing-pass dispatches (the planner needs to
  modify the locked stories to release the lock).
- Dispatches for stories not in any open PC's
  `affected_planned_stories`.
- Dispatches in `DISPATCH MODE: explanation-only` or
  `DISPATCH MODE: defect-incident` (those are read-only or amendment
  scope, distinct from a fresh story execution).

## Lifecycle Walk-Through

A typical Class 3 plan change progresses through these states (the
coordinator and planner each own specific transitions):

1. **Trigger received** (coordinator). Allocate `PC-NNN`. Write
   `request.md`. Write `pc.yaml` with `status: open`. Run
   `checkpoint.sh coordinator --plan-change-open PC-NNN`.
2. **Triage dispatched** (coordinator → planner). Planner runs
   `sdlc-plan-change-triage` skill, writes `triage.md`,
   `affected_planned_stories` list, and class. Updates
   `pc.yaml: status: triaged`, `class: N`,
   `affected_planned_stories: [...]`, `triaged_at: <ISO>`. Returns
   verdict.
3. **Decision recorded** (coordinator). Coordinator presents triage
   summary to user. On approval, writes `decision.md`. Updates
   `pc.yaml: status: approved`, `decided_at: <ISO>`.
4. **Routing pass** (coordinator → planner). Planner re-dispatched
   with `DIRECTIVE: PLAN_CHANGE_APPLY`. Updates
   `pc.yaml: status: applying`. Routing-pass sub-dispatches happen.
   Each artifact change appends to `artifacts-changed.md`.
5. **Close** (planner → coordinator). Routing pass complete. Planner
   updates `pc.yaml: status: closed`, `closed_at: <ISO>`,
   `outcome: applied`. Returns to coordinator. Coordinator runs
   `checkpoint.sh coordinator --plan-change-close PC-NNN` to remove
   from the open index. Locked stories are now dispatchable.

Abandoned variant (user rejects at step 3):
- Coordinator writes `decision.md` with the user's rejection
  rationale. Updates `pc.yaml: status: abandoned`,
  `outcome: abandoned`. Runs `--plan-change-close PC-NNN`.
- No artifacts are modified. `artifacts-changed.md` is created but
  empty (with a header noting "Plan change abandoned at decision
  step").

## Strict Prohibitions

- **Never delete a `.sdlc/plan-changes/PC-NNN/` directory.** Closed
  and abandoned PCs are part of the audit trail. Archiving (e.g., to
  a sub-folder) is acceptable; deletion is not.
- **Never reuse a PC id.** Even after a PC is abandoned, its id is
  permanent. The next PC always increments from the highest existing
  id.
- **Never modify `request.md` or `decision.md` after creation.**
  Mistakes are corrected by opening a new PC that supersedes the old
  one (record the supersession in the new `request.md`'s coordinator
  notes).
- **Never skip `pc.yaml`.** The directory must contain `pc.yaml` from
  the moment it's created; status transitions are how the rest of
  the system reasons about the PC.
- **Never write to `coordinator.yaml: plan_changes[]` directly.** Use
  the `--plan-change-open` / `--plan-change-close` checkpoint flags.
  Direct yaml edits race with concurrent coordinator updates.

## Relationship to Other Flows

- **`sdlc-plan-change-triage`** consumes the PC id allocated by this
  skill and writes `triage.md`. The triage skill defers all directory
  management to this skill.
- **`sdlc-plan-change-escalation`** never writes to
  `.sdlc/plan-changes/`. The hub blocker propagates to the
  coordinator, which opens the PC using this skill.
- **P21 Category C incidents** opened by the routing pass are
  cross-referenced in `pc.yaml: p21_incidents_opened`. The incidents
  themselves live under `.sdlc/incidents/` and follow that convention.
- **P19 / P20 deltas** are recorded in `pc.yaml`'s
  `required_env_delta` and `wire_format_delta` fields and applied
  atomically during the routing pass.
- **Brownfield protocol's `change-log.md`** is a separate
  pre-execution artifact under `plan/validation/`. PC records are
  for during-execution changes and live under `.sdlc/`. They do not
  share content; the brownfield log records change-level
  classifications, the PC log records full triage and audit trails.
