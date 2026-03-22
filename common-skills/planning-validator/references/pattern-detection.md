# Pattern Detection

Aggregate validation findings across stories to detect systemic issues and recommend root-cause fixes.

---

## Purpose

When the same local model error appears across multiple stories (e.g., the same CON-001 consumer metadata mistake in US-002, US-004, US-005, and US-010), fixing it per-story is inefficient. Pattern detection identifies recurring issues and recommends root-cause fixes (update the template, fix the source document) rather than N individual corrections.

## When to Run

- During **Cross-Story Validation** (Mode 3), after all per-story validations are complete.
- Review the aggregated findings from all per-story validation runs in the session.

## Procedure

### Step 1: Aggregate findings

Collect all findings from per-story validations, grouped by:
- Check type (dependency manifest, AC traceability, HLD alignment, etc.)
- Finding category (missing metadata, misaligned terms, structural gaps)
- Error pattern (the specific thing that went wrong)

### Step 2: Identify recurring patterns

Flag a pattern as **systemic** when:
- The same error type appears in **3 or more stories**.
- The same field/metadata is missing across multiple stories.
- The same terminology drift appears across multiple stories.
- The same structural issue (e.g., missing section) recurs.

### Step 3: Analyze root cause

For each systemic pattern:
1. **Template issue** — Is the error caused by a missing or ambiguous instruction in the dispatch template? (e.g., "include consumer list" not emphasized enough)
2. **Source document issue** — Is the error caused by ambiguity or error in an upstream document? (e.g., architecture doc uses inconsistent terms)
3. **Model capability issue** — Is the error caused by a known limitation of the local model? (e.g., consistently fails to update metadata on multi-document edits)

### Step 4: Recommend root-cause fix

| Root Cause | Recommendation |
|-----------|----------------|
| Template gap | Update the dispatch template with explicit instructions for the missing item. Cite the specific template and the missing instruction. |
| Source document ambiguity | Update the source document to resolve the ambiguity. Cite the specific document and the ambiguous section. |
| Source document error | Fix the source document. Cite the error and the correction. |
| Model capability limitation | Add a verification step to the per-story validation that catches this specific pattern. Document the limitation for future routing decisions. |

### Step 5: Report

For each systemic pattern:

```markdown
### Systemic Pattern: [Name]

**Occurrences:** [list of stories where this appeared]
**Pattern:** [description of the recurring error]
**Root cause:** [template / source doc / model capability]
**Evidence:** [specific findings from each story]
**Recommended fix:** [specific action to prevent recurrence]
**Priority:** [Critical / Important — based on downstream impact]
```

## Examples

### Example 1: Missing contract consumer metadata

```
Occurrences: US-002, US-004, US-005, US-010
Pattern: CON-001 consumer list not updated when story consumes the contract
Root cause: Story Decomposer dispatch template doesn't explicitly require updating contract consumer lists when a story references a contract
Recommended fix: Add to story-decomposition-dispatch.md: "For each contract in consumes_contracts, verify the contract file's consumer list includes this story's ID. Update if missing."
```

### Example 2: Terminology drift across stories

```
Occurrences: US-003, US-007, US-008
Pattern: HLD uses "offline_blocked" but architecture and CON-001 use "offline"
Root cause: architecture doc section on connectivity states is ambiguous — mentions both "offline state" and "blocked state" in adjacent paragraphs
Recommended fix: Update system-architecture.md to use only "offline" consistently. Update per-story HLDs that were already generated.
```
