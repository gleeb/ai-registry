# Execution Deep Dive

The Execution Hub (Architect) manages the full implementation lifecycle for a single user story. It converts the story's execution package (HLD, API, Data, Security, Design artifacts) into working, verified, documented code.

## Phase 0: Readiness Check

Before any implementation begins, the Execution Hub verifies prerequisites:

1. **Plan artifacts exist** — Checks that all artifacts required by the story's `candidate_domains` are present in the story folder (hld.md, api.md, data.md, security.md, design/).
2. **Dependencies complete** — Verifies that all stories listed in `depends_on_stories` have been implemented.
3. **Tech skills mapped** — Maps the story manifest's `tech_stack` field to available skills (e.g., `react-native` → `common-skills/react-native/`). These skills are loaded by the Implementer and verified by the Code Reviewer.

**Gate**: All prerequisites must be met. If any fail, the Hub halts and escalates — it does not proceed with partial readiness.

### Phase 0b: Scaffolding Check

If the project is greenfield (no package manager config, no source directories):
1. Scaffolding becomes Task 0 in the staging document.
2. The Implementer is dispatched with the `scaffold-project` skill.
3. Standard review + QA cycle runs on scaffold output.
4. Execution continues with the scaffolded codebase.

## Phase 1: Task Decomposition + Staging Document

The Execution Hub (acting as the Architect) does the intellectual work of breaking the story into implementation units:

1. **Reads documentation hierarchy** — Identifies existing patterns, conventions, and prior decisions.
2. **Creates the staging document** — A Markdown file at `docs/staging/US-NNN-*.md` that becomes the single source of truth for this story's implementation. Scaffolded from plan artifacts using the `project-documentation` skill template.
3. **Pre-populates sections** — Plan references, acceptance criteria (copied from story.md), and tech stack.
4. **Decomposes into implementation units** — Each unit specifies:
   - Function signatures and parameters
   - Interface definitions
   - File paths for each change
   - Dependency order
   - Acceptance criteria it addresses
5. **Creates a sequenced task checklist** in the staging document.

The staging document is the resume anchor — if the agent crashes, the staging doc shows exactly which tasks are done and which remain.

## Phase 2: Per-Task Dev Loop

For each implementation unit in sequence, a three-step cycle runs:

### Step 1: Implement

The Implementer (`sdlc-implementer`) is dispatched with:
- Task specification (function signatures, file paths, boundaries)
- Tech skills to load
- Staging document path
- Explicit scope boundaries

The Implementer:
- Creates an execution checklist mapping concrete file-level steps
- Implements code changes within assigned scope
- Self-verifies every acceptance criterion with fresh evidence (actual command output)
- Updates the staging document with progress, file references, and decisions

### Step 2: Code Review

On implementer success, the Code Reviewer (`sdlc-code-reviewer`) is dispatched. It is **read-only** and:
- Reads the staging document to understand the architecture plan
- Reads every changed file
- Checks plan alignment (spec compliance)
- Assesses code quality, security, patterns
- Returns a structured verdict: **Approved** or **Changes Required**

Verdict rules:
- Any Critical issue → Changes Required
- Any Important issue → Changes Required
- Only Suggestions → Approved

If Changes Required: the Implementer is re-dispatched with review feedback.

### Step 3: QA Verification

On review pass, the QA Verifier (`sdlc-qa`) is dispatched. It is **read-only** and:
- Maps each acceptance criterion to a verification command
- Runs every command fresh — trusts no prior results
- Records exact command, output, and exit code
- Returns **PASS** (all criteria verified) or **FAIL** (any criterion unverified)

Iron law: If the QA agent has not run the command in this session, it cannot claim it passes.

### Iteration Limits

| Step | Max Iterations | On Limit Exceeded |
|---|---|---|
| Code Review rejections | 3 per task | Task marked blocked, escalated to user |
| QA failures | 2 per task | Task marked blocked, escalated to user |

After a task passes QA, its status is updated in the staging document and the next task begins.

## Phase 3: Story-Level Integration

After all per-task loops pass:

1. The Code Reviewer is dispatched for a **full-story holistic review** — checking cross-task consistency, integration points, and overall quality.
2. If approved, the QA Verifier runs a **full-story verification** — running the complete test suite and checking all acceptance criteria together.
3. If the reviewer requests changes, the Hub identifies affected tasks and re-dispatches the Implementer for targeted fixes.

**Gate**: Full-story review + QA must both pass.

## Phase 4: Acceptance Validation

The Acceptance Validator (`sdlc-acceptance-validator`) runs an independent, criterion-by-criterion verification:

1. Extracts ALL acceptance criteria from story.md.
2. Maps each criterion to implementation evidence (file:line references).
3. Runs fresh verification for every criterion.
4. Checks documentation completeness.
5. Generates a validation report with per-criterion evidence.

Every criterion starts as INCOMPLETE — evidence must explicitly prove a pass. The validator does not accept "close enough" or simplified versions.

Verdicts: PASS, FAIL, or UNABLE TO VERIFY (not a pass).

If INCOMPLETE: the Hub identifies failing criteria, creates targeted fix tasks, and re-enters Phase 2. Max 2 re-validations before escalation.

## Phase 5: Documentation Integration

1. The staging document's content is distributed into permanent documentation under `docs/`.
2. `docs/index.md` is updated if new domains were added.
3. All file references in the documentation are verified to point to real files.
4. The staging document is archived or marked as completed.

## Phase 6: User Acceptance

1. The Hub presents to the user:
   - Implementation summary
   - Acceptance validation report with per-criterion evidence
   - Any deviations from the plan
2. User response options:
   - **Approve** → Story marked complete. Hub returns to Coordinator with completion summary. Coordinator dispatches the next story.
   - **Request changes** → Targeted tasks are created and Phase 2 re-enters.
   - **Reject** → Escalated with rejection details.

## Anti-Fabrication Rules

The Implementer operates under strict DENY rules to prevent false completion claims:

| Rule | What It Prevents |
|---|---|
| No claims without file references | Claiming implementation without showing specific code |
| No skipped criteria | Every acceptance criterion must be addressed |
| No placeholders | TODO comments, stub functions, empty implementations |
| No criteria changes | Changing acceptance criteria to match what was built |
| No simplified versions | "Simplified" implementations without explicit approval |
| No deferred work | Deferring in-scope work to future iterations |
| Must map ACs to code | Every acceptance criterion must trace to specific files and lines |
| Must run actual verification | "Tests pass" without command output is not verification |
| Must halt on blockers | If a criterion cannot be implemented, halt and escalate |

## Tech Skill Loading

The story manifest's `tech_stack` field drives skill loading during execution:

```yaml
tech_stack: [react-native, typescript, expo]
```

Maps to skills in `common-skills/`:
- `react-native` → `common-skills/react-native/`
- Additional skills as available

The Implementer loads each skill's SKILL.md for patterns and conventions. The Code Reviewer verifies skill patterns were followed.

## Security Review Integration

The Code Reviewer loads `common-skills/security-review/` when the dispatch includes `SECURITY_REVIEW: true`. This adds OWASP-aligned security checks to the standard code review — no separate security agent dispatch is needed during execution.

Security review covers: secrets detection, input validation, authentication/authorization, SQL injection, XSS, CSRF, and dependency vulnerabilities.

## Staging Document as Source of Truth

The staging document (`docs/staging/US-NNN-*.md`) is the central tracking artifact for execution:

- Created in Phase 1 from plan artifacts
- Updated by the Implementer after every task (progress, file references, decisions)
- Verified by the Code Reviewer (checked for currency)
- Validated by QA (file references point to real files)
- Checked by the Acceptance Validator (documentation completeness gate)
- Distributed into permanent docs in Phase 5

If the workflow is interrupted, the staging document shows the exact state: which tasks are done, which are in progress, and which remain.

## Checkpoint Integration

The Execution Hub writes checkpoints before and after every dispatch using `checkpoint.sh execution`. Combined with the staging document, this provides two independent resume mechanisms. See [troubleshooting.md](troubleshooting.md) for recovery details.
