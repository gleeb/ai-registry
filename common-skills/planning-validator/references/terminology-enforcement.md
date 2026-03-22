# Terminology Enforcement

Detect and enforce naming consistency across plan artifacts. Terminology drift is treated as NEEDS WORK, not deferred.

---

## Purpose

Local planning models frequently introduce synonyms, abbreviations, or variant names for the same concept across different artifacts. This creates downstream confusion when execution models encounter inconsistent terms. Enforcing consistency during planning prevents drift from compounding.

## Procedure

### Step 1: Build term registry

Extract canonical terms from authoritative sources (highest to lowest precedence):

1. **Contract files** (`plan/contracts/`) — field names, type names, state values, enum members
2. **System architecture doc** (`plan/system-architecture.md`) — component names, state names, technology names
3. **PRD** (`plan/prd.md`) — feature names, user-facing terms, constraint terminology

For each term, record:
- Canonical name (as written in the authoritative source)
- Source document and location
- Domain context (what the term refers to)

### Step 2: Check story artifacts

Scan the story's artifacts for each canonical term:
- `story.md` — acceptance criteria, scope, files affected
- `hld.md` — implementation units, interfaces, function names
- `api.md` — endpoint names, field names, parameter names
- `data.md` — entity names, field names, relationship names
- `security.md` — control names, state names

### Step 3: Flag drift

For each divergent term found:

| Drift Type | Example | Severity |
|-----------|---------|----------|
| Same concept, different name | `offline` vs `offline_blocked` | Important |
| Same field, different casing | `api_key` vs `apiKey` vs `has_api_key` | Important |
| Abbreviation not in canonical | `inv` for `inventory` | Suggestion |
| Synonym substitution | `stale_status` vs `stale_state` | Important |
| Contradictory term | `required` vs `optional` for same field | Critical |

### Step 4: Produce guidance (on NEEDS WORK)

For each drift finding:
- State the canonical term and its authoritative source.
- State the divergent term and where it appears.
- Explain why consistency matters: "The implementer will encounter both terms and may create two separate code paths for the same concept."
- Provide the specific correction: "Replace `offline_blocked` with `offline` in hld.md line 42."

## Enforcement vs Deferral

Previous validation treated terminology drift as "DRIFT" severity and deferred it to future cleanup. This check **enforces** consistency:

- **NEEDS WORK** for Important-severity drift (same concept, different name; same field, different casing; synonym substitution).
- **NEEDS WORK** for Critical-severity drift (contradictory terms).
- **Observation** for Suggestion-severity drift (non-canonical abbreviations).
- **Never defer** Important or Critical drift to future cleanup.

## Term Registry Format

```markdown
| Canonical Term | Source | Context |
|---------------|--------|---------|
| `offline` | CON-001, line 15 | Connectivity state when device has no network |
| `api_key` | CON-003, line 8 | Provider API key field name |
| `stale_status` | CON-002, line 22 | Inventory item freshness indicator |
| `inventory_item` | system-architecture.md, Component Inventory | Domain entity for stored items |
```
