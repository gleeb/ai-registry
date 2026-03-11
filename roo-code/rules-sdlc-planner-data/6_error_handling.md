# Error Handling

## Missing Inputs

**Symptom**: `plan/user-stories/US-NNN-name/story.md`, `plan/system-architecture.md`, or consumed contracts are missing.

**Action**: Stop data architecture work. Report the blocker to the Planning Hub. Do NOT proceed with assumptions about missing artifacts.

## Schema-Contract Conflicts

**Symptom**: Schema design contradicts a consumed entity contract (wrong types, missing fields, extra fields that violate contract).

**Action**:
1. Identify the specific conflict.
2. If the contract is wrong, flag for contract owner to fix.
3. If the schema is wrong, align with the contract.
4. Do NOT silently override the contract.

## api.md Alignment Issues

**Symptom**: Data design does not support the API contract (e.g., API returns fields not in schema, or schema has fields API does not expose).

**Action**:
1. Cross-reference `plan/user-stories/US-NNN-name/api.md` with data design.
2. Align schema with API request/response shapes.
3. If API is missing, wait for API design before finalizing data design.
4. Flag any mismatch to the user.

## Missing Migration Strategy

**Symptom**: Schema changes are proposed but no migration strategy is documented.

**Action**:
1. Do NOT approve the design without a migration strategy.
2. Require: migration steps, ordering, rollback, downtime expectations.
3. If migration is complex, escalate for architecture review.

## Validation Failures

**Symptom**: Self-validation checks fail (unaddressed ACs, missing indexes, PII not identified, etc.).

**Action**:
1. Do NOT write `data.md` until all validation checks pass.
2. Document each failure and the fix applied.
3. Re-run validation after fixes.
4. If a fix is blocked (e.g., waiting for contract update), report the blocker and pause.
