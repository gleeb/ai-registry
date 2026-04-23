# `plan/cross-cutting/required-env.md` — Template

This file is the human-readable cross-reference for every environment variable
declared by the project's stories. It is maintained by the
`credential-registration` skill (both bootstrap mode and mid-execution mode).

## File header

```markdown
# Required Environment Variables

This file is the consolidated declaration of every environment variable the
project consumes at runtime, in tests, or during validation. It is generated
and maintained by the `credential-registration` skill.

**Contract:** every variable listed here also appears in `.env.example`. Every
variable in `.env.example` appears here. Values live only in the local `.env`
file (gitignored).

Last updated: <YYYY-MM-DD>
```

## Per-variable section

One section per declared variable, alphabetized by name:

```markdown
## `OPENROUTER_API_KEY`

- **Sensitivity:** secret
- **Scope:** runtime, integration-test, validation
- **Purpose:** Live provider authentication for the photo-identification path.
- **Consumed by:**
  - `src/features/media/identify-bottles.ts` (runtime)
  - `tests/integration/photo-intake-identification.test.ts` (integration-test)
- **Introduced by:** US-004-photo-intake-identification (2026-04-22)
- **Also consumed by:** US-007-bulk-photo-review (2026-05-01)
- **Reference:** https://openrouter.ai/docs
- **Origin:** plan (introduced at plan time by planner-api)
- **Set instruction:** add `OPENROUTER_API_KEY=<your value>` to `.env`
```

### Retrofit variant

When bootstrapping an existing project, use `Origin: retrofit` and mark
ambiguous attributions:

```markdown
## `SUPABASE_URL`

- **Sensitivity:** config
- **Scope:** runtime
- **Purpose:** TODO — describe purpose (retrofit inferred from `src/lib/supabase.ts`)
- **Consumed by:**
  - `src/lib/supabase.ts` (runtime)
- **Introduced by:** retrofit (2026-04-23)
- **Attribution:** unassigned — candidate stories: US-002, US-003
- **Reference:** (none declared)
- **Origin:** retrofit
- **Set instruction:** add `SUPABASE_URL=<your value>` to `.env`
```

The `Attribution: unassigned` marker is a signal to the coordinator to surface
this entry to the user for confirmation on next interaction.

## Update rules

- **Additive.** Never remove a section. If a variable is no longer consumed by
  any story, mark it `Status: deprecated (<YYYY-MM-DD>)` but keep the section.
- **Deduped.** Exactly one section per `name`. Multiple consuming stories are
  listed under `Also consumed by:`.
- **No values.** Never record the actual value. The `Set instruction` line
  shows the template, not the value.
- **Sorted.** Sections are alphabetized by `name` for stable diffs.
