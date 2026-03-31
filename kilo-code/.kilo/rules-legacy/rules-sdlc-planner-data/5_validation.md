# Validation

## Self-Validation Checks

Before submitting the data design to the Planning Hub, verify ALL of the following. EVERY check defaults to FAIL and must be explicitly confirmed.

### Data-Relevant AC Coverage

- [ ] Every data-relevant acceptance criterion is addressed in the design.
- [ ] No AC requiring persistence, queries, or data flow is unaccounted for.
- [ ] Evidence: list the mapping (AC -> design element).

### Schema-Contract Alignment

- [ ] Every consumed entity contract is implemented as specified.
- [ ] No extra fields in schema that contradict the contract.
- [ ] No missing fields required by the contract.
- [ ] Evidence: cross-reference each consumed contract with schema.

### Index Coverage

- [ ] Every query pattern has a corresponding index.
- [ ] Composite index column order matches filter order.
- [ ] No index defined without a documented query pattern.
- [ ] Evidence: list query pattern -> index mapping.

### Migration Strategy

- [ ] Migration strategy exists for any schema change.
- [ ] Migration steps are documented and ordered.
- [ ] Rollback approach is defined.
- [ ] Downtime expectations are documented (zero-downtime or planned outage).

### PII Handling

- [ ] Every PII field is identified and classified.
- [ ] Encryption and access control are addressed (or delegated to security).
- [ ] Retention and deletion are considered.
- [ ] Evidence: list entity -> PII fields -> handling.

## Validation Report Format

After self-validation, produce a summary:

```
Data-relevant ACs: {addressed}/{total}
Consumed contracts: {aligned}/{total}
Query patterns: {indexed}/{total}
Migration strategy: {present|missing}
PII fields: {identified}/{total}
```
