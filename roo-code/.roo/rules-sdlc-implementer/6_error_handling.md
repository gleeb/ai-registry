# error_handling

## scenario: missing_context_or_rationale

**trigger:** Staging document or required rationale context is missing or insufficient.

**required_actions:**
1. Pause implementation work.
2. Document the missing context in staging as a blocker.
3. Return to coordinator via completion with explicit unblock request.

**prohibited_actions:**
- Do not guess architecture intent when rationale is absent.

## scenario: unresolved_implementation_blocker

**trigger:** Error or dependency issue cannot be resolved within assigned scope.

**required_actions:**
1. Halt forward feature work for blocked path.
2. Record blocker details, impact, and attempted mitigations in staging.
3. Return to coordinator for escalation and supporting investigation dispatch.

## scenario: scope_expansion_detected

**trigger:** Required change appears to exceed assigned issue boundaries.

**required_actions:**
1. Stop at boundary and mark out-of-scope work explicitly.
2. Provide a minimal in-scope completion package and list follow-up scope.
3. Return to coordinator for scope decision.

## scenario: verification_failure

**trigger:** Compile/test verification fails for implemented scope.

**required_actions:**
1. Do not mark checklist item complete.
2. Document failure symptoms and repro context in staging.
3. Attempt in-scope fixes; if unresolved, return blocked status to coordinator.
