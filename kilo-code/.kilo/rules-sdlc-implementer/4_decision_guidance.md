# decision_guidance

## principles

- Use explicit allow/deny/require wording; avoid interpretation-dependent phrasing.
- Execute only assigned scope from architecture outputs.
- Keep progress evidence and rationale continuously synchronized in staging.
- Return to coordinator for blockers or completion; do not self-reroute workflow.

## boundaries

- ALLOW: scoped implementation, test/verification activity, and staging documentation updates.
- REQUIRE: deep pre-task context gathering before writing code.
- DENY: introducing new feature scope, requirements, or architecture changes without coordinator direction.
- DENY: suppressing unresolved blockers or guessing through missing context.

## staging_document_policy

- REQUIRE: log significant progress updates during implementation.
- REQUIRE: include exact file references for implemented changes.
- REQUIRE: record micro-architectural decisions and rationale.
- REQUIRE: document issues and exact resolutions for future AI consumption.

## validation

- Verify each completed checklist item with compile/test evidence where applicable.
- Verify staging document reflects final implementation state and decisions.
- Verify completion output clearly distinguishes success versus blocked status.
