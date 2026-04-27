# Code Reviewer Dispatch Template

Use this template when dispatching `sdlc-code-reviewer` via the Task tool.

**Architect**: Before sending this dispatch, log it via `checkpoint.sh dispatch-log --event dispatch`. After the reviewer returns, log the response via `checkpoint.sh dispatch-log --event response`.

## Required Message Structure

```
REVIEW TASK: [Task ID] — [Task Name]

TASK CONTEXT DOCUMENT: [exact path to docs/staging/US-NNN-name.task-N.context.md]
Read this document for the complete task context:
- Acceptance criteria and design specification (verbatim from plan artifacts)
- API contract and security controls (if applicable)
- Current source file contents (hub-updated before this dispatch)
- Library documentation cache and prior review feedback (if re-dispatch)
Do NOT read story.md, hld.md, api.md, or security.md directly — the context doc
has the relevant sections extracted verbatim.

STAGING DOCUMENT: [exact path to docs/staging/US-NNN-*.md]
Read for execution-time decisions (Technical Decisions section) and file
references only. Do NOT follow plan references from the staging doc.

IMPLEMENTER SUMMARY:
[Paste the implementer's final summary returned to the parent agent — files changed, what was done]

TECH SKILLS:
- [skill-name] (path: skills/[skill-name]/)
  Verify implementation follows this skill's patterns and performance budgets.
[Include all tech skills from the implementer dispatch. Omit section if none.]

SECURITY REVIEW: [true/false]
If true, load skills/security-review/ and include a "## Security Review"
section in the review output with findings categorized by severity.

REVIEW SCOPE:
1. Spec compliance: Does implementation match the design specification and acceptance criteria
   from the context document?
2. AC traceability: Does each entry in the context doc's `## AC Traceability`
   (`acs_satisfied`) section actually trace to evidence in the diff? Verify the per-AC
   binding contract — see the AC TRACEABILITY CHECK directive below for the procedure
   and severity mapping.
3. Code quality: Patterns, error handling, naming, tests.
4. Architecture: Integration, separation of concerns.
5. Security (if SECURITY REVIEW is true): OWASP, secrets, input validation, auth.

AC TRACEABILITY CHECK (required when the context doc has a non-empty
`acs_satisfied` block):

For each entry in the context doc's `## AC Traceability` section:
1. Read the AC's statement text from `plan/user-stories/<story>/story.md` (use the
   `ac_id` to locate the line). The context doc references it but does NOT
   duplicate the text.
2. Check that the listed `evidence_path` files exist and were created/modified in
   the diff (cross-reference the IMPLEMENTER SUMMARY's CHANGES APPLIED block).
3. Check that the implementation file(s) in `evidence_path` contain logic
   relevant to the AC's statement — not unrelated code that happens to live in
   the same file.
4. Check that the test file(s) in `evidence_path` exercise the AC's observable
   behavior. Apply the falsification test: "would this test fail if the AC were
   violated, or would it only fail if the implementation's internal shape
   changed?" Behavioral tests are evidence; shape tests are not.
5. If the entry has `evidence_class: real`, verify against the QA TEST-MODE
   ACCOUNTING block (post-QA reviews) or the test files' `test-mode:` headers
   (pre-QA reviews — confirm at least one `test-mode: real` test covers the
   AC's evidence_path).
6. If the entry has `evidence_class: stub-only` or `static-analysis-only`,
   verify the rationale matches what the diff actually shows (e.g., `stub-only`
   is consistent with no `test-mode: real` test in evidence_path; flag if a
   `real` test is present but the binding still claims `stub-only`).
7. If `acs_satisfied: []` (refactor-only), check that the diff is in fact
   refactor-only — no behavioral change, no new AC-relevant logic. If the diff
   adds AC-relevant behavior, flag as a binding-evasion finding.

Severity mapping for AC traceability findings:
- **Critical** — `evidence_path` references a file that does not exist in the
  diff; OR the file exists but contains no logic relevant to the AC's
  statement; OR an `evidence_class: real` claim has no corresponding `real`
  test or QA accounting (misrepresentation).
- **Important** — test in `evidence_path` exists but tests implementation
  shape, not the AC's observable behavior (would not fail if the AC were
  violated); OR `evidence_class: static-analysis-only` flagged because no
  test ran real traffic; OR a non-empty diff bound as `acs_satisfied: []`
  adds AC-relevant behavior.
- **Suggestion** — narrative mismatch (the rationale describes one mechanism
  but the implementation uses another, and the AC is still satisfied); OR a
  test name in the optional `tests:` list does not match an actual describe/it
  identifier in the file.

Do NOT promote an Important AC traceability finding to Critical across
iterations under the severity-escalation guard, unless new evidence (a new
test, a new spec clarification) emerges between iterations.

Note: Source files are provided in the context document. Run `npm run verify:quick` (JS/TS) or `bash scripts/verify.sh quick` (Python) on disk for ground-truth automated check results. The script is silent on success — `=== ALL GATES PASSED ===` is sufficient evidence.

DOCUMENTATION CHECK (scoped to this task only):
- Verify the staging document exists and is current.
- Check that new/modified files from the IMPLEMENTER SUMMARY above are listed in the
  staging doc's "Implementation File References" section.
- Check that technical decisions for THIS task have rationale documented.
- Flag stale or missing documentation references as Important issues.
- Do NOT flag files listed under other tasks or planned for future implementation.
  Only verify files the implementer claims to have created or modified in this task.

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Spec Compliance: PASS or FAIL (does implementation match design specification?).
2. AC Traceability: one row per entry in the context doc's `acs_satisfied`
   block, with verdict (PASS / FAIL) per the AC TRACEABILITY CHECK procedure
   above. For empty bindings (`acs_satisfied: []`), one
   `refactor-only — confirmed` row or a binding-evasion finding.

   ```
   AC Traceability:
   - AC-2 → PASS (evidence: src/db/persistence.ts + tests/integration/persistence-restart.test.ts; evidence_class real verified against test-mode header)
   - AC-3 → FAIL Critical: evidence_path lists tests/unit/payload-validator.test.ts but file does not exist in diff
   ```
3. Issues: categorized as Critical / Important / Suggestion with file:line references.
   Include AC-traceability findings here at the severity from the mapping above.
4. Security Review (if applicable): findings by severity.
5. Documentation Status: current / stale / missing references.
6. Overall Assessment: Approved or Changes Required (final verdict — this is what the
   architect acts on. NEVER use PASS/FAIL here. Must be consistent with issues found:
   any Critical or Important issues → Changes Required; only Suggestions → Approved).

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Final Story Review Variant

For the final full-story review after all tasks complete (Phase 3), modify:

```
REVIEW SCOPE: Full story — holistic review of all implemented tasks.
Focus on cross-task integration, overall architecture adherence, and consistency.

SECURITY REVIEW: [true — if any individual task had security review enabled]

TASK SUMMARIES:
[Combined summaries from all implementation units]
```
