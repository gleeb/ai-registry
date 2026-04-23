---
name: credential-registration
description: >
  Register, declare, and retrofit environment-variable-based credentials for a
  project. Load this skill in the PLANNER HUB (`sdlc-planner`) when dispatched
  with a CREDENTIAL_REGISTRATION directive from the coordinator — either to
  retrofit a project that has no `required_env` declarations or `.env.example`
  yet (bootstrap mode), or to declare a new variable mid-execution (addition
  mode).
---

# Credential Registration

## Purpose

This skill is the **planner hub's** handler for declaration-only plan updates
that introduce or back-fill `required_env` entries. It is dispatched by the
coordinator on user intent but executed by the planner, because the decisions
the skill must make — "is this really declaration-only or a scope change in
disguise?", "which stories should also declare this?", "does the proposed
classification conflict with `api.md`?" — are planner-shaped decisions that
require read access to `api.md`, architecture artifacts, and every story's
scope declaration.

The skill performs declarative, bounded writes to three artifact families
(`.env.example`, `plan/cross-cutting/required-env.md`, per-story
`required_env` blocks). It does not touch product code, does not modify
`api.md` or architecture artifacts (those changes go through the Brownfield /
Plan Change Protocol), does not invent values, and does not write to `.env`.

## When to Use (planner-hub only)

Load this skill in the planner hub (`sdlc-planner`) when you receive a
dispatch message whose directive is `CREDENTIAL_REGISTRATION`. The dispatch
payload will include:

- `mode`: `bootstrap` or `addition`
- `name` (addition mode only): the variable name the user requested
- `fields` (addition mode, optional): any of `purpose`, `scope`, `sensitivity`,
  `reference` that the user supplied to the coordinator
- `active_story` (addition mode, when applicable): the story currently in
  execution, used as the default attribution
- `user_hints` (optional): additional attribution or context the user provided

Dispatch any other form of planning work (full plan generation, phase-level
replan, plan change with scope implications) through the normal planner
workflow, not this skill.

## When NOT to Use

- **Never load in the coordinator.** The coordinator's role for this flow is
  to route the user's intent to this skill via a planner dispatch, not to
  execute the skill. Coordinator-owned credential handling is limited to
  `MISSING_CREDENTIALS` (declaration exists, value missing locally), which
  is user-environment action and requires no planning.
- **Never load in any execution agent** (implementer, scaffolder, reviewer,
  QA, acceptance-validator, architect, engineering hub). Those agents halt on
  missing credentials; they do not declare them.
- **Do not use for new external dependencies that imply scope change.** If
  the user's request is actually "switch from provider X to provider Y" or
  "adopt a new external service," route to the Plan Change Protocol. The
  scope-change detection step below exists specifically to catch these.

## Core Principles

1. **Declarations are committed; values are not.** The skill writes to
   `.env.example`, `plan/cross-cutting/required-env.md`, and `story.md`'s
   `required_env` block. It never writes to `.env`. It never reads `.env`.
2. **Decision before write.** Every invocation runs the scope-change detection
   step before any artifact write. If the decision is `ROUTE_TO_PLAN_CHANGE`,
   the skill returns that verdict without touching any file.
3. **One `.env.example`, deduped.** When a variable is consumed by multiple
   stories, there is exactly one entry in `.env.example` and its comment
   header lists all contributing stories.
4. **Attribution is recorded.** Every declaration records the story (or the
   `retrofit` origin) that introduced it. Genuinely ambiguous attributions
   are marked `attribution: unassigned` with candidate stories listed, not
   guessed at.
5. **Idempotence.** Running bootstrap on a project that already has
   `.env.example` and `required-env.md` must be a no-op; it returns a `NOOP`
   summary of the current declared state.
6. **No value handling.** The skill never asks for values, never echoes
   values, never stores values. The coordinator (not this skill) is
   responsible for the user-facing "set the value in your local `.env`"
   instruction after the skill returns.

## Three Return Verdicts

Every invocation returns one of:

- **`DECLARED`** — artifacts were written successfully. Summary includes the
  variable(s) declared, attributions, classifications, any conflicts detected
  and resolved, and the `.env` line(s) the user must add.
- **`ROUTE_TO_PLAN_CHANGE`** — the request is a scope change in disguise.
  Summary includes a one-paragraph rationale citing the specific `api.md` or
  story contract that contradicts the request, plus the user's original
  request unchanged so the plan-change flow has the full context. No
  artifacts were written.
- **`NOOP`** — bootstrap mode detected no gap; the project already has
  complete and consistent declarations. Summary includes the current declared
  variable set for user confirmation. No artifacts were written.

The coordinator consumes the verdict and decides next action: relay to user,
route to the plan-change protocol, or instruct user to populate `.env` and
resume.

## Mode A — Bootstrap / Retrofit

Use when `mode: bootstrap`, typically invoked when a project lacks the
expected declaration artifacts (`.env.example`, `plan/cross-cutting/required-env.md`,
per-story `required_env` blocks).

**Procedure:**

1. **Detect the gap.** Check for existence of `.env.example`, of
   `plan/cross-cutting/required-env.md`, and of `required_env` fields in each
   `plan/user-stories/*/story.md`. If everything is present and consistent,
   return `NOOP` with the current declared set. Otherwise, proceed.

2. **Inventory code usage.** Scan `src/`, `app/`, `lib/`, and `tests/` (or
   the project's equivalent source roots inferred from `package.json` /
   `tsconfig.json` / project conventions) for env-var reads:
   - `process.env.<NAME>` (Node / Next.js server)
   - `process.env["<NAME>"]` (bracket form)
   - `import.meta.env.<NAME>` (Vite / modern ESM)
   - Framework-specific accessors present in the project (React Native
     `@env`, Expo `Constants.expoConfig.extra`, Cloudflare `env.<NAME>`, etc.
     — detect based on detected framework in `package.json`).
   Record each unique `<NAME>` and the list of files referencing it.

3. **Classify each name.** For each detected name, derive:
   - `sensitivity: secret | config` — names containing `KEY`, `SECRET`,
     `TOKEN`, `PASSWORD`, `PRIVATE` default to `secret`; names containing
     `URL`, `HOST`, `PORT`, `PUBLIC`, `NEXT_PUBLIC_` default to `config`.
     Anything ambiguous is `secret` (fail-safe).
   - `scope` — inferred from reference locations: `src/` or `app/` implies
     `runtime`; `tests/` or `*.test.*` or `*.spec.*` implies
     `integration-test` when the file performs real network calls or
     `unit-test-placeholder` when the file is purely mocked. Default to
     `runtime` when ambiguous.
   - `purpose` — extract from the nearest comment or surrounding context;
     leave a `TODO: describe purpose` marker if none can be derived.
   - `reference` — left empty during retrofit; user fills in later.
   Validate the classification by cross-checking with each relevant story's
   `api.md`: if `api.md` describes an integration that consumes this
   variable, the `api.md` phrasing refines the `purpose` and `scope`.
   Consulting `planner-api` as a read-only subagent is appropriate here
   when the classification is non-obvious.

4. **Attribute each variable to a story.** Cross-reference each consuming
   file against every `plan/user-stories/*/story.md`'s scope declaration
   (files-in-scope, feature boundaries). Unambiguous matches are assigned
   directly. When a variable is consumed by shared code touched by multiple
   stories, mark the entry `attribution: unassigned` and list the candidate
   stories; do not guess.

5. **Seed `.env.example`** at repo root. See
   `references/env-example-template.md`. One entry per detected name. If
   `.env.example` already exists with partial content, preserve existing
   entries and append missing ones; never reorder or delete.

6. **Seed `plan/cross-cutting/required-env.md`** with one section per name.
   Format per `references/required-env-template.md`. Retrofit entries
   receive `Origin: retrofit` and a retrofit date.

7. **Attach `required_env` blocks** to each in-flight story. For stories
   with assigned attributions, append the variable to the story's
   `required_env` list. For unassigned attributions, do not modify any
   story; those will be resolved after user confirmation.

8. **Return `DECLARED`** (or `DECLARED-PARTIAL` if unassigned attributions
   remain) with a structured summary: inventory counts, per-variable
   classification, unassigned list awaiting user confirmation, and the list
   of variables the user must set in `.env` before resuming.

## Mode B — Mid-Execution Addition

Use when `mode: addition`. A story is in execution (or recently paused) and
the user wants to declare a new variable.

**Procedure:**

1. **Parse the dispatch payload.** Required on arrival: `name`. Expected
   from user via coordinator pass-through: `purpose`, `scope`, `sensitivity`.
   Optional: `reference`, explicit `attribution`.

2. **Scope-change detection.** Read the active story's `api.md` and the
   relevant architecture artifacts. Determine:
   - Does the current `api.md` already reference the provider or integration
     class that this variable authenticates?
   - If the current plan says we call Internal Proxy X and the user wants to
     register `OPENROUTER_API_KEY`, the plan does not imply OpenRouter —
     this is a scope change.
   - If the current `api.md` already says the feature calls OpenRouter but
     forgot to declare the credential, this is a missed declaration —
     proceed as declaration-only.
   If the detection returns "scope change," return verdict
   `ROUTE_TO_PLAN_CHANGE` with a one-paragraph rationale citing the specific
   contract clause that contradicts the request. Do not write any artifacts
   in this case.

3. **Field completion & validation.** If any of `purpose`, `scope`,
   `sensitivity` is missing from the payload, derive what can be derived
   from `api.md` and the consuming code, and return the missing-field list
   in the summary so the coordinator can ask the user **one** consolidated
   question. Never multi-question. Never ask for the value.

   Reconcile user-provided fields with what `api.md` implies. Example: user
   says `scope: [runtime]` but the story's api.md describes integration
   tests exercising this provider → flag as a conflict in the return
   summary; the default resolution is to add `integration-test` (safer) and
   let the coordinator surface the change to the user.

4. **Cross-story propagation.** Search other `story.md` files and their
   consumed code paths for references that will also consume this variable.
   If any are found, include them in the `Also consumed by:` list in
   `required-env.md` and append `required_env` entries to those stories.
   This is what the coordinator cannot do alone — it requires reading plan
   artifacts across all stories.

5. **Atomic three-artifact write.**
   - Append or merge the entry in `.env.example` (comment header attributes
     to the active story and any cross-story consumers).
   - Append or update the matching section in
     `plan/cross-cutting/required-env.md`.
   - Append the entry to each affected story's `required_env` block in
     `story.md`.

6. **Return `DECLARED`** with a structured summary: declared variable(s),
   attribution list, conflicts detected and resolved, the exact `.env` line
   the user must add, and a re-dispatch hint signaling that Phase 0a should
   be re-run after the user populates `.env`.

## Strict Prohibitions

- Never write to `.env`. Ever.
- Never read `.env`. Agents do not parse it.
- Never ask for the value. The coordinator (not this skill) instructs the
  user to populate `.env` locally, based on the skill's return summary.
- Never echo or quote a value from `process.env` in reports or returns.
- Never invent a placeholder value to "unblock" a story. Fabricated
  credentials produce green gates over broken integrations and are a
  completion-contract violation.
- Never modify `api.md`, architecture artifacts, or story acceptance
  criteria. If the registration implies those changes, return
  `ROUTE_TO_PLAN_CHANGE`; do not write.
- Never rename, remove, or reorder existing `.env.example` entries unless
  the dispatch explicitly requests cleanup. Additive only.

## Relationship to Other Flows

- **`MISSING_CREDENTIALS` (coordinator-handled).** Declaration already
  exists; value is not set in the local shell on this machine. No planning
  decision required; the coordinator asks the user to populate `.env` and
  re-dispatches Phase 0a. This skill is NOT involved.
- **Plan Change Protocol.** When scope-change detection returns
  `ROUTE_TO_PLAN_CHANGE`, the coordinator hands the same user request into
  the plan-change flow. That flow may ultimately result in a new
  `required_env` entry being declared — that declaration is produced as
  part of the plan-change artifact, not by re-invoking this skill.
- **Normal planning cycle.** During initial plan generation, `required_env`
  declarations are produced by `planner-api` and `planner-stories` as part
  of their standard artifacts. This skill exists for out-of-cycle updates
  (retrofit, mid-execution addition); it is not a replacement for the
  normal planning path.

## References

- `references/required-env-template.md` — schema for
  `plan/cross-cutting/required-env.md` sections.
- `references/env-example-template.md` — comment-header convention for
  `.env.example` entries.
