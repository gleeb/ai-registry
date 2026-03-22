# Work Verification Protocol

How to independently verify that the local model's work holds up — the same way a senior developer would review a junior's deliverables before approving them.

---

## Philosophy

This is not about catching deception. Local models don't lie on purpose — they confabulate. They pattern-match on what "successful output looks like" and produce plausible-sounding results that may not reflect reality. A model might report "all tests pass" not out of malice, but because that's the most likely completion of "I ran the tests and..."

Your job is the same as a senior reviewing a junior's work: **verify the work actually holds up** by independently checking it yourself.

---

## Command Selection

Select 2-3 commands to re-verify. Priority order:

1. **Test suite runs** (`npm run test`, `jest`, `pytest`, etc.) — highest signal; test counts and pass/fail are concrete
2. **Build commands** (`npm run build`, `expo export`, `tsc --noEmit`) — binary pass/fail with specific error output
3. **Lint/typecheck** (`npm run lint`, `npm run typecheck`) — useful but lower signal (may pass trivially)
4. **Custom verification commands** — any command the QA verifier or implementer used for criterion verification

Avoid selecting:
- Commands that just check file existence (too easy to get right without doing meaningful work)
- Commands that produce non-deterministic output (timestamps, random IDs)
- Commands that require external services not available in the review environment

## Verification Procedure

For each selected command:

1. **Record the claimed result:**
   - Extract the exact command from the agent's report
   - Note the claimed exit code
   - Note key output metrics (test count, error count, file list)

2. **Run fresh:**
   - Execute the exact same command from the project root
   - Capture full stdout and stderr
   - Record the exit code

3. **Compare:**
   - Exit code: must match (0 vs 0, or both non-zero)
   - Test counts: total tests, passed, failed, skipped must match within reasonable margin
   - Error messages: any errors present in fresh run should have been reported
   - File references: files mentioned in output should exist

## What Discrepancies Tell You

### The work is unreliable (significant discrepancies)

These mean the local model's self-reported results don't match reality. The work needs to be redone with proper guidance:

- Claimed exit code 0, actual exit code non-zero (or vice versa)
- Claimed N tests pass, actual shows fewer tests exist
- Claimed output references files that don't exist on disk
- Claimed output format doesn't match the tool's actual output format
- Claimed to run a test file that doesn't exist

This is similar to a junior dev who says "I ran all the tests" but the tests don't compile, or there are fewer tests than claimed. It's not malice — it's incomplete work or oversight. But the work can't be trusted and needs redo with specific guidance on what went wrong.

### Minor variances (acceptable)

- Minor differences in test timing
- Different ordering of parallel test results
- Different absolute paths in output
- Warnings present in one but not the other
- Dependency resolution messages differ

### Expected differences (ignore)

- Timestamps differ
- Process IDs differ
- Cache-related messages differ
- Color/formatting differences

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
