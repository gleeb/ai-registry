# Validation

## Per-Story Self-Validation Checks

Before submitting the per-story security design to the Planning Hub, verify ALL of the following. EVERY check defaults to FAIL and must be explicitly confirmed.

### Entry Point Auth

- [ ] Every entry point has explicit auth requirements documented.
- [ ] No endpoint is "assumed" secure without documentation.
- [ ] Auth requirements align with auth-model contract.
- [ ] Evidence: list entry point -> auth requirement.

### PII Identification and Protection

- [ ] Every PII field is identified and classified.
- [ ] Encryption (at rest, in transit) is documented or delegated.
- [ ] Access controls for PII are defined.
- [ ] Evidence: list entity -> PII fields -> protection.

### Threat Assessment

- [ ] STRIDE (or equivalent) applied to story entry points.
- [ ] Mitigations documented for identified threats.
- [ ] No threat dismissed without justification.
- [ ] Evidence: list threat -> mitigation.

### Contract Compliance

- [ ] Auth approach matches auth-model contract.
- [ ] No extensions to auth contract without coordination.
- [ ] Token format, expiry, refresh align with contract.
- [ ] Evidence: cross-reference with contract.

## Rollup Self-Validation Checks

Before submitting the security overview, verify ALL of the following. EVERY check defaults to FAIL.

### Aggregation Completeness

- [ ] All per-story `security.md` files have been read and aggregated.
- [ ] No story with security-relevant scope is missing from the overview.
- [ ] Evidence: list story ID -> included in overview.

### Consistency Check

- [ ] No conflicting auth strategies for similar endpoint types.
- [ ] No inconsistent PII handling across stories.
- [ ] No gaps in rate limiting for comparable endpoints.
- [ ] Evidence: list any inconsistencies found and resolved.

### Compliance Check

- [ ] Compliance requirements (GDPR, HIPAA, etc.) are addressed.
- [ ] Credential management is defined system-wide.
- [ ] Residual risks are documented with ownership.
- [ ] Evidence: list requirement -> addressing.

## Validation Report Format

### Per-Story

```
Entry points: {total}
Auth coverage: {covered}/{total}
PII fields: {identified}/{total}
Threats: {mitigated}/{total}
Contract compliance: {pass|fail}
```

### Rollup

```
Stories aggregated: {count}
Inconsistencies: {count}
Compliance requirements: {addressed}/{total}
Residual risks: {count}
```
