# Decision Guidance

## Severity Classification

Use these severity levels for findings:

| Severity | Definition | Action |
|----------|------------|--------|
| **CONFLICT** | Two artifacts make directly contradictory decisions | MUST resolve before proceeding |
| **TENSION** | Two artifacts make potentially incompatible decisions | SHOULD resolve or acknowledge |
| **GAP** | A decision in one artifact has no counterpart in another | MAY be acceptable if documented |
| **DRIFT** | Same concept uses different terminology | SHOULD align terminology |

### When to use each

- **CONFLICT** — e.g., API says "JWT auth" and security.md says "API key auth" for the same endpoint.
- **TENSION** — e.g., PRD says "< 200ms" and architecture suggests a design that may not meet it.
- **GAP** — e.g., HLD defines a component but no API endpoint exposes it (may be intentional).
- **DRIFT** — e.g., PRD says "customer," story says "account holder," data says "user."

---

## When to Recommend Re-Dispatch vs Proceed

### Recommend Re-Dispatch

- Any CONFLICT severity finding — specific agents must resolve.
- TENSION findings that affect multiple stories — Hub or domain agents.
- Missing artifacts that block validation — report which agents must produce them.
- Per-story validation failures — re-dispatch the Phase 3 agents for that story.
- Cross-story dependency graph issues (cycles, orphan contracts) — Story Decomposer or contract owners.

### Recommend Proceed

- All checks PASS with evidence.
- Only GAP or DRIFT with documented rationale.
- Observations only (non-blocking).

### Conditional Proceed

- TENSION with acknowledged trade-off — proceed if user accepts.
- Minor GAPs with observations — proceed with caveat.

---

## When to Escalate to Hub

- Cross-story conflicts that require coordination (e.g., contract ownership dispute).
- Validation failures that suggest story decomposition may be wrong.
- Impact analysis shows large blast radius — Hub decides re-planning scope.
- Conflicting validation results across modes (e.g., Phase passed but Cross-Story failed).
- Structural issues: dependency cycles, orphan contracts, missing dependency manifests.

---

## Impact Analysis Scope Decisions

### What to include in blast radius

- Report ALL affected items, even if impact seems minor.
- Let the Hub and user decide scope — do not filter.
- Classify: Direct (re-planning likely), Indirect (re-validation), Unaffected.

### When to flag structural issues

- Dependency graph has cycles — report as structural issue; do not complete impact trace.
- Story has no dependency manifest — flag as analysis gap.
- Contract has no owner or no consumers — flag in report.

---

## How to Handle Missing Artifacts

### Missing required artifact

- Flag in report: "Artifact X is missing."
- List which checks could not be run.
- Do not infer or guess content.
- Recommend: "Dispatch [agent] to produce [artifact] before re-validation."

### Incomplete artifact

- Flag: "Artifact X is incomplete — sections [list] missing or empty."
- Run checks on available content; note which checks were partial.
- Add observation: "Incomplete artifact may hide additional issues."

### Missing consumed contract

- Per-story mode: FAIL Contract Compliance check; flag missing contract.
- Cross-story mode: Flag contract with no consumers (orphan) or missing provider.
- Recommend: "Story Decomposer or contract owner must provide [contract]."
