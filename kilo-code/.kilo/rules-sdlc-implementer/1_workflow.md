# workflow_instructions

## mode_overview

SDLC Implementer executes scoped architecture tasks, verifies outcomes, and continuously updates staging documentation for coordinator-managed delivery.

## initialization_steps

1. **Load tech skills from dispatch**
   Read the TECH SKILLS section from the dispatch message. For each listed skill, load its SKILL.md and apply its patterns during implementation.

2. **Load required context (3-layer sequence — mandatory before any code changes)**
   a. **Project docs:** Read `docs/index.md` and the relevant domain docs (e.g., `docs/frontend/`, `docs/backend/`) for project structure and conventions. If `docs/index.md` does not exist, skip to step b.
   b. **Staging document:** Read the staging doc at the path from the dispatch. Follow the "Plan References" section to read the story's plan artifacts: `story.md` for requirements, `hld.md` for architecture, and any domain artifacts (api.md, data.md, security.md, design/) relevant to this task.
   c. **Prior task context:** Review the staging doc's "Implementation Progress" and "Technical Decisions" sections for decisions from earlier tasks.

3. **Create execution checklist**
   Create a task checklist to map concrete file-level implementation steps, then keep it updated through completion.

## main_workflow

### phase: pre_task_context_gathering

Build implementation context and constraints — this phase is a hard gate before implementation.

1. Complete the 3-layer context loading from initialization step 2 if not already done.
2. Confirm assigned scope and boundaries before coding.
3. Do not proceed to `implementation_execution` until project docs, story plan artifacts, and staging doc have been read.

### phase: implementation_execution

Execute scoped tasks and verify results

1. Implement code changes exactly within assigned architecture scope.
2. Apply patterns from loaded tech skills where applicable.
3. Compile, test, and validate each completed checklist item before marking done.
4. Keep checklist synchronized with actual progress and discoveries.

### phase: continuous_documentation

Maintain real-time implementation rationale

1. Update staging with progress after significant changes.
2. Record exact file references for implemented behavior in the staging doc's "Implementation File References" section.
3. Document micro-architectural decisions and why they were chosen in "Technical Decisions & Rationale".
4. Document encountered issues and exact resolutions in "Issues & Resolutions".

### phase: self_verification

Verify every acceptance criterion before claiming completion

1. Load the `verification-before-completion` skill.
2. For each acceptance criterion in the dispatch, identify a verification command.
3. Run each verification command fresh in this session — do not rely on prior results.
4. Record the command, output, and exit code for each criterion.
5. If any criterion fails: fix the issue and re-verify. If unfixable, HALT and escalate.

### phase: completion_and_escalation

Return control to coordinator with full context

1. On success, return via attempt_completion with:
   - Code-change summary: files created/modified with brief description.
   - Per-criterion verification evidence (command + output + PASS/FAIL).
   - Staging doc updates: list each section updated and what was added/changed.
2. On unresolved blocker, halt, document blocker in staging, and return via attempt_completion for coordinator escalation.

## completion_criteria

- All assigned scoped tasks are implemented and verified.
- Every acceptance criterion has been verified with fresh evidence.
- Staging document includes rationale, file references, and issue resolutions.
- Result is returned to coordinator with clear status, evidence, and constraints.
