# Code Quality Review Protocol

How to review a story's implementation as a senior developer — using git diff for scoping, the staging document for context, then drilling into the actual code for the real review.

---

## Philosophy

This is not about catching deception. Local models don't lie on purpose — they confabulate. They pattern-match on what "successful output looks like" and produce plausible-sounding results that may not reflect reality.

Your job is the same as a senior reviewing a junior's work: **drill into the implementation, understand it, and verify it holds up.**

---

## Layered Review Procedure

### Layer 1: Scope via Git Diff

Git diff is a scoping tool — it tells you which files changed during the story's execution cycle.

1. Run `git diff` using the branch/commit info from the GIT CONTEXT in the dispatch (e.g., `git diff <base>..HEAD -- <paths>`).
2. If GIT CONTEXT is not available, use `git log` to identify commits associated with this story, then diff those.
3. Produce a list of changed files. This is your review scope.

### Layer 2: Context from Staging Document

The staging document provides the planned context:

1. Read the task decomposition — what was each implementation unit supposed to produce?
2. Read the architecture decisions — what patterns and structures were chosen and why?
3. Read the file references — what files were planned to be created/modified?
4. Read the acceptance criteria mapping — which tasks map to which ACs?

Cross-reference the staging doc's planned file list with the git diff's actual changed files. Flag discrepancies (files planned but not changed, files changed but not planned).

### Layer 3: Drill Into the Implementation

For each changed file, read and reason about the actual code:

1. **Read the full file** — not just the diff hunks. Understand the complete context: imports, module structure, how this file fits into the project.
2. **Assess code quality:**
   - Follows project conventions and established patterns
   - Appropriate abstraction level (not over-engineered, not under-abstracted)
   - Error handling covers failure cases
   - No security anti-patterns (hardcoded secrets, unsanitized input, etc.)
   - Architecture aligns with the approved plan from the staging doc
3. **Trace logic paths** — follow the code from entry points through to results. Does the logic do what the AC describes?
4. **Compare against task specification** — does this file implement what the staging doc said it should?

### Layer 4: Verification Command Execution

Re-run ALL verification commands from agent reports to confirm the work holds up:

1. Collect every verification command from:
   - Implementer self-verification (from completion summaries)
   - QA verification commands (from QA reports)
   - Reviewer-suggested commands (if any)
2. For each command, record the claimed result from the agent's report.
3. Execute the command fresh from the project root.
4. Capture full output and exit code.
5. Compare claimed vs. actual.

---

## Verification Command Analysis

### Priority order for verification commands

1. **Test suite runs** (`npm run test`, `jest`, `pytest`, etc.) — highest signal; test counts and pass/fail are concrete
2. **Build commands** (`npm run build`, `expo export`, `tsc --noEmit`) — binary pass/fail with specific error output
3. **Lint/typecheck** (`npm run lint`, `npm run typecheck`) — useful but lower signal (may pass trivially)
4. **Custom verification commands** — any command the QA verifier or implementer used for criterion verification

### What Discrepancies Tell You

**The work is unreliable (significant discrepancies):**

These mean the local model's self-reported results don't match reality:

- Claimed exit code 0, actual exit code non-zero (or vice versa)
- Claimed N tests pass, actual shows fewer tests exist
- Claimed output references files that don't exist on disk
- Claimed output format doesn't match the tool's actual output format
- Claimed to run a test file that doesn't exist

This is similar to a junior dev who says "I ran all the tests" but the tests don't compile. It's not malice — it's incomplete work or oversight. But the work can't be trusted and needs redo with specific guidance on what went wrong.

**Minor variances (acceptable):**

- Minor differences in test timing
- Different ordering of parallel test results
- Different absolute paths in output
- Warnings present in one but not the other
- Dependency resolution messages differ

**Expected differences (ignore):**

- Timestamps differ
- Process IDs differ
- Cache-related messages differ
- Color/formatting differences

---

## Reporting

### On significant discrepancies:

1. Document the exact discrepancy with side-by-side comparison
2. Determine whether this is an isolated oversight or a pattern of unreliable work
3. Include the actual command output as evidence
4. Provide guidance: what commands should have been run, what the correct output looks like, and what the local model should do differently

### On severe unreliability (escalation):

If the discrepancies indicate the work product is fundamentally unreliable — e.g., the implementation doesn't build, tests that were claimed to pass don't exist, or multiple verification claims are contradicted — set the escalation flag. This isn't punitive; it means the local model may not be capable of this task and it needs to be reassigned to a more capable model.

## Environmental Considerations

Before concluding the work is unreliable, consider:
- Has the codebase changed since the agent ran? (git status, recent modifications)
- Are there missing dependencies? (node_modules deleted, virtual env not activated)
- Is the test database in a different state?
- Were environment variables different?

If environmental factors explain the discrepancy, note it as an observation rather than a work quality issue.
