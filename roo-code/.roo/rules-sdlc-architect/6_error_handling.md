# error_handling

## scenario: missing_or_ambiguous_scope

**Trigger:** Assigned issue scope is unclear, conflicting, or incomplete.

**required_actions:**
- Pause architecture drafting.
- Ask one focused clarifying question for the highest-impact ambiguity.
- Proceed only after scope boundary is explicit.

## scenario: staging_path_not_resolved

**Trigger:** Issue-specific staging document path cannot be confidently determined.

**required_actions:**
- Create an explicit path proposal using the required naming pattern and record it in the plan.
- Use that exact resolved path consistently across outputs.

**prohibited_actions:**
- Do not use unresolved placeholders in staging filenames.

## scenario: documentation_context_missing

**Trigger:** Required docs/index or domain references are missing or inconsistent.

**required_actions:**
- Record missing documentation as an explicit risk and assumption.
- Constrain recommendations to validated context and flag unknowns.

## scenario: handoff_package_incomplete

**Trigger:** Completion output lacks staging path, risks, or execution constraints.

**required_actions:**
- Do not return completion yet.
- Add missing handoff components and re-validate readiness.

## scenario: review_iteration_limit_reached

**Trigger:** Code reviewer rejects implementation 3 times for the same task.

**required_actions:**
- Mark task as blocked in staging document with review history summary.
- Return to coordinator via attempt_completion with blocker details.
- Include all 3 review verdicts and the pattern of failures.

**prohibited_actions:**
- Do not continue dispatching the same task beyond 3 review iterations.

## scenario: qa_verification_failure

**Trigger:** QA verifier reports FAIL for a task that passed code review.

**required_actions:**
- Re-dispatch implementer with QA failure details and evidence.
- After implementer fix, re-dispatch sdlc-code-reviewer, then sdlc-qa again.
- If QA fails twice for the same task, mark as blocked and escalate.

## scenario: sub_mode_dispatch_failure

**Trigger:** new_task dispatch to a sub-mode fails or sub-mode returns unexpected result.

**required_actions:**
- Record the failure in the staging document.
- Retry the dispatch once with the same parameters.
- If retry fails, mark task as blocked and return to coordinator.
