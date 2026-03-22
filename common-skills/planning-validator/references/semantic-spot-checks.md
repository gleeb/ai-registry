# Semantic Spot-Checks

Verify that acceptance criteria correctly interpret PRD requirements — meaning, not just section references.

---

## Purpose

Local planning models often reference the correct PRD section but misinterpret the requirement. This check verifies **semantic accuracy**: does the AC correctly capture what the PRD actually says?

## Procedure

### Step 1: Select criteria to spot-check

- Pick 2-3 acceptance criteria from the story being validated.
- Prefer criteria that reference specific PRD constraints or NFRs.
- Prefer criteria with quantitative or behavioral requirements (easier to verify misinterpretation).

### Step 2: Trace to PRD

For each selected AC:
1. Read the AC text and identify the PRD section it references.
2. Read the actual PRD section.
3. Compare the meaning:
   - Does the AC correctly represent the PRD requirement?
   - Does the AC narrow or broaden the requirement inappropriately?
   - Does the AC add conditions not in the PRD?
   - Does the AC omit conditions that are in the PRD?

### Step 3: Assess alignment

| Finding | Assessment |
|---------|-----------|
| AC correctly captures PRD meaning | PASS |
| AC references correct section but misinterprets meaning | NEEDS WORK |
| AC adds conditions not in PRD | NEEDS WORK (unless justified in story scope) |
| AC omits conditions from PRD | NEEDS WORK |
| AC references wrong PRD section | NEEDS WORK |

### Step 4: Produce guidance (on NEEDS WORK)

For each misaligned AC:
- Quote the PRD text and the AC text side by side.
- Explain what the PRD actually means.
- Explain why the AC misinterprets it.
- Provide a corrected AC that accurately reflects the PRD requirement.

## Examples

### Misinterpretation: broadening

```
PRD: "Maximum four top-level screens: Chat, Inventory, Settings, Uploads/Media."
AC: "App navigation scaffold exposes at least four top-level screens."

Issue: PRD says "maximum" (constraint), AC says "at least" (minimum).
Corrected: "App navigation scaffold exposes exactly four top-level screens: Chat, Inventory, Settings, and Uploads/Media."
```

### Misinterpretation: omission

```
PRD: "Web app becomes interactive within 2 seconds on standard broadband."
AC: "The app loads quickly."

Issue: AC drops the quantitative target (2 seconds) and the condition (standard broadband).
Corrected: "Web app reaches interactive state within 2 seconds on a standard broadband connection (≥25 Mbps)."
```
