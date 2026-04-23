# `.env.example` — Template and Conventions

`.env.example` is the canonical, committed declaration of every environment
variable the project consumes. It carries names, attribution, and purpose in
comments; it never carries values.

## File header

```dotenv
# .env.example — canonical declaration of required environment variables.
# Managed by the `credential-registration` skill.
#
# Copy this file to `.env` (gitignored) and fill in values locally.
# Never commit `.env`. Never paste values into agent chat.
```

## Per-variable block

Every variable gets a three-line (minimum) comment header followed by the
assignment with an empty RHS:

```dotenv
# Introduced by US-004-photo-intake-identification (scope: runtime, integration-test, validation)
# Purpose: OpenRouter provider authentication for photo identification.
# Reference: https://openrouter.ai/docs
OPENROUTER_API_KEY=
```

### Multi-story consumption

When a variable is consumed by more than one story, list all of them on the
`Introduced by` line (first consumer stays first; later consumers are appended
chronologically):

```dotenv
# Introduced by US-004-photo-intake-identification, US-007-bulk-photo-review (scope: runtime, integration-test)
# Purpose: OpenRouter provider authentication (shared across photo features).
# Reference: https://openrouter.ai/docs
OPENROUTER_API_KEY=
```

### Retrofit entries

When the bootstrap mode creates entries for a project that already had env
vars in use before any formal declaration existed, mark the origin
explicitly:

```dotenv
# Introduced by retrofit (2026-04-23) — detected in src/lib/supabase.ts
# Purpose: TODO — describe purpose
# Reference: (none)
SUPABASE_URL=
```

### Optional `reference`

When no useful public documentation exists, omit the `Reference:` line
entirely rather than leaving it blank:

```dotenv
# Introduced by US-012-internal-billing (scope: runtime)
# Purpose: Connection URL for the internal billing queue.
BILLING_QUEUE_URL=
```

## Ordering

- Entries are **grouped by first-introducing story**, stories ordered by their
  numeric ID ascending.
- Within a group, entries are ordered by the order of introduction (i.e. order
  of registration calls). Do not alphabetize — stable diffs matter more than
  visual tidiness, and reordering breaks `git blame` on historical audits.
- Retrofit entries form a single group at the top, labelled by a divider:

```dotenv
# === Retrofit entries (detected in pre-existing code) ===

# Introduced by retrofit (2026-04-23) — detected in src/lib/supabase.ts
# ...
SUPABASE_URL=

# === Introduced by US-004-photo-intake-identification ===

# Introduced by US-004-photo-intake-identification (scope: runtime, integration-test, validation)
# ...
OPENROUTER_API_KEY=
```

## Update rules

- **Additive.** Never remove entries. If deprecated, append a `# DEPRECATED
  (<YYYY-MM-DD>)` line to the comment header; keep the declaration.
- **Never values.** The RHS of `=` is always empty in this file.
- **Never reorder.** Append to the appropriate group; do not shuffle historical
  entries.
