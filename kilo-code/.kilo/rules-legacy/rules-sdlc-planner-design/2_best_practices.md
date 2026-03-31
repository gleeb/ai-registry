# Best Practices for Per-Story Design

## Per-Story Scoping

- Design only for this story's acceptance criteria. Do not add screens or flows for other stories.
- Each mockup must map to at least one acceptance criterion in `story.md`.
- If a screen serves multiple stories, it belongs to the story that first defines it.

## Brand Consistency

- **Always follow `plan/design/design-spec.md`** when it exists.
- Use design tokens for all visual properties — colors, typography, spacing, shadows.
- Do not introduce new patterns that conflict with the established design system.
- If the design system needs extension for this story, document the extension and flag for review.

## All Mockup States

- Every screen must include designs for:
  - **Happy path** — primary success state
  - **Error state** — when something fails (API error, validation error)
  - **Empty state** — when no data to display
  - **Loading state** — when fetching (skeleton, spinner, or equivalent)
- Missing states lead to poor implementation and bad UX.

## WCAG 2.2 AA Compliance

- WCAG 2.2 AA compliance is mandatory, not optional.
- Color contrast ratios: 4.5:1 for normal text, 3:1 for large text and UI components.
- Font sizes: minimum 16px body, appropriate heading scale.
- Touch targets: at least 44x44px for interactive elements.
- Keyboard navigation and focus indicators must be considered.
- Semantic structure (headings, landmarks) must be documented or implied.

## Design Tokens

- Use design tokens for all visual properties — no hardcoded colors, fonts, or spacing.
- Document tokens in `design-spec.md` or in the story's handoff documentation.
- Tokens must be consistent across all mockups in the story.

## Component Documentation

- Document component patterns in `design-spec.md` or per-story handoff.
- Document all states for each component: default, hover, focus, active, disabled, loading, error, empty.
- Use consistent component patterns across all screens — same buttons, forms, cards, navigation.

## Responsive at All Breakpoints

- Define breakpoints (e.g., mobile under 768px, tablet 768–1024px, desktop over 1024px).
- Provide mockups or notes for key screens at each breakpoint.
- Document how layout adapts at each breakpoint.

## Function Over Form

- Usability before aesthetics. Every design decision must serve user goals.
- Beautiful but unusable designs are failures.
- Validate every design choice against user goals.

## Iterate with User on Visual Direction

- Present color palette and typography early on first design story.
- Get user approval before creating full mockups.
- Avoid large rework by aligning on direction first.
