# Planning Guidance Format

Structured format for the Plan Validator's guidance output when returning NEEDS WORK. Designed for direct inclusion in planning agent re-dispatch messages via the `VALIDATOR GUIDANCE` section.

---

## Full Guidance Package (on NEEDS WORK)

```markdown
## Validator Guidance Package

### Verdict Summary
- Overall: NEEDS WORK
- Checks failed: [list of failing check names and IDs]
- Stories affected: [list of story IDs]

### Corrections

#### [Finding 1: Check Name — Issue Title]
- **Check:** [which validation check found this (e.g., Check #10 Semantic Spot-Check)]
- **What's wrong:** [specific issue with evidence — cite document, section, line]
- **Better result:** [what the corrected artifact should say]
- **Reasoning:** [why — explain the deeper analysis, the PRD intent, the architectural principle]
- **Correction steps:**
  1. [specific edit: file, section, old text → new text]
  2. [verification: how to confirm the fix is correct]

#### [Finding 2]
...

### Knowledge Gaps Identified

#### [Gap 1]
- **What the local model seems to misunderstand:** [description]
- **Evidence from output:** [what in the artifact suggests this gap]
- **Relevant concept:** [the framework convention, domain concept, or planning pattern]

#### [Gap 2]
...

### Documentation (fetched excerpts and/or fetch instructions)

Include whichever form is most useful for each knowledge gap. Both can coexist.

#### Fetched Documentation (when the validator retrieved docs directly)

#### [Doc 1: Framework/Library — Section]
- **Relevance:** [why this doc addresses the identified knowledge gap]
- **Source:** [library/framework name, section title]
- **Content:**
  [pertinent excerpt]

#### Documentation Fetch Instructions (for the local model to retrieve itself)

#### [Gap 1: Topic]
- **What to search for:** [specific search terms for context7 MCP]
- **Library/package:** [exact name and version]
- **Section to look for:** [specific section, API, or concept name]
- **Why:** [what this documentation will help the local model understand]

### Improvement Instructions (for re-dispatch)

These instructions should be included in the planning agent's re-dispatch message:

1. [Highest priority correction]
2. [Second priority correction]
3. [Terminology fix — canonical terms to use]
4. [Fetch documentation — use context7 to look up X for library Y before revising]
5. [Verification — how to confirm all corrections are applied]

### Documentation (for re-dispatch)

Include any fetched documentation excerpts directly. For fetch instructions,
the local model should use context7 MCP to retrieve the docs before revising.

[Fetched doc excerpts and/or fetch instructions from above]
```

---

## Systemic Findings (from Pattern Detection)

When pattern detection identifies systemic issues, add:

```markdown
### Systemic Patterns

#### [Pattern Name]
- **Occurrences:** [N stories]
- **Root cause:** [template gap / source doc issue / model limitation]
- **Recommended fix:** [specific action]
- **Priority:** [Critical / Important]
```

---

## Usage by the Planning Hub

The Planning Hub (commercial) extracts the guidance package and includes it in re-dispatches:

1. **Planning agent re-dispatch:** Include the `Improvement Instructions` and `Documentation` sections in a `VALIDATOR GUIDANCE` section in the dispatch message. If fetch instructions are included, the local agent should use context7 to retrieve the docs before revising.
2. **Template updates (systemic patterns):** If the pattern detection recommends a template fix, update the template before re-dispatching — this prevents the same error in future stories.
3. **Source document fixes:** If the root cause is in an upstream document (architecture, PRD), fix the source first, then re-dispatch the affected planning agents.
