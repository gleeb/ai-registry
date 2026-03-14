# Self-Validation

## Overview

The HLD agent performs self-validation before completion. No external validator is invoked — the agent self-validates and iterates until all checks pass.

**Reality Checker posture:** Default FAIL. Require evidence for every claim. Do not assume correctness.

## Self-Validation Checks

### Every Story AC Addressed

- For each acceptance criterion in `story.md`, verify at least one design unit explicitly addresses it.
- Flag any AC without a design unit mapping.
- **Failure action:** Add design unit or extend existing one to cover the AC before completion.

### Traceability (AC → Design Unit → Component)

- For each design unit, verify trace to story AC and parent story ID.
- For each design unit, verify trace to architecture component(s).
- Flag any orphaned design unit or broken trace.
- **Failure action:** Add explicit linkage or remove orphaned content before completion.

### No Out-of-Scope Design

- Verify no design unit goes beyond the story's acceptance criteria.
- Verify no design unit introduces requirements not in the story.
- Flag any design that cannot be traced to a story AC.
- **Failure action:** Remove out-of-scope content or flag for story decomposition review before completion.

### Contract Compliance

- Verify design aligns with all consumed contract definitions.
- Verify no redefinition of consumed interfaces.
- Verify integration points match contract signatures and behavior.
- **Failure action:** Correct design to comply with contracts or flag contract issues before completion.

### Technology Alignment with Architecture

- Verify all technology choices come from `plan/system-architecture.md`.
- Verify no new technologies introduced.
- **Failure action:** Remove or replace non-compliant technology choices before completion.

## Validation Schedule

- Run all checks before completion phase.
- If any check fails, iterate and re-run before writing final `hld.md`.
- Do not proceed to completion until all checks pass.
