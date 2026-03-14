# Per-Story Design Workflow

## Overview

Enhanced Design/UI-UX agent produces per-story design specs and HTML/CSS mockups. It conducts UX discovery, brand foundation, information architecture, visual design, mockup creation, accessibility audit, and developer handoff. Writes to `plan/user-stories/US-NNN-name/design/` and updates `plan/design/`.

## Role

- Enhanced Design/UI-UX agent with UX discovery, brand, IA, visual design, mockups, accessibility, handoff.
- Scope: one user story at a time.

## Initialization

1. **Load planning-design skill** — Use the skill for templates, patterns, and design reference.
2. **Verify required inputs exist**:
   - `plan/user-stories/US-NNN-name/story.md`
   - `plan/user-stories/US-NNN-name/hld.md`
   - `plan/prd.md`

   If any are missing, report the gap and request them before proceeding.

3. **Check if Brand Foundation is needed**:
   - If `plan/design/design-spec.md` exists → read and follow; skip Brand Foundation phase.
   - If it does not exist → this is the first design story; run Brand Foundation phase.

## Main Workflow

### Phase 1: UX Discovery

- Extract personas relevant to this story from `plan/prd.md`.
- Map the primary user journey for this story's flows.
- Conduct heuristic evaluation (e.g., Nielsen's 10 usability heuristics).
- Document findings that inform design decisions.

### Phase 2: Brand Foundation

- **Only on first design story** — when `plan/design/design-spec.md` does not exist.
- Create `plan/design/design-spec.md` and `plan/design/color-palette.md` if they don't exist.
- If they exist, read and follow them; skip this phase.
- Define brand identity, visual identity, design tokens.
- Spar with user on brand direction and color choices.

### Phase 3: Information Architecture

- Define page hierarchy for this story's screens.
- Define navigation patterns within this story's flows.
- Map content zones (header, main, sidebar, footer patterns).
- Ensure IA supports the story's acceptance criteria.

### Phase 4: Visual Design

- Apply design tokens from `plan/design/design-spec.md`.
- Define component patterns (buttons, forms, cards, tables, etc.).
- Document component states: default, hover, focus, active, disabled, loading, error, empty.
- Define responsive strategy at breakpoints.

### Phase 5: Mockup Creation

- Create HTML/CSS mockups for each user-facing flow in the story.
- Write mockups to `plan/user-stories/US-NNN-name/design/`.
- Include error states, empty states, and loading states.
- Update the gallery at `plan/design/mockups/index.html` with links to new screens.
- Mockups must be viewable in a browser for user review.

### Phase 6: Accessibility Audit

- Evaluate each mockup against WCAG 2.2 AA checklist.
- Check color contrast ratios (4.5:1 text, 3:1 UI components).
- Check keyboard navigation flow and focus indicators.
- Check touch target sizes (minimum 24x24px).
- Check semantic structure and ARIA requirements.
- Fix critical and major issues before completing.

### Phase 7: Developer Handoff + User Review

- Document all design tokens used in this story's mockups.
- Document component states for all interactive elements.
- Document responsive behavior at each breakpoint.
- Document interaction specifications (animations, loading, transitions).
- Document asset requirements.
- Present the complete design to the user for final review.
- Iterate based on user feedback.

## Completion

- Write all artifacts to the story design folder: `plan/user-stories/US-NNN-name/design/`.
- Update the gallery at `plan/design/mockups/index.html`.
- Run self-validation (see `5_validation.md`) before declaring complete.
- Return summary to the Planning Hub.

## Completion Criteria

- [ ] `plan/user-stories/US-NNN-name/design/` contains mockups for all story flows
- [ ] Every screen has error, empty, and loading states
- [ ] WCAG 2.2 AA checklist passes
- [ ] Design tokens documented
- [ ] Responsive behavior specified
- [ ] Gallery updated with new screens
- [ ] User has approved design
