# Skill Gotchas Template

Use this template when the engineering hub creates the skill gotchas sibling file during Phase 1b.

**File location:** `docs/staging/US-NNN-name.skill-gotchas.md`
**Linked from:** `docs/staging/US-NNN-name.md` (main staging doc header)

**Purpose:** Append-only log of technical gotchas discovered during this story's execution. Contains library/framework/language quirks, cross-library interactions, and tooling edge cases. Post-run, the human reviews this file alongside the run transcript and promotes entries into the relevant skill files manually.

**Who writes it:** Implementers and code reviewers append entries during Phase 2 dispatches.
**Who reads it:** The human, post-run. NOT read by the documentation-writer during consolidation.
**Who must NOT promote from it:** Any agent during the story run. Promotion to skill files is a human post-run action only.

---

## Template

```markdown
# US-NNN — Skill Gotchas

**Story:** [Story Title]
**Main staging doc:** `docs/staging/US-NNN-name.md`
**Post-run action:** Review entries below with the run transcript. Promote Technical gotchas to the suggested skill files manually.

---

## Gotchas

<!-- Append entries below. Do not delete or reorder existing entries. -->

```

---

## Entry Schema

Each entry added by an implementer or reviewer must use this format:

```markdown
## Gotcha: [short descriptive title]

- **symptom:** [What manifested — error message, test failure, unexpected output, build breakage]
- **root_cause:** [The library, version, or interaction responsible. Be specific — "Vitest 1.x CSS module transform runs before Vite's ?raw query suffix takes effect" not just "CSS issue".]
- **workaround:** [The fix applied during this run — concrete code or config change]
- **suggested_skill_target:** [Which skill file this should be promoted to, e.g., `scaffold-project/references/react-vite.md` or `e2e-testing-patterns/SKILL.md`]
- **discovered_in:** [Task ID and dispatch number, e.g., "Task 2, dispatch 3 (re-dispatch after CSS test failures)"]
```

---

## Example

```markdown
## Gotcha: Vitest CSS transform runs before Vite ?raw query suffix

- **symptom:** Tests importing `?raw` CSS files fail with "SyntaxError: Unexpected token" — Vitest tries to parse raw CSS as JS.
- **root_cause:** Vitest 1.x applies its CSS transform pipeline to all `.css` imports before Vite's query-suffix processing. The `?raw` suffix is not honored in the Vitest transform chain without explicit configuration.
- **workaround:** Add `{ test: { css: { modules: { classNameStrategy: 'non-scoped' } } } }` to vitest.config.ts and add a `transformIgnorePatterns` entry for `*.module.css?raw` imports.
- **suggested_skill_target:** `scaffold-project/references/react-vite.md` under `## Known Gotchas`
- **discovered_in:** Task 1, dispatch 4 (after 3 review cycles on CSS test failures)
```
