# Plan Validator Best Practices

## Reality Checker Philosophy

The validator operates with a skeptical, evidence-based posture. Assume artifacts need work until proven otherwise.

### Default to NEEDS WORK

- Every check starts as FAIL.
- Passing requires explicit evidence — not assumptions or references alone.
- A story or phase with zero issues found is suspicious — dig deeper.

### Evidence Protocol

For each check, document:

1. **What was checked** — the specific validation dimension or rule.
2. **What was examined** — specific document sections, field values, artifact paths.
3. **What was found** — the concrete finding (PASS with evidence, or FAIL with specific issue).

Example:

```
- What checked: HLD-to-API alignment for component X.
- Evidence examined: hld.md §3.2 (data flow), api.md §2.1 (endpoint schema).
- Finding: PASS — data flow fields A, B, C map to response schema fields a, b, c.
```

### No "Zero Issues Found"

- If you find zero issues, that report is suspicious.
- Re-examine: Did you skim? Did you check references without reading content?
- Add observations: questions, areas for deeper review, edge cases not yet validated.
- Observations section is mandatory in every report.

### Specification Compliance

- Read BOTH documents involved in a check — do not trust that references exist.
- Verify content matches: a reference to "PRD section 7.3" is insufficient — read section 7.3 and verify the story actually addresses it.
- "References exist" ≠ "Content aligns." Always verify alignment.

### Thorough Reading

- Do not skim. Read the relevant sections in full.
- For traceability: extract requirements from source, then search target for corresponding coverage.
- For consistency: compare actual content, not just headers or section titles.

## Observations Section Mandatory

Every validation report must include an **Observations** section with:

- Non-blocking items (potential improvements, minor drifts).
- Questions for the planning team or user.
- Areas for deeper review (e.g., "Security model could use more detail on token refresh").
- Edge cases not explicitly validated.

If you have nothing to add, ask: "What did I NOT check?" and add at least one observation.

## Anti-Patterns

- **Lenient passing** — Do not mark PASS because "it looks fine." Require evidence.
- **Reference-only checks** — Do not pass a check because "the story references the PRD section." Verify the story content addresses the PRD content.
- **Skipping observations** — Never omit the observations section.
- **Assuming completeness** — Do not assume an artifact is complete because it has sections. Verify the sections contain sufficient content.
