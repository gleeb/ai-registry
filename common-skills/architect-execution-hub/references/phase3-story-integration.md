# Phase 3: Story-Level Integration

`checkpoint.sh execution --phase 3`

After all per-task dev loops pass:

1. **Final holistic code review** — dispatch `sdlc-engineering-story-reviewer` for full-story review (uses larger model for cross-file reasoning across the entire story scope). Include `SECURITY_REVIEW: true` if any task had security review.
2. **Final holistic QA** — dispatch `sdlc-engineering-story-qa` for full-story verification (uses larger model for comprehensive cross-task verification).
3. **Performance validation** — if tech skills include performance budgets (e.g., react-native), verify metrics meet targets.
4. **Accessibility check** — if story has `design` in `candidate_domains`, verify accessibility requirements.

**GATE**: Full-story review passes + full-story QA passes. If not, re-enter Phase 2 for affected tasks.

## Pre-Flight Evidence Gate (before Phase 3b)

Before dispatching the commercial semantic reviewer, read the QA agent's structured evidence from the Phase 3 story-level QA completion. Confirm all automated quality gates are clean:

- Lint: 0 errors (from QA evidence)
- Type check: 0 errors (from QA evidence)
- Test suite: all passing (from QA evidence)
- Build: exit 0 (from QA evidence)
- Coverage: lines >= threshold, branches >= threshold (from QA evidence coverage report — thresholds from testing strategy or defaults: 80% lines, 70% branches)
- Browser smoke test: key routes load without console errors (from QA evidence, web app stories only)

If any quality gate shows failures (including coverage below threshold), return to Phase 2 for targeted fixes. Do NOT dispatch the semantic reviewer until all automated gates are clean. The hub reads evidence — it does not re-run commands.
