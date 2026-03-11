# Self-Validation for Per-Story Design

## Posture

**Default FAIL** — Do not declare completion until all checks pass. If any check fails, iterate on the design before writing.

## Validation Checks

### Every Story AC with UI Has a Mockup

- Each acceptance criterion that involves user-facing UI has at least one mockup.
- Mockups cover all critical user flows in the story.
- No orphan flows without corresponding screens.

### All Mockup States Present

- For each screen: error state is designed (API failure, validation error).
- For each screen: empty state is designed (no data to display).
- For each screen: loading state is designed (skeleton, spinner, or equivalent).
- Happy path is also present for each screen.

### WCAG 2.2 AA Checklist Passes

- Color contrast ratios meet WCAG AA (4.5:1 normal text, 3:1 large text).
- Font sizes are readable (minimum 16px body, appropriate heading scale).
- Touch targets are at least 44x44px where applicable.
- Keyboard navigation is considered for interactive elements.
- Semantic structure (headings, landmarks) is documented or implied.

### Design Tokens Documented

- All visual properties use design tokens (colors, typography, spacing).
- Tokens are documented in design-spec.md or per-story handoff.
- No hardcoded values that should be tokens.

### Responsive Behavior Specified

- Breakpoints are defined (e.g., mobile under 768px, tablet 768–1024px, desktop over 1024px).
- Key screens have mockups or notes for at least mobile and desktop.
- Layout adapts appropriately at each breakpoint.

### Gallery Updated

- Gallery at `plan/design/mockups/index.html` includes links to all new screens.
- Gallery is functional HTML — navigable and viewable in a browser.

## Validation Flow

1. Run all checks after Phase 7 (Developer Handoff + User Review).
2. If any check fails — iterate, do not declare complete.
3. Do not report completion to the Hub until all checks pass.
4. Document any intentional exceptions (e.g., decorative elements) in design-spec.
