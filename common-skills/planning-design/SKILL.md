---
name: planning-design
description: Enhanced per-story Design/UI-UX specialist with 7-phase workflow. Use when the Planning Hub dispatches design work for a specific user story in Phase 3. Conducts UX discovery, establishes brand foundation, defines information architecture, creates visual design, produces HTML/CSS mockups, runs accessibility audit (WCAG 2.2 AA), and generates developer handoff specs. Reads story.md and hld.md. Writes to plan/user-stories/US-NNN-name/design/ and plan/design/.
---

# Planning Design (7-Phase Per-Story Workflow)

## When to use
- Use when the Planning Hub dispatches Design work for a specific user story (`sdlc-planner-design`).
- Use when the story's `candidate_domains` includes `design`.
- Use when updating or revising existing per-story design artifacts.

## When NOT to use
- DENY use for implementation work — design is planning only.
- DENY use for stories without user-facing UI.
- DENY use for backend-only stories.
- DENY use for modifying other stories' design artifacts without Hub dispatch.

## Inputs required
1. `plan/user-stories/US-NNN-name/story.md` — scope, acceptance criteria, UI flows.
2. `plan/user-stories/US-NNN-name/hld.md` — component structure, user flows.
3. `plan/prd.md` — user personas, product vision.
4. `plan/design/design-spec.md` (if exists) — existing design system to follow.
5. `plan/design/color-palette.md` (if exists) — existing color palette.

## Contract terms
- **REQUIRE**: mandatory condition that must be satisfied.
- **DENY**: action that is forbidden.
- **ALLOW**: action that is permitted only within stated bounds.

## Workflow

### Phase 1: UX Discovery

Reference: [`references/UX-DISCOVERY.md`](references/UX-DISCOVERY.md)

1. Identify personas relevant to this story from `plan/prd.md`.
2. Map the primary user journey for this story's flows.
3. Evaluate against Nielsen's 10 usability heuristics.
4. Document findings that inform design decisions.
5. Spar with user on persona assumptions and journey pain points.

### Phase 2: Brand Foundation

Reference: [`references/BRAND-FOUNDATION.md`](references/BRAND-FOUNDATION.md)

Only runs on the **first story with design work** or if no brand foundation exists yet.

1. If `plan/design/design-spec.md` exists, read and follow it. Skip to Phase 3.
2. If no brand foundation exists:
   - Define brand identity (personality, voice, positioning).
   - Define visual identity (colors, typography, spacing, iconography).
   - Define design tokens.
   - Write to `plan/design/design-spec.md` and `plan/design/color-palette.md`.
3. Spar with user on brand direction and color choices.

### Phase 3: Information Architecture

1. Define page hierarchy and content structure for this story's screens.
2. Define navigation patterns within this story's flows.
3. Map content zones on each screen (header, main, sidebar, footer patterns).
4. Ensure information architecture supports the story's acceptance criteria.
5. For multi-story products, ensure IA is consistent with established patterns.

### Phase 4: Visual Design

1. Apply design tokens from `plan/design/design-spec.md`.
2. Define component patterns for this story (buttons, forms, cards, tables, etc.).
3. Document component states: default, hover, focus, active, disabled, loading, error, empty.
4. Define responsive strategy at breakpoints.
5. Spar with user on visual direction and component choices.

### Phase 5: Mockup Creation

1. Create HTML/CSS mockups for each user-facing flow in the story.
2. Write mockups to `plan/user-stories/US-NNN-name/design/`.
3. Include error states, empty states, and loading states.
4. Update the global gallery at `plan/design/mockups/index.html` with links to new screens.
5. Mockups must be viewable in a browser for user review.

### Phase 6: Accessibility Audit

Reference: [`references/ACCESSIBILITY-CHECKLIST.md`](references/ACCESSIBILITY-CHECKLIST.md)

1. Evaluate each mockup against WCAG 2.2 AA criteria.
2. Check color contrast ratios (4.5:1 text, 3:1 UI components).
3. Check keyboard navigation flow and focus indicators.
4. Check touch target sizes (24x24px minimum).
5. Check semantic structure and ARIA requirements.
6. Document findings with severity and required fixes.
7. Fix critical and major issues before completing.

### Phase 7: Developer Handoff + User Review

Reference: [`references/DEVELOPER-HANDOFF.md`](references/DEVELOPER-HANDOFF.md)

1. Document all design tokens used in this story's mockups.
2. Document component states for all interactive elements.
3. Document responsive behavior at each breakpoint.
4. Document interaction specifications (animations, loading, transitions).
5. Document asset requirements.
6. Present the complete design to the user for final review.
7. Iterate based on user feedback.

## Sparring Protocol

- "Does this layout serve the persona's primary goal? What's their fastest path?"
- "What happens when this screen has zero data? Have you designed the empty state?"
- "What does the error state look like? Is the error message actionable?"
- "Does this color combination meet WCAG contrast requirements?"
- "How does this component behave on mobile? Does it need a different layout?"
- "Is this interaction pattern consistent with other stories' designs?"
- "What if the user needs to undo this action? How do they recover?"

## Anti-Pleasing Patterns

- **Missing states**: DENY mockups that only show the happy path. Require error, empty, and loading.
- **Accessibility afterthought**: Phase 6 is mandatory, not optional. DENY "we'll check a11y later."
- **Inconsistent design system**: All mockups must follow `plan/design/design-spec.md`.
- **Pixel-perfect without specifications**: Mockups without handoff specs are incomplete.
- **Scope creep**: Design only for this story's acceptance criteria.

## Output

- `plan/user-stories/US-NNN-name/design/*.html` — per-story mockups
- `plan/design/design-spec.md` — design system (created on first design story)
- `plan/design/color-palette.md` — color system (created on first design story)
- `plan/design/mockups/index.html` — gallery (updated with each design story)

## Files

- [`references/UX-DISCOVERY.md`](references/UX-DISCOVERY.md): Personas, journey mapping, heuristics.
- [`references/BRAND-FOUNDATION.md`](references/BRAND-FOUNDATION.md): Brand identity, visual identity, design tokens.
- [`references/ACCESSIBILITY-CHECKLIST.md`](references/ACCESSIBILITY-CHECKLIST.md): WCAG 2.2 AA checklist.
- [`references/DEVELOPER-HANDOFF.md`](references/DEVELOPER-HANDOFF.md): Design tokens, component states, responsive specs.
- [`references/DESIGN-SPEC.md`](references/DESIGN-SPEC.md): Design specification template.
- [`references/GALLERY-TEMPLATE.md`](references/GALLERY-TEMPLATE.md): Mockup gallery template.

## Troubleshooting

- If story.md has no UI flows, this story should not have `design` in candidate_domains. Report to Hub.
- If hld.md is not ready, wait — design depends on component structure.
- If no brand foundation exists and this isn't the first design story, check if it was skipped. Flag for Hub.
- If accessibility audit finds critical issues, fix them before completing. Do not defer.
