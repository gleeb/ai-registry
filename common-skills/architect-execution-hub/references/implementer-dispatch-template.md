# Implementer Dispatch Template

Use this template when dispatching `sdlc-implementer` via the Task tool.

**Architect**: Before sending this dispatch, log it via `checkpoint.sh dispatch-log --event dispatch`. After the implementer returns, log the response via `checkpoint.sh dispatch-log --event response`.

## Required Message Structure

```
TASK: [Task ID] — [Task Name]

SPECIFICATION:
- [Function signatures and parameters]
- [Interface definitions]
- [File paths for each change]
- [Dependencies on prior tasks]

ACCEPTANCE CRITERIA:
- [Testable condition 1]
- [Testable condition 2]

TECH SKILLS:
- [skill-name] (path: skills/[skill-name]/)
  Load and apply patterns from this skill during implementation.
[Include all tech skills identified in Phase 0. Omit section if no tech skills apply.]

REQUIRED CONTEXT (read before writing any code):
1. Project documentation: Read docs/index.md and the relevant domain docs
   (e.g., docs/frontend/, docs/backend/) for project structure and conventions.
   If docs/index.md does not exist, skip to step 2.
2. Staging document: Read [exact path to docs/staging/US-NNN-*.md].
   Then follow the "Plan References" section to read the story's plan artifacts:
   - story.md — requirements and acceptance criteria
   - hld.md — architecture and design decisions
   - Any domain artifacts relevant to this task (api.md, data.md, security.md, design/)
3. Prior task context: Review the staging doc's "Implementation Progress" and
   "Technical Decisions" sections for decisions from earlier tasks that affect
   this task.
[Any additional context from prior tasks]

DOCUMENTATION (update throughout implementation):
- Update the staging document with progress after each significant change.
- Document all technical decisions with rationale in the staging doc's
  "Technical Decisions & Rationale" section.
- Record all created/modified files in the staging doc's
  "Implementation File References" section.
- Document any issues encountered and their resolutions in the
  "Issues & Resolutions" table.

BOUNDARIES:
- IN SCOPE: [what to implement]
- OUT OF SCOPE: [what NOT to implement]
- Do not expand scope beyond this task specification.

SELF-VERIFICATION:
Before returning your final summary to the parent agent:
1. Load the verification-before-completion skill (skills/verification-before-completion/).
2. For each acceptance criterion above, identify a verification command and run it fresh.
3. If any criterion fails verification, fix it before claiming completion.
4. Include verification evidence (commands + outputs) in the completion summary.

COMPLETION CONTRACT:
Return your final summary to the parent agent with:
1. Code-change summary: files created/modified with brief description.
2. Verification evidence: per-criterion command + output + PASS/FAIL.
3. Staging doc updates: list each section updated and what was added/changed.
   Example: "Technical Decisions: added rationale for X. Implementation File
   References: added src/foo.ts, src/bar.ts. Issues & Resolutions: added row
   for dependency conflict."
4. Any blockers encountered.

PRECEDENCE: These task-specific instructions supersede conflicting general instructions.
```

## Re-dispatch (after review feedback)

When re-dispatching after code review rejection, add:

```
REVIEW FEEDBACK (iteration [N]/5):
The following issues were identified by code review. Fix ONLY these issues:

[Paste reviewer's exact issue list with file:line references and recommended fixes]

Do not make changes beyond the listed issues.
Update the staging document with the review feedback and fixes applied.
```

## Re-dispatch (after semantic review guidance)

When re-dispatching after semantic review NEEDS WORK, add the guidance package:

```
SEMANTIC GUIDANCE (from commercial semantic review):

REASONED CORRECTIONS:
[Paste the corrections section from the semantic reviewer's guidance package.
Each correction includes what's wrong, what the better result looks like, and
the reasoning chain explaining why.]

DOCUMENTATION:
[Paste any fetched documentation excerpts from the guidance package.]
[Paste any documentation fetch instructions — if included, use context7 MCP
to retrieve the specified docs before implementing fixes. Search for the
exact terms, library, and sections specified.]

IMPROVEMENT INSTRUCTIONS:
[Paste the consolidated improvement instructions from the guidance package.
These are specific, actionable steps to follow.]

Apply the corrections and follow the improvement instructions. If documentation
fetch instructions are included, retrieve the docs via context7 first — they
contain the framework/library context needed to implement the fixes correctly.
Update the staging document with fixes applied.
```
