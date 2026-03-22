# Guidance Package Format

Structured format for the semantic reviewer's guidance output. This format is designed for direct inclusion in implementer re-dispatch messages via the `SEMANTIC GUIDANCE` section.

---

## Full Guidance Package (on NEEDS WORK)

```markdown
## Guidance Package

### Verdict Summary
- Overall: NEEDS WORK
- Checks failed: [list of failing check names]
- Escalation: [none / work-unreliable / persistent-failure]

### Corrections

#### [Finding 1 Title]
- **Check:** [which of the 5 checks found this]
- **What's wrong:** [specific issue with evidence]
- **Better result:** [what the correct output looks like]
- **Reasoning:** [why — the deeper analysis the local model couldn't reach]
- **Improvement steps:**
  1. [specific actionable step with file path]
  2. [specific actionable step]
  3. [verification command to confirm fix]

#### [Finding 2 Title]
...

### Knowledge Gaps Identified

#### [Gap 1]
- **What the local model seems to misunderstand:** [description]
- **Evidence from output:** [what in the agent's output suggests this gap]
- **Relevant concept:** [the framework convention, library pattern, or domain concept]

#### [Gap 2]
...

### Documentation (fetched excerpts and/or fetch instructions)

Include whichever form is most useful for each knowledge gap. Both can coexist.

#### Fetched Documentation (when the reviewer retrieved docs directly)

#### [Doc 1: Library/Framework Name — Section]
- **Relevance:** [why this doc addresses the identified knowledge gap]
- **Source:** [library name, version, section title]
- **Content:**
  [pertinent excerpt — focused, not the entire doc]

#### Documentation Fetch Instructions (for the local model to retrieve itself)

#### [Gap 1: Topic]
- **What to search for:** [specific search terms for context7 MCP]
- **Library/package:** [exact name and version]
- **Section to look for:** [specific section, API, or concept name]
- **Why:** [what this documentation will help the local model understand]

### Improvement Instructions (for re-dispatch)

These instructions should be included in the implementer's re-dispatch message:

1. [High-priority fix — most critical issue first]
2. [Second priority fix]
3. [Terminology correction — update X to Y in files A, B, C]
4. [Fetch documentation — use context7 to look up X for library Y before implementing]
5. [Verification — run these commands to confirm all fixes]
```

---

## Proactive Observations (on PASS)

```markdown
## Proactive Observations

### Terminology Notes
- [Term X in file:line could be renamed to Y for consistency with CON-NNN]
- [...]

### Useful Documentation
- [Library doc section that could improve the implementation pattern in file:line]
- [Framework best practice relevant to the approach used in file:line]

### Quality Notes
- [Positive: pattern X in file is well-implemented]
- [Improvement opportunity: pattern Y in file could be simplified using Z]

### Recommendations for Next Story
- [Documentation to pre-fetch for related stories]
- [Patterns to reinforce in future implementer dispatches]
```

---

## Usage by the Architect

The Architect extracts the guidance package and includes it in re-dispatches:

1. **Implementer re-dispatch:** Include the `Improvement Instructions` and `Documentation` sections in a `SEMANTIC GUIDANCE` block in the dispatch message. If the guidance includes fetch instructions, the implementer should use context7 to retrieve the docs before implementing fixes.
2. **Code reviewer re-dispatch (if needed):** Include the `Corrections` section so the reviewer knows what to focus on.
3. **Proactive observations (on PASS):** Optionally include in the acceptance validator dispatch for richer context, or store for the next story's dispatches.
