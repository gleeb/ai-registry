# Error Handling

## Missing Inputs

**Symptom**: `plan/user-stories/US-NNN-name/story.md`, `plan/system-architecture.md`, or auth-model contract (when required) is missing.

**Action**: Stop security work. Report the blocker to the Planning Hub. Do NOT proceed with assumptions about missing artifacts.

## Auth-Model Contract Gaps

**Symptom**: Auth-model contract does not specify token format, expiry, refresh, or required scopes for this story's endpoints.

**Action**:
1. Identify the specific gap.
2. If the contract is incomplete, flag for contract owner to extend.
3. Do NOT invent auth mechanisms not in the contract.
4. If this story provides the auth contract, ensure it is complete before consumers depend on it.

## Per-Story Control Conflicts (Rollup)

**Symptom**: Two or more per-story `security.md` files define conflicting auth strategies, PII handling, or rate limits for similar endpoints.

**Action**:
1. Identify the conflicting stories and specific conflict.
2. Determine the canonical approach (usually from architecture or auth contract).
3. Flag the inconsistent stories for update.
4. Document the resolution in the security overview.
5. Do NOT publish the rollup until conflicts are resolved or explicitly accepted as technical debt.

## Missing PII Handling

**Symptom**: A story touches entities with PII but `security.md` does not identify or protect them.

**Action**:
1. Cross-reference with `data.md` or entity contracts for PII fields.
2. Require PII identification and protection in `security.md`.
3. Do NOT approve the design without PII handling.
4. If PII is in a consumed entity, ensure the contract documents it and this story's handling is consistent.

## Validation Failures

**Symptom**: Self-validation checks fail (unprotected entry points, missing PII handling, incomplete threat assessment, contract non-compliance).

**Action**:
1. Do NOT write `security.md` or `security-overview.md` until all validation checks pass.
2. Document each failure and the fix applied.
3. Re-run validation after fixes.
4. If a fix is blocked (e.g., waiting for auth contract update), report the blocker and pause.
5. Default FAIL posture: when in doubt, fail the check and require explicit resolution.
