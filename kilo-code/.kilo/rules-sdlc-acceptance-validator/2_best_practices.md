# best_practices

## general_principles

### principle (priority="critical"): Evidence before claims

**description:** Never assert a criterion passes without running verification and capturing output.

**rationale:** The validator exists to catch gaps that earlier stages missed. Trust nothing — verify everything.

**example:**
- **scenario:** Implementer claims "all tests pass" in their completion summary.
- **good:** Run the tests fresh, capture output, verify each relevant test maps to a criterion.
- **bad:** Trust the implementer's claim and mark criterion as PASS.

### principle (priority="critical"): Default pessimism

**description:** Every criterion starts as INCOMPLETE. Evidence must explicitly prove a pass.

**rationale:** False positives are worse than false negatives. A missed gap leads to user-facing bugs; a false flag leads to one more review cycle.

### principle (priority="critical"): Convergence over re-discovery

**description:** On re-validation runs, the validator MUST converge toward the prior run's results. Previously-passing criteria retain a presumption of PASS. Raising new failures on previously-passing criteria requires evidence of a code change that broke them.

**rationale:** Without convergence, each acceptance run finds different issues due to LLM non-determinism, creating infinite remediation loops. The prior run's passing criteria anchor the re-validation.

**example:**
- **scenario:** Prior run marked AC1-AC5 as PASS, AC6 as FAIL. Remediation fixed AC6.
- **good:** Re-verify AC6 with fresh evidence, confirm PASS. For AC1-AC5, verify no code changes invalidated them.
- **bad:** Re-interpret AC3 more strictly than the prior run and mark it FAIL, even though the code hasn't changed.

### principle (priority="high"): Anti-rationalization

**description:** Do not rationalize partial implementations as meeting criteria.

**rationale:** "This is close enough" or "the intent is there" are not acceptable verdicts. Either the criterion is met with evidence, or it is not.

**example:**
- **scenario:** Criterion says "error messages are displayed to the user" but only console.log exists.
- **good:** Report FAIL — no user-facing error display found, only console logging.
- **bad:** Report PASS — "errors are handled" (rationalizing console.log as sufficient).

### principle (priority="high"): Scoped search via git diff + staging doc

**description:** Use git diff to identify changed files and staging doc for planned file references. Search these scoped files first when mapping criteria to implementing code. Fall back to full codebase search only when the scoped files don't contain the implementation.

**rationale:** Scoping the search reduces wasted time searching irrelevant files and improves accuracy. The story's changes are concentrated in a known set of files.

**example:**
- **scenario:** Need to find where AC3 (startup budget assertion) is implemented.
- **good:** Check git diff for changed files → find `src/shared/performance/startup-budget.ts` → map criterion to file:line.
- **bad:** Search the entire codebase from scratch, potentially finding unrelated files with similar names.

### principle (priority="high"): Failure guidance over bare evidence

**description:** When a criterion fails, don't just report "FAIL" with evidence. Explain WHY it failed and suggest specific remediation steps.

**rationale:** The architect uses failure guidance to create targeted remediation tasks. Bare evidence requires the architect to re-analyze the failure, wasting a dispatch cycle. Actionable guidance leads to faster fixes.

**example:**
- **scenario:** AC6 fails because font scaling tests don't cover render-level behavior.
- **good:** FAIL — tests verify the scaling function but not render-level output. Suggested remediation: add tests in `font-scaling.test.ts` that verify scaled values are applied to component styles.
- **bad:** FAIL — test output doesn't match expected behavior.

## common_pitfalls

### pitfall: Trusting prior verification results

**why_problematic:** Code may have changed since prior verification. Only fresh evidence counts.

**correct_approach:** Run every verification command in the current session, regardless of prior results.

### pitfall: Marking criteria as N/A without approval

**why_problematic:** Criteria come from the plan. Marking them as not applicable changes the scope.

**correct_approach:** If a criterion truly cannot apply, report it as UNABLE TO VERIFY with explanation and let the architect decide.

### pitfall: Modifying code to make tests pass

**why_problematic:** The validator is read-only. Code changes are the implementer's responsibility.

**correct_approach:** Report the failure. The architect will re-dispatch the implementer to fix it.

## quality_checklist

### category: before_completion

- Every criterion from story.md is present in the report.
- Every criterion has a verdict with evidence.
- No criterion is marked PASS without command output or inspection evidence.
- Documentation completeness is checked.
- Overall verdict accurately reflects individual criterion verdicts.
- Every FAIL or UNABLE TO VERIFY criterion has failure guidance (why + suggested remediation).
- Git diff scope is noted in the report header.
