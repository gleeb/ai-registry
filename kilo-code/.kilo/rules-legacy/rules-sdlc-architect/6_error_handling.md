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
- Include all 5 review verdicts and the pattern of failures.

**prohibited_actions:**
- Do not continue dispatching the same task beyond 5 review iterations.

## scenario: qa_verification_failure

**Trigger:** QA verifier reports FAIL for a task that passed code review.

**required_actions:**
- Re-dispatch implementer with QA failure details and evidence.
- After implementer fix, re-dispatch sdlc-code-reviewer, then sdlc-qa again.
- If QA fails twice for the same task, mark as blocked and escalate.

## scenario: acceptance_validation_limit_reached

**Trigger:** Acceptance validator returns INCOMPLETE for the 3rd time (acceptance_iteration >= 2).

**required_actions:**
- Mark story as acceptance-blocked in staging document.
- Return to coordinator with all 3 acceptance reports and remediation history.
- Include specific recommendation: which criteria keep failing and why.

**prohibited_actions:**
- Do not dispatch another remediation cycle.
- Do not dispatch another acceptance validator.
- Do not attempt to "fix it one more time."

## scenario: sub_mode_dispatch_failure

**Trigger:** new_task dispatch to a sub-mode fails or sub-mode returns unexpected result.

**required_actions:**
- Record the failure in the staging document.
- Retry the dispatch once with the same parameters.
- If retry fails, mark task as blocked and return to coordinator.

## scenario: branch_lifecycle_violation

**Trigger:** Work was done on wrong branch, story branch is missing, or verify.sh reports branch issues.

**required_actions:**
- If story branch does not exist: run `checkpoint.sh git --branch-create --story {US-NNN-name} --base main`.
- If work was done on wrong branch: create the story branch from the current state and update `execution.yaml` fields (`branch_name`, `base_branch`, `base_commit`).
- Run `verify.sh execution` to confirm the branch state is consistent.
- Continue execution from the current phase.

**prohibited_actions:**
- Do not escalate branch lifecycle issues to the coordinator. These are operational issues resolvable with checkpoint tools.

## scenario: checkpoint_consistency_drift

**Trigger:** verify.sh reports inconsistencies between checkpoint state and actual artifacts on disk.

**required_actions:**
- Run `checkpoint.sh init` to re-derive full state from existing artifacts (`plan/`, `docs/staging/`).
- Run `verify.sh execution` to confirm state is now consistent.
- If specific fields are still incorrect, overwrite them using `checkpoint.sh execution` with values derived from the staging doc task checklist and git log.
- Continue execution from the corrected phase/task/step.

**prohibited_actions:**
- Do not escalate checkpoint drift to the coordinator. Resolve with checkpoint tools.
- Do not blindly trust the checkpoint over disk artifacts — verify.sh output takes precedence.
