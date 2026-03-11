# Error Handling

## Missing Artifacts

### Trigger

- A required artifact specified in the dispatch does not exist.
- Example: `plan/user-stories/US-003/story.md` missing; `plan/contracts/auth-model.md` missing.

### Action

- Flag in report: "Artifact [path] is missing."
- Report which checks could not be run (list them explicitly).
- Do not infer or guess content.
- Recommendation: "Dispatch [agent] to produce [artifact] before re-validation."

### Prohibited

- Do not run checks that depend on the missing artifact and pretend they passed.
- Do not create placeholder content.
- Do not skip reporting the gap.

---

## Incomplete Artifacts

### Trigger

- An artifact exists but is incomplete (missing sections, empty sections, truncated content).

### Action

- Flag: "Artifact [path] is incomplete — [list missing/empty sections]."
- Run checks on available content; note which checks were partial or skipped.
- Add observation: "Incomplete artifact may hide additional issues."
- If critical sections are missing, recommend re-dispatch to complete the artifact.

### Prohibited

- Do not assume missing sections are "fine" or "not needed."
- Do not pass completeness checks when sections are empty.

---

## Dependency Graph Cycles

### Trigger

- Building the dependency graph from `depends_on_stories` yields a cycle (e.g., US-003 → US-005 → US-003).

### Action

- Report as structural issue: "Dependency cycle detected: [list cycle]."
- For Cross-Story mode: FAIL dependency graph integrity check.
- For Impact Analysis: Report the cycle; do not complete full impact trace (results would be ambiguous).
- Recommendation: "Break cycle by extracting shared contract, merging stories, or removing false dependency. Re-run Story Decomposer if needed."

### Prohibited

- Do not ignore cycles.
- Do not attempt to "resolve" cycles by omitting edges — report the actual structure.

---

## Contract Ownership Disputes

### Trigger

- Multiple stories list the same contract in `provides_contracts`.
- A contract file exists but no story claims ownership.

### Action

- Report: "Contract ownership dispute: [contract] claimed by [list stories]."
- Or: "Orphan contract: [contract] has no provider story."
- Severity: CONFLICT (duplicate) or GAP (orphan).
- Recommendation: "Escalate to Hub. Assign single owner (typically earlier story in execution order) or remove orphan contract."

### Prohibited

- Do not silently pick an owner.
- Do not ignore orphan contracts.

---

## Conflicting Validation Results Across Modes

### Trigger

- Phase validation passed, but Cross-Story validation fails.
- Per-Story validation passed for all stories, but Cross-Story finds contract conflicts.
- Impact analysis suggests different scope than a previous validation report.

### Action

- Report the conflict: "Validation inconsistency: [Mode A] passed [check], but [Mode B] found [issue]."
- Do not suppress one result in favor of the other.
- Recommendation: "Escalate to Hub. Re-run validation in [mode] after resolving [issue]. Cross-Story and Phase results must align."

### Prohibited

- Do not hide conflicting results.
- Do not assume one mode is "more correct" without escalation.

---

## Summary Table

| Error | Action | Prohibited |
|-------|--------|------------|
| Missing artifact | Flag, list skipped checks, recommend dispatch | Infer, guess, skip reporting |
| Incomplete artifact | Flag sections, run partial checks, add observation | Assume completeness |
| Dependency cycle | Report cycle, FAIL graph integrity, recommend fix | Ignore, fake resolution |
| Contract ownership dispute | Report, escalate to Hub | Silently assign owner |
| Conflicting results across modes | Report both, escalate to Hub | Suppress one result |
