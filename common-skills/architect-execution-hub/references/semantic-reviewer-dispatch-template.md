# Semantic Reviewer Dispatch Template

Use this template when dispatching `sdlc-semantic-reviewer` via `new_task` in Phase 3b.

**Architect**: Before sending this dispatch, log it via `checkpoint.sh dispatch-log --event dispatch`. After the semantic reviewer returns, log the response via `checkpoint.sh dispatch-log --event response`.

## Required Message Structure

```
SEMANTIC REVIEW: US-NNN — [Story Title]

STORY: [exact path to plan/user-stories/US-NNN-name/story.md]

STAGING DOCUMENT: [exact path to docs/staging/US-NNN-name.md]
Read the staging document for architecture plan, LLD, task decomposition, and implementation context.

ACCEPTANCE CRITERIA:
1. [Criterion 1 — copied exactly from story.md]
2. [Criterion 2]
3. [Criterion N]

TECH STACK:
- [framework/library 1] (version)
- [framework/library 2] (version)
[From the story's dependency manifest or staging doc tech stack section]

LOCAL REVIEW VERDICTS:
[Paste all code reviewer attempt_completion results for this story — both per-task and full-story]

Task 1 Review:
  Spec Compliance: [PASS/FAIL]
  Issues: [summary]
  Overall: [Approved/Changes Required]

Task N Review:
  ...

Full-Story Review:
  Spec Compliance: [PASS/FAIL]
  Issues: [summary]
  Overall: [Approved/Changes Required]

LOCAL QA VERDICTS:
[Paste all QA verifier attempt_completion results for this story — both per-task and full-story]

Task 1 QA:
  Status: [PASS/FAIL]
  Per-criterion: [summary]

Task N QA:
  ...

Full-Story QA:
  Status: [PASS/FAIL]
  Per-criterion: [summary]

IMPLEMENTER SUMMARIES:
[Paste all implementer attempt_completion results for this story]

Task 1:
  Files: [list]
  Summary: [what was done]
  Verification: [self-verification results]

Task N:
  ...

MCP SERVERS:
context7 is available for documentation retrieval. You may use it to fetch
documentation when you need it to validate your own reasoning or to include
a targeted excerpt in the guidance. Alternatively, you can provide fetch
instructions (search terms, library, section) for the local model to retrieve
the docs itself via context7. Choose whichever approach is most effective.

INSTRUCTIONS:
1. Load the semantic-review skill (common-skills/semantic-review/).
2. Run Phase A: all 5 validation checks.
3. If any check fails: run Phase B to produce a guidance package with reasoned
   corrections, knowledge gaps, documentation guidance (fetched excerpts and/or
   fetch instructions for the local model), and improvement instructions.
4. If all checks pass: produce proactive observations.

COMPLETION CONTRACT:
Return via attempt_completion with:
1. Verdict: PASS / NEEDS WORK.
2. Per-check results (all 5 checks): check name, PASS/NEEDS WORK, evidence summary.
3. Guidance package (on NEEDS WORK): corrections with reasoning, knowledge gaps,
   documentation (fetched excerpts and/or fetch instructions for the local model),
   and consolidated improvement instructions.
4. Proactive observations (on PASS): terminology notes, useful docs, quality notes.
5. Escalation flags (if applicable): work fundamentally unreliable → flag for coordinator + user.

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Second Iteration Variant

When re-dispatching after the implementer addressed the first semantic review's guidance:

```
SEMANTIC REVIEW (iteration 2): US-NNN — [Story Title]

PREVIOUS GUIDANCE:
[Paste the guidance package from the first semantic review]

FOCUS:
1. Verify that the previous guidance was followed.
2. Check whether the identified knowledge gaps are addressed.
3. Run all 5 checks again with attention to previously failing areas.
4. If the same issues persist, recommend escalation to coordinator.

[... rest of template same as above ...]
```
