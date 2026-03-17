# Sparring Patterns for Per-Story Design

## Philosophy

- Challenge design choices that prioritize aesthetics without usability justification.
- Challenge designs that omit error, empty, or loading states.
- Challenge inconsistent components and accessibility violations.
- Sparring improves design quality; it is not adversarial.
- When challenging, propose a resolution, not just a problem.

## Challenge Categories

### Persona Fit

- Does this layout serve the persona's primary goal? What's their fastest path?
- Is this design aligned with the personas identified in the PRD?
- Would this persona find this flow intuitive or confusing?

### Empty / Error / Loading States

- Screen [X] shows the happy path. What does the user see when the API fails?
- When there are no [items] to display, what does this screen show?
- How does the user know data is loading on this screen?
- What does the error state look like? Is the error message actionable?

### Color Contrast

- This text has contrast ratio [X]. WCAG AA requires 4.5:1 for normal text. Can we adjust?
- Interactive elements have sufficient contrast for focus states?
- Semantic colors (success, error, warning) are distinguishable?

### Mobile Behavior

- Which breakpoints have we designed for? Do we have mockups for mobile?
- How does this component behave on mobile? Does it need a different layout?
- How does this layout adapt at [breakpoint]?

### Interaction Consistency

- Is this interaction pattern consistent with other stories' designs?
- Screen [A] uses [button style X] but Screen [B] uses [different style]. Should these be consistent?
- Form patterns differ between these screens. Is that intentional?
- Navigation appears differently here than on other screens. Should we align?

### Information Hierarchy

- Does the visual hierarchy support the user's primary task?
- Is the most important information the most prominent?
- Is this [color/typography/layout] choice visually striking but unclear for usability?

### Accessibility

- How does a keyboard user navigate this flow?
- Font size [X] may be too small for some users. Have we checked readability?
- Touch targets here are [X]px. Minimum recommended is 44x44. Can we increase?

### Design System Compliance

- All mockups must follow `plan/design/design-spec.md`.
- Does this component match the documented design system?
- Are we introducing patterns that conflict with existing designs?

## Anti-Pleasing Patterns (DENIED)

- **Happy-path-only mockups** — No mockups that only show the success state. Require error, empty, and loading.
- **Accessibility afterthought** — Phase 6 (Accessibility Audit) is mandatory. DENY "we'll check a11y later."
- **Inconsistent design system** — All mockups must follow `plan/design/design-spec.md`.
- **Aesthetic without usability** — Design choices that don't serve user goals.
- **Scope creep** — Design only for this story's acceptance criteria.
