# Semantic Review Checklist

Detailed procedures for the 3 validation checks. Each check defaults to NEEDS WORK — prove PASS with cited evidence. All checks do a full sweep — no sampling.

---

## Check 1: Agent Report Integrity

**Goal:** Detect contradictions in local model self-reports AND verify all agents worked on the same scope.

This check has two sub-sections: internal consistency (are individual reports self-consistent?) and cross-agent coherence (do all agents agree on what was done?).

### Sub-section A: Internal Consistency

1. Collect all final summaries returned to the parent agent from:
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

4. Cross-reference within reports:
   - If code reviewer flagged issues in specific files, QA should have verified those files
   - If QA found regressions, code reviewer should have flagged related patterns

### Sub-section B: Cross-Agent Coherence

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
AGENT REPORT INTEGRITY CHECK:

Internal Consistency:
- [Task N] Code Review: Spec Compliance=[PASS/FAIL], Assessment=[Approved/Changes Required]
  Issues: [count by severity]
  Consistency: [OK / CONTRADICTION: detail]
- [Task N] QA: Status=[PASS/FAIL], Per-criterion: [N/N pass]
  Consistency: [OK / CONTRADICTION: detail]
- Cross-reference: [OK / MISMATCH: detail]

Cross-Agent Coherence:
Files by agent:
  Implementer: [list]
  Reviewer: [list]
  QA: [list]
  Staging doc: [list]
Disk check: [all exist / missing: list]
Scope alignment: [COHERENT / MISMATCH: detail]
```

See [`verdict-consistency-rules.md`](verdict-consistency-rules.md) for the full enumeration of contradiction and coherence patterns.

---

## Check 2: Code Quality Review

**Goal:** Review the story's implementation as a senior developer — assess code quality, verify semantic correctness against acceptance criteria, and confirm the work holds up.

This is not a surface-level diff scan. The reviewer drills into the actual implementation, traces logic paths, and reasons about behavior.

### Procedure

**Step 1: Scope via git diff**

Run `git diff` (or use the GIT CONTEXT from the dispatch) to identify all files changed during the story's execution cycle. This is the scoping step — it tells you where to look.

**Step 2: Gather context from staging document**

Read the staging document for:
- Task decomposition (what was planned for each implementation unit)
- Architecture decisions and rationale
- Planned file references (what files should have been created/modified)
- Acceptance criteria mapping

**Step 3: Drill into each changed file**

For each file identified in the git diff:
1. Read the full file (not just the diff hunks — understand the complete context).
2. Assess code quality:
   - Follows project conventions and patterns
   - Appropriate abstraction level
   - Error handling is adequate
   - No security anti-patterns (if applicable)
   - Architecture alignment with the approved plan
3. Compare against the staging doc's task specification for this file.

**Step 4: Verify semantic correctness against ALL acceptance criteria**

For EACH acceptance criterion from story.md:
1. Parse the AC to understand the required behavior (what should happen, under what conditions, with what result).
2. Trace through the implementing code to verify the logic actually produces the described behavior.
3. Assess:
   - Does the happy path work?
   - Are edge cases from the AC handled?
   - Is the behavior testable as described?
4. Flag misalignment:
   - File/function exists with the right name but doesn't implement the behavior
   - Implementation handles a simplified version of the AC
   - Key conditions from the AC are missing in the code
   - The AC requires integration between components but the integration is missing

**Step 5: Re-run ALL verification commands**

Collect ALL verification commands from agent reports (implementer self-verification, QA commands, reviewer commands). Re-run each one fresh:
1. Record the claimed result from the agent's report.
2. Execute the same command from the project root.
3. Capture output and exit code.
4. Compare — flag significant discrepancies (different exit codes, different test counts, missing files).

See [`evidence-verification-protocol.md`](evidence-verification-protocol.md) for the full verification procedure, discrepancy analysis, and environmental considerations.

### Evidence Format

```
CODE QUALITY REVIEW:

Changed files reviewed: [N files from git diff]
Staging doc context: [task decomposition summary]

Per-file quality:
- [file:path]: [quality assessment — patterns, conventions, architecture alignment]

Per-AC semantic verification:
- AC[N]: "[criterion text]"
  Implementing code: [file:line]
  Behavior analysis: [ALIGNED / MISALIGNED: specific gap]

Verification commands re-run: [N commands]
- [command]: claimed=[exit code], actual=[exit code], [VERIFIED / UNRELIABLE: detail]

Overall: [PASS / NEEDS WORK: summary of findings]
```

---

## Check 3: Terminology and Contract Alignment

**Goal:** Detect naming drift between plan and implementation across ALL domain terms.

### Procedure

1. Build a term registry from authoritative sources:
   - Contract files in `plan/contracts/` (field names, type names, state names)
   - System architecture doc (`plan/system-architecture.md`) — component names, state names
   - Story.md — domain terms used in acceptance criteria

2. Identify changed files from git diff (scoping).

3. Search ALL changed files for these terms:
   - Type/interface names
   - Variable and function names
   - State values (string literals, enum values)
   - Error messages and status strings

4. Flag drift patterns:
   - Same concept, different name (e.g., `offline` vs `offline_blocked`)
   - Same field, different casing convention (e.g., `api_key` vs `apiKey` vs `has_api_key`)
   - Abbreviations not in the plan (e.g., `inv` for `inventory`)
   - Plan uses one term, code uses a synonym (e.g., `stale_status` vs `stale_state`)

### Evidence Format

```
TERMINOLOGY AND CONTRACT ALIGNMENT CHECK:
| Plan Term | Source | Code Term | File:Line | Severity |
|-----------|--------|-----------|-----------|----------|
| offline   | CON-001| offline_blocked | src/shared/types/runtime-state.ts:15 | Medium |
```
