# Sparring Patterns

## Overview

The validator applies self-challenges to its own findings before finalizing the report. These patterns prevent lenient passes and superficial validation.

## Universal Self-Challenges

Apply these to every validation run:

### "Did I actually read both documents or just check headers?"

- If you only verified that a reference exists (e.g., "story references PRD 7.3"), you did not fully validate.
- Re-run: Open both documents, read the relevant sections, verify content alignment.
- Do not pass traceability checks on reference existence alone.

### "Is this really a PASS or am I being lenient?"

- If you are unsure, default to NEEDS WORK.
- Ask: "What evidence would convince a skeptical reviewer that this passes?"
- If you cannot cite specific content, it is not a PASS.

### "What did I NOT check?"

- List the validation dimensions you did not run or only partially ran.
- Add these as observations or flag as scope gaps.
- Do not claim full coverage if you skipped checks.

### "If this report came to me for review, what would I question?"

- Role-play as a reviewer of your own report.
- Identify weak findings, vague evidence, or questionable passes.
- Strengthen or downgrade those findings before finalizing.

---

## Challenge Patterns by Validation Dimension

### Traceability

- "Did I extract discrete requirements from the source, or did I assume coverage?"
- "For each requirement, did I find a specific downstream entry, or a vague 'covered somewhere'?"
- "Are there orphaned downstream entries (content with no upstream requirement)?"
- "Did I calculate coverage, or just assert 'all traced'?"

### Consistency (Cross-Domain)

- "Did I compare actual field values and schemas, or just section structure?"
- "For HLD-API alignment: did I map every data flow to every schema field?"
- "For contract compliance: did I compare the contract definition character-by-character with story usage?"
- "Did I check for terminology drift (same concept, different names)?"

### Completeness

- "Did I verify every PRD requirement has a downstream trace, or did I sample?"
- "Did I verify every architecture component is referenced by at least one story?"
- "Did I verify every acceptance criterion has test coverage mapping?"
- "What requirements might exist that I did not extract?"

### Conflict Detection

- "Did I run all conflict patterns from conflict-detection.md, or only the obvious ones?"
- "For CONFLICT severity: did I confirm direct contradiction, or just tension?"
- "Did I check for dependency cycles in the story graph?"
- "Did I verify contract ownership (no duplicate owners, no orphan contracts)?"

### Per-Story Checks

- "For each of the 9 checks: did I read the artifacts or infer from structure?"
- "Dependency manifest: did I verify each referenced item exists and is correct?"
- "Acceptance criteria traceability: did I find explicit downstream references to each AC?"
- "Contract compliance: did I compare consumed contract definitions with story artifact usage?"

### Impact Analysis

- "Did I trace all dependency edges from the change point, or stop at first level?"
- "Did I classify every affected artifact (Direct/Indirect/Unaffected)?"
- "Did I report cycles in the dependency graph if present?"
- "Did I avoid modifying any artifacts (read-only)?"

---

## Anti-Pleasing Patterns

- **No false agreement** — Do not pass checks to avoid conflict. If evidence is weak, mark NEEDS WORK.
- **Probe before closure** — Do not declare "looks good" without verifying content.
- **Challenge scope** — If you skipped checks due to missing artifacts, say so explicitly. Do not imply full coverage.
