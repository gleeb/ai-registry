# Semantic Review Checklist

Detailed procedures for the 5 validation checks. Each check defaults to NEEDS WORK — prove PASS with cited evidence.

---

## Check 1: Verdict Consistency

**Goal:** Detect contradictions in local model self-reports.

### Procedure

1. Collect all `attempt_completion` results from:
   - Per-task code reviewers (each task's Spec Compliance + Overall Assessment)
   - Per-task QA verifiers (each task's Verification Status + per-criterion results)
   - Full-story code reviewer (Spec Compliance + Overall Assessment)
   - Full-story QA verifier (Verification Status + per-criterion results)

2. For each code review result, verify:
   - If Spec Compliance = PASS, then Overall Assessment must be Approved (not Changes Required)
   - If any Critical or Important issues are listed, Overall Assessment must be Changes Required
   - If Overall Assessment = Approved, no Critical or Important issues should be listed
   - Issue severity categorization must be consistent (same issue type shouldn't be Critical in one task and Suggestion in another)

3. For each QA result, verify:
   - If Verification Status = PASS, all per-criterion results must be PASS
   - If any criterion is FAIL, Verification Status must be FAIL
   - Verification commands must produce actual output (not just "command exists")

4. Cross-reference:
   - If code reviewer flagged issues in specific files, QA should have verified those files
   - If QA found regressions, code reviewer should have flagged related patterns

### Evidence Format

```
VERDICT CONSISTENCY CHECK:
- [Task N] Code Review: Spec Compliance=[PASS/FAIL], Assessment=[Approved/Changes Required]
  Issues: [count by severity]
  Consistency: [OK / CONTRADICTION: detail]
- [Task N] QA: Status=[PASS/FAIL], Per-criterion: [N/N pass]
  Consistency: [OK / CONTRADICTION: detail]
- Cross-reference: [OK / MISMATCH: detail]
```

---

## Check 2: Work Verification

**Goal:** Independently verify that the local model's work actually holds up — like a senior developer re-checking a junior's deliverables.

### Procedure

1. Select 2-3 verification commands from the local agents' reports:
   - Prefer test runs (`npm run test`, `jest`, `pytest`) over lint/typecheck
   - Prefer commands with specific expected output (test count, exit code)
   - If QA ran verification commands, use those; otherwise use implementer self-verification

2. For each selected command:
   a. Run the exact same command in the current project directory
   b. Capture the full output and exit code
   c. Compare with the claimed output:
      - Exit code match?
      - Test count match (if applicable)?
      - Key output lines match?
      - File references in output exist?

3. Flag significant discrepancies:
   - Different exit codes (0 vs non-zero)
   - Different test counts (e.g., claimed 15 tests, actual 12)
   - Missing files referenced in claimed output
   - Output format suggests the command was never actually run

### Evidence Format

```
WORK VERIFICATION CHECK:
Command: [exact command]
Claimed output: [summary of what agent reported]
Actual output: [summary of fresh run]
Exit code: claimed=[N] actual=[N]
Assessment: [VERIFIED / UNRELIABLE: specific discrepancy]
```

### Important Notes

- Minor output differences (timestamps, order of parallel test results) are acceptable
- Focus on substantive differences that indicate the work doesn't hold up
- If the project environment has changed since the agent ran (e.g., new dependencies), note this as context
- Discrepancies are usually confabulation (the model filled in plausible-sounding results), not intentional deception — guide toward getting it right, don't just flag the gap

---

## Check 3: Plan-to-Code Spot-Check

**Goal:** Verify acceptance criteria are semantically implemented, not just structurally present.

### Procedure

1. Read all acceptance criteria from story.md

2. Select 2-3 criteria for spot-checking:
   - Prefer criteria with specific behavioral requirements
   - Prefer criteria related to core functionality over documentation/structure
   - Prefer criteria that touch multiple files or modules
   - If security is in candidate_domains, include at least one security-related AC

3. For each selected criterion:
   a. Parse the AC to understand the required behavior (what should happen, under what conditions, with what result)
   b. Search the codebase for the implementing code
   c. Read the implementation and trace the logic
   d. Assess whether the code actually produces the behavior described in the AC:
      - Does the happy path work?
      - Are edge cases from the AC handled?
      - Is the behavior testable as described?

4. Flag misalignment:
   - File/function exists with the right name but doesn't implement the behavior
   - Implementation handles a simplified version of the AC
   - Key conditions from the AC are missing in the code
   - The AC requires integration between components but the integration is missing

### Evidence Format

```
PLAN-TO-CODE SPOT-CHECK:
AC: "[acceptance criterion text]"
Source: story.md, criterion [N]
Implementing code: [file:line]
Behavior analysis:
  Required: [what the AC says should happen]
  Implemented: [what the code actually does]
  Assessment: [ALIGNED / MISALIGNED: specific gap]
```

---

## Check 4: Terminology Consistency

**Goal:** Detect naming drift between plan and implementation.

### Procedure

1. Build a term registry from authoritative sources:
   - Contract files in `plan/contracts/` (field names, type names, state names)
   - System architecture doc (`plan/system-architecture.md`) — component names, state names
   - Story.md — domain terms used in acceptance criteria

2. Search the implementation code for these terms:
   - Type/interface names
   - Variable and function names
   - State values (string literals, enum values)
   - Error messages and status strings

3. Flag drift patterns:
   - Same concept, different name (e.g., `offline` vs `offline_blocked`)
   - Same field, different casing convention (e.g., `api_key` vs `apiKey` vs `has_api_key`)
   - Abbreviations not in the plan (e.g., `inv` for `inventory`)
   - Plan uses one term, code uses a synonym (e.g., `stale_status` vs `stale_state`)

### Evidence Format

```
TERMINOLOGY CONSISTENCY CHECK:
| Plan Term | Source | Code Term | File:Line | Severity |
|-----------|--------|-----------|-----------|----------|
| offline   | CON-001| offline_blocked | src/shared/types/runtime-state.ts:15 | Medium |
```

---

## Check 5: Cross-Report Coherence

**Goal:** Verify all local agents were working on the same scope.

### Procedure

1. Extract file lists from each agent:
   - Implementer: files created/modified (from completion summary)
   - Code Reviewer: files reviewed (from review scope)
   - QA Verifier: files verified (from verification targets)
   - Staging document: file references section

2. Compare:
   - Files the implementer claims to have created should exist on disk
   - Files the reviewer reviewed should match the implementer's file list
   - Files QA verified should cover the reviewer's scope
   - Staging document file references should match all of the above

3. Flag mismatches:
   - Files in implementer summary but not reviewed
   - Files reviewed but not in staging document
   - Files in staging document that don't exist on disk
   - QA verified different files than what was reviewed

### Evidence Format

```
CROSS-REPORT COHERENCE CHECK:
Files by agent:
  Implementer: [list]
  Reviewer: [list]
  QA: [list]
  Staging doc: [list]
Disk check: [all exist / missing: list]
Scope alignment: [COHERENT / MISMATCH: detail]
```
